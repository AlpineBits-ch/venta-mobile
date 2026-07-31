# End-to-end encryption (MLS)

venta_mobile encrypts DM conversations and guild channels with MLS (RFC 9420),
against the same server contract and the same openmls build as the Alpine
desktop client. The two interoperate: a group created on desktop can be joined
and read on mobile and vice versa.

## Layout

| Piece | Where | Alpine equivalent |
| --- | --- | --- |
| Crypto engine (Rust/openmls) | `packages/venta_mls` | `src-tauri/src/crypto/mls.rs` |
| Identity, group registry, plaintext cache | `core/mls/mls_service.dart`, `mls_store.dart` | `mls.service.ts` |
| Ordering and retry rules | `core/mls/mls_sync_service.dart` | `mls-sync.service.ts` |
| HTTP transport | `features/mls/data/mls_api.dart` | `mls-transport.service.ts` |
| Realtime nudges → sync work | `core/mls/mls_realtime_bridge.dart` | wiring inside `main-page.component.ts` |
| Channel toggle | `core/mls/channel_encryption_service.dart` | `channel-encryption.service.ts` |
| Admission by reviewed request | `core/mls/mls_join_request_service.dart` | `mls-join-request.service.ts` |
| Encrypted DM creation | `core/mls/conversation_encryption_service.dart` | inline in `new-conversation-dialog.component.ts` |
| Launch sequence | `core/mls/mls_session_manager.dart` | `main-page.component.ts` + device-registration modal |
| Decrypt on read | `features/messaging/data/message_decryptor.dart` | `decryptMessages` in `message.store.ts` |

## The three rules

These are what make MLS survivable, and none of them is visible in the type
system. `test/mls_sync_test.dart` covers each.

1. **Commits apply in strict epoch order, fetched from the server.** The realtime
   `conversation.MlsCommit` push carries no commit bytes by design. Group state
   advances only by `GET .../mls/commits?sinceEpoch=N` and applying in sequence.
   A client that applies commits in push-arrival order is forked off the group
   permanently, and MLS offers no way back.
2. **A commit is staged, published, then merged.** The server accepts exactly one
   commit per epoch. Merging before it accepts means a lost race leaves this
   device advanced on a commit nobody else has. On a 409 the staged commit is
   discarded, this device catches up, and the change is re-issued — once. A
   second rejection gives up rather than looping.
3. **A Welcome is acknowledged only after its join succeeds.** Its init key is
   single-use. Acking a failed join locks this device out of that context for
   good, which is why `GET /conversations/welcomes` is called *with* `deviceId`
   (non-destructive) and followed by an explicit `/welcomes/ack`.

A fourth, quieter one: **a Remove proposal picked up during catch-up is committed
outside the queue.** MLS does not let anyone commit their own removal, so a leave
publishes a proposal and a remaining member turns it into a commit — until then
the group keeps encrypting to someone who has already thrown their keys away.
Committing inline would deadlock, because committing publishes and publishing
takes the per-context queue catch-up is already holding. `syncContext` therefore
notes the context and drains it after releasing the queue.

## Generations

Encryption can be toggled off and back on. Each stretch is a genuinely new MLS
group whose epochs restart at zero, so the group registry is keyed by
`(contextId, generation)` and never by context alone. A message names the
generation it was sealed under; decrypting against whichever group is currently
held would produce silent garbage rather than an honest failure.

Terminating a generation decrypts nothing. Messages sent under it stay ciphertext
forever, readable only by devices that still hold that group — the channel
settings screen says so before the toggle, not after.

## Identity and scoping

This device's MLS identity is an Ed25519 keypair whose BasicCredential carries
the **account's user id**, matching Alpine. It is stored in the OS keychain keyed
by `(deviceId, userId)`, and each account gets its own state directory under
`<support>/mls/<userId>/`. Two accounts on one handset therefore keep separate
groups, and switching back finds history intact rather than wiped.

`MlsService.init(userId)` swaps state when the account changes.
`resetSessionScopedCaches` deliberately does *not* do this — it is synchronous
and unloading group state is not, so doing it there would race the
`prepareIdentity` that runs moments later on sign-in.

The published `identityPublicKey` on the device registration is the MLS signing
public key for any install that sets MLS up before registering. A device already
registered under the old random placeholder keeps it: correcting the field means
deleting and re-creating the device row, which revokes that device's login
sessions, and the server stores that column without ever reading it (verified
against `Identity.Domain/Entities/UserDevice.cs` and every consumer of it).

## Launch order

`startAuthenticatedServices` runs these in a specific order:

1. `MlsSessionManager.prepareIdentity` — mints or unlocks the signing key. Must
   precede registration, because that key is what registration publishes.
2. `DeviceRegistrationService.ensureRegistered`.
3. Push services.
4. `MlsRealtimeBridge.start`.
5. `MlsSessionManager.sync` — detached. Uploads key packages (the server decides
   how many) and joins every group this device was invited to while away. Both
   endpoints reject a device the server does not know, hence after step 2.

## Key package supply

Every group this device is added to consumes one single-use key package. Run out
and the server has nothing to hand callers, so the device is quietly left out of
new conversations — readable by everyone except the person holding it. The
last-resort package is the reusable floor that prevents that.

The server decides how many to upload (`GET .../devices/client/{id}/generate`);
it is the one that knows what has been consumed, expired or swept, and that call
also drives its housekeeping.

Alpine replenishes at exactly two moments: launch, and immediately after
registering a device. Mobile covers both through `MlsSessionManager.sync`, and
adds a third — **resume from background**, rate-limited to once an hour. A
desktop client is closed and reopened often enough for launch-only to hold; a
phone app stays resident for days, so without it a device that drains its supply
stays unaddable until the next cold start. There is no key *rotation* on either
client: the signing identity is stable, and replenishing must never rotate it or
every device already in a group with this one stops recognising its credential.

## Admission to an encrypted channel

Somebody who joins a guild after a channel was encrypted holds no group keys, and
nobody can mint them a Welcome unprompted — the server has none either, so only a
current member can produce an Add commit. They ask, members review, and the
approval that meets the threshold is what mints the Welcome.

`core/mls/mls_join_request_service.dart`, mirroring Alpine's
`mls-join-request.service.ts`. Channels only: a conversation's roster is fixed at
creation and everyone in it was welcomed then, so the server exposes no
join-request route for one.

**Verification is the whole point, so it is done properly.** The requester mints
a key package *specifically for the request* rather than pointing at the pool, so
the reviewed bytes are bytes nobody else can hand out. Before adding anything,
the approving client re-derives the hash, the fingerprint and the claimed
identity from what the server handed back and checks all three against what was
reviewed. Skipping that would make the review ceremonial — a server substituting
its own key package between approval and add would have its key welcomed into the
group. A mismatch aborts and says so plainly, because it is the one failure here
that might mean tampering rather than breakage.

The fingerprint is of the **signature** key, not the key package: it is stable
across every package a device mints, which is what makes it something two people
can read to each other over a call. A key-package hash changes on every request
and would be useless for that. `packages/venta_mls/rust/src/tests.rs` pins both
properties — stable across a device's packages, different between devices.

Threshold is the server's (`MlsJoinRequest.RequiredApprovals`, currently 2, and
relaxed to 1 while a group has fewer than two known members). The server closes a
request only when the commit lands, never on approval — an approval that never
produced a commit has to stay open for someone else to act on, which is what
`fulfilledJoinRequestIds` on the commit publish is for.

Both halves have UI: the review queue in `ChannelEncryptionScreen`, and
`ChannelAccessBanner` at the top of a channel this device cannot read.
**Alpine has the requester-side service but no UI for it** — the banner is
mobile-only, and without it the loop is a dead end.

## Push notifications

Encrypted messages are decrypted on the device *before* the notification is
shown, rather than the server sending "you have a new encrypted message" — see
[push-decryption.md](push-decryption.md). Two consequences matter here:

- The plaintext cache has more than one writer (the app, plus Android's FCM
  background isolate or iOS's notification service extension), so every write to
  it merges rather than overwrites.
- On iOS, MLS state lives in the App Group container so the extension can read
  it, and the extension opens the engine read-only so it can never write a stale
  copy over what the app committed.

## Who gets keys

**Enabling channel encryption builds the group over the channel's real
viewers**, not the guild's member list — `GET /api/v1/guild/channels/{id}/viewers`,
resolved server-side against the same permission logic that gates reads.

The distinction is a confidentiality one rather than a tidiness one: on a channel
with restrictive overwrites, the guild member list hands group keys to people who
cannot open the channel at all, making its traffic readable to a wider audience
than the channel itself. Anyone left off the roster is not stranded — they can
ask, via the join-request flow above.

**Adding someone to a group conversation is two steps in a fixed order** —
`core/mls/conversation_member_service.dart`. Roster first
(`POST /conversations/{id}/members`), then admitting their devices to the group.
A member who cannot yet read sees an empty conversation, which is recoverable and
visible to them; the reverse would leave them holding group keys for a
conversation the server does not believe they are in. The ordering has its own
test because nothing in the type system enforces it and both orders "work".

## Known gaps

**Nothing calls `ConversationMemberService` yet.** Mobile has no add-member UI
for group conversations — the members sheet is read-only — so the service is
available and unwired. Alpine is in the same position: it added the service in
`9d6a335` with no call site either. Wiring it needs a friend-picker surface that
does not exist on either client rather than an MLS decision.

**Search is unavailable in encrypted contexts.** The server indexes plaintext
only, so a search there returns empty rather than erroring. `ThreadView` shows an
explicit "not available" state instead of an empty-results one.

**iOS is unbuilt.** See `packages/venta_mls/README.md`.
