import 'package:signalr_netcore/iretry_policy.dart';

/// Matches Alpine's `RealtimeConnectionService` backoff exactly: 1s,
/// doubling each attempt, capped at 60s, retried forever.
class ExponentialRetryPolicy implements IRetryPolicy {
  @override
  int? nextRetryDelayInMilliseconds(RetryContext retryContext) {
    final exponent = retryContext.previousRetryCount.clamp(0, 6); // 2^6s already exceeds the cap
    final delayMs = 1000 * (1 << exponent);
    return delayMs > 60000 ? 60000 : delayMs;
  }
}
