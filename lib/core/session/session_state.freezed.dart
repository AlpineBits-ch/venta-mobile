// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'session_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$SessionState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SessionState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'SessionState()';
}


}

/// @nodoc
class $SessionStateCopyWith<$Res>  {
$SessionStateCopyWith(SessionState _, $Res Function(SessionState) __);
}


/// Adds pattern-matching-related methods to [SessionState].
extension SessionStatePatterns on SessionState {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( SessionUnknown value)?  unknown,TResult Function( SessionUnauthenticated value)?  unauthenticated,TResult Function( SessionAuthenticated value)?  authenticated,TResult Function( SessionServerMisconfigured value)?  serverMisconfigured,required TResult orElse(),}){
final _that = this;
switch (_that) {
case SessionUnknown() when unknown != null:
return unknown(_that);case SessionUnauthenticated() when unauthenticated != null:
return unauthenticated(_that);case SessionAuthenticated() when authenticated != null:
return authenticated(_that);case SessionServerMisconfigured() when serverMisconfigured != null:
return serverMisconfigured(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( SessionUnknown value)  unknown,required TResult Function( SessionUnauthenticated value)  unauthenticated,required TResult Function( SessionAuthenticated value)  authenticated,required TResult Function( SessionServerMisconfigured value)  serverMisconfigured,}){
final _that = this;
switch (_that) {
case SessionUnknown():
return unknown(_that);case SessionUnauthenticated():
return unauthenticated(_that);case SessionAuthenticated():
return authenticated(_that);case SessionServerMisconfigured():
return serverMisconfigured(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( SessionUnknown value)?  unknown,TResult? Function( SessionUnauthenticated value)?  unauthenticated,TResult? Function( SessionAuthenticated value)?  authenticated,TResult? Function( SessionServerMisconfigured value)?  serverMisconfigured,}){
final _that = this;
switch (_that) {
case SessionUnknown() when unknown != null:
return unknown(_that);case SessionUnauthenticated() when unauthenticated != null:
return unauthenticated(_that);case SessionAuthenticated() when authenticated != null:
return authenticated(_that);case SessionServerMisconfigured() when serverMisconfigured != null:
return serverMisconfigured(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  unknown,TResult Function()?  unauthenticated,TResult Function( String userId)?  authenticated,TResult Function( String message)?  serverMisconfigured,required TResult orElse(),}) {final _that = this;
switch (_that) {
case SessionUnknown() when unknown != null:
return unknown();case SessionUnauthenticated() when unauthenticated != null:
return unauthenticated();case SessionAuthenticated() when authenticated != null:
return authenticated(_that.userId);case SessionServerMisconfigured() when serverMisconfigured != null:
return serverMisconfigured(_that.message);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  unknown,required TResult Function()  unauthenticated,required TResult Function( String userId)  authenticated,required TResult Function( String message)  serverMisconfigured,}) {final _that = this;
switch (_that) {
case SessionUnknown():
return unknown();case SessionUnauthenticated():
return unauthenticated();case SessionAuthenticated():
return authenticated(_that.userId);case SessionServerMisconfigured():
return serverMisconfigured(_that.message);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  unknown,TResult? Function()?  unauthenticated,TResult? Function( String userId)?  authenticated,TResult? Function( String message)?  serverMisconfigured,}) {final _that = this;
switch (_that) {
case SessionUnknown() when unknown != null:
return unknown();case SessionUnauthenticated() when unauthenticated != null:
return unauthenticated();case SessionAuthenticated() when authenticated != null:
return authenticated(_that.userId);case SessionServerMisconfigured() when serverMisconfigured != null:
return serverMisconfigured(_that.message);case _:
  return null;

}
}

}

/// @nodoc


class SessionUnknown implements SessionState {
  const SessionUnknown();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SessionUnknown);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'SessionState.unknown()';
}


}




/// @nodoc


class SessionUnauthenticated implements SessionState {
  const SessionUnauthenticated();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SessionUnauthenticated);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'SessionState.unauthenticated()';
}


}




/// @nodoc


class SessionAuthenticated implements SessionState {
  const SessionAuthenticated({required this.userId});
  

 final  String userId;

/// Create a copy of SessionState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SessionAuthenticatedCopyWith<SessionAuthenticated> get copyWith => _$SessionAuthenticatedCopyWithImpl<SessionAuthenticated>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SessionAuthenticated&&(identical(other.userId, userId) || other.userId == userId));
}


@override
int get hashCode => Object.hash(runtimeType,userId);

@override
String toString() {
  return 'SessionState.authenticated(userId: $userId)';
}


}

/// @nodoc
abstract mixin class $SessionAuthenticatedCopyWith<$Res> implements $SessionStateCopyWith<$Res> {
  factory $SessionAuthenticatedCopyWith(SessionAuthenticated value, $Res Function(SessionAuthenticated) _then) = _$SessionAuthenticatedCopyWithImpl;
@useResult
$Res call({
 String userId
});




}
/// @nodoc
class _$SessionAuthenticatedCopyWithImpl<$Res>
    implements $SessionAuthenticatedCopyWith<$Res> {
  _$SessionAuthenticatedCopyWithImpl(this._self, this._then);

  final SessionAuthenticated _self;
  final $Res Function(SessionAuthenticated) _then;

/// Create a copy of SessionState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? userId = null,}) {
  return _then(SessionAuthenticated(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class SessionServerMisconfigured implements SessionState {
  const SessionServerMisconfigured({required this.message});
  

 final  String message;

/// Create a copy of SessionState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SessionServerMisconfiguredCopyWith<SessionServerMisconfigured> get copyWith => _$SessionServerMisconfiguredCopyWithImpl<SessionServerMisconfigured>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SessionServerMisconfigured&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,message);

@override
String toString() {
  return 'SessionState.serverMisconfigured(message: $message)';
}


}

/// @nodoc
abstract mixin class $SessionServerMisconfiguredCopyWith<$Res> implements $SessionStateCopyWith<$Res> {
  factory $SessionServerMisconfiguredCopyWith(SessionServerMisconfigured value, $Res Function(SessionServerMisconfigured) _then) = _$SessionServerMisconfiguredCopyWithImpl;
@useResult
$Res call({
 String message
});




}
/// @nodoc
class _$SessionServerMisconfiguredCopyWithImpl<$Res>
    implements $SessionServerMisconfiguredCopyWith<$Res> {
  _$SessionServerMisconfiguredCopyWithImpl(this._self, this._then);

  final SessionServerMisconfigured _self;
  final $Res Function(SessionServerMisconfigured) _then;

/// Create a copy of SessionState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(SessionServerMisconfigured(
message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
