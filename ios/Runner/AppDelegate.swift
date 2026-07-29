import AVFAudio
import CallKit
import Flutter
import PushKit
import UIKit
import WebRTC
import flutter_callkit_incoming

// PushKit/CallKit wiring for native incoming-call UI — see
// docs/native-call-push-backend-spec.md for the payload this expects from
// the backend's VoIP push, and CallKitService (Dart) for the other half:
// this delegate only registers the VoIP token and surfaces incoming pushes
// as a CallKit call; the Dart side (flutter_callkit_incoming's `onEvent`
// stream, consumed by CallKitService) is what actually calls the
// accept/decline/end REST endpoints and connects WebRTC. Deliberately does
// NOT report call actions to any third-party endpoint (unlike the plugin's
// own example AppDelegate) — accept/decline/end are handled entirely by our
// own backend via the Flutter side.
@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate, PKPushRegistryDelegate,
  CallkitIncomingAppDelegate
{
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    let voipRegistry = PKPushRegistry(queue: .main)
    voipRegistry.delegate = self
    voipRegistry.desiredPushTypes = [.voIP]

    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self
    }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
  }

  // The UIScene-based implicit engine (didInitializeImplicitFlutterEngine
  // above) only gets created once a scene connects
  // (scene:willConnectToSession:options:) - see Flutter's UIScene migration
  // guide. A PushKit VoIP relaunch creates this process with no scene/window
  // at all, so that never fires, GeneratedPluginRegistrant.register never
  // runs, and SwiftFlutterCallkitIncomingPlugin.sharedInstance stays nil.
  // That silently no-ops every `sharedInstance?.` call below via optional
  // chaining - including the completion() inside showCallkitIncoming's
  // trailing closure, which PushKit requires be called synchronously, every
  // time, with no exceptions. Skipping it gets the process SIGKILLed by
  // FrontBoard (0xbaadca11 - "bad call") for violating the VoIP push
  // contract, which is indistinguishable from "no popup ever appears".
  // Booting this headless engine first guarantees the plugin is registered
  // (and sharedInstance non-nil) before we try to report the call, with no
  // dependency on any scene ever connecting.
  private lazy var voipEngine: FlutterEngine = {
    let engine = FlutterEngine(name: "venta_voip_engine")
    engine.run()
    GeneratedPluginRegistrant.register(with: engine)
    return engine
  }()

  private func ensureFlutterEngineForCallKitReporting() {
    if SwiftFlutterCallkitIncomingPlugin.sharedInstance == nil {
      _ = voipEngine
    }
  }

  // Missed-call notification support (shown when the call rings out).
  override func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    willPresent notification: UNNotification,
    withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
  ) {
    CallkitNotificationManager.shared.userNotificationCenter(
      center, willPresent: notification, withCompletionHandler: completionHandler)
  }

  override func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    didReceive response: UNNotificationResponse,
    withCompletionHandler completionHandler: @escaping () -> Void
  ) {
    if response.actionIdentifier == CallkitNotificationManager.CALLBACK_ACTION {
      let data = response.notification.request.content.userInfo as? [String: Any]
      SwiftFlutterCallkitIncomingPlugin.sharedInstance?.sendCallbackEvent(data)
    }
    completionHandler()
  }

  // MARK: - PKPushRegistryDelegate

  func pushRegistry(
    _ registry: PKPushRegistry, didUpdate credentials: PKPushCredentials, for type: PKPushType
  ) {
    let deviceToken = credentials.token.map { String(format: "%02x", $0) }.joined()
    SwiftFlutterCallkitIncomingPlugin.sharedInstance?.setDevicePushTokenVoIP(deviceToken)
  }

  func pushRegistry(_ registry: PKPushRegistry, didInvalidatePushTokenFor type: PKPushType) {
    SwiftFlutterCallkitIncomingPlugin.sharedInstance?.setDevicePushTokenVoIP("")
  }

  // Apple requires reporting the call to CallKit synchronously within this
  // callback, every time, with no exceptions — an app that doesn't gets
  // silently killed by the OS and future VoIP pushes stop being delivered.
  func pushRegistry(
    _ registry: PKPushRegistry, didReceiveIncomingPushWith payload: PKPushPayload,
    for type: PKPushType, completion: @escaping () -> Void
  ) {
    guard type == .voIP else {
      completion()
      return
    }

    ensureFlutterEngineForCallKitReporting()

    let id = payload.dictionaryPayload["callId"] as? String ?? UUID().uuidString

    // "end" cancels a ring already shown on this device — sent when the call
    // was answered/declined/timed out on another device or by the caller.
    // Without this a phantom CallKit ring sits there until its own ~30s
    // timeout. See docs/native-call-push-backend-spec.md.
    //
    // We still have to report a NEW call via showCallkitIncoming here, even
    // though we're immediately ending it: PushKit requires every VoIP push
    // to result in a CallKit report before completion(), with no exceptions
    // (Apple enforces this with -[PKPushRegistry
    // _terminateAppIfThereAreUnhandledVoIPPushes], which kills the process).
    // Calling plugin.endCall() alone only works if this process already has
    // a call reported for this id (i.e. showCallkitIncoming ran earlier in
    // this launch) — when PushKit relaunches a killed app for this exact
    // "end" push, self.data inside the plugin is nil, endCall() silently
    // no-ops, and the push goes unreported, crashing the app on the next
    // suspend. Reporting-then-ending guarantees a report always happens.
    if payload.dictionaryPayload["type"] as? String == "end" {
      let endData = flutter_callkit_incoming.Data(id: id, nameCaller: "", handle: "", type: 0)
      SwiftFlutterCallkitIncomingPlugin.sharedInstance?.showCallkitIncoming(endData, fromPushKit: true) {
        SwiftFlutterCallkitIncomingPlugin.sharedInstance?.endCall(endData)
        completion()
      }
      return
    }

    let nameCaller = payload.dictionaryPayload["callerName"] as? String ?? "Unknown"
    let avatar = payload.dictionaryPayload["callerAvatarUrl"] as? String ?? ""
    let conversationId = payload.dictionaryPayload["conversationId"] as? String ?? ""

    let data = flutter_callkit_incoming.Data(id: id, nameCaller: nameCaller, handle: nameCaller, type: 0)
    data.avatar = avatar
    data.extra = ["conversationId": conversationId]

    SwiftFlutterCallkitIncomingPlugin.sharedInstance?.showCallkitIncoming(data, fromPushKit: true) {
      completion()
    }
  }

  // MARK: - CallkitIncomingAppDelegate
  //
  // These just fulfill the CXAction promptly, per Apple's requirement. The
  // actual accept/decline/end REST calls happen in Dart (CallKitService,
  // listening to FlutterCallkitIncoming.onEvent) — the Flutter engine is
  // already running by the time these fire, since PushKit relaunches the
  // app process for every VoIP push.

  func onAccept(_ call: Call, _ action: CXAnswerCallAction) {
    action.fulfill()
  }

  func onDecline(_ call: Call, _ action: CXEndCallAction) {
    action.fulfill()
  }

  func onEnd(_ call: Call, _ action: CXEndCallAction) {
    action.fulfill()
  }

  func onTimeOut(_ call: Call) {}

  // WebRTC (flutter_webrtc) manages its own RTCAudioSession independently of
  // CallKit, but per Apple's rules only CallKit may activate/deactivate the
  // shared AVAudioSession during a self-managed call — WebRTC calling
  // setActive itself outside this window is a no-op against a session it
  // doesn't actually own. These callbacks are the handoff: they tell
  // RTCAudioSession the OS just granted (or revoked) the audio route, which
  // is what actually starts the audio unit doing mic capture/speaker output.
  // Without this, signaling completes and the call looks connected, but no
  // audio flows in either direction — see venta_mobile's silent-call report.
  func didActivateAudioSession(_ audioSession: AVAudioSession) {
    RTCAudioSession.sharedInstance().audioSessionDidActivate(audioSession)
  }

  func didDeactivateAudioSession(_ audioSession: AVAudioSession) {
    RTCAudioSession.sharedInstance().audioSessionDidDeactivate(audioSession)
  }

  func providerDidReset() {}
}
