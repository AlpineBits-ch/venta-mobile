# Native call popup + push notifications — backend spec

The Flutter client (`gg.venta.mobile`) side of this is implemented — push
token registration, message notifications, and CallKit/Android incoming-call
UI wiring via `flutter_callkit_incoming`. This document is everything the
**Echo backend** (`C:\Users\Domin\RiderProjects\Echo`) still needs, in the
order it blocks the client.

Researched against the current backend state (`Messaging.Application`,
`Identity.Application`) — file:line references below point at what exists
today.

## Architecture change: FCM-only for regular pushes, direct APNs only for VoIP

Today `PushNotifiaction.cs` picks direct APNs vs FCM per-token via a 64-char
length heuristic, on the theory that iOS needs direct APNs. It doesn't —
FCM has always been able to deliver to iOS: the iOS FCM SDK registers with
APNs internally and hands back an FCM token, and `FirebaseMessaging.SendAsync`
relays to APNs behind the scenes. Since the client is Flutter with
`firebase_messaging` on both platforms, the standard (and much simpler) setup
is FCM for *everything except VoIP*.

**VoIP/CallKit push is the one exception, and it's a hard Apple requirement,
not a preference.** FCM's API has no VoIP push type at all — CallKit
requires PushKit registration (a separate token from the regular
APNs/FCM token) and delivery via direct APNs with `apns-push-type: voip` to
a dedicated `.voip` topic. There's no FCM equivalent for this one thing.

Net effect on this spec: §1 below (message pushes) drops direct APNs
entirely and fixes the bundle-ID bug for free — FCM matches a token to its
APNs config via the token's registered app in the Firebase project, not a
string literal in backend code. Direct APNs (`dotAPNS`) survives only inside
§3's VoIP path, which needs it regardless (`ApplePushType.Voip`, confirmed
present in the currently-installed `dotAPNS` package — just unused today,
`PushNotifiaction.cs` only ever constructs `.Alert`).

**Client-side dependency**: the Flutter client currently registers its
regular-push token as `Platform.isIOS ? getAPNSToken() : getToken()` (raw
APNs token on iOS) — built against the *current* direct-APNs backend. If you
adopt this simplification, that needs to flip to `getToken()` (FCM token) on
both platforms before/alongside this backend change, or iOS message push
breaks the other way (backend sends via FCM, client registered a raw APNs
token FCM doesn't recognize). Flag when you're ready for this and it'll get
updated together.

## 1. Simplify + fix: message pushes should go through FCM only

`Messaging.Application/Services/PushNotifiaction.cs` currently:

```csharp
bool isApnToken = notificationParams.Token.Length == 64;
```
...branching to a hardcoded direct-APNs client (`BundleId = "com.alpinebits.echo"`,
`Credentials/AuthKey_U6JZ45ZLGM.p8`) for iOS. That hardcoded bundle ID
doesn't match this app (`gg.venta.mobile`) — as it stands today, **zero
push notifications reach iOS Flutter clients** via this path, regardless of
anything else in this doc.

Fix: delete the branch. Send every regular (non-VoIP) push — messages,
friend requests, whatever else uses `PushNotifiaction.SendPushNotification`
— via `FirebaseMessaging.DefaultInstance.SendAsync`, unconditionally,
keyed only on which `FirebaseApp` the token's project belongs to (see §5).
No topic, no bundle ID, no per-platform branching needed for this path at
all once the client also registers an FCM token on iOS (see above).

Also, while touching this file: `Messaging.Application/Handler/Messages/MessageCreatedHandler.cs:46-51`
builds `PushNotificationParams` with only `Title`/`Body`/`Token` —
`Data` is left as its default empty dict, even though `PushNotificationParams.Data`
already exists and is already wired through to FCM's `Data` field. Add:

```csharp
Data = new Dictionary<string, string> { ["conversationId"] = messageCreated.ConversationId },
```

Without this, the client has no way to deep-link a tapped message
notification to the right conversation (`PushNotificationService` on the
Flutter side already reads `data['conversationId']` — it just never
receives one today).

## 2. New: VoIP token registration

iOS PushKit VoIP tokens are a distinct token space from regular APNs/FCM
tokens — a call push sent to the regular-push token will not arrive, and
vice versa. Android has no equivalent concept; the Flutter client reuses its
existing FCM token (§1) for call pushes on Android, so this endpoint only
ever gets called from iOS.

Mirror the existing device-token endpoint
(`Identity.Application/Controllers/UserController.cs:102-125`,
`Identity.Domain/Entities/UserDeviceToken.cs`) exactly:

- New entity `UserVoipToken { Id, Token, UserId }` on `ApplicationUser`,
  same shape as `UserDeviceToken`.
- `POST api/v1/identity/users/self/voip-token` (the `/identity` segment is the
  YARP gateway prefix that routes to the Identity microservice — same as the
  existing device-token endpoint), `[Authorize]`, body
  `CreateDeviceTokenDto`-shaped (`{ "token": string }`), same
  duplicate-returns-202/new-returns-201 semantics.
- A corresponding `GetVoipTokenForUserIdRequest`/`...Handler` (mirroring
  `GetDeviceTokenHandler.cs`) for the call-push sender in §3 to consume.

No platform/bundle-id column needed here — CallKit/VoIP push is a new
feature with no legacy Alpine equivalent (confirmed: Alpine's call UI never
attempted CallKit/PushKit), so the topic can just be hardcoded (§3).

## 3. New: push fallback for `call.IncomingCall`

Today, `VoiceController.CallAsync`
(`Messaging.Application/Controllers/VoiceController.cs:76`) only does:

```csharp
await hubContext.Clients.Users(request.Participants).SendAsync("call.IncomingCall", call);
```

100% SignalR — confirmed zero push-notification fallback anywhere in the
call path. A backgrounded or killed client never learns about an incoming
call. Add a parallel push fan-out alongside that SignalR send (redundant
sends are harmless — the client is idempotent per `callId`, and if the
SignalR message already reached a live client, CallKit just won't be shown
twice for the same id).

For each participant other than the caller, look up their caller-facing
profile (same pattern as `MessageCreatedHandler.cs:34`,
`GetProfileByUserIdRequest`) and their tokens, then:

**Android** (their `UserDeviceToken`, i.e. FCM token) — send via
`FirebaseMessaging`, **data-only, no `Notification` block**, high priority
so it wakes a Doze-restricted/backgrounded app:

```csharp
var message = new Message {
    Token = fcmToken,
    Data = new Dictionary<string, string> {
        ["type"] = "call",
        ["callId"] = call.Id,
        ["conversationId"] = call.ConversationId,
        ["callerName"] = callerProfile.UserName,
        ["callerAvatarUrl"] = callerProfile.AvatarUrl ?? "",
    },
    Android = new AndroidConfig { Priority = Priority.High },
};
```

No `Notification` block is deliberate — the Flutter client's own background
handler decides the UI (native incoming-call screen), not the OS tray.

**iOS** (their new `UserVoipToken`) — send via the one remaining `ApnsClient`
instance (§1 removed the other one), configured with topic
`gg.venta.mobile.voip` (Apple's convention — VoIP topic is always
`<bundle-id>.voip`), push type `.Voip`, priority 10, **no alert/sound/badge**
(this is a silent push — CallKit is what actually rings, not the push
itself):

```csharp
var push = new ApplePush(ApplePushType.Voip).AddToken(voipToken);
push.AddCustomProperty("callId", call.Id);
push.AddCustomProperty("conversationId", call.ConversationId);
push.AddCustomProperty("callerName", callerProfile.UserName);
push.AddCustomProperty("callerAvatarUrl", callerProfile.AvatarUrl ?? "");
await voipApnsClient.SendAsync(push);
```

The client's `AppDelegate.swift` (`didReceiveIncomingPushWith`) reads
exactly these keys off `payload.dictionaryPayload` — keep the field names
in sync with this doc if either side changes.

## 4. New: cancel-ringing push (glare / multi-device / timeout)

`CallAcceptedHandler.cs`, `CallDeclinedHandler.cs` (both SignalR-only,
`Messaging.Application/Handler/Call/`) and the `call.CallEnded` broadcast in
`VoiceController.cs:178` all currently only touch the hub. If a call is
answered/declined/ended while another one of the callee's devices is
ringing (backgrounded or killed, showing the native CallKit/Android
incoming-call UI from §3), that device's ring is never torn down — it just
sits there until CallKit's own ~30s timeout. This is very noticeable and
easy to miss in testing (it only shows up with a second device, or a
call that's answered right as it starts ringing).

Fix: from all three of those handlers (accepted, declined, ended), send the
**same push channel as §3** but with a distinct payload the client
recognizes as "tear down, don't show":

- **Android**: same data-only FCM message, but `["callSubtype"] = "end"`
  alongside `["type"] = "call"` and `["callId"]`.
- **iOS**: same VoIP push, but with a top-level `"type": "end"` custom
  property (VoIP pushes don't need the Android-side `type: "call"` /
  `callSubtype` split — the VoIP channel is call-only by construction, so
  `type` alone disambiguates "show" vs "end").

Only send this to participants who *aren't* the one who just took the
action (no point tearing down your own device's UI — it's already
transitioning via the normal in-app flow).

## Payload field reference

| Field | Android (FCM data) | iOS (APNs VoIP custom properties) |
|---|---|---|
| discriminator | `type: "call"` always; `callSubtype: "end"` for cancel | `type: "end"` for cancel; absent/anything else = incoming |
| call id | `callId` | `callId` |
| conversation id | `conversationId` | `conversationId` |
| caller display name | `callerName` | `callerName` |
| caller avatar | `callerAvatarUrl` | `callerAvatarUrl` |

## 5. Blocker: backend's Firebase project doesn't match the new app's

`Messaging.Infrastructure/MessagingInfrastructure.cs:50-54` calls
`FirebaseApp.Create` **once**, as a singleton, from a service-account JSON
read out of the `FIREBASE_SEVRICE_ACCOUNT_JSON_BASE_64` env var
(`AppEnvironment/Env.cs:37` — note the existing typo in the var name, not
introduced here). `FirebaseMessaging.DefaultInstance` sends through that one
app — and with §1's simplification, *all* regular push (Android and iOS
both) now depends on this being right, not just Android's.

The Android app was just registered in Firebase console under project
**`venta-gg`** (`google-services.json` now in
`venta_mobile/android/app/` — project_id confirms it), which is almost
certainly **not** the project the backend's current service-account
credential belongs to (that credential likely predates this app, from
whatever project Alpine's Android build used). A token registered under
`venta-gg` cannot be sent to by a service account from a different project —
`FirebaseMessaging.DefaultInstance.SendAsync` will fail for every token from
this app until the backend's credential is swapped (or extended) to cover
`venta-gg`.

Two ways to fix, pick one:

- **(a) Recommended, simplest** — if Alpine's Android build is not actively
  sending pushes that matter anymore, just regenerate
  `FIREBASE_SEVRICE_ACCOUNT_JSON_BASE_64` from a service account key
  downloaded from the `venta-gg` project (Firebase console → Project
  Settings → Service Accounts → Generate new private key), base64-encode
  it, and swap the env var. One `FirebaseApp`, same as today, no per-token
  routing logic needed anywhere.
- **(b)** If Alpine push still needs to keep working, register a *second*
  named `FirebaseApp` (`FirebaseApp.Create(options, "venta-gg")`) alongside
  the existing default one, and pick the right one per token when sending —
  which needs some way to know which project a given token belongs to (a
  platform/app marker on `UserDeviceToken`, since a bare FCM token doesn't
  self-identify its project).

Also register a new iOS app (bundle `gg.venta.mobile`) under the same
`venta-gg` Firebase project — with §1's simplification this is now load-
bearing for real iOS message push, not just a formality for `firebase_core`
to initialize. Then, on a real Mac (not from Windows):

- Add the downloaded `GoogleService-Info.plist` to the Xcode project via the
  Runner target UI (same reasoning as the CI signing setup earlier — don't
  hand-edit `project.pbxproj` for this).
- Enable the **Push Notifications** capability in Signing & Capabilities
  (writes `Runner.entitlements`, `aps-environment`) — same reasoning, not
  done blind from Windows.

## Known limitation (not blocking, just flagging)

The client is self-hostable (`AuthRepository.baseUrl` is per-server, not
fixed to `venta.gg`). Push notifications are tied to whichever Firebase
project / APNs credentials the *backend* the client happens to be pointed
at was configured with — a self-hosted operator running their own Echo
instance would need their own Firebase project (for regular push) and APNs
VoIP key (for calls) matching this same client bundle ID for push to work
against their server. Out of scope here; just don't be surprised if a
self-hosted instance has working websocket calls but no push fallback.
