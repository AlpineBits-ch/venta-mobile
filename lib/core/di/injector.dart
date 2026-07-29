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
import '../device/device_id_service.dart';
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
    () => AuthRepository(api: getIt(), secureStorage: getIt()),
  );
  getIt.registerLazySingleton<ApiClient>(
    () => ApiClient(authRepository: getIt()),
  );
  getIt.registerLazySingleton<IdentityApi>(
    () => IdentityApi(client: getIt()),
  );
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
    () => ProfileRepository(api: getIt(), realtimeService: getIt()),
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
      realtimeService: getIt(),
      myUserId: getIt<AuthRepository>().currentUserId ?? '',
    ),
  );
  getIt.registerLazySingleton<SoundService>(() => SoundService());
  getIt.registerLazySingleton<VoiceApi>(() => VoiceApi(client: getIt()));
  getIt.registerLazySingleton<VoiceRepository>(
    () => VoiceRepository(
      api: getIt(),
      realtimeService: getIt(),
      deviceIdService: getIt(),
    ),
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
    () => PushNotificationService(api: getIt()),
  );
  getIt.registerLazySingleton<CallKitService>(
    () => CallKitService(
      callCubit: getIt(),
      authRepository: getIt(),
      profileRepository: getIt(),
      pushTokenApi: getIt(),
      secureStorage: getIt(),
    ),
  );
}

/// Starts the push-notification and native-call-UI services — call once per
/// authenticated session (cold start with a restored session, or right after
/// login/register), mirroring [RealtimeService.start]'s own call sites.
Future<void> startPushServices() async {
  await getIt<PushNotificationService>().start();
  await getIt<CallKitService>().start();
}
