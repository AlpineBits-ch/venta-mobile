import AVFAudio
import CallKit
import CryptoKit
import Flutter
import PushKit
import UIKit
import WebRTC

// PushKit/CallKit wiring for native incoming-call UI — see
// docs/native-call-push-backend-spec.md for the payload this expects from
// the backend's VoIP push, and CallKitService (Dart) for the other half.
//
// Owns a CXProvider directly rather than going through a third-party plugin
// (flutter_callkit_incoming, still used on Android). Reporting a call to
// CallKit now has zero dependency on a Flutter engine, plugin registrar, or
// any Dart code existing yet — PushKit's report-the-call deadline is strict
// enough (miss it and the OS SIGKILLs the process with FRONTBOARD
// 0xbaadca11, then stops delivering future VoIP pushes) that routing it
// through anything requiring an engine boot is fragile by construction; see
// the venta_mobile "native call screen crashes on iOS" investigation.
//
// Relaying a user action (answer/decline/end) back to Dart has no such
// deadline, so that path is allowed to lazily boot a real Flutter engine if
// nothing is running yet — see `ensureEngineForActionRelay`.
@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate, PKPushRegistryDelegate,
  CXProviderDelegate
{
  private static let channelName = "gg.venta.mobile/callkit"

  private lazy var cxProvider: CXProvider = {
    let config = CXProviderConfiguration(localizedName: "Venta Mobile")
    config.supportsVideo = false
    config.maximumCallGroups = 1
    config.maximumCallsPerCallGroup = 1
    config.supportedHandleTypes = [.generic]
    let provider = CXProvider(configuration: config)
    provider.setDelegate(self, queue: nil)
    return provider
  }()

  private let callController = CXCallController()

  // callId (our string, matches the backend Call aggregate's id) <-> UUID
  // (what CallKit actually deals in) - populated whenever we report a call,
  // since the UUID<->callId mapping is otherwise one-way (see `uuid(for:)`).
  private var callIdsByUUID: [UUID: String] = [:]
  // Whether each reported call has already been answered - CXEndCallAction
  // is the same action type for both "decline a ringing call" and "hang up
  // a connected one"; Dart needs to know which happened.
  private var answeredCalls: Set<UUID> = []
  // Sidesteps re-relaying an accept to Dart when Dart itself is the one
  // that triggered it (see `markCallConnected`) - it already knows.
  private var selfInitiatedAnswers: Set<UUID> = []

  private var voipToken: String?
  private var callKitChannel: FlutterMethodChannel?
  private var pendingEvents: [[String: Any]] = []
  private lazy var actionRelayEngine: FlutterEngine = {
    let engine = FlutterEngine(name: "venta_call_action_engine")
    engine.run()
    GeneratedPluginRegistrant.register(with: engine)
    attachChannel(messenger: engine.binaryMessenger)
    return engine
  }()

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    let voipRegistry = PKPushRegistry(queue: .main)
    voipRegistry.delegate = self
    voipRegistry.desiredPushTypes = [.voIP]

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    attachChannel(messenger: engineBridge.applicationRegistrar.messenger())
  }

  // Answering/declining/ending from the system CallKit UI (lock screen,
  // banner) normally foregrounds the app on its own, which boots the real
  // UIScene-driven engine (didInitializeImplicitFlutterEngine above) a
  // moment later. But a decline in particular doesn't strictly need any app
  // UI, so iOS can relay it to a relaunched-but-sceneless process the same
  // way it delivers a PushKit push - falling back to this lazily-booted
  // engine (running the *real* main(), unlike the old PushKit-report path,
  // since there's no tight deadline here and the real accept/decline HTTP
  // call needs the full DI/auth graph anyway) covers that gap.
  private func ensureEngineForActionRelay() {
    if callKitChannel == nil {
      _ = actionRelayEngine
    }
  }

  private func attachChannel(messenger: FlutterBinaryMessenger) {
    let channel = FlutterMethodChannel(name: Self.channelName, binaryMessenger: messenger)
    channel.setMethodCallHandler { [weak self] call, result in
      self?.handleMethodCall(call, result: result)
    }
    callKitChannel = channel
  }

  // `pendingEvents` is the single source of truth - relayEvent always
  // buffers there first, so nothing is ever lost to a race between an
  // engine merely existing and Dart's IosCallKitBridge actually having
  // called setMethodCallHandler on its end (native creating a channel
  // object doesn't imply Dart has registered a handler for it yet). The
  // "wake" ping is a pure best-effort hint telling an already-listening
  // Dart side to go drain the buffer now instead of waiting for its next
  // natural drain point; losing the ping loses nothing but immediacy -
  // IosCallKitBridge's constructor always drains once up front too, which
  // is what actually guarantees delivery for the cold-start case (the only
  // one where a race is realistically possible).
  private func relayEvent(_ payload: [String: Any]) {
    pendingEvents.append(payload)
    callKitChannel?.invokeMethod("wake", arguments: nil)
  }

  private func handleMethodCall(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "getVoipToken":
      result(voipToken)

    case "drainPendingEvents":
      result(pendingEvents)
      pendingEvents.removeAll()

    case "reportIncomingCall":
      guard let args = call.arguments as? [String: Any], let id = args["callId"] as? String else {
        result(FlutterError(code: "bad_args", message: "callId required", details: nil))
        return
      }
      reportIncomingCall(
        id: id,
        callerName: args["callerName"] as? String ?? "Unknown",
        completion: { error in
          result(error == nil)
        })

    case "setCallConnected":
      guard let args = call.arguments as? [String: Any], let id = args["callId"] as? String else {
        result(FlutterError(code: "bad_args", message: "callId required", details: nil))
        return
      }
      markCallConnected(id: id)
      result(nil)

    case "endCall":
      guard let args = call.arguments as? [String: Any], let id = args["callId"] as? String else {
        result(FlutterError(code: "bad_args", message: "callId required", details: nil))
        return
      }
      endReportedCall(id: id, reason: .remoteEnded)
      result(nil)

    default:
      result(FlutterMethodNotImplemented)
    }
  }

  // Deterministic string->UUID mapping (SHA256-derived) so native and Dart
  // never need to synchronize an id-generation scheme - the same callId
  // always yields the same UUID. callIdsByUUID is still needed for the
  // reverse direction once a CXAction only hands back a UUID.
  private func uuid(for callId: String) -> UUID {
    let digest = SHA256.hash(data: Data(callId.utf8))
    return NSUUID(uuidBytes: Array(digest.prefix(16))) as UUID
  }

  private func reportIncomingCall(id: String, callerName: String, completion: ((Error?) -> Void)? = nil) {
    let callUUID = uuid(for: id)
    callIdsByUUID[callUUID] = id
    let update = CXCallUpdate()
    update.remoteHandle = CXHandle(type: .generic, value: callerName)
    update.localizedCallerName = callerName
    update.hasVideo = false
    update.supportsHolding = false
    update.supportsGrouping = false
    update.supportsUngrouping = false
    update.supportsDTMF = false
    cxProvider.reportNewIncomingCall(with: callUUID, update: update) { error in
      completion?(error)
    }
  }

  private func endReportedCall(id: String, reason: CXCallEndedReason) {
    let callUUID = uuid(for: id)
    cxProvider.reportCall(with: callUUID, endedAt: Date(), reason: reason)
    callIdsByUUID.removeValue(forKey: callUUID)
    answeredCalls.remove(callUUID)
    selfInitiatedAnswers.remove(callUUID)
  }

  // Answering from Dart's own in-app UI (as opposed to the native
  // CallKit banner/lock-screen button) never performs a CXAnswerCallAction
  // on its own - nothing tells CallKit the call was picked up, so its
  // session stays "ringing" forever and iOS never grants the audio route,
  // leaving WebRTC signaling fully connected but silent in both directions.
  // Submitting the same action ourselves through CXCallController is what
  // actually triggers provider(_:didActivate:) below.
  private func markCallConnected(id: String) {
    let callUUID = uuid(for: id)
    selfInitiatedAnswers.insert(callUUID)
    let action = CXAnswerCallAction(call: callUUID)
    callController.request(CXTransaction(action: action)) { error in
      if let error {
        print("[AppDelegate] markCallConnected failed for \(id): \(error)")
      }
    }
  }

  // MARK: - PKPushRegistryDelegate

  func pushRegistry(
    _ registry: PKPushRegistry, didUpdate credentials: PKPushCredentials, for type: PKPushType
  ) {
    let token = credentials.token.map { String(format: "%02x", $0) }.joined()
    voipToken = token
    relayEvent(["type": "voipTokenUpdated", "token": token])
  }

  func pushRegistry(_ registry: PKPushRegistry, didInvalidatePushTokenFor type: PKPushType) {
    voipToken = nil
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
    //
    // We still have to report a NEW call here, even though we're
    // immediately ending it: PushKit requires every VoIP push to result in
    // an actual reportNewIncomingCall before completion(), with no
    // exceptions (Apple enforces this with -[PKPushRegistry
    // _terminateAppIfThereAreUnhandledVoIPPushes], which kills the
    // process) - reportCall(endedAt:) alone doesn't satisfy that, it only
    // updates a call CallKit already knows about.
    if payload.dictionaryPayload["type"] as? String == "end" {
      reportIncomingCall(id: id, callerName: "") { [weak self] _ in
        self?.endReportedCall(id: id, reason: .remoteEnded)
        completion()
      }
      return
    }

    let callerName = payload.dictionaryPayload["callerName"] as? String ?? "Unknown"
    let conversationId = payload.dictionaryPayload["conversationId"] as? String ?? ""
    reportIncomingCall(id: id, callerName: callerName) { [weak self] _ in
      self?.relayEvent([
        "type": "reported", "callId": id, "conversationId": conversationId,
      ])
      completion()
    }
  }

  // MARK: - CXProviderDelegate
  //
  // These fulfill the CXAction promptly, per Apple's requirement, then relay
  // to Dart over the custom channel (ensureEngineForActionRelay covers the
  // case where nothing is running yet). The actual accept/decline/end REST
  // calls happen in Dart (CallKitService, listening for these events) -
  // mirrors the previous plugin-mediated flow, just without the plugin.

  func provider(_ provider: CXProvider, perform action: CXAnswerCallAction) {
    let wasSelfInitiated = selfInitiatedAnswers.remove(action.callUUID) != nil
    answeredCalls.insert(action.callUUID)
    action.fulfill()
    guard !wasSelfInitiated, let id = callIdsByUUID[action.callUUID] else { return }
    ensureEngineForActionRelay()
    relayEvent(["type": "accept", "callId": id])
  }

  func provider(_ provider: CXProvider, perform action: CXEndCallAction) {
    let wasAnswered = answeredCalls.remove(action.callUUID) != nil
    action.fulfill()
    guard let id = callIdsByUUID[action.callUUID] else { return }
    ensureEngineForActionRelay()
    relayEvent(["type": wasAnswered ? "end" : "decline", "callId": id])
  }

  func provider(_ provider: CXProvider, timedOutPerforming action: CXAction) {
    action.fulfill()
  }

  func providerDidReset() {
    callIdsByUUID.removeAll()
    answeredCalls.removeAll()
    selfInitiatedAnswers.removeAll()
  }

  // WebRTC (flutter_webrtc) manages its own RTCAudioSession independently of
  // CallKit, but per Apple's rules only CallKit may activate/deactivate the
  // shared AVAudioSession during a self-managed call — WebRTC calling
  // setActive itself outside this window is a no-op against a session it
  // doesn't actually own. These callbacks are the handoff: they tell
  // RTCAudioSession the OS just granted (or revoked) the audio route, which
  // is what actually starts the audio unit doing mic capture/speaker output.
  // Without this, signaling completes and the call looks connected, but no
  // audio flows in either direction — see venta_mobile's silent-call report.
  func provider(_ provider: CXProvider, didActivate audioSession: AVAudioSession) {
    RTCAudioSession.sharedInstance().audioSessionDidActivate(audioSession)
  }

  func provider(_ provider: CXProvider, didDeactivate audioSession: AVAudioSession) {
    RTCAudioSession.sharedInstance().audioSessionDidDeactivate(audioSession)
  }
}
