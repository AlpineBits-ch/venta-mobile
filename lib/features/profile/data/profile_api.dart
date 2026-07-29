import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';
import 'models/profile_dto.dart';

class ProfileApi {
  ProfileApi({required this.client});

  final ApiClient client;

  Future<ProfileDto> getSelf() async {
    final response = await client.dio.get<Map<String, dynamic>>(
      client.url('/api/v1/social/profiles/me'),
    );
    return ProfileDto.fromJson(response.data!);
  }

  Future<ProfileDto> setSelfStatus(OnlineStatus status) async {
    final response = await client.dio.patch<Map<String, dynamic>>(
      client.url('/api/v1/social/profiles/me/status'),
      data: {'status': _statusWireValue(status)},
    );
    return ProfileDto.fromJson(response.data!);
  }

  Future<ProfileDto> getById(String profileId) async {
    final response = await client.dio.get<Map<String, dynamic>>(
      client.url('/api/v1/social/profiles/$profileId'),
    );
    return ProfileDto.fromJson(response.data!);
  }

  Future<ProfileDto> getByUserId(String userId) async {
    final response = await client.dio.get<Map<String, dynamic>>(
      client.url('/api/v1/social/profiles/by-user/$userId'),
    );
    return ProfileDto.fromJson(response.data!);
  }

  Future<void> updateProfile({
    required String profileId,
    String? bio,
    String? accentColor,
    ProfileFont? font,
  }) async {
    await client.dio.patch<void>(
      client.url('/api/v1/social/profiles/me'),
      data: {
        'bio': ?bio,
        'accentColor': ?accentColor,
        if (font != null) 'font': _fontWireValue(font),
      },
    );
  }

  Future<void> uploadAvatar({
    required String profileId,
    required String filePath,
  }) async {
    await client.dio.patch<void>(
      client.url('/api/v1/social/profiles/$profileId/avatar'),
      data: FormData.fromMap({'file': await MultipartFile.fromFile(filePath)}),
    );
  }

  Future<void> uploadBanner({
    required String profileId,
    required String filePath,
  }) async {
    await client.dio.patch<void>(
      client.url('/api/v1/social/profiles/$profileId/banner'),
      data: FormData.fromMap({'file': await MultipartFile.fromFile(filePath)}),
    );
  }

  Future<void> removeAvatar(String profileId) async {
    await client.dio.delete<void>(
      client.url('/api/v1/social/profiles/$profileId/avatar'),
    );
  }

  String _fontWireValue(ProfileFont font) => switch (font) {
    ProfileFont.defaultFont => 'Default',
    ProfileFont.serif => 'Serif',
    ProfileFont.monospace => 'Monospace',
    ProfileFont.rounded => 'Rounded',
    ProfileFont.display => 'Display',
    ProfileFont.handwritten => 'Handwritten',
  };

  String _statusWireValue(OnlineStatus status) => switch (status) {
    OnlineStatus.offline => 'Offline',
    OnlineStatus.hidden => 'Hidden',
    OnlineStatus.online => 'Online',
    OnlineStatus.idle => 'Idle',
    OnlineStatus.doNotDisturb => 'DoNotDisturb',
  };
}
