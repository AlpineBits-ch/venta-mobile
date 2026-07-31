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

### Setup (needed once per checkout)

The extension's sources are checked in; the Xcode target is not, because
`project.pbxproj` is not a file to hand-edit.

```sh
cd ios && ruby scripts/add_notification_extension.rb
pod install
```

Then, in Xcode / on the Apple Developer portal:

- Select a signing team for the `NotificationService` target.
- Create the App Group `group.gg.venta.mobile` and enable it on **both** the app
  id and the extension's app id, then regenerate both provisioning profiles.

Without the App Group the app still runs — `SharedContainer.directory()` returns
null, MLS state stays where it was, and encrypted notifications show the
placeholder.

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
