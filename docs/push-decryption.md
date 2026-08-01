# Decrypting push notifications

An encrypted message used to arrive on a phone as "You have a new encrypted
message". The server cannot read the body — that is the point of MLS — so it had
nothing better to send.

The fix is to stop asking the server to write the notification. It ships the
ciphertext *inside* the push, and the device decrypts it in the moment before the
notification is displayed. The message is still end-to-end encrypted; the tray
entry is just one more place the recipient's own key material is used.

The same push also carries the sender's avatar URL, which both platforms fetch
and attach, so a notification shows who it is from rather than the app icon.

## Shape of a message push

Built by `Messaging.Application/Services/MessagePushService.cs`, sent for both
DMs (`MessageCreatedHandler`) and guild channels (`ChannelPushRequestedHandler`).

| key | meaning |
| --- | --- |
| `type` | always `message` — distinguishes these from call pushes |
| `messageId`, `contextId` | the message, and the conversation/channel that owns the MLS group |
| `conversationId` / `channelId` + `guildId` | which one it is, and where tapping should land |
| `authorId`, `senderName`, `senderAvatarUrl` | who sent it |
| `recipientUserId` | which account on the handset it is for — MLS state is stored per user id |
| `encrypted` | `1` or `0` |
| `body` | the real text when plaintext; the placeholder when encrypted |
| `ciphertext` | base64 MLS message (encrypted only) |
| `mlsGeneration` | which of the context's successive groups sealed it |
| `truncated` | `1` when the ciphertext did not fit — see below |

The one thing the server never sends is the plaintext of an encrypted message. If
a device cannot decrypt, it shows `body`, which is the same placeholder as
before.

### Android and iOS get different envelopes

One `Message` carries both configs, because a push token says only "FCM", not
which platform issued it.

- **Android**: data-only, `Priority.High`. A `notification` block would have the
  OS draw the entry itself — with the placeholder, uncorrectably — and would stop
  the Flutter background isolate from being the thing that decides what it says.
- **iOS**: an APNs alert with `mutable-content: 1`. A silent
  (`content-available`) push is not guaranteed delivery on iOS and a killed app
  would simply miss messages, so the alert is real and the notification service
  extension gets ~30 seconds to rewrite its body.

**Trade-off worth knowing:** data-only messages are treated more harshly by
aggressive OEM battery managers (Xiaomi, Huawei and friends) than notification
messages are, and are not delivered at all to a force-stopped app. That is the
price of being able to show the real text; the alternative is a permanent
placeholder.

### Size

FCM caps a message's data payload at 4KB. The ciphertext is the only unbounded
field, so it is the one that gets dropped: over 3000 base64 characters, the
server sends `truncated: 1` instead and the device falls back to the placeholder.
Everything else — name, avatar, routing — still works.

## Android: the FCM background isolate

`firebaseMessagingBackgroundHandler` → `MessageNotifier.show` →
`MessagePushDecryptor.decrypt`.

The background isolate is a fresh Dart isolate with no `getIt`, no session and no
`MlsService`, so it opens its own `MlsStore` and its own `VentaMls`. On Android
that isolate runs *inside the app's process*, which means it shares the Rust
engine's process-global state with the running app — so advancing the ratchet
here is consistent by construction, and `initStorage` is a deliberate no-op when
the engine is already pointed at that directory (see `init_storage` in
`packages/venta_mls/rust/src/mls.rs`).

Two details that are easy to get wrong:

- `flutter_local_notifications` must be `initialize`d in the background isolate.
  It never was before, because the backend used to send a `notification` block
  and the OS drew the entry; a data-only push has nobody else to draw it.
- The decrypted plaintext **must** be written to the message cache. MLS reads a
  message off the wire exactly once, so without that write the conversation the
  user is about to open shows "cannot decrypt" for the exact message they just
  read in the tray.

## iOS: the notification service extension

`ios/NotificationService/` — `NotificationService.swift` rewrites the
notification, `MlsNotificationDecryptor.swift` is a small Swift re-implementation
of the Dart decryptor. It links the same `libventa_mls.a` and calls
`venta_mls_call` directly, so both paths are the same openmls build reading the
same state file.

The extension is a **separate process**, which drives two decisions:

1. MLS state lives in the App Group container (`group.gg.venta.mobile`) rather
   than Application Support — that container is the only directory both processes
   can open. `MlsStore.resolveRoot` moves an existing `mls/` directory across on
   first run.
2. The engine is opened **read-only**. The extension would load state at one
   moment and write it back at another, and anything the app committed in between
   would be silently replaced by the older copy. Losing the ratchet step this
   decrypt consumed costs nothing, because the plaintext goes into the message
   cache, which is where history is read from anyway.

### Setup, and why the order matters

The extension's sources are checked in; the Xcode target is not, because
`project.pbxproj` has to be written by Xcode itself.

`ios/Runner/Runner.entitlements` declaring an App Group that the provisioning
profile does not carry is not a degraded build, it is a **hard archive failure**:

```
Provisioning profile "Venta Mobile App Store" doesn't include the App Groups capability.
```

and the profile in `.github/workflows/release.yml` is a pre-generated base64
secret (`IOS_PROVISION_PROFILE_BASE64`), not something the build can mint.

So it goes in two phases, and the entitlement can only be declared once phase 1
has landed.

### Phase 1 — the App Group (no Mac needed)

The app's own profile is the only thing blocking the archive, because the
extension is not a target yet.

1. [Register the App Group](https://developer.apple.com/account/resources/identifiers/list/applicationGroup)
   `group.gg.venta.mobile`. This is the one step with no API equivalent — there
   is no public `/v1/appGroups` endpoint.
2. On the `gg.venta.mobile` App ID, tick **App Groups** → Configure → select the
   group → Save. Existing profiles go invalid; that is expected.
3. Regenerate the **Venta Mobile App Store** profile and download it. Keep the
   name: `ExportOptions.plist` maps the bundle id to it.
4. `IOS_PROVISION_PROFILE_BASE64` ← the new profile, base64, no trailing newline.
5. Declare `com.apple.security.application-groups` in **both**
   `Runner.entitlements` and `Runner-Release.entitlements` — in the same commit
   as step 4, never before it.

### Phase 2 — the extension (needs a Mac)

6. In Xcode: **File → New → Target → Notification Service Extension**, product
   name `NotificationService`, embed in `Runner`. The wizard writes into
   `ios/NotificationService/`, so move the checked-in sources aside first and
   copy them back over its generated ones afterwards — ours keep
   `$(FLUTTER_BUILD_NAME)`/`$(FLUTTER_BUILD_NUMBER)` in `Info.plist`, and an
   extension whose version does not match the app's is rejected at upload.

   Create the target in Xcode rather than by editing `project.pbxproj`. A
   previous blind edit from a non-Mac machine produced a file `xcodebuild`
   refused to parse, twice — the workflow still carries a warning about it.

7. On the new target: bridging header
   `NotificationService/NotificationService-Bridging-Header.h`, `Other Linker
   Flags` = `$(SRCROOT)/../packages/venta_mls/ios/build/libventa_mls.a`,
   deployment target 15.0, and a Run Script phase **above** Compile Sources
   running `"${SRCROOT}/../packages/venta_mls/ios/build_rust.sh"`. Nothing else
   orders the pod's build of that archive against this target, and linking a
   missing one fails with no useful explanation.

8. App Groups capability on the extension target too, same group.

9. Register the App ID `gg.venta.mobile.NotificationService` with App Groups —
   the same `group.gg.venta.mobile`, not a second group — generate an App Store
   profile named **Venta Notification**, and put it in
   `IOS_EXT_PROVISION_PROFILE_BASE64`. The workflow installs it and adds the
   second `provisioningProfiles` entry automatically. It decides whether the
   secret is required by looking for the target in `project.pbxproj`, so the
   workflow is valid either side of this change and a forgotten secret is
   reported as a forgotten secret.

   The name is not cosmetic. Both targets sign manually, so each names its
   profile literally in `project.pbxproj`
   (`PROVISIONING_PROFILE_SPECIFIER[sdk=iphoneos*]`). A profile that doesn't
   match fails half a minute into the archive with a message that mentions
   neither name:

   ```
   "NotificationService" requires a provisioning profile with the App Groups feature.
   ```

   `check_specifier` in the workflow compares the two up front so that surfaces
   in seconds instead.

10. Remove `${TARGET_BUILD_DIR}/${INFOPLIST_PATH}` from the **Input Files** of
    the `Thin Binary` build phase on the **Runner** target — Xcode's own
    Build Phases editor, or the `inputPaths` list in `project.pbxproj`, which
    is a value edit rather than a structural one.

    Without this the archive fails with `Cycle inside Runner; building could
    produce unreliable results`, and never gets as far as signing:

    ```
    CodeSign Runner.app  ->  Frameworks/WebRTC.framework
      ->  [CP] Embed Pods Frameworks   (phase 8)
      ->  Thin Binary                  (phase 7)
      ->  Runner.app/Info.plist        <- that input
      ->  Copy NotificationService.appex into Runner.app/PlugIns
      ->  Embed Foundation Extensions  (phase 9, after the Pods phase)
    ```

    Xcode appends `Embed Foundation Extensions` last when the wizard adds an
    extension, which is what closes the loop — the Pods phase and the appex
    copy each end up waiting on the other. Flutter declares that input so its
    thinning script is ordered after Info.plist processing, which it writes to
    in debug/profile builds (`AddObservatoryBonjourService`); release builds,
    the only ones this workflow makes, return from that early. The phase is
    `alwaysOutOfDate`, so dropping the input doesn't stop it running.

    A `flutter create`-style project regeneration would put the input back and
    the cycle with it.

11. Commit `project.pbxproj`.

The first launch after this moves existing MLS state into the App Group container
(`MlsStore.resolveRoot`). That migration is the one irreversible step here — if it
fails, the device loses its encrypted history — so it falls back from `rename` to
a recursive copy, and a failure leaves the app usable and re-joining from
Welcomes.

## The plaintext cache has two writers

This is the part that can lose data rather than merely disappoint.

`mls_message_cache.json` is written *whole* by whichever process saves it. The app
is one writer; the thing that decrypted the last notification is another. A plain
overwrite therefore deletes the other's decrypted messages — and since MLS
ratchets forward only, those messages can never be read again from their
ciphertext.

So every write merges: `MlsStore._write(merge: true)` in Dart,
`writeStringMap` in Swift. And the app calls `MlsStore.reloadMessageCache()` on
resume to pick up what was decrypted while it was away. `test/push_decryption_test.dart`
covers all three.

## Related backend fix

`MessageCreatedHandler` used to forward channel messages to Guild with
`EncryptionState = Plain` hardcoded, which told every realtime client and the
channel push path that an MLS-encrypted channel message was readable text.
`MlsGeneration` was likewise never populated on `MessageCreated`. Both are fixed
here, because a channel push cannot be decrypted without them.
