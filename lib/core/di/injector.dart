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
import '../../features/profile/data/profile_api.dart';
import '../../features/profile/data/profile_repository.dart';
import '../../features/voice/bloc/call_cubit.dart';
import '../../features/voice/data/voice_api.dart';
import '../../features/voice/data/voice_repository.dart';
import '../../features/voice/webrtc/call_webrtc_service.dart';
import '../../features/wiki/data/wiki_api.dart';
import '../../features/wiki/data/wiki_repository.dart';
import '../device/device_api.dart';
import '../device/device_id_service.dart';
import '../device/device_registration_service.dart';
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
Future<void> configureDependencies() async {
  getIt.registerLazySingleton<SecureStorageService>(
    () => SecureStorageService(),
  );
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
    () => DeviceRegistrationService(api: getIt(), deviceIdService: getIt()),
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
    () => ConversationRepository(api: getIt(), realtimeService: getIt()),
  );
  getIt.registerLazySingleton<MessageApi>(() => MessageApi(client: getIt()));
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
    () => PushNotificationService(api: getIt(), deviceIdService: getIt()),
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
}

/// Registers this device and starts the push-notification and native-call-UI
/// services - call once per authenticated session (cold start with a restored
/// session, or right after login/register), mirroring [RealtimeService.start]'s
/// own call sites.
///
/// Registration goes first and is awaited: the push tokens registered just
/// after are attached to that device row, and the `X-Device-Id` every call and
/// voice-join carries is only honoured once the device exists.
Future<void> startAuthenticatedServices() async {
  await getIt<DeviceRegistrationService>().ensureRegistered();
  await getIt<PushNotificationService>().start();
  await getIt<CallKitService>().start();
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
}
