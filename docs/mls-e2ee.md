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
| Counted, surfaced failures | `core/mls/mls_failure_log.dart` | — (mobile only) |
| Account master key | `core/crypto/master_key_service.dart` | `master-key.service.ts` |
| Account identity key + device certificates | `core/crypto/account_identity_service.dart` | — (not yet built) |
| Protection level | `core/mls/protection_level_service.dart` | — (not yet built) |
| Device admission proofs | `core/mls/device_admission_service.dart` | — (not yet built) |
| Certificate enforcement phase | `core/mls/mls_policy_service.dart`, `leaf_verification_service.dart` | — (not yet built) |
| Backup / restore | `core/mls/mls_backup_service.dart` | `mls_export_backup` / `mls_import_backup` |

## The message envelope

`content` off the REST page or the realtime socket is **`base64(utf8(what the
sender POSTed))`**. `CreateMessageDto.Content` is a `string` server-side but
`Message.Content` is a `byte[]`, so the server stores
`Encoding.UTF8.GetBytes(dto.Content)` and `System.Text.Json` base64s it on the
way back out. An encrypted send POSTs a base64 MLS `PrivateMessage`, so the
reader receives base64 of base64 and **must strip the outer layer before the
engine sees it** — the engine base64-decodes exactly once.

The push path is the other shape. `MessagePushService` unwraps server-side, so
`MessagePushPayload.ciphertext` is already single-encoded and must **not** be
decoded again.

This asymmetry is why the original bug looked intermittent rather than total:
when a notification landed and decrypted, the plaintext went into the cache and
the conversation rendered normally; when it was dropped, throttled by an OEM
battery manager, truncated, or simply beaten by the socket, the message was
permanently unreadable. `MessageContentCodec.decodeStrict` is the unwrap, and
`test/mls_decrypt_test.dart`'s `wire encoding` group is the regression guard.

**Do not add a heuristic that sniffs which encoding a value uses.** The encoding
is deterministic per transport, and a sniffer would silently misparse ciphertext
that happens to look like base64.

## Failures are counted, not swallowed

Every failure mode on the read path is silent by nature: a message that will not
decrypt looks exactly like a message that has not arrived, and a device that was
never admitted looks exactly like a quiet conversation. That silence is why the
envelope bug shipped undetected, so `MlsFailureLog` counts decrypt and join
failures per context.

The distinction the UI needs is *"this one message is past the ratchet"* versus
*"this device cannot read this conversation at all"*, and nothing in a single
failure tells them apart — MLS reports both as a deserialization or epoch error.
The signal is repetition: three consecutive failures with no success in between
flips `cannotRead`, and one success clears the streak. A spoofed sender and a
generation this device never joined are deliberately **not** counted; the keys
worked in the first case and the join-request affordance already covers the
second, so counting either would put "re-link this device" in front of people
who should not see it.

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

And a fifth, which follows from it: **a proposal is not progress.** Processing
one does not advance any client's MLS epoch, so a page containing nothing but
proposals is a *terminating* page. Counting one as applied made `_syncContextInner`
loop forever — the next page returned the same row, `applied` was never zero, and
it held the per-context queue the whole time, so the drain that would have
resolved it could never run. The proposal is identified by the server's
`isProposal` flag rather than by parsing the payload; a transport layer guessing
at MLS bytes is how that bug is reintroduced.

### When a publish outcome is unknown

Rule 2 has a third case beside "accepted" and "rejected": a timeout, a dropped
connection, a 5xx. The commit may or may not have landed, and **discarding it is
the wrong guess**. If the server did take it, the commit comes back in the next
catch-up page, this device tries to `processMessage` its own commit, fails, and
is forked off the group with no way back.

So it stays staged and the context is noted in `_unconfirmedCommits`. The next
catch-up settles it: our commit at that epoch means merge, somebody else's means
drop ours and apply theirs. Re-publishing meanwhile is safe — the server matches
on `(senderDeviceId, generation, epoch, payload hash)` and returns
`duplicate: true` with the stored row, which is a **success**, not a lost race.

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

## Admission to an encrypted context

Somebody who joins a guild after a channel was encrypted holds no group keys, and
nobody can mint them a Welcome unprompted — the server has none either, so only a
current member can produce an Add commit. They ask, members review, and the
approval that meets the threshold is what mints the Welcome.

`core/mls/mls_join_request_service.dart`, mirroring Alpine's
`mls-join-request.service.ts`. **Conversations as well as channels**, since
contract §B. This used to be channel-only on the theory that a conversation's
roster is fixed at creation and everyone in it was welcomed then — but a group
member is a **device**, not a user. A handset registered after the DM already
existed was never welcomed to anything, had no route in, and nobody could give it
one. That is root cause R2 of "my friend texts me and I can't read it", and it is
the more common half of what this closes.

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
`ChannelAccessBanner` at the top of any context this device cannot read.
**Alpine has the requester-side service but no UI for it** — the banner is
mobile-only, and without it the loop is a dead end.

The banner tries an **external commit** first (`rejoinGroup`), because when the
server still holds a GroupInfo for the live generation this device can walk back
in on its own with no approval and no round trip through another person. That
primitive was implemented and Rust-tested on both clients with zero callers until
now. It falls back to a join request when there is no GroupInfo to rejoin with.

## Identity, and refusing to re-mint over live groups

A keychain miss on a device that holds no groups is a first run. On a device that
*does* hold groups it is lost keys, and the two used to be the same code path:
`createIdentity` minted a fresh Ed25519 pair over live group state, leaving the
device holding leaves it could neither sign for nor decrypt while `isUnlocked`
read true and the composer offered to send. Every message it sent was refused,
none it received could be read, and nothing said so.

`createIdentity` now throws `MlsIdentityConflictException` rather than minting
over a non-empty registry, and `MlsService.identityStatus` carries
`keysMissing` so the banner can offer "re-link this device".
`recoverWithFreshIdentity` is the explicit, user-initiated version — it wipes and
mints, which permanently destroys every encrypted message this account holds on
this handset, so it belongs behind a confirmation rather than in a launch
sequence.

It also mints **zero** key packages. The ten it used to produce were never
uploaded and never freed: they sat in the engine's store, which is re-serialized
in full on every send, receive and commit, so they made every later operation
slower forever in exchange for nothing. Replenish mints exactly what the server
asks for moments later, and that is the only batch anyone can consume.

## Key packages the server hands out for keys we no longer have

The replenish count is derived purely from server rows, but the private init keys
live only in the local MLS store. So a device that wipes that store leaves ~100
unconsumed packages behind, the server answers `Count = 0`, nothing is
re-uploaded, and **every Welcome sealed to one of them is undecryptable by the
device it was addressed to** — silently and permanently. That is root cause R3.

`DELETE api/v1/devices/client/{id}/key-packages` (contract §A) is the fix, and it
has to run *before* re-registering and replenishing on every path that clears
local MLS state: the corrupt-state wipe in `MlsService.init`, and immediately
after minting a new signing keypair on an existing `clientDeviceId`.
`MlsSessionManager.resetServerKeyPackages` is the one place that does it.

## Push notifications

Encrypted messages are decrypted on the device *before* the notification is
shown, rather than the server sending "you have a new encrypted message" — see
[push-decryption.md](push-decryption.md). Two consequences matter here:

- The plaintext cache has more than one writer (the app, plus Android's FCM
  background isolate or iOS's notification service extension), so every write to
  it merges rather than overwrites.
- On iOS, MLS state moves into the App Group container so the extension can read
  it, and the extension opens the engine read-only so it can never write a stale
  copy over what the app committed. The App Group entitlement and the release
  provisioning profile have to change together — declaring one the profile does
  not carry fails the archive outright, so
  [push-decryption.md](push-decryption.md#setup-and-why-the-order-matters) sets
  out the order.

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

## Account switching

Two accounts on one handset are kept apart in three places, and all three had to
be fixed together — any one of them alone still leaked.

1. `MlsStore.stateDirectory` cached its directory **ignoring the user id**, so a
   push for account B was handed account A's directory. It is now keyed by the
   account it was resolved for, and `MlsStore.init` for a different account
   resets rather than returning early.
2. The Rust `init_storage` **inserted into** whatever was already in the provider
   rather than replacing it, so switching accounts merged two accounts' key
   material into one store and the next save wrote A's private keys into B's
   file. It now clears groups, pending messages, signers and provider storage
   whenever the directory changes.
3. Because of (2), the FCM background isolate — which shares a process with the
   app on Android — could tear down the foreground session by initialising for
   another account. `MessagePushDecryptor` asks the engine which directory it is
   pointed at and leaves it alone when they differ, showing the server's
   placeholder instead. Losing one notification body beats destroying a live
   session to read it.

## The master key is wrapped twice

`core/crypto/master_key_service.dart`, contract §C.1.1. The account master key is
random 32 bytes wrapped **independently** under `Argon2id(password, salt_p)` and
`Argon2id(recoveryCode, salt_r)`. Both wrappings seal the same bytes and share a
version.

One wrapping was not enough, and the reason is not hypothetical: `ResetPassword`
never touched `EncryptedMasterKey`, so a reset left it sealed under a password the
user had — by definition of a reset — forgotten. Every backup blob and the account
identity key became permanently unopenable, silently, at exactly the moment
someone was trying to recover their account.

With two wrappings a reset invalidates the password one only. Unlocking with the
recovery code re-wraps under the new password **in the same call**, so the next
unlock is ordinary again and the step cannot be forgotten. That re-wrap carries no
password check server-side: producing a valid wrapping *is* the proof, and
requiring the password would gate recovery on the very thing that was just reset.

A password *change* — where the user still knows the old one — re-wraps in place
and needs no code. Neither path ever mints a new master key: every backup blob and
every admission proof is bound to the existing one.

`MasterKeyStatus` is what the UI branches on, and two of its values demand action:

- `needsRecoveryCode` — only a password wrapping exists. Every account created
  before §C.1.1 is here, each one a single reset from total loss, so
  `VerifiedDevices` and cloud engine-state backup stay unavailable until a code is
  saved.
- `historyLost` — **already gone**, not a warning about the future. A reset
  invalidated the password wrapping and there was no code to fall back on.

### The recovery-code format is wire format

Contract §C.1.2. 32 characters over a **31-symbol** alphabet
(`23456789ABCDEFGHJKMNPQRSTUVWXYZ`), eight groups of four, ~158.5 bits. None of
`I`, `L`, `O`, `0` or `1` — the pairs people transcribe wrongly off paper.

The alphabet is shared with the desktop client and the two diverged on it, which
is worth stating plainly because the failure mode was so quiet. A 32nd symbol,
`*`, was appended here purely so a 5-bit mask would be uniform. Sound reasoning
about bias, wrong trade: `*` is punctuation in a string a human copies off paper
under stress, and it was not in the desktop client's alphabet — so that client's
validator rejected every code containing one and fell back to the **unnormalised
raw input**, deriving a different key silently, during the one operation the code
exists for. About one character in 32 was a `*`. Nothing server-side could have
noticed: the server only ever sees the wrapping, never the code.

Generation is therefore **rejection sampling** — draw a byte, discard it at or
above 248, else `alphabet[b % 31]` — which removes the bias without adding a
character. The discard rate is 8/256 and this runs once per account.

Normalisation is **total**: strip whitespace and `-`, uppercase, validate, and on
failure return `MlsErrorKind.recoveryCodeInvalid`. Never fall back to raw input —
that converts a recoverable typo into unrecoverable data loss with no diagnostic,
since the KDF happily derives *a* key from the typo and all the user learns is
"wrong code". Recovery codes only; a password is case-sensitive, may contain
anything, and never passes through it.

`RecoveryCodeScreen` shows the code once and confirms by **re-entry** rather than
a checkbox: "I have saved this" is a box people tick; typing it back is something
they can only do if they did. Its validator names the offending character, since
`0`-for-`O` is the mistake people actually make and "does not match" gives them
nothing to act on.

`testdata/mls-golden/v1/recovery-code.json` is this client's half of the
cross-client fixture, in the §F golden-vector pattern — a code plus the wrapping
it opens, for the desktop client to consume. This class of bug is otherwise
invisible until somebody is mid-recovery with no second copy.

### The KDF headers are the authority

The master key uses Argon2 `p = 1`; the backup envelope uses `p = 4`. That
divergence is safe **only** because both formats are self-describing and both
readers derive from the declared header, never from this build's constants — the
constants are write-side only. A reader that hardcoded them would open everything
it wrote itself and fail solely on a blob written by the desktop client, at the
one moment that path is ever exercised.

`declared_kdf_parameters_are_the_ones_actually_used` and its master-key twin
perturb each of `m`, `t` and `p` in turn and assert the read then fails. **Do not
align the two parallelism values** — every key already wrapped under the other
would stop opening, and nothing would notice until someone needed it.

## Backup and restore

`core/mls/mls_backup_service.dart`, envelope format in contract §D. The envelope
is assembled **Rust-side** so it stays byte-identical to Alpine's — a `.venta-keys`
file written on a phone has to open on a desktop — and so the signing keypair,
which lives in the engine's signer table, does not go back onto the Dart heap.

`export_state` alone was never enough to restore anything. It covers the provider
store and group ids, and omits the four things that matter: the **Ed25519 signing
key** (keychain and engine memory, never provider storage), the **device id**
(the keychain entries are named after it), the **group registry** (without which
the restored groups are unaddressable and every context reads as unencrypted),
and the **plaintext message cache** (the only readable copy of history).

**The engine comes across only when the envelope's device id matches this
device's.** Not "when the engine is empty" — a new device always has an empty
engine, so that rule would clone ratchet state onto every new handset. Two
devices sharing one leaf derive the same sender-ratchet keys, so openmls treats
the repeat as a replay and at least one becomes unable to send; forward secrecy
for that leaf is gone; and an Update from one leaves the other holding keys the
group believes were rotated. A `userId` mismatch is refused outright.

On a new device the signing key, registry and message cache are restored and the
groups are re-joined — by external commit where the server still holds a
GroupInfo, by join request otherwise. **History from before the re-join stays
unreadable**, which is correct MLS behaviour and is shown rather than papered
over.

## Known gaps

**Nothing calls `ConversationMemberService` yet.** Mobile has no add-member UI
for group conversations — the members sheet is read-only — so the service is
available and unwired. Alpine is in the same position: it added the service in
`9d6a335` with no call site either. Wiring it needs a friend-picker surface that
does not exist on either client rather than an MLS decision.

**Search is unavailable in encrypted contexts.** The server indexes plaintext
only, so a search there returns empty rather than erroring. `ThreadView` shows an
explicit "not available" state instead of an empty-results one.

**The protection-level and device-certificate machinery is built but not
enforced.** `MasterKeyService`, `AccountIdentityService`, `ProtectionLevelService`,
`DeviceAdmissionService`, `MlsPolicyService` and `LeafVerificationService` exist
and are tested, but nothing calls `LeafVerificationService` from the commit path
yet, and no launch sequence establishes the account identity key. That ordering is
deliberate: contract §I.7 puts these at deployment steps 4–5 while the base64 fix,
failure surfacing and key-package reset are steps 1–2, and §I.1 defaults
certificate enforcement to `Observe` precisely because no device in the field has
a certificate. Wiring enforcement before coverage exists would have this client
proposing the removal of every other device in every group it is in.

**No settings UI for the recovery code yet.** `MasterKeyService.setUp` /
`addRecoveryCode` and `RecoveryCodeScreen` exist and are tested, but nothing calls
them from a launch or settings path — so §C.1.1's retrofit prompt for existing
accounts is unwired, and `MasterKeyStatus.historyLost` has no surface. The
mechanism is complete; the trigger is not.

**The backup cadence is manual.** `MlsBackupService.backUpIfStale` implements the
§H.6 debounce but nothing calls it on a state change, and there is no settings UI
for the passphrase, the last-backup time, or the protection level. A backup that
only exists when someone presses a button will not be there when it is needed, so
this is a real gap rather than a deferral.

**iOS is unbuilt.** See `packages/venta_mls/README.md`.
