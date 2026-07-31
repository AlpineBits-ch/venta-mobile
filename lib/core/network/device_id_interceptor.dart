import 'package:dio/dio.dart';

/// Attaches `X-Device-Id` to every authenticated request and recovers from the
/// one error the server answers when it doesn't recognise the id.
///
/// Attaching it everywhere rather than at the call sites that need it: five
/// endpoints validate the header today (call accept/decline/leave, the
/// Cloudflare session create, guild voice join) and that set has already grown
/// twice. The endpoints that don't read it don't care that it's there, and the
/// alternative - remembering to add the header to each new device-scoped call -
/// is exactly how `GuildVoiceApi`'s Cloudflare endpoints ended up sending
/// nothing while `VoiceApi`'s sent the real id.
///
/// The `400` recovery matters on a first run and after "forget this device":
/// the header names a device the account hasn't registered, every call and
/// voice join fails, and nothing about the error is retryable on its own. One
/// re-registration and one retry turns it into a hiccup instead of a session
/// that can't place calls until the app is restarted.
class DeviceIdInterceptor extends Interceptor {
  DeviceIdInterceptor({
    required this.deviceId,
    required this.registerDevice,
    Dio Function()? retryClient,
  }) : _retryClient = retryClient ?? Dio.new;

  /// Null before `DeviceIdService.init()` has run - send nothing rather than
  /// throw, which leaves the server on its pre-device `default` behaviour.
  final String? Function() deviceId;

  final Future<void> Function() registerDevice;

  /// Builds the client the retry goes out on - a bare [Dio] by default, like
  /// `AuthInterceptor` uses: retrying through the owning client would run this
  /// chain again and could loop. Injectable so the recovery path is testable
  /// without a live server.
  final Dio Function() _retryClient;

  static const headerName = 'X-Device-Id';

  /// Verbatim tail of the server's message (`Unknown X-Device-Id '...' -
  /// register the device first.`). Matched on the message rather than the bare
  /// `400` because the same status covers ordinary validation failures, which
  /// re-registering would not fix.
  static const _unknownDeviceMarker = 'register the device first';

  /// Request-extra that opts a request out of the recovery path. Set by the
  /// retry below, so a request is only ever retried once, and by the device
  /// registration call itself - recovering from *that* would re-enter the
  /// registration already in flight and wait on its own result.
  static const skipRecoveryKey = 'deviceIdRetried';

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (!options.headers.containsKey(headerName)) {
      final id = deviceId();
      if (id != null) options.headers[headerName] = id;
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final alreadyRetried = err.requestOptions.extra[skipRecoveryKey] == true;
    if (err.response?.statusCode == 400 &&
        !alreadyRetried &&
        _isUnknownDevice(err.response?.data)) {
      try {
        await registerDevice();
        final options = err.requestOptions..extra[skipRecoveryKey] = true;
        // The id may have changed nothing, but the device row it names now
        // exists - resend the header rather than whatever was on the request.
        final id = deviceId();
        if (id != null) options.headers[headerName] = id;
        final retryResponse = await _retryClient().fetch<dynamic>(options);
        handler.resolve(retryResponse);
        return;
      } catch (_) {
        // Registration or the retry failed - surface the original error.
      }
    }
    handler.next(err);
  }

  bool _isUnknownDevice(Object? body) {
    final text = body is String ? body : body?.toString();
    return text != null && text.contains(_unknownDeviceMarker);
  }
}
