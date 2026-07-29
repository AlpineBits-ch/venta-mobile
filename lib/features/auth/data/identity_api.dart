import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';
import 'models/user_dto.dart';

/// Thrown by [IdentityApi.cancelDeletion] on a 409 — the purge has already
/// started (`PurgeInProgress`), so cancellation is no longer possible.
class DeletionNotCancellableException implements Exception {
  DeletionNotCancellableException(this.message);

  final String message;
}

class IdentityApi {
  IdentityApi({required this.client});

  final ApiClient client;

  String get _base => client.url('/api/v1/identity/users/self');

  Future<UserDto> getSelf() async {
    final response = await client.dio.get<Map<String, dynamic>>(_base);
    return UserDto.fromJson(response.data!);
  }

  /// Requests deletion of the current account. Returns the purge date —
  /// deletion is cancellable via [cancelDeletion] until that point.
  Future<DateTime> requestDeletion() async {
    final response = await client.dio.delete<Map<String, dynamic>>(_base);
    return DateTime.parse(response.data!['purgeScheduledAt'] as String);
  }

  Future<void> cancelDeletion() async {
    try {
      await client.dio.post<void>('$_base/cancel-deletion');
    } on DioException catch (e) {
      if (e.response?.statusCode == 409) {
        throw DeletionNotCancellableException(
          e.response?.data is String
              ? e.response!.data as String
              : 'Account is not pending deletion, or the purge has already started.',
        );
      }
      rethrow;
    }
  }
}
