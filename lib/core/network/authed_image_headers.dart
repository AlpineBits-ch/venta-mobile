import '../../features/auth/data/auth_repository.dart';
import '../di/injector.dart';

/// Bearer headers for an image loaded outside dio.
///
/// `CachedNetworkImage` fetches through its own HTTP client, so none of the
/// interceptors that authenticate every other request reach it. Anything it
/// loads from an authorized route therefore arrives anonymous unless the
/// headers are passed in by hand.
///
/// That is not hypothetical: Messaging's `AttachmentController` carries
/// `[Authorize]` at the *class* level (it was moved there from the upload
/// action alone, because every read route had been reachable with nothing but
/// a leaked id), and its read guard answers **404, not 401**. So an
/// unauthenticated thumbnail request is indistinguishable from a deleted
/// attachment: the image simply renders as broken, with no error to trace.
///
/// Returns null when there is no session, so a signed-out load stays
/// header-free rather than sending `Bearer null`.
Map<String, String>? authedImageHeaders() {
  final token = getIt<AuthRepository>().currentAccessToken;
  if (token == null || token.isEmpty) return null;
  return {'Authorization': 'Bearer $token'};
}
