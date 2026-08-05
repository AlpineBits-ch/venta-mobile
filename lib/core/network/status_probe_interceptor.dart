import 'package:dio/dio.dart';

/// Fires a platform-status check the moment the API stops answering.
///
/// This is §3's first one-shot trigger - "the app fails to reach the API at all
/// (network error, or 502/503/504 from the gateway)" - and it lives in an
/// interceptor rather than in each screen's catch block because that is the
/// only place that sees *every* request. The point is timing: the user is
/// staring at a broken screen deciding whether to blame their wifi, and the
/// banner has to be there when they look up, not 40 seconds later when the poll
/// next comes round.
///
/// [onUnreachable] is expected to be cheap, non-throwing and self-throttling -
/// an outage fails every request in flight at once, so this runs in bursts. See
/// `StatusRepository.probeAfterFailure`.
///
/// Deliberately narrow about what counts. A `401`, a `403`, a `404` or a `500`
/// from a specific endpoint says something about that request, not about the
/// platform, and probing on those would poll the status endpoint every time
/// somebody typed a wrong invite code.
class StatusProbeInterceptor extends Interceptor {
  StatusProbeInterceptor(this.onUnreachable);

  final void Function() onUnreachable;

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (_isUnreachable(err)) onUnreachable();
    handler.next(err);
  }

  static bool _isUnreachable(DioException err) {
    switch (err.type) {
      case DioExceptionType.connectionError:
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        return true;
      case DioExceptionType.badResponse:
        // The gateway's own failures. `500` is excluded on purpose: it comes
        // from a service that answered, and the status service is the one that
        // decides whether that amounts to an incident.
        final status = err.response?.statusCode;
        return status == 502 || status == 503 || status == 504;
      case DioExceptionType.badCertificate:
      case DioExceptionType.cancel:
      case DioExceptionType.transformTimeout:
      case DioExceptionType.unknown:
        // `unknown` is where a `SocketException` lands on some platforms, but
        // it is also where every client-side bug in a response transformer
        // lands. Left out: a probe missed costs one poll interval, a probe on
        // every decode failure costs a request per failure.
        return false;
    }
  }
}
