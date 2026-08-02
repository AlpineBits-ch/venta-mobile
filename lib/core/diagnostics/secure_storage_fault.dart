import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

/// A keychain / Keystore refusal, decoded.
///
/// `flutter_secure_storage_darwin` reports every non-`noErr` `OSStatus` as one
/// shape (`FlutterSecureStorageDarwinPlugin.handleResponse`):
///
/// ```
/// PlatformException(
///   code:    'Unexpected security result code',
///   message: 'Code: <OSStatus>, Message: <SecCopyErrorMessageString>',
///   details: <OSStatus as int>,
/// )
/// ```
///
/// The number is the whole diagnosis and the three failures it distinguishes
/// want completely different responses - `-34018` is a signing/entitlement
/// mistake that no user action fixes, `-25308` is a locked device that fixes
/// itself, and `-25300` should never surface at all because the plugin already
/// maps "no such item" to a null read. Losing that distinction is what left us
/// guessing for a day, so it is parsed rather than printed.
class SecureStorageFault {
  const SecureStorageFault({
    required this.osStatus,
    required this.code,
    required this.rawMessage,
  });

  /// The `OSStatus`, or null when the platform did not give one (Android, or a
  /// `MissingPluginException`).
  final int? osStatus;

  /// `PlatformException.code`.
  final String code;

  /// `PlatformException.message`, verbatim.
  final String rawMessage;

  /// Null when [error] is not a secure-storage platform failure.
  static SecureStorageFault? from(Object error) {
    if (error is! PlatformException) return null;
    final details = error.details;
    return SecureStorageFault(
      osStatus: details is int ? details : _statusFromMessage(error.message),
      code: error.code,
      rawMessage: error.message ?? '',
    );
  }

  /// `details` is the reliable source; this is the fallback for a plugin
  /// version that only puts the number in the message.
  static int? _statusFromMessage(String? message) {
    if (message == null) return null;
    final match = RegExp(r'Code:\s*(-?\d+)').firstMatch(message);
    return match == null ? null : int.tryParse(match.group(1)!);
  }

  /// The Apple constant name, so a log line is greppable against Apple's docs.
  String get statusName => switch (osStatus) {
    -34018 => 'errSecMissingEntitlement',
    -25300 => 'errSecItemNotFound',
    -25308 => 'errSecInteractionNotAllowed',
    -25299 => 'errSecDuplicateItem',
    -25293 => 'errSecAuthFailed',
    -26275 => 'errSecNoSuchKeychain',
    -50 => 'errSecParam',
    null => 'unknown',
    _ => 'OSStatus $osStatus',
  };

  /// What it means for this app, in words a bug report can act on.
  ///
  /// Deliberately concrete about the two that are actionable from our side. A
  /// generic "secure storage error" would be exactly as useless as the
  /// "Something went wrong" this replaces.
  String get explanation => switch (osStatus) {
    -34018 =>
      'the app is not signed for the keychain access group it asked for - '
          'check keychain-access-groups against the provisioning profile',
    -25308 =>
      'the device was locked, or the item was stored under an accessibility '
          'class that is not available yet',
    -25300 => 'no such item (the plugin normally maps this to an empty read)',
    -25299 => 'an item with that key already exists',
    -25293 => 'the keychain refused authentication',
    _ => 'the platform refused the keychain request',
  };

  /// One line, for a log, a Sentry tag, or the UI. Carries the number, because
  /// the number is the answer.
  @override
  String toString() =>
      'keychain $statusName (${osStatus ?? 'no status'}): $explanation';
}

/// Records a failure that was deliberately swallowed so the app could keep
/// running.
///
/// **A caught exception is not reported to Sentry.** Every guard added to the
/// launch path is therefore also a place where the evidence stops - which is
/// how a keychain fault stayed invisible through a white screen, a fail-soft
/// release, and a login failure, with Sentry silent throughout. Degrading has
/// to be loud somewhere, and the somewhere is here.
///
/// [context] is a stable identifier (`AuthRepository.login/writeTokens`), not a
/// sentence, so occurrences group in the issue list rather than fragmenting.
void reportSwallowed(
  String context,
  Object error, [
  StackTrace? stackTrace,
  Map<String, String>? extra,
]) {
  final fault = SecureStorageFault.from(error);
  final description = fault?.toString() ?? '$error';
  debugPrint('swallowed [$context] $description');

  try {
    unawaited(
      Sentry.captureException(
        error,
        stackTrace: stackTrace,
        withScope: (scope) {
          scope.setTag('swallowed_at', context);
          if (fault?.osStatus != null) {
            scope.setTag('os_status', '${fault!.osStatus}');
            scope.setTag('os_status_name', fault.statusName);
          }
          extra?.forEach(scope.setTag);
          // A swallowed fault is not fatal by definition, but it is not noise
          // either - these are the ones that produce "the app is behaving
          // oddly" reports with nothing attached.
          scope.level = SentryLevel.warning;
        },
      ),
    );
  } catch (e) {
    // Sentry may not be initialised - this runs on the launch path, and Sentry
    // is the last thing to start. An error reporter that throws replaces a
    // diagnosable fault with an undiagnosable one.
    debugPrint('swallowed [$context] could not be reported: $e');
  }
}
