import 'dart:async';

import 'package:get_it/get_it.dart';

import '../../features/auth/data/account_repository.dart';
import '../../features/auth/data/auth_api.dart';
import '../../features/auth/data/auth_repository.dart';
import '../../features/auth/data/identity_api.dart';
import '../../features/conversations/data/conversation_api.dart';
import '../../features/conversations/data/conversation_repository.dart';
import '../../features/friends/data/relationship_api.dart';
import '../../features/friends/data/relationship_repository.dart';
import '../../features/guild_voice/bloc/guild_voice_cubit.dart';
import '../../features/guild_voice/data/guild_voice_api.dart';
import '../../features/guild_voice/data/guild_voice_repository.dart';
import '../../features/guild_voice/webrtc/guild_voice_webrtc_service.dart';
import '../../features/guilds/data/guild_api.dart';
import '../../features/guilds/data/guild_repository.dart';
import '../../features/household/data/household_api.dart';
import '../../features/household/data/household_repository.dart';
import '../../features/messaging/data/bot_command_api.dart';
import '../../features/messaging/data/message_api.dart';
import '../../features/mls/data/mls_api.dart';
import '../../features/profile/data/profile_api.dart';
import '../../features/profile/data/profile_repository.dart';
import '../../features/voice/bloc/call_cubit.dart';
import '../../features/voice/data/voice_api.dart';
import '../../features/voice/data/voice_repository.dart';
import '../../features/voice/webrtc/call_webrtc_service.dart';
import '../../features/wiki/data/wiki_api.dart';
import '../../features/wiki/data/wiki_repository.dart';
import '../crypto/account_encryption_service.dart';
import '../crypto/account_identity_service.dart';
import '../crypto/master_key_api.dart';
import '../crypto/master_key_service.dart';
import '../device/device_api.dart';
import '../device/device_id_service.dart';
import '../device/device_registration_service.dart';
import '../mls/channel_encryption_service.dart';
import '../mls/conversation_encryption_service.dart';
import '../mls/conversation_member_service.dart';
import '../mls/device_admission_service.dart';
import '../mls/leaf_verification_service.dart';
import '../mls/mls_backup_api.dart';
import '../mls/mls_backup_service.dart';
import '../mls/mls_failure_log.dart';
import '../mls/mls_join_request_service.dart';
import '../mls/mls_policy_service.dart';
import '../mls/mls_realtime_bridge.dart';
import '../mls/mls_service.dart';
import '../mls/mls_session_manager.dart';
import '../mls/mls_store.dart';
import '../mls/mls_sync_service.dart';
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
  getIt.registerLazySingleton<AuthApi>(() => AuthApi());
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepository(
      api: getIt(),
      secureStorage: getIt(),
      deviceIdService: getIt(),
    ),
  );
  getIt.registerLazySingleton<ApiClient>(
    () => ApiClient(
      authRepository: getIt(),
      deviceId: () => getIt<DeviceIdService>().deviceIdOrNull,
      // Resolved lazily on purpose: the registration service is built on top
      // of this very client, so taking it eagerly here would deadlock get_it.
      registerDevice: () => getIt<DeviceRegistrationService>().register(),
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
  getIt.registerLazySingleton<MasterKeyApi>(() => MasterKeyApi(client: getIt()));
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
  getIt.registerLazySingleton<HouseholdApi>(
    () => HouseholdApi(client: getIt()),
  );
  getIt.registerLazySingleton<HouseholdRepository>(
    () => HouseholdRepository(realtimeService: getIt()),
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
    () => GuildVoiceApi(client: getIt()),
  );
  getIt.registerLazySingleton<GuildVoiceRepository>(
    () => GuildVoiceRepository(
      api: getIt(),
      realtimeService: getIt(),
      deviceIdService: getIt(),
    ),
  );
  getIt.registerLazySingleton<GuildVoiceCubit>(
    () => GuildVoiceCubit(
      repository: getIt(),
      authRepository: getIt(),
      soundService: getIt(),
      webRtcServiceFactory: () => GuildVoiceWebRtcService(api: getIt()),
    ),
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
  // Device registration is per account, not per install: the id this handset
  // registered for the previous user means nothing to the next one, and every
  // call/voice action would be rejected until it registers again.
  getIt<DeviceRegistrationService>().reset();
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
  await getIt<MlsSessionManager>().prepareIdentity();
  await getIt<DeviceRegistrationService>().ensureRegistered();
  await getIt<PushNotificationService>().start();
  await getIt<CallKitService>().start();
  getIt<MlsRealtimeBridge>().start();
  // Detached, and after registration: publishing a certificate needs the device
  // row to exist, and none of it is worth holding a launch on. Failure here is
  // logged and leaves the account exactly as it was.
  unawaited(getIt<AccountEncryptionService>().establish(password: password));
  unawaited(getIt<MlsSessionManager>().sync());
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
