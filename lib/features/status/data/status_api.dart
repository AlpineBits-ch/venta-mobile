import 'package:dio/dio.dart';

import '../../auth/data/auth_repository.dart';
import 'models/platform_status_dto.dart';

/// `GET /api/v1/status/summary`, and nothing else.
///
/// **Deliberately not on [ApiClient].** The status endpoints are anonymous and
/// CORS-open, and the whole point of them is that they answer when nothing else
/// does - so this must not go anywhere near `AuthInterceptor`, which would
/// block every call behind `ensureValidToken()`. On a cold start with an expired
/// refresh token that await is a round-trip to the very identity service the
/// status page might be reporting as down, and a `401` there would take the
/// status check with it. A bare [Dio] has no bearer token to attach, no refresh
/// to attempt, and no session to be expired.
///
/// `RateLimitInterceptor` is left off for the adjacent reason: it holds a
/// request through a `429` wait, and a status check that arrives late is a
/// status check nobody is still looking at.
///
/// The base URL comes from [AuthRepository.baseUrl] rather than a constant, so
/// a self-hosted instance reports its own health instead of venta.gg's.
///
/// The other four documented endpoints are not here, and each is a deliberate
/// omission rather than an oversight:
///
/// * `/status/incidents` and `/status/incidents/{ref}` - history and
///   permalinks. The summary already carries the *open* incidents with their
///   update timelines, which is everything the two screens in this client
///   render; the archive is what `status.venta.gg` is for, and this app links
///   out to it.
/// * `/status/uptime` - the 90-day strip. Twelve components times ninety days,
///   which the spec is explicit that no client should be pulling on a poll. The
///   per-component number this app shows in settings comes from
///   `components[].uptime90d` on the summary it already has.
/// * `/status/feed.atom` - for feed readers, not for apps.
class StatusApi {
  StatusApi({required this.authRepository, Dio? dio})
    : dio =
          dio ??
          Dio(
            BaseOptions(
              // Shorter than `ApiClient`'s 15s. Nothing waits on this call and
              // nothing retries it - the poll comes round again in 60 seconds -
              // so a status endpoint that has itself gone slow should be given
              // up on rather than left holding a request.
              connectTimeout: const Duration(seconds: 8),
              receiveTimeout: const Duration(seconds: 8),
            ),
          );

  final Dio dio;
  final AuthRepository authRepository;

  Future<PlatformStatusDto> getSummary() async {
    final response = await dio.get<Map<String, dynamic>>(
      '${authRepository.baseUrl}/api/v1/status/summary',
    );
    return PlatformStatusDto.fromJson(response.data!);
  }
}
