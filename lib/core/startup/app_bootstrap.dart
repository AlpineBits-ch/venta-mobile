import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

/// One initialisation step that did not complete.
class StartupFailure {
  const StartupFailure(this.step, this.error, this.stackTrace);

  final String step;
  final Object error;
  final StackTrace stackTrace;

  @override
  String toString() => '$step: $error';
}

/// Runs the pre-`runApp` initialisation so that **no step can stop the app from
/// rendering**.
///
/// The shape this replaces was: eight bare `await`s in `main`, with `runApp`
/// nested inside the last of them (`SentryFlutter.init`'s `appRunner`). Any one
/// of those throwing meant `runApp` was never reached - and a Flutter engine
/// with no root widget is a **white screen with no diagnostic whatsoever**: no
/// error text, no stack, nothing in the UI to distinguish "the keychain refused"
/// from "the network is down" from "a plugin crashed". That failure mode cost a
/// day of investigation for a symptom the app itself could have named in one
/// line, and it is worse than any of the faults it can hide.
///
/// Several of those awaits are plugin or platform calls that behave differently
/// on iOS than on Android - the keychain in particular, where an access-group
/// mismatch or a read before first unlock throws a `PlatformException` on iOS
/// and has no Android equivalent at all. So "it renders on Android" was never
/// evidence that it renders on iOS, and the structure guaranteed that the
/// difference would surface as a blank screen rather than as a message.
///
/// The rule here: **degrade the feature, never the launch.** A user with no
/// Firebase, no Sentry, no persisted theme and no keychain should still reach a
/// login screen that tells them what is wrong.
class AppBootstrap {
  AppBootstrap({this.onFailure});

  /// Reported per failure as it happens, so a crash-reporter that came up
  /// successfully still learns about the steps that did not.
  final void Function(StartupFailure failure)? onFailure;

  final List<StartupFailure> _failures = [];

  /// Everything that failed, in the order it failed.
  List<StartupFailure> get failures => List.unmodifiable(_failures);

  bool get isClean => _failures.isEmpty;

  /// Runs [body], recording rather than propagating anything it throws.
  ///
  /// Returns whether it succeeded, so a caller that has a fallback can install
  /// one. Catches `Object`, not `Exception`: a `PlatformException` is an
  /// exception but a `MissingPluginException`, a `StateError` from an
  /// unregistered dependency and an out-of-memory failure inside a plugin are
  /// not all of one type, and the point is that *none* of them may reach the
  /// caller.
  Future<bool> step(String name, Future<void> Function() body) async {
    try {
      await body();
      return true;
    } catch (error, stackTrace) {
      final failure = StartupFailure(name, error, stackTrace);
      _failures.add(failure);
      debugPrint('startup: $name failed: $error');
      debugPrintStack(stackTrace: stackTrace);
      onFailure?.call(failure);
      return false;
    }
  }

  /// A one-line summary for the diagnostic surface and for a bug report.
  String get summary => _failures.isEmpty
      ? 'startup clean'
      : _failures.map((f) => f.toString()).join('\n');
}

/// A [Storage] that forgets everything when the process does.
///
/// Installed when `HydratedStorage.build` fails, and it is not cosmetic:
/// `HydratedBloc.storage` is a `late` static, so *reading* it before it is
/// assigned throws - and it is read by `ThemeCubit`'s construction and by
/// `RoutePersistence`, both of which run while the first frame is being built.
/// A failed disk-storage init would therefore take down the widget tree a beat
/// after `runApp` succeeded, which looks exactly like the failure this whole
/// file exists to prevent.
///
/// Losing the persisted theme and the last-visited route is a real but small
/// cost, and strictly better than not starting.
class InMemoryHydratedStorage implements Storage {
  final Map<String, dynamic> _values = {};

  @override
  dynamic read(String key) => _values[key];

  @override
  Future<void> write(String key, dynamic value) async => _values[key] = value;

  @override
  Future<void> delete(String key) async => _values.remove(key);

  @override
  Future<void> clear() async => _values.clear();

  @override
  Future<void> close() async {}
}

/// Routes framework and platform errors somewhere they can be seen.
///
/// Three separate channels, and all three matter:
///
/// * [FlutterError.onError] - errors thrown inside build/layout/paint. In
///   release these are otherwise printed to a console nobody is attached to.
/// * [PlatformDispatcher.instance.onError] - unhandled asynchronous errors that
///   escape the zone, which is where a fire-and-forget `unawaited(...)` on the
///   launch path lands.
/// * [ErrorWidget.builder] - what actually gets *drawn* when a widget's build
///   throws. The release default is a bare grey rectangle with no text, which is
///   indistinguishable from a blank screen; in debug it is the red screen. This
///   makes the release surface say what happened.
void installGlobalErrorHandlers({
  void Function(Object error, StackTrace stack)? report,
}) {
  final previous = FlutterError.onError;
  FlutterError.onError = (details) {
    previous?.call(details);
    report?.call(details.exception, details.stack ?? StackTrace.current);
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    debugPrint('unhandled async error: $error');
    debugPrintStack(stackTrace: stack);
    report?.call(error, stack);
    // Handled: returning false re-raises into the platform, which on iOS ends
    // the process. An error from a detached background task is not worth
    // terminating a running app over.
    return true;
  };

  ErrorWidget.builder = (details) => StartupErrorSurface(
    title: 'Something broke while drawing this screen',
    detail: '${details.exception}',
  );
}

/// The last-resort diagnostic. Deliberately dependency-free - no theme, no
/// generated localisations, no DI - because it has to render in exactly the
/// situation where those are the things that failed.
class StartupErrorSurface extends StatelessWidget {
  const StartupErrorSurface({
    super.key,
    required this.title,
    required this.detail,
  });

  final String title;
  final String detail;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Container(
        color: const Color(0xFF14161B),
        padding: const EdgeInsets.fromLTRB(24, 96, 24, 24),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xFFF2F3F5),
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  decoration: TextDecoration.none,
                ),
              ),
              const SizedBox(height: 12),
              // Selectable would need a Material ancestor. Plain text, because
              // this must render with nothing else working.
              Text(
                detail,
                style: const TextStyle(
                  color: Color(0xFFB5BAC1),
                  fontSize: 13,
                  height: 1.4,
                  decoration: TextDecoration.none,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Please send this text to support. Restarting the app is safe '
                'and may clear it.',
                style: TextStyle(
                  color: Color(0xFF80848E),
                  fontSize: 12,
                  decoration: TextDecoration.none,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
