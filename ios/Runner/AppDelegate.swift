import AVFAudio
import CallKit
import CryptoKit
import Flutter
import PushKit
import UIKit
import WebRTC

// PushKit/CallKit wiring for native incoming-call UI - see
// docs/native-call-push-backend-spec.md for the payload this expects from
// the backend's VoIP push, and CallKitService (Dart) for the other half.
//
// Owns a CXProvider directly rather than going through a third-party plugin
// (flutter_callkit_incoming, still used on Android). Reporting a call to
// CallKit now has zero dependency on a Flutter engine, plugin registrar, or
// any Dart code existing yet - PushKit's report-the-call deadline is strict
// enough (miss it and the OS SIGKILLs the process with FRONTBOARD
// 0xbaadca11, then stops delivering future VoIP pushes) that routing it
// through anything requiring an engine boot is fragile by construction; see
// the venta_mobile "native call screen crashes on iOS" investigation.
//
// Relaying a user action (answer/decline/end) back to Dart has no such
// deadline, so that path is allowed to lazily boot a real Flutter engine if
// nothing is running yet - see `ensureEngineForActionRelay`.
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
  // Same idea for ends: when Dart's own in-app "hang up" drives a
  // CXEndCallAction (see `requestEndCall`), the delegate must not echo that end
  // back to Dart, which already tore its call state down.
  private var selfInitiatedEnds: Set<UUID> = []

  // Must be held for the whole app lifetime: PushKit stops delivering the token
  // update and, crucially, incoming VoIP pushes the moment the registry is
  // deallocated. As a local in didFinishLaunchingWithOptions it died the
  // instant that method returned, so a killed app relaunched by a VoIP push had
  // no live registry to hand the push to - the call never arrived.
  private var voipRegistry: PKPushRegistry?
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
    self.voipRegistry = voipRegistry

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
      requestEndCall(id: id)
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
    configureAudioSession()
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

  // Out-of-band end: the call ended for a reason outside the user's action on
  // this device (remote hang-up, answered/declined elsewhere). reportCall(
  // endedAt:) is exactly the right tool for that and removes the CallKit call.
  private func endReportedCall(id: String, reason: CXCallEndedReason) {
    let callUUID = uuid(for: id)
    cxProvider.reportCall(with: callUUID, endedAt: Date(), reason: reason)
    callIdsByUUID.removeValue(forKey: callUUID)
    answeredCalls.remove(callUUID)
    selfInitiatedAnswers.remove(callUUID)
    selfInitiatedEnds.remove(callUUID)
    endManualCallAudio()
  }

  // User-initiated end from the app's own in-call UI. Unlike the remote case
  // above, this must go through a CXEndCallAction transaction - that's what
  // lets CallKit own the teardown: it ends the call *and* deactivates the audio
  // session (firing provider(_:didDeactivate:)), clearing the "call in
  // progress" state. reportCall(endedAt:) leaves a self-activated session (see
  // configureAudioSession) live, so the system keeps showing an active call.
  // Marked self-initiated so the CXEndCallAction delegate doesn't echo the end
  // back to Dart, which already tore its own state down. Falls back to the
  // out-of-band end if CallKit rejects the transaction, so the UI can't wedge.
  private func requestEndCall(id: String) {
    let callUUID = uuid(for: id)
    guard callIdsByUUID[callUUID] != nil else { return }
    selfInitiatedEnds.insert(callUUID)
    let action = CXEndCallAction(call: callUUID)
    callController.request(CXTransaction(action: action)) { [weak self] error in
      guard let error else { return }
      print("[AppDelegate] requestEndCall failed for \(id): \(error)")
      DispatchQueue.main.async {
        self?.selfInitiatedEnds.remove(callUUID)
        self?.endReportedCall(id: id, reason: .remoteEnded)
      }
    }
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

  // Put the shared AVAudioSession into a call-capable category *before* CallKit
  // tries to activate it. When the user answers, CallKit activates the app's
  // audio session synchronously; if it's still in the default (solo-ambient)
  // category - which can't record - that activation fails and iOS immediately
  // tears the call down showing "Call Failed" on the native screen. WebRTC only
  // switches the category to playAndRecord much later, when it opens the mic
  // during connect, which is far too late. We set only the category/mode, never
  // activate: CallKit owns activation (provider(_:didActivate:)). Setting a
  // category on an inactive session has no audible side effect (no ducking/route
  // change until activation), so it's safe both while ringing and at answer.
  private func configureAudioSession() {
    do {
      try AVAudioSession.sharedInstance().setCategory(
        .playAndRecord,
        mode: .voiceChat,
        options: [.allowBluetooth, .allowBluetoothA2DP, .allowAirPlay])
    } catch {
      print("[AppDelegate] configureAudioSession failed: \(error)")
    }
  }

  // The core of getting two-way audio right under CallKit. By default WebRTC
  // (flutter_webrtc) runs RTCAudioSession in *automatic* mode: it brings its
  // audio unit up the instant an audio track is ready, activating the session
  // itself. Under CallKit that's the wrong owner - CallKit, not WebRTC, decides
  // when the session goes live - and the mismatch produced every symptom we
  // saw: mic dead on the first call (WebRTC opened the unit before CallKit had
  // the session, so the record bus never armed), "Call Failed" answering from
  // the background (WebRTC racing CallKit for activation), and it only "working
  // the second time" because leftover session state happened to line up.
  //
  // Manual mode removes the race entirely: WebRTC won't touch the audio unit on
  // its own; it starts/stops strictly when we flip isAudioEnabled. We enable
  // manual mode at answer (isAudioEnabled=false), then let CallKit's
  // didActivate/didDeactivate be the single source of truth for when audio may
  // run. The ordering between Dart's getUserMedia and CallKit's activation no
  // longer matters: whichever happens second, the unit starts once a track
  // exists AND isAudioEnabled is true. Scoped to CallKit-answered calls and
  // fully torn down on end, so outgoing calls and guild voice keep WebRTC's
  // default automatic behavior.
  private func beginManualCallAudio() {
    let rtc = RTCAudioSession.sharedInstance()
    // Capture activation state *before* taking over: on a native CallKit answer
    // the session isn't active yet (Dart hasn't reached getUserMedia), so audio
    // stays off until didActivate. But when Dart answered from the app's own UI,
    // WebRTC already activated the session during connect and CallKit may not
    // re-fire didActivate - seed from the current state so audio isn't stranded.
    let wasActive = rtc.isActive
    rtc.useManualAudio = true
    rtc.isAudioEnabled = wasActive
  }

  private func endManualCallAudio() {
    let rtc = RTCAudioSession.sharedInstance()
    rtc.isAudioEnabled = false
    rtc.useManualAudio = false
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
  // callback, every time, with no exceptions - an app that doesn't gets
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

    // "end" cancels a ring already shown on this device - sent when the call
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
    // Set the call category so CallKit's activation succeeds, and hand audio
    // control to CallKit (manual mode) so WebRTC can't race it - this is what
    // fixes background "Call Failed" and first-call one-way audio. Both must be
    // in place before fulfilling, since CallKit activates right after.
    configureAudioSession()
    beginManualCallAudio()
    let wasSelfInitiated = selfInitiatedAnswers.remove(action.callUUID) != nil
    answeredCalls.insert(action.callUUID)
    action.fulfill()
    guard !wasSelfInitiated, let id = callIdsByUUID[action.callUUID] else { return }
    ensureEngineForActionRelay()
    relayEvent(["type": "accept", "callId": id])
  }

  func provider(_ provider: CXProvider, perform action: CXEndCallAction) {
    let wasSelfInitiated = selfInitiatedEnds.remove(action.callUUID) != nil
    let wasAnswered = answeredCalls.remove(action.callUUID) != nil
    action.fulfill()
    let id = callIdsByUUID.removeValue(forKey: action.callUUID)
    selfInitiatedAnswers.remove(action.callUUID)
    endManualCallAudio()
    // Dart's own hang-up drove this end (requestEndCall) - it already tore its
    // call state down, so don't relay it back. The map cleanup above also makes
    // the redundant iosBridge.endCall that follows a *native* end a no-op.
    guard !wasSelfInitiated, let id else { return }
    ensureEngineForActionRelay()
    relayEvent(["type": wasAnswered ? "end" : "decline", "callId": id])
  }

  func provider(_ provider: CXProvider, timedOutPerforming action: CXAction) {
    action.fulfill()
  }

  func providerDidReset(_ provider: CXProvider) {
    callIdsByUUID.removeAll()
    answeredCalls.removeAll()
    selfInitiatedAnswers.removeAll()
    selfInitiatedEnds.removeAll()
    endManualCallAudio()
  }

  // CallKit is the single source of truth for when audio may run (see
  // beginManualCallAudio). didActivate = the OS granted the route: tell
  // RTCAudioSession, then flip isAudioEnabled on to let WebRTC start its unit
  // (mic + speaker). didDeactivate = the route was revoked (call end, or an
  // interruption): flip audio off first, then inform RTCAudioSession. In manual
  // mode this pair alone drives two-way audio, with no ordering dependency on
  // when Dart's getUserMedia runs.
  func provider(_ provider: CXProvider, didActivate audioSession: AVAudioSession) {
    let rtc = RTCAudioSession.sharedInstance()
    rtc.audioSessionDidActivate(audioSession)
    rtc.isAudioEnabled = true
  }

  func provider(_ provider: CXProvider, didDeactivate audioSession: AVAudioSession) {
    let rtc = RTCAudioSession.sharedInstance()
    rtc.isAudioEnabled = false
    rtc.audioSessionDidDeactivate(audioSession)
  }
}
