import 'identity_api.dart';
import 'models/user_dto.dart';

/// Account-lifecycle operations (status, deletion request/cancel) for the
/// signed-in user. Separate from [AuthRepository], which owns tokens/session
/// and never needs a bearer-authenticated [ApiClient] call.
class AccountRepository {
  AccountRepository({required this.api});

  final IdentityApi api;

  Future<UserDto> getSelf() => api.getSelf();

  Future<DateTime> requestDeletion() => api.requestDeletion();

  Future<void> cancelDeletion() => api.cancelDeletion();
}
