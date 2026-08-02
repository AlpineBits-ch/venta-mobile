import 'package:flutter_bloc/flutter_bloc.dart';

/// Emitting after `close()` throws, and every screen-scoped bloc in this app can
/// be closed while it is waiting on the network.
///
/// The shape is always the same: a screen constructs a bloc, the bloc awaits a
/// repository, the human presses back, `close()` runs, and the `await` resumes
/// into an `emit` that now throws
/// `StateError: Cannot emit new states after calling close`. It reached
/// production as a crash in `UserProfileCubit._load` and the same code was
/// written in nine other classes.
///
/// Two helpers rather than one, because the two base classes have different
/// mechanics:
///
/// * A [Cubit] emits through [BlocBase.emit], whose only question is whether
///   the object is closed - [SafeEmit.emitIfOpen].
/// * A [Bloc] emits through the [Emitter] handed to its handler, which is
///   *also* closed out when the handler returns. [EmitterIfOpen.ifOpen]
///   therefore checks [Emitter.isDone], which covers both "the bloc was closed"
///   (`close()` cancels every live emitter) and "this handler already
///   finished" - a second failure mode with a different message that a plain
///   `isClosed` check would sail straight past.
///
/// Deliberately silent. There is nothing for a caller to do about a state that
/// no longer has anywhere to go, and the only alternative - throwing - is the
/// bug being fixed.
mixin SafeEmit<State> on BlocBase<State> {
  /// [emit], unless this object has been closed.
  ///
  /// Safe to use for emits that *cannot* race a close (the ones before any
  /// `await`), and used for those too: a rule that applies to every emit in a
  /// class is one a reviewer can check by looking, where "only the ones after
  /// an await" needs the whole method read to verify, and was wrong in eight
  /// places when it was.
  // ignore: invalid_use_of_visible_for_testing_member
  void emitIfOpen(State state) {
    if (isClosed) return;
    emit(state);
  }
}

/// The [Bloc] half of [SafeEmit].
extension EmitterIfOpen<State> on Emitter<State> {
  /// Emits [state] unless the bloc has been closed or this handler has already
  /// completed.
  void ifOpen(State state) {
    if (isDone) return;
    this(state);
  }
}
