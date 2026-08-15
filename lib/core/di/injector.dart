import 'dart:async';

import 'package:get_it/get_it.dart';

import '../../features/auth/data/account_repository.dart';
import '../../features/auth/data/auth_api.dart';
import '../../features/auth/data/auth_repository.dart';
import '../../features/auth/data/identity_api.dart';
import '../../features/billing/data/billing_api.dart';
import '../../features/billing/data/degradation_log.dart';
import '../../features/billing/data/entitlement_api.dart';
import '../../features/billing/data/plan_repository.dart';
import '../../features/conversations/data/conversation_api.dart';
import '../../features/conversations/data/conversation_repository.dart';
import '../../features/friends/data/relationship_api.dart';
import '../../features/friends/data/relationship_repository.dart';
import '../../features/guild_voice/bloc/guild_voice_activity_cubit.dart';
import '../../features/guild_voice/bloc/guild_voice_cubit.dart';
import '../../features/guild_voice/data/guild_voice_api.dart';
import '../../features/guild_voice/data/guild_voice_repository.dart';
import '../../features/guild_voice/webrtc/guild_voice_webrtc_service.dart';
import '../../features/guilds/data/guild_api.dart';
import '../../features/guilds/data/guild_repository.dart';
import '../../features/household/data/household_api.dart';
import '../../features/household/data/household_repository.dart';
import '../../features/inbox/data/inbox_api.dart';
import '../../features/inbox/data/inbox_repository.dart';
import '../../features/messaging/data/bot_command_api.dart';
import '../../features/messaging/data/message_api.dart';
import '../../features/mls/data/mls_api.dart';
import '../../features/privacy/data/privacy_api.dart';
import '../../features/privacy/data/privacy_repository.dart';
import '../../features/profile/data/profile_api.dart';
import '../../features/support/data/support_api.dart';
import '../../features/support/data/support_repository.dart';
import '../../features/profile/data/profile_repository.dart';
import '../../features/status/data/status_api.dart';
import '../../features/status/data/status_repository.dart';
import '../../features/voice/bloc/call_cubit.dart';
import '../../features/voice/data/voice_api.dart';
import '../../features/voice/data/voice_repository.dart';
import '../../features/voice/webrtc/call_webrtc_service.dart';
import '../../features/wiki/data/wiki_api.dart';
import '../../features/wiki/data/wiki_repository.dart';
import '../ai/ai_key_store.dart';
import '../ai/vision_client.dart';
import '../crypto/account_encryption_service.dart';
import '../crypto/account_identity_service.dart';
import '../crypto/master_key_api.dart';
import '../crypto/master_key_service.dart';
import '../device/device_api.dart';
import '../device/device_id_service.dart';
import '../device/device_registration_service.dart';
import '../diagnostics/telemetry_consent.dart';
import '../mls/channel_encryption_service.dart';
import '../mls/conversation_encryption_service.dart';
import '../mls/conversation_member_service.dart';
import '../mls/device_admission_service.dart';
import '../mls/leaf_verification_service.dart';
import '../mls/mls_backup_api.dart';
import '../mls/mls_backup_service.dart';
import '../mls/mls_coverage_service.dart';
import '../mls/mls_failure_log.dart';
import '../mls/mls_join_request_service.dart';
import '../mls/mls_policy_service.dart';
import '../mls/mls_realtime_bridge.dart';
import '../mls/mls_service.dart';
import '../mls/mls_session_manager.dart';
import '../mls/mls_store.dart';
import '../mls/mls_sync_service.dart';
import '../locale/locale_cubit.dart';
import '../mls/protection_level_service.dart';
import '../network/api_client.dart';
import '../push/call_kit_service.dart';
import '../push/push_notification_service.dart';
import '../push/push_token_api.dart';
import '../realtime/realtime_service.dart';
import '../realtime/realtime_transport.dart';
import '../realtime/signalr_netcore_transport.dart';
import '../sound/sound_service.dart';
import '../storage/secure_storage_service.dart';

final getIt = GetIt.instance;

/// Registers app-lifetime singletons. Called once from `main()` before
/// `runApp`. Repositories/services are registered here as they're built;
/// blocs stay owned by the widget tree and pull their dependencies from
/// [getIt] inside `BlocProvider`'s `create:`.
Future<void> configureDependencies({String appVersion = 'unknown'}) async {
  getIt.registerLazySingleton<SecureStorageService>(
    () => SecureStorageService(),
  );
  // Shared, so the decryptor, the sync service and the banner all read one
  // answer to "can this device read this context". A `MlsFailureLog.shared`
  // rather than a fresh instance because the FCM background isolate reaches the
  // same code with no container to resolve from.
  getIt.registerLazySingleton<MlsFailureLog>(() => MlsFailureLog.shared);
  getIt.registerLazySingleton<DeviceIdService>(
    () => DeviceIdService(secureStorage: getIt()),
  );
  // Resolved in `main()` before Sentry starts - it decides what identifier a
  // crash report carries, and there is no useful moment to decide that later.
  getIt.registerLazySingleton<TelemetryConsent>(
    () => TelemetryConsent(secureStorage: getIt()),
  );
  getIt.registerLazySingleton<AuthApi>(() => AuthApi());
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepository(
      api: getIt(),
      secureStorage: getIt(),
      deviceIdService: getIt(),
    ),
  );
  // The one bloc registered here rather than owned by the widget tree, and it
  // is registered because something outside the widget tree needs it: the
  // `Accept-Language` header on every request. An interceptor has no
  // `BuildContext`, so the choice has to be reachable without one - and it must
  // be the *same* instance the settings screen writes to, or the header would
  // keep answering with a second cubit's default forever. `App` provides it
  // with `BlocProvider.value` for that reason, exactly as it does `CallCubit`.
  //
  // Not in `resetSessionScopedCaches`: the language belongs to the handset, not
  // to the account. Somebody who set this to Italian and then switched accounts
  // did not thereby ask to read German again.
  getIt.registerLazySingleton<LocaleCubit>(() => LocaleCubit());
  // Registered before `ApiClient`, which takes it directly: it holds a list and
  // depends on nothing, so there is no cycle to break with a callback.
  //
  // In `resetSessionScopedCaches`: a reduction belongs to whoever made the
  // request, and carrying one across a sign-in would tell the next person about
  // somebody else's plan.
  getIt.registerLazySingleton<DegradationLog>(() => DegradationLog());
  getIt.registerLazySingleton<ApiClient>(
    () => ApiClient(
      authRepository: getIt(),
      // Every enforcement site in the API reports a reduction the same way -
      // as a `degradations` array on the 200 it was reduced on - so this is
      // collected once here rather than at each call site that could ever be
      // reduced. See `DegradationInterceptor`.
      degradations: getIt<DegradationLog>(),
      // Read per request, not captured: this client is built once at startup
      // and lives as long as the app, so a value taken here would pin the
      // header to the language in force at launch.
      language: () => getIt<LocaleCubit>().state,
      deviceId: () => getIt<DeviceIdService>().deviceIdOrNull,
      // Resolved lazily on purpose: the registration service is built on top
      // of this very client, so taking it eagerly here would deadlock get_it.
      registerDevice: () => getIt<DeviceRegistrationService>().register(),
      // Lazily for the same reason, and one step further: `StatusRepository`
      // reaches `RealtimeService`, which is registered further down this
      // function. It is also self-throttling, so an outage failing fifty
      // requests at once still costs one status check.
      onUnreachable: () => getIt<StatusRepository>().probeAfterFailure(),
    ),
  );
  getIt.registerLazySingleton<DeviceApi>(() => DeviceApi(client: getIt()));
  getIt.registerLazySingleton<DeviceRegistrationService>(
    () => DeviceRegistrationService(
      api: getIt(),
      deviceIdService: getIt(),
      mls: getIt(),
    ),
  );
  getIt.registerLazySingleton<IdentityApi>(() => IdentityApi(client: getIt()));
  getIt.registerLazySingleton<AccountRepository>(
    () => AccountRepository(api: getIt()),
  );
  getIt.registerLazySingleton<RealtimeTransport>(
    () => SignalrNetcoreTransport(),
  );
  getIt.registerLazySingleton<RealtimeService>(
    () => RealtimeService(
      transport: getIt(),
      authRepository: getIt(),
      deviceIdService: getIt(),
    ),
  );
  // Anonymous by construction - `StatusApi` builds its own bare `Dio` rather
  // than taking `ApiClient`, so a status check never waits on a token. See the
  // class for why that matters on the exact launch where it is needed.
  getIt.registerLazySingleton<StatusApi>(
    () => StatusApi(authRepository: getIt()),
  );
  // Not in `resetSessionScopedCaches`: platform status belongs to the instance,
  // not to the account, and it is the one thing that must keep working across a
  // sign-out - especially a sign-out the incident caused.
  getIt.registerLazySingleton<StatusRepository>(
    () => StatusRepository(
      api: getIt(),
      authRepository: getIt(),
      realtimeService: getIt(),
    ),
  );
  getIt.registerLazySingleton<PrivacyApi>(() => PrivacyApi(client: getIt()));
  getIt.registerLazySingleton<PrivacyRepository>(
    () => PrivacyRepository(api: getIt()),
  );
  getIt.registerLazySingleton<SupportApi>(() => SupportApi(client: getIt()));
  // Not in `resetSessionScopedCaches` - it holds nothing. Reports are read
  // through on every open and the support URL is derived from
  // `AuthRepository.baseUrl` at call time, so there is no per-account state
  // here to carry into the next session.
  getIt.registerLazySingleton<SupportRepository>(
    () => SupportRepository(api: getIt(), authRepository: getIt()),
  );
  getIt.registerLazySingleton<ProfileApi>(() => ProfileApi(client: getIt()));
  getIt.registerLazySingleton<ProfileRepository>(
    () => ProfileRepository(
      api: getIt(),
      authRepository: getIt(),
      realtimeService: getIt(),
    ),
  );
  getIt.registerLazySingleton<RelationshipApi>(
    () => RelationshipApi(client: getIt()),
  );
  getIt.registerLazySingleton<RelationshipRepository>(
    () => RelationshipRepository(api: getIt(), realtimeService: getIt()),
  );
  getIt.registerLazySingleton<ConversationApi>(
    () => ConversationApi(client: getIt()),
  );
  getIt.registerLazySingleton<ConversationRepository>(
    () => ConversationRepository(
      api: getIt(),
      mlsSync: getIt(),
      realtimeService: getIt(),
    ),
  );
  getIt.registerLazySingleton<MessageApi>(() => MessageApi(client: getIt()));
  getIt.registerLazySingleton<MlsApi>(() => MlsApi(client: getIt()));
  getIt.registerLazySingleton<MlsStore>(() => MlsStore());
  getIt.registerLazySingleton<MlsService>(
    () => MlsService(
      store: getIt(),
      secureStorage: getIt(),
      deviceIdService: getIt(),
    ),
  );
  getIt.registerLazySingleton<MlsSyncService>(
    () => MlsSyncService(mls: getIt(), api: getIt(), deviceIdService: getIt()),
  );
  getIt.registerLazySingleton<MlsCoverageService>(
    () => MlsCoverageService(
      api: getIt(),
      mls: getIt(),
      // Subscribed here rather than at every call site, so a Welcome landing or
      // a commit going out drops the cached answer for all of them - including
      // the notice that has to come down the moment this device gets in.
      contextChanged: getIt<MlsSyncService>().contextChanged,
    ),
  );
  getIt.registerLazySingleton<MlsSessionManager>(
    () => MlsSessionManager(
      mls: getIt(),
      sync_: getIt(),
      deviceApi: getIt(),
      deviceIdService: getIt(),
      authRepository: getIt(),
      secureStorage: getIt(),
      joinRequests: getIt(),
      conversations: getIt(),
    ),
  );
  getIt.registerLazySingleton<MlsRealtimeBridge>(
    () => MlsRealtimeBridge(
      realtimeService: getIt(),
      mls: getIt(),
      sync: getIt(),
      api: getIt(),
      admission: getIt(),
      authRepository: getIt(),
    ),
  );
  getIt.registerLazySingleton<ConversationEncryptionService>(
    () => ConversationEncryptionService(
      mls: getIt(),
      api: getIt(),
      conversationApi: getIt(),
      deviceIdService: getIt(),
    ),
  );
  getIt.registerLazySingleton<ConversationMemberService>(
    () => ConversationMemberService(api: getIt(), mls: getIt(), sync: getIt()),
  );
  getIt.registerLazySingleton<MlsJoinRequestService>(
    () => MlsJoinRequestService(
      mls: getIt(),
      sync: getIt(),
      api: getIt(),
      deviceIdService: getIt(),
    ),
  );

  // Contract §C/§G/§H. The master key is the root of all three: it authorises a
  // new device of yours (§G), wraps the account identity key that lets peers
  // verify a device with none of yours online (§H), and seals the backup
  // envelope (§C).
  getIt.registerLazySingleton<MasterKeyApi>(
    () => MasterKeyApi(client: getIt()),
  );
  getIt.registerLazySingleton<MasterKeyService>(
    () => MasterKeyService(api: getIt(), secureStorage: getIt()),
  );
  getIt.registerLazySingleton<AccountIdentityService>(
    () => AccountIdentityService(
      api: getIt(),
      masterKeys: getIt(),
      secureStorage: getIt(),
    ),
  );
  // The production caller for all of the above. Without it the master key, the
  // account identity key and this device's certificate are all code nothing ever
  // runs - which is the state §G/§H were in, and why certificate coverage was
  // zero and `certificateEnforcement` could never leave `Observe`.
  getIt.registerLazySingleton<AccountEncryptionService>(
    () => AccountEncryptionService(
      masterKeys: getIt(),
      identity: getIt(),
      mls: getIt(),
      deviceApi: getIt(),
      deviceIdService: getIt(),
      authRepository: getIt(),
      secureStorage: getIt(),
    ),
  );
  getIt.registerLazySingleton<MlsPolicyService>(
    () => MlsPolicyService(client: getIt()),
  );
  getIt.registerLazySingleton<LeafVerificationService>(
    () => LeafVerificationService(
      identity: getIt(),
      deviceApi: getIt(),
      policy: getIt(),
    ),
  );
  getIt.registerLazySingleton<ProtectionLevelService>(
    () => ProtectionLevelService(
      client: getIt(),
      identity: getIt(),
      masterKeyApi: getIt(),
      masterKeys: getIt(),
      secureStorage: getIt(),
    ),
  );
  getIt.registerLazySingleton<DeviceAdmissionService>(
    () => DeviceAdmissionService(
      api: getIt(),
      mls: getIt(),
      joinRequests: getIt(),
      masterKeys: getIt(),
      protectionLevels: getIt(),
      deviceIdService: getIt(),
    ),
  );
  getIt.registerLazySingleton<MlsBackupApi>(
    () => MlsBackupApi(client: getIt()),
  );
  getIt.registerLazySingleton<MlsBackupService>(
    () => MlsBackupService(
      mls: getIt(),
      api: getIt(),
      mlsApi: getIt(),
      identity: getIt(),
      secureStorage: getIt(),
      deviceIdService: getIt(),
      appVersion: appVersion,
    ),
  );
  getIt.registerLazySingleton<ChannelEncryptionService>(
    () => ChannelEncryptionService(
      mls: getIt(),
      sync: getIt(),
      api: getIt(),
      deviceIdService: getIt(),
    ),
  );
  getIt.registerLazySingleton<BotCommandApi>(
    () => BotCommandApi(client: getIt()),
  );
  getIt.registerLazySingleton<GuildApi>(() => GuildApi(client: getIt()));
  getIt.registerLazySingleton<GuildRepository>(
    () => GuildRepository(
      api: getIt(),
      authRepository: getIt(),
      realtimeService: getIt(),
    ),
  );
  // The read-only plan surface. There is no billing *write* client anywhere in
  // this app and there must not be one: this platform describes the plan an
  // account is on and the plans that exist, and says nothing about whether or
  // where any of them could be obtained.
  //
  // `PlanRepository` is not in `resetSessionScopedCaches`. The only state it
  // holds is `available`, which answers "does this instance publish a plan
  // catalogue" - a property of the deployment, not of whoever is signed in.
  getIt.registerLazySingleton<BillingApi>(() => BillingApi(client: getIt()));
  getIt.registerLazySingleton<EntitlementApi>(
    () => EntitlementApi(client: getIt()),
  );
  getIt.registerLazySingleton<PlanRepository>(
    () => PlanRepository(
      entitlements: getIt(),
      billing: getIt(),
      // Read from the guild list this app already holds rather than fetched: a
      // subscription names a server by id, and the only reason to resolve it is
      // to put a name on a row. A server the reader has since left resolves to
      // null and gets the generic description.
      guildName: (guildId) =>
          getIt<GuildRepository>().cachedById(guildId)?.name,
    ),
  );
  getIt.registerLazySingleton<InboxApi>(() => InboxApi(client: getIt()));
  getIt.registerLazySingleton<InboxRepository>(
    () => InboxRepository(api: getIt(), realtimeService: getIt(), mls: getIt()),
  );
  getIt.registerLazySingleton<HouseholdApi>(
    () => HouseholdApi(client: getIt()),
  );
  getIt.registerLazySingleton<HouseholdRepository>(
    () => HouseholdRepository(api: getIt(), realtimeService: getIt()),
  );
  // Bring-your-own-key AI. Deliberately built on `SecureStorageService` and
  // nothing else: no `ApiClient`, no `AuthRepository`, no interceptors - the
  // whole privacy claim of pantry vision is that a photo and a key go straight
  // to the provider and never near `api.venta.gg`, and that claim is easiest to
  // keep true by giving this layer no way to reach it.
  //
  // Not in `resetSessionScopedCaches`: the key belongs to the person paying for
  // it and lives in the device keychain, and neither object caches anything a
  // second account could read. `AiKeyStore` reads through to secure storage on
  // every call.
  getIt.registerLazySingleton<AiKeyStore>(() => AiKeyStore(storage: getIt()));
  getIt.registerLazySingleton<PantryVisionClient>(
    () => PantryVisionClient(keys: getIt()),
  );
  getIt.registerLazySingleton<SoundService>(() => SoundService());
  getIt.registerLazySingleton<VoiceApi>(
    () => VoiceApi(client: getIt(), deviceIdService: getIt()),
  );
  getIt.registerLazySingleton<VoiceRepository>(
    () => VoiceRepository(api: getIt(), realtimeService: getIt()),
  );
  getIt.registerLazySingleton<CallCubit>(
    () => CallCubit(
      repository: getIt(),
      authRepository: getIt(),
      soundService: getIt(),
      webRtcServiceFactory: () => CallWebRtcService(api: getIt()),
    ),
  );
  getIt.registerLazySingleton<GuildVoiceApi>(
    () => GuildVoiceApi(client: getIt(), deviceIdService: getIt()),
  );
  getIt.registerLazySingleton<GuildVoiceRepository>(
    () => GuildVoiceRepository(api: getIt(), realtimeService: getIt()),
  );
  getIt.registerLazySingleton<GuildVoiceCubit>(
    () => GuildVoiceCubit(
      repository: getIt(),
      authRepository: getIt(),
      soundService: getIt(),
      webRtcServiceFactory: () => GuildVoiceWebRtcService(api: getIt()),
    ),
  );
  getIt.registerLazySingleton<GuildVoiceActivityCubit>(
    () => GuildVoiceActivityCubit(repository: getIt()),
  );
  getIt.registerLazySingleton<WikiApi>(() => WikiApi(client: getIt()));
  getIt.registerLazySingleton<WikiRepository>(
    () => WikiRepository(api: getIt(), realtimeService: getIt()),
  );
  getIt.registerLazySingleton<PushTokenApi>(
    () => PushTokenApi(client: getIt()),
  );
  getIt.registerLazySingleton<PushNotificationService>(
    () => PushNotificationService(
      api: getIt(),
      deviceIdService: getIt(),
      mlsStore: getIt(),
    ),
  );
  getIt.registerLazySingleton<CallKitService>(
    () => CallKitService(
      callCubit: getIt(),
      authRepository: getIt(),
      profileRepository: getIt(),
      pushTokenApi: getIt(),
      secureStorage: getIt(),
      deviceIdService: getIt(),
    ),
  );
}

/// Wipes every app-lifetime cache that belongs to one signed-in account.
///
/// These repositories are lazy singletons, so they outlive the session that
/// filled them: without this, signing in as someone else keeps the previous
/// account's profile (which is what the user banner renders), DM list,
/// friends and guilds in memory, and the cache-first readers in front of them
/// never refetch. Call on sign-in as well as sign-out - an expired session
/// followed by a fresh login never passes through an explicit logout.
///
/// Resolving each one constructs it if it hasn't been already; that's cheap
/// and they all get built the moment any authenticated screen mounts anyway.
void resetSessionScopedCaches() {
  getIt<ProfileRepository>().clear();
  getIt<ConversationRepository>().clear();
  getIt<RelationshipRepository>().clear();
  getIt<GuildRepository>().clear();
  // The badge is drawn from a cached summary and sits in the app bar of the
  // first screen the next account sees - carrying the previous one's count
  // over is the most visible possible stale-cache bug.
  getIt<InboxRepository>().clear();
  // The home digest is per user, not per house - "your turn" and "the house
  // owes you 24 CHF" are answers about the account that asked. The card would
  // otherwise open the next session showing the previous member's position.
  getIt<HouseholdRepository>().clear();
  // The privacy record belongs to one account and gates what this device emits
  // on behalf of it. Carrying the previous account's copy over would have this
  // handset applying a stranger's answer to "may I send a typing indicator".
  getIt<PrivacyRepository>().clear();
  // Voice occupancy is per guild *membership*: the next account is in a
  // different set of servers, and a rail badge left over from the previous one
  // would sit on a server the new user cannot even see into.
  getIt<GuildVoiceActivityCubit>().clear();
  // Device registration is per account, not per install: the id this handset
  // registered for the previous user means nothing to the next one, and every
  // call/voice action would be rejected until it registers again.
  getIt<DeviceRegistrationService>().reset();
  // A reduction is a statement about one request made by one account. Left in
  // place, the plan screen would tell the next person to sign in on this
  // handset that their video was capped by somebody else's server plan.
  getIt<DegradationLog>().clear();
  // MLS is deliberately *not* reset here. It is per account too, and more
  // sharply so - an identity is credentialed to one user id - but this function
  // is synchronous and unloading group state is not, so doing it here would race
  // the `MlsSessionManager.prepareIdentity` that runs moments later on sign-in.
  // `MlsService.init` takes the user id and swaps state itself when it changes,
  // which is the same outcome without the race.
}

/// Registers this device and starts the push-notification and native-call-UI
/// services - call once per authenticated session (cold start with a restored
/// session, or right after login/register), mirroring [RealtimeService.start]'s
/// own call sites.
///
/// The MLS identity comes first and registration second, because the key the
/// former mints is what the latter publishes as this device's
/// `identityPublicKey` - see `MlsSessionManager` for the phase split.
///
/// Registration is awaited before the push services: the push tokens registered
/// just after are attached to that device row, and the `X-Device-Id` every call
/// and voice-join carries is only honoured once the device exists.
///
/// The MLS *sync* half runs detached. Uploading key packages and joining every
/// group this device was invited to while away can take several round-trips, and
/// none of the app's other screens need to wait on it.
///
/// [password] is present only on the paths that just collected one - sign-in,
/// registration, email verification. Contract §I.2 says the account identity key
/// "can only appear when an upgraded client next unlocks", and on this platform
/// that is literally true: the server gates publishing it, and writing the
/// recovery-key envelope, on the account password. A cold start with a restored
/// session passes null and does the subset that needs no credential - adopting a
/// master key and identity key already in the keychain, and refreshing this
/// device's certificate. It must never be a *required* parameter: the overwhelming
/// majority of launches have no password and must not be degraded by that.
Future<void> startAuthenticatedServices({String? password}) async {
  // First, and awaited: until it lands, crash reports for this session are
  // filed under the per-install pseudonym, which is the correct behaviour but
  // also the behaviour a consenting user did not ask for. It is one small GET,
  // and everything below it is slower.
  //
  // Detached from the failure path deliberately - `applyTelemetryConsent`
  // swallows, because a privacy endpoint that is down must not stop a login.
  await applyTelemetryConsent();
  await getIt<MlsSessionManager>().prepareIdentity();
  await getIt<DeviceRegistrationService>().ensureRegistered();
  await getIt<PushNotificationService>().start();
  await getIt<CallKitService>().start();
  // After CallKitService, so a ring found here reaches the native call UI too.
  // Detached: it is a network round-trip, and nothing else waits on the answer.
  //
  // Needed on top of CallCubit's own realtime-connect hook because the socket is
  // started before this function runs and connects while it is still awaiting
  // MLS and device registration - by the time the cubit exists to listen, the
  // `connected` event it would have caught up on is long gone. Which is exactly
  // the case this covers: the app opened while the phone was already ringing.
  unawaited(getIt<CallCubit>().catchUpOnPendingCall());
  // Detached for the same reason: the server rail's voice indicator is nice to
  // have promptly and worth holding nothing up for. Live updates take over from
  // the guild-wide presence events once this lands.
  unawaited(getIt<GuildVoiceActivityCubit>().load());
  getIt<MlsRealtimeBridge>().start();
  // Detached, and after registration: publishing a certificate needs the device
  // row to exist, and none of it is worth holding a launch on. Failure here is
  // logged and leaves the account exactly as it was.
  unawaited(getIt<AccountEncryptionService>().establish(password: password));
  unawaited(getIt<MlsSessionManager>().sync());
}

/// Reads the account's privacy record and tells [TelemetryConsent] what it
/// says, so crash reports carry a real user id only where consent exists.
///
/// Never throws. A failure here leaves reports pseudonymous, which is the
/// direction a failure must go: the alternative - assuming consent because the
/// consent endpoint was unreachable - is the one outcome that cannot be undone
/// after the fact.
///
/// Also called from the Privacy screen the moment the flag is toggled, so
/// consent takes effect on the next report rather than on the next launch.
Future<void> applyTelemetryConsent() async {
  try {
    final settings = await getIt<PrivacyRepository>().ensureLoaded();
    await getIt<TelemetryConsent>().apply(
      allowDataCollection: settings.allowDataCollection,
      userId: getIt<AuthRepository>().currentUserId,
    );
  } catch (_) {
    await getIt<TelemetryConsent>().apply(allowDataCollection: false);
  }
}

/// Undoes the push half of [startAuthenticatedServices] while the session is
/// still valid - both calls need a bearer token, so this has to run *before*
/// `AuthRepository.logout()` clears it.
///
/// The device registration itself deliberately survives: it names the
/// installation, and the next login on this handset should reuse it. "Forget
/// this device" is the explicit action that removes it
/// ([DeviceRegistrationService.forgetThisDevice]).
Future<void> stopAuthenticatedServices() async {
  // Back to the per-install pseudonym before the session goes. The next person
  // to use this handset must not have their crashes filed under the last one's
  // user id, and `resetSessionScopedCaches` clears the record this was read
  // from - so it has to happen here, not there.
  await getIt<TelemetryConsent>().signedOut();
  await getIt<PushNotificationService>().unregisterToken();
  await getIt<CallKitService>().unregisterVoipToken();
  await getIt<MlsRealtimeBridge>().stop();
  // The prompt belongs to one account. Leaving it raised would show the next
  // sign-in a recovery-code offer for somebody else's master key.
  getIt<AccountEncryptionService>().recoveryCodeOwed.value = false;
  // Locks the session, keeping the groups and the identity. Those belong to the
  // installation, and throwing them away on an ordinary sign-out would lock this
  // handset out of every group it is in - `MlsService.forgetEverything` is the
  // deliberate version, wired to "forget this device".
  await getIt<MlsSessionManager>().stop();
}
