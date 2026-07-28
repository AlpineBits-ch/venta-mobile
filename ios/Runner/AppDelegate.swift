import AVFAudio
import CallKit
import Flutter
import PushKit
import UIKit
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

    let id = payload.dictionaryPayload["callId"] as? String ?? UUID().uuidString

    // "end" cancels a ring already shown on this device — sent when the call
    // was answered/declined/timed out on another device or by the caller.
    // Without this a phantom CallKit ring sits there until its own ~30s
    // timeout. See docs/native-call-push-backend-spec.md.
    if payload.dictionaryPayload["type"] as? String == "end" {
      let endData = flutter_callkit_incoming.Data(id: id, nameCaller: "", handle: "", type: 0)
      SwiftFlutterCallkitIncomingPlugin.sharedInstance?.endCall(endData)
      completion()
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

  func didActivateAudioSession(_ audioSession: AVAudioSession) {}

  func didDeactivateAudioSession(_ audioSession: AVAudioSession) {}

  func providerDidReset() {}
}
