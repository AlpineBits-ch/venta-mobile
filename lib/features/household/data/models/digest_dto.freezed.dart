// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'digest_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$HouseholdDigestDto {

 String get guildId; HouseholdChoresDigestDto? get chores; List<HouseholdListDigestDto>? get lists; HouseholdPantryDigestDto? get pantry; List<HouseholdLedgerDigestDto>? get ledger; HouseholdDecisionsDigestDto? get decisions;/// The same rows `GET /home-status` returns. `HomeStatusBoard` fetches its
/// own rather than reading these - it also needs quiet hours, and it is an
/// editor rather than a glance - so the digest card ignores this section.
 List<HomeStatusDto>? get homeStatus;
/// Create a copy of HouseholdDigestDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HouseholdDigestDtoCopyWith<HouseholdDigestDto> get copyWith => _$HouseholdDigestDtoCopyWithImpl<HouseholdDigestDto>(this as HouseholdDigestDto, _$identity);

  /// Serializes this HouseholdDigestDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HouseholdDigestDto&&(identical(other.guildId, guildId) || other.guildId == guildId)&&(identical(other.chores, chores) || other.chores == chores)&&const DeepCollectionEquality().equals(other.lists, lists)&&(identical(other.pantry, pantry) || other.pantry == pantry)&&const DeepCollectionEquality().equals(other.ledger, ledger)&&(identical(other.decisions, decisions) || other.decisions == decisions)&&const DeepCollectionEquality().equals(other.homeStatus, homeStatus));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,guildId,chores,const DeepCollectionEquality().hash(lists),pantry,const DeepCollectionEquality().hash(ledger),decisions,const DeepCollectionEquality().hash(homeStatus));

@override
String toString() {
  return 'HouseholdDigestDto(guildId: $guildId, chores: $chores, lists: $lists, pantry: $pantry, ledger: $ledger, decisions: $decisions, homeStatus: $homeStatus)';
}


}

/// @nodoc
abstract mixin class $HouseholdDigestDtoCopyWith<$Res>  {
  factory $HouseholdDigestDtoCopyWith(HouseholdDigestDto value, $Res Function(HouseholdDigestDto) _then) = _$HouseholdDigestDtoCopyWithImpl;
@useResult
$Res call({
 String guildId, HouseholdChoresDigestDto? chores, List<HouseholdListDigestDto>? lists, HouseholdPantryDigestDto? pantry, List<HouseholdLedgerDigestDto>? ledger, HouseholdDecisionsDigestDto? decisions, List<HomeStatusDto>? homeStatus
});


$HouseholdChoresDigestDtoCopyWith<$Res>? get chores;$HouseholdPantryDigestDtoCopyWith<$Res>? get pantry;$HouseholdDecisionsDigestDtoCopyWith<$Res>? get decisions;

}
/// @nodoc
class _$HouseholdDigestDtoCopyWithImpl<$Res>
    implements $HouseholdDigestDtoCopyWith<$Res> {
  _$HouseholdDigestDtoCopyWithImpl(this._self, this._then);

  final HouseholdDigestDto _self;
  final $Res Function(HouseholdDigestDto) _then;

/// Create a copy of HouseholdDigestDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? guildId = null,Object? chores = freezed,Object? lists = freezed,Object? pantry = freezed,Object? ledger = freezed,Object? decisions = freezed,Object? homeStatus = freezed,}) {
  return _then(_self.copyWith(
guildId: null == guildId ? _self.guildId : guildId // ignore: cast_nullable_to_non_nullable
as String,chores: freezed == chores ? _self.chores : chores // ignore: cast_nullable_to_non_nullable
as HouseholdChoresDigestDto?,lists: freezed == lists ? _self.lists : lists // ignore: cast_nullable_to_non_nullable
as List<HouseholdListDigestDto>?,pantry: freezed == pantry ? _self.pantry : pantry // ignore: cast_nullable_to_non_nullable
as HouseholdPantryDigestDto?,ledger: freezed == ledger ? _self.ledger : ledger // ignore: cast_nullable_to_non_nullable
as List<HouseholdLedgerDigestDto>?,decisions: freezed == decisions ? _self.decisions : decisions // ignore: cast_nullable_to_non_nullable
as HouseholdDecisionsDigestDto?,homeStatus: freezed == homeStatus ? _self.homeStatus : homeStatus // ignore: cast_nullable_to_non_nullable
as List<HomeStatusDto>?,
  ));
}
/// Create a copy of HouseholdDigestDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$HouseholdChoresDigestDtoCopyWith<$Res>? get chores {
    if (_self.chores == null) {
    return null;
  }

  return $HouseholdChoresDigestDtoCopyWith<$Res>(_self.chores!, (value) {
    return _then(_self.copyWith(chores: value));
  });
}/// Create a copy of HouseholdDigestDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$HouseholdPantryDigestDtoCopyWith<$Res>? get pantry {
    if (_self.pantry == null) {
    return null;
  }

  return $HouseholdPantryDigestDtoCopyWith<$Res>(_self.pantry!, (value) {
    return _then(_self.copyWith(pantry: value));
  });
}/// Create a copy of HouseholdDigestDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$HouseholdDecisionsDigestDtoCopyWith<$Res>? get decisions {
    if (_self.decisions == null) {
    return null;
  }

  return $HouseholdDecisionsDigestDtoCopyWith<$Res>(_self.decisions!, (value) {
    return _then(_self.copyWith(decisions: value));
  });
}
}


/// Adds pattern-matching-related methods to [HouseholdDigestDto].
extension HouseholdDigestDtoPatterns on HouseholdDigestDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _HouseholdDigestDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _HouseholdDigestDto() when $default != null:
return $default(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _HouseholdDigestDto value)  $default,){
final _that = this;
switch (_that) {
case _HouseholdDigestDto():
return $default(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _HouseholdDigestDto value)?  $default,){
final _that = this;
switch (_that) {
case _HouseholdDigestDto() when $default != null:
return $default(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String guildId,  HouseholdChoresDigestDto? chores,  List<HouseholdListDigestDto>? lists,  HouseholdPantryDigestDto? pantry,  List<HouseholdLedgerDigestDto>? ledger,  HouseholdDecisionsDigestDto? decisions,  List<HomeStatusDto>? homeStatus)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _HouseholdDigestDto() when $default != null:
return $default(_that.guildId,_that.chores,_that.lists,_that.pantry,_that.ledger,_that.decisions,_that.homeStatus);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String guildId,  HouseholdChoresDigestDto? chores,  List<HouseholdListDigestDto>? lists,  HouseholdPantryDigestDto? pantry,  List<HouseholdLedgerDigestDto>? ledger,  HouseholdDecisionsDigestDto? decisions,  List<HomeStatusDto>? homeStatus)  $default,) {final _that = this;
switch (_that) {
case _HouseholdDigestDto():
return $default(_that.guildId,_that.chores,_that.lists,_that.pantry,_that.ledger,_that.decisions,_that.homeStatus);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String guildId,  HouseholdChoresDigestDto? chores,  List<HouseholdListDigestDto>? lists,  HouseholdPantryDigestDto? pantry,  List<HouseholdLedgerDigestDto>? ledger,  HouseholdDecisionsDigestDto? decisions,  List<HomeStatusDto>? homeStatus)?  $default,) {final _that = this;
switch (_that) {
case _HouseholdDigestDto() when $default != null:
return $default(_that.guildId,_that.chores,_that.lists,_that.pantry,_that.ledger,_that.decisions,_that.homeStatus);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _HouseholdDigestDto implements HouseholdDigestDto {
  const _HouseholdDigestDto({this.guildId = '', this.chores, final  List<HouseholdListDigestDto>? lists, this.pantry, final  List<HouseholdLedgerDigestDto>? ledger, this.decisions, final  List<HomeStatusDto>? homeStatus}): _lists = lists,_ledger = ledger,_homeStatus = homeStatus;
  factory _HouseholdDigestDto.fromJson(Map<String, dynamic> json) => _$HouseholdDigestDtoFromJson(json);

@override@JsonKey() final  String guildId;
@override final  HouseholdChoresDigestDto? chores;
 final  List<HouseholdListDigestDto>? _lists;
@override List<HouseholdListDigestDto>? get lists {
  final value = _lists;
  if (value == null) return null;
  if (_lists is EqualUnmodifiableListView) return _lists;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

@override final  HouseholdPantryDigestDto? pantry;
 final  List<HouseholdLedgerDigestDto>? _ledger;
@override List<HouseholdLedgerDigestDto>? get ledger {
  final value = _ledger;
  if (value == null) return null;
  if (_ledger is EqualUnmodifiableListView) return _ledger;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

@override final  HouseholdDecisionsDigestDto? decisions;
/// The same rows `GET /home-status` returns. `HomeStatusBoard` fetches its
/// own rather than reading these - it also needs quiet hours, and it is an
/// editor rather than a glance - so the digest card ignores this section.
 final  List<HomeStatusDto>? _homeStatus;
/// The same rows `GET /home-status` returns. `HomeStatusBoard` fetches its
/// own rather than reading these - it also needs quiet hours, and it is an
/// editor rather than a glance - so the digest card ignores this section.
@override List<HomeStatusDto>? get homeStatus {
  final value = _homeStatus;
  if (value == null) return null;
  if (_homeStatus is EqualUnmodifiableListView) return _homeStatus;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}


/// Create a copy of HouseholdDigestDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HouseholdDigestDtoCopyWith<_HouseholdDigestDto> get copyWith => __$HouseholdDigestDtoCopyWithImpl<_HouseholdDigestDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$HouseholdDigestDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _HouseholdDigestDto&&(identical(other.guildId, guildId) || other.guildId == guildId)&&(identical(other.chores, chores) || other.chores == chores)&&const DeepCollectionEquality().equals(other._lists, _lists)&&(identical(other.pantry, pantry) || other.pantry == pantry)&&const DeepCollectionEquality().equals(other._ledger, _ledger)&&(identical(other.decisions, decisions) || other.decisions == decisions)&&const DeepCollectionEquality().equals(other._homeStatus, _homeStatus));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,guildId,chores,const DeepCollectionEquality().hash(_lists),pantry,const DeepCollectionEquality().hash(_ledger),decisions,const DeepCollectionEquality().hash(_homeStatus));

@override
String toString() {
  return 'HouseholdDigestDto(guildId: $guildId, chores: $chores, lists: $lists, pantry: $pantry, ledger: $ledger, decisions: $decisions, homeStatus: $homeStatus)';
}


}

/// @nodoc
abstract mixin class _$HouseholdDigestDtoCopyWith<$Res> implements $HouseholdDigestDtoCopyWith<$Res> {
  factory _$HouseholdDigestDtoCopyWith(_HouseholdDigestDto value, $Res Function(_HouseholdDigestDto) _then) = __$HouseholdDigestDtoCopyWithImpl;
@override @useResult
$Res call({
 String guildId, HouseholdChoresDigestDto? chores, List<HouseholdListDigestDto>? lists, HouseholdPantryDigestDto? pantry, List<HouseholdLedgerDigestDto>? ledger, HouseholdDecisionsDigestDto? decisions, List<HomeStatusDto>? homeStatus
});


@override $HouseholdChoresDigestDtoCopyWith<$Res>? get chores;@override $HouseholdPantryDigestDtoCopyWith<$Res>? get pantry;@override $HouseholdDecisionsDigestDtoCopyWith<$Res>? get decisions;

}
/// @nodoc
class __$HouseholdDigestDtoCopyWithImpl<$Res>
    implements _$HouseholdDigestDtoCopyWith<$Res> {
  __$HouseholdDigestDtoCopyWithImpl(this._self, this._then);

  final _HouseholdDigestDto _self;
  final $Res Function(_HouseholdDigestDto) _then;

/// Create a copy of HouseholdDigestDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? guildId = null,Object? chores = freezed,Object? lists = freezed,Object? pantry = freezed,Object? ledger = freezed,Object? decisions = freezed,Object? homeStatus = freezed,}) {
  return _then(_HouseholdDigestDto(
guildId: null == guildId ? _self.guildId : guildId // ignore: cast_nullable_to_non_nullable
as String,chores: freezed == chores ? _self.chores : chores // ignore: cast_nullable_to_non_nullable
as HouseholdChoresDigestDto?,lists: freezed == lists ? _self._lists : lists // ignore: cast_nullable_to_non_nullable
as List<HouseholdListDigestDto>?,pantry: freezed == pantry ? _self.pantry : pantry // ignore: cast_nullable_to_non_nullable
as HouseholdPantryDigestDto?,ledger: freezed == ledger ? _self._ledger : ledger // ignore: cast_nullable_to_non_nullable
as List<HouseholdLedgerDigestDto>?,decisions: freezed == decisions ? _self.decisions : decisions // ignore: cast_nullable_to_non_nullable
as HouseholdDecisionsDigestDto?,homeStatus: freezed == homeStatus ? _self._homeStatus : homeStatus // ignore: cast_nullable_to_non_nullable
as List<HomeStatusDto>?,
  ));
}

/// Create a copy of HouseholdDigestDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$HouseholdChoresDigestDtoCopyWith<$Res>? get chores {
    if (_self.chores == null) {
    return null;
  }

  return $HouseholdChoresDigestDtoCopyWith<$Res>(_self.chores!, (value) {
    return _then(_self.copyWith(chores: value));
  });
}/// Create a copy of HouseholdDigestDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$HouseholdPantryDigestDtoCopyWith<$Res>? get pantry {
    if (_self.pantry == null) {
    return null;
  }

  return $HouseholdPantryDigestDtoCopyWith<$Res>(_self.pantry!, (value) {
    return _then(_self.copyWith(pantry: value));
  });
}/// Create a copy of HouseholdDigestDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$HouseholdDecisionsDigestDtoCopyWith<$Res>? get decisions {
    if (_self.decisions == null) {
    return null;
  }

  return $HouseholdDecisionsDigestDtoCopyWith<$Res>(_self.decisions!, (value) {
    return _then(_self.copyWith(decisions: value));
  });
}
}


/// @nodoc
mixin _$HouseholdChoresDigestDto {

/// Yours, due within a day or already past due. At most ten.
 List<ChoreOccurrenceDto> get mine; int get mineOverdueCount;/// Everyone's, not just yours - a house that is behind is worth seeing.
 int get houseOverdueCount;
/// Create a copy of HouseholdChoresDigestDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HouseholdChoresDigestDtoCopyWith<HouseholdChoresDigestDto> get copyWith => _$HouseholdChoresDigestDtoCopyWithImpl<HouseholdChoresDigestDto>(this as HouseholdChoresDigestDto, _$identity);

  /// Serializes this HouseholdChoresDigestDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HouseholdChoresDigestDto&&const DeepCollectionEquality().equals(other.mine, mine)&&(identical(other.mineOverdueCount, mineOverdueCount) || other.mineOverdueCount == mineOverdueCount)&&(identical(other.houseOverdueCount, houseOverdueCount) || other.houseOverdueCount == houseOverdueCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(mine),mineOverdueCount,houseOverdueCount);

@override
String toString() {
  return 'HouseholdChoresDigestDto(mine: $mine, mineOverdueCount: $mineOverdueCount, houseOverdueCount: $houseOverdueCount)';
}


}

/// @nodoc
abstract mixin class $HouseholdChoresDigestDtoCopyWith<$Res>  {
  factory $HouseholdChoresDigestDtoCopyWith(HouseholdChoresDigestDto value, $Res Function(HouseholdChoresDigestDto) _then) = _$HouseholdChoresDigestDtoCopyWithImpl;
@useResult
$Res call({
 List<ChoreOccurrenceDto> mine, int mineOverdueCount, int houseOverdueCount
});




}
/// @nodoc
class _$HouseholdChoresDigestDtoCopyWithImpl<$Res>
    implements $HouseholdChoresDigestDtoCopyWith<$Res> {
  _$HouseholdChoresDigestDtoCopyWithImpl(this._self, this._then);

  final HouseholdChoresDigestDto _self;
  final $Res Function(HouseholdChoresDigestDto) _then;

/// Create a copy of HouseholdChoresDigestDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? mine = null,Object? mineOverdueCount = null,Object? houseOverdueCount = null,}) {
  return _then(_self.copyWith(
mine: null == mine ? _self.mine : mine // ignore: cast_nullable_to_non_nullable
as List<ChoreOccurrenceDto>,mineOverdueCount: null == mineOverdueCount ? _self.mineOverdueCount : mineOverdueCount // ignore: cast_nullable_to_non_nullable
as int,houseOverdueCount: null == houseOverdueCount ? _self.houseOverdueCount : houseOverdueCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [HouseholdChoresDigestDto].
extension HouseholdChoresDigestDtoPatterns on HouseholdChoresDigestDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _HouseholdChoresDigestDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _HouseholdChoresDigestDto() when $default != null:
return $default(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _HouseholdChoresDigestDto value)  $default,){
final _that = this;
switch (_that) {
case _HouseholdChoresDigestDto():
return $default(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _HouseholdChoresDigestDto value)?  $default,){
final _that = this;
switch (_that) {
case _HouseholdChoresDigestDto() when $default != null:
return $default(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<ChoreOccurrenceDto> mine,  int mineOverdueCount,  int houseOverdueCount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _HouseholdChoresDigestDto() when $default != null:
return $default(_that.mine,_that.mineOverdueCount,_that.houseOverdueCount);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<ChoreOccurrenceDto> mine,  int mineOverdueCount,  int houseOverdueCount)  $default,) {final _that = this;
switch (_that) {
case _HouseholdChoresDigestDto():
return $default(_that.mine,_that.mineOverdueCount,_that.houseOverdueCount);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<ChoreOccurrenceDto> mine,  int mineOverdueCount,  int houseOverdueCount)?  $default,) {final _that = this;
switch (_that) {
case _HouseholdChoresDigestDto() when $default != null:
return $default(_that.mine,_that.mineOverdueCount,_that.houseOverdueCount);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _HouseholdChoresDigestDto implements HouseholdChoresDigestDto {
  const _HouseholdChoresDigestDto({final  List<ChoreOccurrenceDto> mine = const <ChoreOccurrenceDto>[], this.mineOverdueCount = 0, this.houseOverdueCount = 0}): _mine = mine;
  factory _HouseholdChoresDigestDto.fromJson(Map<String, dynamic> json) => _$HouseholdChoresDigestDtoFromJson(json);

/// Yours, due within a day or already past due. At most ten.
 final  List<ChoreOccurrenceDto> _mine;
/// Yours, due within a day or already past due. At most ten.
@override@JsonKey() List<ChoreOccurrenceDto> get mine {
  if (_mine is EqualUnmodifiableListView) return _mine;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_mine);
}

@override@JsonKey() final  int mineOverdueCount;
/// Everyone's, not just yours - a house that is behind is worth seeing.
@override@JsonKey() final  int houseOverdueCount;

/// Create a copy of HouseholdChoresDigestDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HouseholdChoresDigestDtoCopyWith<_HouseholdChoresDigestDto> get copyWith => __$HouseholdChoresDigestDtoCopyWithImpl<_HouseholdChoresDigestDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$HouseholdChoresDigestDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _HouseholdChoresDigestDto&&const DeepCollectionEquality().equals(other._mine, _mine)&&(identical(other.mineOverdueCount, mineOverdueCount) || other.mineOverdueCount == mineOverdueCount)&&(identical(other.houseOverdueCount, houseOverdueCount) || other.houseOverdueCount == houseOverdueCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_mine),mineOverdueCount,houseOverdueCount);

@override
String toString() {
  return 'HouseholdChoresDigestDto(mine: $mine, mineOverdueCount: $mineOverdueCount, houseOverdueCount: $houseOverdueCount)';
}


}

/// @nodoc
abstract mixin class _$HouseholdChoresDigestDtoCopyWith<$Res> implements $HouseholdChoresDigestDtoCopyWith<$Res> {
  factory _$HouseholdChoresDigestDtoCopyWith(_HouseholdChoresDigestDto value, $Res Function(_HouseholdChoresDigestDto) _then) = __$HouseholdChoresDigestDtoCopyWithImpl;
@override @useResult
$Res call({
 List<ChoreOccurrenceDto> mine, int mineOverdueCount, int houseOverdueCount
});




}
/// @nodoc
class __$HouseholdChoresDigestDtoCopyWithImpl<$Res>
    implements _$HouseholdChoresDigestDtoCopyWith<$Res> {
  __$HouseholdChoresDigestDtoCopyWithImpl(this._self, this._then);

  final _HouseholdChoresDigestDto _self;
  final $Res Function(_HouseholdChoresDigestDto) _then;

/// Create a copy of HouseholdChoresDigestDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? mine = null,Object? mineOverdueCount = null,Object? houseOverdueCount = null,}) {
  return _then(_HouseholdChoresDigestDto(
mine: null == mine ? _self._mine : mine // ignore: cast_nullable_to_non_nullable
as List<ChoreOccurrenceDto>,mineOverdueCount: null == mineOverdueCount ? _self.mineOverdueCount : mineOverdueCount // ignore: cast_nullable_to_non_nullable
as int,houseOverdueCount: null == houseOverdueCount ? _self.houseOverdueCount : houseOverdueCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$HouseholdListDigestDto {

 String get channelId; String get channelName; int get openCount; List<ListItemDto> get preview;
/// Create a copy of HouseholdListDigestDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HouseholdListDigestDtoCopyWith<HouseholdListDigestDto> get copyWith => _$HouseholdListDigestDtoCopyWithImpl<HouseholdListDigestDto>(this as HouseholdListDigestDto, _$identity);

  /// Serializes this HouseholdListDigestDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HouseholdListDigestDto&&(identical(other.channelId, channelId) || other.channelId == channelId)&&(identical(other.channelName, channelName) || other.channelName == channelName)&&(identical(other.openCount, openCount) || other.openCount == openCount)&&const DeepCollectionEquality().equals(other.preview, preview));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,channelId,channelName,openCount,const DeepCollectionEquality().hash(preview));

@override
String toString() {
  return 'HouseholdListDigestDto(channelId: $channelId, channelName: $channelName, openCount: $openCount, preview: $preview)';
}


}

/// @nodoc
abstract mixin class $HouseholdListDigestDtoCopyWith<$Res>  {
  factory $HouseholdListDigestDtoCopyWith(HouseholdListDigestDto value, $Res Function(HouseholdListDigestDto) _then) = _$HouseholdListDigestDtoCopyWithImpl;
@useResult
$Res call({
 String channelId, String channelName, int openCount, List<ListItemDto> preview
});




}
/// @nodoc
class _$HouseholdListDigestDtoCopyWithImpl<$Res>
    implements $HouseholdListDigestDtoCopyWith<$Res> {
  _$HouseholdListDigestDtoCopyWithImpl(this._self, this._then);

  final HouseholdListDigestDto _self;
  final $Res Function(HouseholdListDigestDto) _then;

/// Create a copy of HouseholdListDigestDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? channelId = null,Object? channelName = null,Object? openCount = null,Object? preview = null,}) {
  return _then(_self.copyWith(
channelId: null == channelId ? _self.channelId : channelId // ignore: cast_nullable_to_non_nullable
as String,channelName: null == channelName ? _self.channelName : channelName // ignore: cast_nullable_to_non_nullable
as String,openCount: null == openCount ? _self.openCount : openCount // ignore: cast_nullable_to_non_nullable
as int,preview: null == preview ? _self.preview : preview // ignore: cast_nullable_to_non_nullable
as List<ListItemDto>,
  ));
}

}


/// Adds pattern-matching-related methods to [HouseholdListDigestDto].
extension HouseholdListDigestDtoPatterns on HouseholdListDigestDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _HouseholdListDigestDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _HouseholdListDigestDto() when $default != null:
return $default(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _HouseholdListDigestDto value)  $default,){
final _that = this;
switch (_that) {
case _HouseholdListDigestDto():
return $default(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _HouseholdListDigestDto value)?  $default,){
final _that = this;
switch (_that) {
case _HouseholdListDigestDto() when $default != null:
return $default(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String channelId,  String channelName,  int openCount,  List<ListItemDto> preview)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _HouseholdListDigestDto() when $default != null:
return $default(_that.channelId,_that.channelName,_that.openCount,_that.preview);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String channelId,  String channelName,  int openCount,  List<ListItemDto> preview)  $default,) {final _that = this;
switch (_that) {
case _HouseholdListDigestDto():
return $default(_that.channelId,_that.channelName,_that.openCount,_that.preview);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String channelId,  String channelName,  int openCount,  List<ListItemDto> preview)?  $default,) {final _that = this;
switch (_that) {
case _HouseholdListDigestDto() when $default != null:
return $default(_that.channelId,_that.channelName,_that.openCount,_that.preview);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _HouseholdListDigestDto implements HouseholdListDigestDto {
  const _HouseholdListDigestDto({this.channelId = '', this.channelName = '', this.openCount = 0, final  List<ListItemDto> preview = const <ListItemDto>[]}): _preview = preview;
  factory _HouseholdListDigestDto.fromJson(Map<String, dynamic> json) => _$HouseholdListDigestDtoFromJson(json);

@override@JsonKey() final  String channelId;
@override@JsonKey() final  String channelName;
@override@JsonKey() final  int openCount;
 final  List<ListItemDto> _preview;
@override@JsonKey() List<ListItemDto> get preview {
  if (_preview is EqualUnmodifiableListView) return _preview;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_preview);
}


/// Create a copy of HouseholdListDigestDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HouseholdListDigestDtoCopyWith<_HouseholdListDigestDto> get copyWith => __$HouseholdListDigestDtoCopyWithImpl<_HouseholdListDigestDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$HouseholdListDigestDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _HouseholdListDigestDto&&(identical(other.channelId, channelId) || other.channelId == channelId)&&(identical(other.channelName, channelName) || other.channelName == channelName)&&(identical(other.openCount, openCount) || other.openCount == openCount)&&const DeepCollectionEquality().equals(other._preview, _preview));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,channelId,channelName,openCount,const DeepCollectionEquality().hash(_preview));

@override
String toString() {
  return 'HouseholdListDigestDto(channelId: $channelId, channelName: $channelName, openCount: $openCount, preview: $preview)';
}


}

/// @nodoc
abstract mixin class _$HouseholdListDigestDtoCopyWith<$Res> implements $HouseholdListDigestDtoCopyWith<$Res> {
  factory _$HouseholdListDigestDtoCopyWith(_HouseholdListDigestDto value, $Res Function(_HouseholdListDigestDto) _then) = __$HouseholdListDigestDtoCopyWithImpl;
@override @useResult
$Res call({
 String channelId, String channelName, int openCount, List<ListItemDto> preview
});




}
/// @nodoc
class __$HouseholdListDigestDtoCopyWithImpl<$Res>
    implements _$HouseholdListDigestDtoCopyWith<$Res> {
  __$HouseholdListDigestDtoCopyWithImpl(this._self, this._then);

  final _HouseholdListDigestDto _self;
  final $Res Function(_HouseholdListDigestDto) _then;

/// Create a copy of HouseholdListDigestDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? channelId = null,Object? channelName = null,Object? openCount = null,Object? preview = null,}) {
  return _then(_HouseholdListDigestDto(
channelId: null == channelId ? _self.channelId : channelId // ignore: cast_nullable_to_non_nullable
as String,channelName: null == channelName ? _self.channelName : channelName // ignore: cast_nullable_to_non_nullable
as String,openCount: null == openCount ? _self.openCount : openCount // ignore: cast_nullable_to_non_nullable
as int,preview: null == preview ? _self._preview : preview // ignore: cast_nullable_to_non_nullable
as List<ListItemDto>,
  ));
}


}


/// @nodoc
mixin _$HouseholdPantryDigestDto {

 int get expiringCount; List<PantryItemDto> get soonest;
/// Create a copy of HouseholdPantryDigestDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HouseholdPantryDigestDtoCopyWith<HouseholdPantryDigestDto> get copyWith => _$HouseholdPantryDigestDtoCopyWithImpl<HouseholdPantryDigestDto>(this as HouseholdPantryDigestDto, _$identity);

  /// Serializes this HouseholdPantryDigestDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HouseholdPantryDigestDto&&(identical(other.expiringCount, expiringCount) || other.expiringCount == expiringCount)&&const DeepCollectionEquality().equals(other.soonest, soonest));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,expiringCount,const DeepCollectionEquality().hash(soonest));

@override
String toString() {
  return 'HouseholdPantryDigestDto(expiringCount: $expiringCount, soonest: $soonest)';
}


}

/// @nodoc
abstract mixin class $HouseholdPantryDigestDtoCopyWith<$Res>  {
  factory $HouseholdPantryDigestDtoCopyWith(HouseholdPantryDigestDto value, $Res Function(HouseholdPantryDigestDto) _then) = _$HouseholdPantryDigestDtoCopyWithImpl;
@useResult
$Res call({
 int expiringCount, List<PantryItemDto> soonest
});




}
/// @nodoc
class _$HouseholdPantryDigestDtoCopyWithImpl<$Res>
    implements $HouseholdPantryDigestDtoCopyWith<$Res> {
  _$HouseholdPantryDigestDtoCopyWithImpl(this._self, this._then);

  final HouseholdPantryDigestDto _self;
  final $Res Function(HouseholdPantryDigestDto) _then;

/// Create a copy of HouseholdPantryDigestDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? expiringCount = null,Object? soonest = null,}) {
  return _then(_self.copyWith(
expiringCount: null == expiringCount ? _self.expiringCount : expiringCount // ignore: cast_nullable_to_non_nullable
as int,soonest: null == soonest ? _self.soonest : soonest // ignore: cast_nullable_to_non_nullable
as List<PantryItemDto>,
  ));
}

}


/// Adds pattern-matching-related methods to [HouseholdPantryDigestDto].
extension HouseholdPantryDigestDtoPatterns on HouseholdPantryDigestDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _HouseholdPantryDigestDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _HouseholdPantryDigestDto() when $default != null:
return $default(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _HouseholdPantryDigestDto value)  $default,){
final _that = this;
switch (_that) {
case _HouseholdPantryDigestDto():
return $default(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _HouseholdPantryDigestDto value)?  $default,){
final _that = this;
switch (_that) {
case _HouseholdPantryDigestDto() when $default != null:
return $default(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int expiringCount,  List<PantryItemDto> soonest)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _HouseholdPantryDigestDto() when $default != null:
return $default(_that.expiringCount,_that.soonest);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int expiringCount,  List<PantryItemDto> soonest)  $default,) {final _that = this;
switch (_that) {
case _HouseholdPantryDigestDto():
return $default(_that.expiringCount,_that.soonest);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int expiringCount,  List<PantryItemDto> soonest)?  $default,) {final _that = this;
switch (_that) {
case _HouseholdPantryDigestDto() when $default != null:
return $default(_that.expiringCount,_that.soonest);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _HouseholdPantryDigestDto implements HouseholdPantryDigestDto {
  const _HouseholdPantryDigestDto({this.expiringCount = 0, final  List<PantryItemDto> soonest = const <PantryItemDto>[]}): _soonest = soonest;
  factory _HouseholdPantryDigestDto.fromJson(Map<String, dynamic> json) => _$HouseholdPantryDigestDtoFromJson(json);

@override@JsonKey() final  int expiringCount;
 final  List<PantryItemDto> _soonest;
@override@JsonKey() List<PantryItemDto> get soonest {
  if (_soonest is EqualUnmodifiableListView) return _soonest;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_soonest);
}


/// Create a copy of HouseholdPantryDigestDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HouseholdPantryDigestDtoCopyWith<_HouseholdPantryDigestDto> get copyWith => __$HouseholdPantryDigestDtoCopyWithImpl<_HouseholdPantryDigestDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$HouseholdPantryDigestDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _HouseholdPantryDigestDto&&(identical(other.expiringCount, expiringCount) || other.expiringCount == expiringCount)&&const DeepCollectionEquality().equals(other._soonest, _soonest));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,expiringCount,const DeepCollectionEquality().hash(_soonest));

@override
String toString() {
  return 'HouseholdPantryDigestDto(expiringCount: $expiringCount, soonest: $soonest)';
}


}

/// @nodoc
abstract mixin class _$HouseholdPantryDigestDtoCopyWith<$Res> implements $HouseholdPantryDigestDtoCopyWith<$Res> {
  factory _$HouseholdPantryDigestDtoCopyWith(_HouseholdPantryDigestDto value, $Res Function(_HouseholdPantryDigestDto) _then) = __$HouseholdPantryDigestDtoCopyWithImpl;
@override @useResult
$Res call({
 int expiringCount, List<PantryItemDto> soonest
});




}
/// @nodoc
class __$HouseholdPantryDigestDtoCopyWithImpl<$Res>
    implements _$HouseholdPantryDigestDtoCopyWith<$Res> {
  __$HouseholdPantryDigestDtoCopyWithImpl(this._self, this._then);

  final _HouseholdPantryDigestDto _self;
  final $Res Function(_HouseholdPantryDigestDto) _then;

/// Create a copy of HouseholdPantryDigestDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? expiringCount = null,Object? soonest = null,}) {
  return _then(_HouseholdPantryDigestDto(
expiringCount: null == expiringCount ? _self.expiringCount : expiringCount // ignore: cast_nullable_to_non_nullable
as int,soonest: null == soonest ? _self._soonest : soonest // ignore: cast_nullable_to_non_nullable
as List<PantryItemDto>,
  ));
}


}


/// @nodoc
mixin _$HouseholdLedgerDigestDto {

 String get channelId; String get channelName; String get currency;/// **Your own position only**, in minor units. Positive means the house
/// owes you.
 int get myNetMinor;
/// Create a copy of HouseholdLedgerDigestDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HouseholdLedgerDigestDtoCopyWith<HouseholdLedgerDigestDto> get copyWith => _$HouseholdLedgerDigestDtoCopyWithImpl<HouseholdLedgerDigestDto>(this as HouseholdLedgerDigestDto, _$identity);

  /// Serializes this HouseholdLedgerDigestDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HouseholdLedgerDigestDto&&(identical(other.channelId, channelId) || other.channelId == channelId)&&(identical(other.channelName, channelName) || other.channelName == channelName)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.myNetMinor, myNetMinor) || other.myNetMinor == myNetMinor));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,channelId,channelName,currency,myNetMinor);

@override
String toString() {
  return 'HouseholdLedgerDigestDto(channelId: $channelId, channelName: $channelName, currency: $currency, myNetMinor: $myNetMinor)';
}


}

/// @nodoc
abstract mixin class $HouseholdLedgerDigestDtoCopyWith<$Res>  {
  factory $HouseholdLedgerDigestDtoCopyWith(HouseholdLedgerDigestDto value, $Res Function(HouseholdLedgerDigestDto) _then) = _$HouseholdLedgerDigestDtoCopyWithImpl;
@useResult
$Res call({
 String channelId, String channelName, String currency, int myNetMinor
});




}
/// @nodoc
class _$HouseholdLedgerDigestDtoCopyWithImpl<$Res>
    implements $HouseholdLedgerDigestDtoCopyWith<$Res> {
  _$HouseholdLedgerDigestDtoCopyWithImpl(this._self, this._then);

  final HouseholdLedgerDigestDto _self;
  final $Res Function(HouseholdLedgerDigestDto) _then;

/// Create a copy of HouseholdLedgerDigestDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? channelId = null,Object? channelName = null,Object? currency = null,Object? myNetMinor = null,}) {
  return _then(_self.copyWith(
channelId: null == channelId ? _self.channelId : channelId // ignore: cast_nullable_to_non_nullable
as String,channelName: null == channelName ? _self.channelName : channelName // ignore: cast_nullable_to_non_nullable
as String,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,myNetMinor: null == myNetMinor ? _self.myNetMinor : myNetMinor // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [HouseholdLedgerDigestDto].
extension HouseholdLedgerDigestDtoPatterns on HouseholdLedgerDigestDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _HouseholdLedgerDigestDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _HouseholdLedgerDigestDto() when $default != null:
return $default(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _HouseholdLedgerDigestDto value)  $default,){
final _that = this;
switch (_that) {
case _HouseholdLedgerDigestDto():
return $default(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _HouseholdLedgerDigestDto value)?  $default,){
final _that = this;
switch (_that) {
case _HouseholdLedgerDigestDto() when $default != null:
return $default(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String channelId,  String channelName,  String currency,  int myNetMinor)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _HouseholdLedgerDigestDto() when $default != null:
return $default(_that.channelId,_that.channelName,_that.currency,_that.myNetMinor);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String channelId,  String channelName,  String currency,  int myNetMinor)  $default,) {final _that = this;
switch (_that) {
case _HouseholdLedgerDigestDto():
return $default(_that.channelId,_that.channelName,_that.currency,_that.myNetMinor);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String channelId,  String channelName,  String currency,  int myNetMinor)?  $default,) {final _that = this;
switch (_that) {
case _HouseholdLedgerDigestDto() when $default != null:
return $default(_that.channelId,_that.channelName,_that.currency,_that.myNetMinor);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _HouseholdLedgerDigestDto implements HouseholdLedgerDigestDto {
  const _HouseholdLedgerDigestDto({this.channelId = '', this.channelName = '', this.currency = 'CHF', this.myNetMinor = 0});
  factory _HouseholdLedgerDigestDto.fromJson(Map<String, dynamic> json) => _$HouseholdLedgerDigestDtoFromJson(json);

@override@JsonKey() final  String channelId;
@override@JsonKey() final  String channelName;
@override@JsonKey() final  String currency;
/// **Your own position only**, in minor units. Positive means the house
/// owes you.
@override@JsonKey() final  int myNetMinor;

/// Create a copy of HouseholdLedgerDigestDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HouseholdLedgerDigestDtoCopyWith<_HouseholdLedgerDigestDto> get copyWith => __$HouseholdLedgerDigestDtoCopyWithImpl<_HouseholdLedgerDigestDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$HouseholdLedgerDigestDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _HouseholdLedgerDigestDto&&(identical(other.channelId, channelId) || other.channelId == channelId)&&(identical(other.channelName, channelName) || other.channelName == channelName)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.myNetMinor, myNetMinor) || other.myNetMinor == myNetMinor));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,channelId,channelName,currency,myNetMinor);

@override
String toString() {
  return 'HouseholdLedgerDigestDto(channelId: $channelId, channelName: $channelName, currency: $currency, myNetMinor: $myNetMinor)';
}


}

/// @nodoc
abstract mixin class _$HouseholdLedgerDigestDtoCopyWith<$Res> implements $HouseholdLedgerDigestDtoCopyWith<$Res> {
  factory _$HouseholdLedgerDigestDtoCopyWith(_HouseholdLedgerDigestDto value, $Res Function(_HouseholdLedgerDigestDto) _then) = __$HouseholdLedgerDigestDtoCopyWithImpl;
@override @useResult
$Res call({
 String channelId, String channelName, String currency, int myNetMinor
});




}
/// @nodoc
class __$HouseholdLedgerDigestDtoCopyWithImpl<$Res>
    implements _$HouseholdLedgerDigestDtoCopyWith<$Res> {
  __$HouseholdLedgerDigestDtoCopyWithImpl(this._self, this._then);

  final _HouseholdLedgerDigestDto _self;
  final $Res Function(_HouseholdLedgerDigestDto) _then;

/// Create a copy of HouseholdLedgerDigestDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? channelId = null,Object? channelName = null,Object? currency = null,Object? myNetMinor = null,}) {
  return _then(_HouseholdLedgerDigestDto(
channelId: null == channelId ? _self.channelId : channelId // ignore: cast_nullable_to_non_nullable
as String,channelName: null == channelName ? _self.channelName : channelName // ignore: cast_nullable_to_non_nullable
as String,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,myNetMinor: null == myNetMinor ? _self.myNetMinor : myNetMinor // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$HouseholdDecisionsDigestDto {

 int get openCount; List<HouseholdDecisionDigestEntryDto> get awaitingMyVote;
/// Create a copy of HouseholdDecisionsDigestDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HouseholdDecisionsDigestDtoCopyWith<HouseholdDecisionsDigestDto> get copyWith => _$HouseholdDecisionsDigestDtoCopyWithImpl<HouseholdDecisionsDigestDto>(this as HouseholdDecisionsDigestDto, _$identity);

  /// Serializes this HouseholdDecisionsDigestDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HouseholdDecisionsDigestDto&&(identical(other.openCount, openCount) || other.openCount == openCount)&&const DeepCollectionEquality().equals(other.awaitingMyVote, awaitingMyVote));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,openCount,const DeepCollectionEquality().hash(awaitingMyVote));

@override
String toString() {
  return 'HouseholdDecisionsDigestDto(openCount: $openCount, awaitingMyVote: $awaitingMyVote)';
}


}

/// @nodoc
abstract mixin class $HouseholdDecisionsDigestDtoCopyWith<$Res>  {
  factory $HouseholdDecisionsDigestDtoCopyWith(HouseholdDecisionsDigestDto value, $Res Function(HouseholdDecisionsDigestDto) _then) = _$HouseholdDecisionsDigestDtoCopyWithImpl;
@useResult
$Res call({
 int openCount, List<HouseholdDecisionDigestEntryDto> awaitingMyVote
});




}
/// @nodoc
class _$HouseholdDecisionsDigestDtoCopyWithImpl<$Res>
    implements $HouseholdDecisionsDigestDtoCopyWith<$Res> {
  _$HouseholdDecisionsDigestDtoCopyWithImpl(this._self, this._then);

  final HouseholdDecisionsDigestDto _self;
  final $Res Function(HouseholdDecisionsDigestDto) _then;

/// Create a copy of HouseholdDecisionsDigestDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? openCount = null,Object? awaitingMyVote = null,}) {
  return _then(_self.copyWith(
openCount: null == openCount ? _self.openCount : openCount // ignore: cast_nullable_to_non_nullable
as int,awaitingMyVote: null == awaitingMyVote ? _self.awaitingMyVote : awaitingMyVote // ignore: cast_nullable_to_non_nullable
as List<HouseholdDecisionDigestEntryDto>,
  ));
}

}


/// Adds pattern-matching-related methods to [HouseholdDecisionsDigestDto].
extension HouseholdDecisionsDigestDtoPatterns on HouseholdDecisionsDigestDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _HouseholdDecisionsDigestDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _HouseholdDecisionsDigestDto() when $default != null:
return $default(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _HouseholdDecisionsDigestDto value)  $default,){
final _that = this;
switch (_that) {
case _HouseholdDecisionsDigestDto():
return $default(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _HouseholdDecisionsDigestDto value)?  $default,){
final _that = this;
switch (_that) {
case _HouseholdDecisionsDigestDto() when $default != null:
return $default(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int openCount,  List<HouseholdDecisionDigestEntryDto> awaitingMyVote)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _HouseholdDecisionsDigestDto() when $default != null:
return $default(_that.openCount,_that.awaitingMyVote);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int openCount,  List<HouseholdDecisionDigestEntryDto> awaitingMyVote)  $default,) {final _that = this;
switch (_that) {
case _HouseholdDecisionsDigestDto():
return $default(_that.openCount,_that.awaitingMyVote);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int openCount,  List<HouseholdDecisionDigestEntryDto> awaitingMyVote)?  $default,) {final _that = this;
switch (_that) {
case _HouseholdDecisionsDigestDto() when $default != null:
return $default(_that.openCount,_that.awaitingMyVote);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _HouseholdDecisionsDigestDto implements HouseholdDecisionsDigestDto {
  const _HouseholdDecisionsDigestDto({this.openCount = 0, final  List<HouseholdDecisionDigestEntryDto> awaitingMyVote = const <HouseholdDecisionDigestEntryDto>[]}): _awaitingMyVote = awaitingMyVote;
  factory _HouseholdDecisionsDigestDto.fromJson(Map<String, dynamic> json) => _$HouseholdDecisionsDigestDtoFromJson(json);

@override@JsonKey() final  int openCount;
 final  List<HouseholdDecisionDigestEntryDto> _awaitingMyVote;
@override@JsonKey() List<HouseholdDecisionDigestEntryDto> get awaitingMyVote {
  if (_awaitingMyVote is EqualUnmodifiableListView) return _awaitingMyVote;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_awaitingMyVote);
}


/// Create a copy of HouseholdDecisionsDigestDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HouseholdDecisionsDigestDtoCopyWith<_HouseholdDecisionsDigestDto> get copyWith => __$HouseholdDecisionsDigestDtoCopyWithImpl<_HouseholdDecisionsDigestDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$HouseholdDecisionsDigestDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _HouseholdDecisionsDigestDto&&(identical(other.openCount, openCount) || other.openCount == openCount)&&const DeepCollectionEquality().equals(other._awaitingMyVote, _awaitingMyVote));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,openCount,const DeepCollectionEquality().hash(_awaitingMyVote));

@override
String toString() {
  return 'HouseholdDecisionsDigestDto(openCount: $openCount, awaitingMyVote: $awaitingMyVote)';
}


}

/// @nodoc
abstract mixin class _$HouseholdDecisionsDigestDtoCopyWith<$Res> implements $HouseholdDecisionsDigestDtoCopyWith<$Res> {
  factory _$HouseholdDecisionsDigestDtoCopyWith(_HouseholdDecisionsDigestDto value, $Res Function(_HouseholdDecisionsDigestDto) _then) = __$HouseholdDecisionsDigestDtoCopyWithImpl;
@override @useResult
$Res call({
 int openCount, List<HouseholdDecisionDigestEntryDto> awaitingMyVote
});




}
/// @nodoc
class __$HouseholdDecisionsDigestDtoCopyWithImpl<$Res>
    implements _$HouseholdDecisionsDigestDtoCopyWith<$Res> {
  __$HouseholdDecisionsDigestDtoCopyWithImpl(this._self, this._then);

  final _HouseholdDecisionsDigestDto _self;
  final $Res Function(_HouseholdDecisionsDigestDto) _then;

/// Create a copy of HouseholdDecisionsDigestDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? openCount = null,Object? awaitingMyVote = null,}) {
  return _then(_HouseholdDecisionsDigestDto(
openCount: null == openCount ? _self.openCount : openCount // ignore: cast_nullable_to_non_nullable
as int,awaitingMyVote: null == awaitingMyVote ? _self._awaitingMyVote : awaitingMyVote // ignore: cast_nullable_to_non_nullable
as List<HouseholdDecisionDigestEntryDto>,
  ));
}


}


/// @nodoc
mixin _$HouseholdDecisionDigestEntryDto {

 String get id; String get channelId; String get title; DateTime? get closesAt;
/// Create a copy of HouseholdDecisionDigestEntryDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HouseholdDecisionDigestEntryDtoCopyWith<HouseholdDecisionDigestEntryDto> get copyWith => _$HouseholdDecisionDigestEntryDtoCopyWithImpl<HouseholdDecisionDigestEntryDto>(this as HouseholdDecisionDigestEntryDto, _$identity);

  /// Serializes this HouseholdDecisionDigestEntryDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HouseholdDecisionDigestEntryDto&&(identical(other.id, id) || other.id == id)&&(identical(other.channelId, channelId) || other.channelId == channelId)&&(identical(other.title, title) || other.title == title)&&(identical(other.closesAt, closesAt) || other.closesAt == closesAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,channelId,title,closesAt);

@override
String toString() {
  return 'HouseholdDecisionDigestEntryDto(id: $id, channelId: $channelId, title: $title, closesAt: $closesAt)';
}


}

/// @nodoc
abstract mixin class $HouseholdDecisionDigestEntryDtoCopyWith<$Res>  {
  factory $HouseholdDecisionDigestEntryDtoCopyWith(HouseholdDecisionDigestEntryDto value, $Res Function(HouseholdDecisionDigestEntryDto) _then) = _$HouseholdDecisionDigestEntryDtoCopyWithImpl;
@useResult
$Res call({
 String id, String channelId, String title, DateTime? closesAt
});




}
/// @nodoc
class _$HouseholdDecisionDigestEntryDtoCopyWithImpl<$Res>
    implements $HouseholdDecisionDigestEntryDtoCopyWith<$Res> {
  _$HouseholdDecisionDigestEntryDtoCopyWithImpl(this._self, this._then);

  final HouseholdDecisionDigestEntryDto _self;
  final $Res Function(HouseholdDecisionDigestEntryDto) _then;

/// Create a copy of HouseholdDecisionDigestEntryDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? channelId = null,Object? title = null,Object? closesAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,channelId: null == channelId ? _self.channelId : channelId // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,closesAt: freezed == closesAt ? _self.closesAt : closesAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [HouseholdDecisionDigestEntryDto].
extension HouseholdDecisionDigestEntryDtoPatterns on HouseholdDecisionDigestEntryDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _HouseholdDecisionDigestEntryDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _HouseholdDecisionDigestEntryDto() when $default != null:
return $default(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _HouseholdDecisionDigestEntryDto value)  $default,){
final _that = this;
switch (_that) {
case _HouseholdDecisionDigestEntryDto():
return $default(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _HouseholdDecisionDigestEntryDto value)?  $default,){
final _that = this;
switch (_that) {
case _HouseholdDecisionDigestEntryDto() when $default != null:
return $default(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String channelId,  String title,  DateTime? closesAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _HouseholdDecisionDigestEntryDto() when $default != null:
return $default(_that.id,_that.channelId,_that.title,_that.closesAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String channelId,  String title,  DateTime? closesAt)  $default,) {final _that = this;
switch (_that) {
case _HouseholdDecisionDigestEntryDto():
return $default(_that.id,_that.channelId,_that.title,_that.closesAt);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String channelId,  String title,  DateTime? closesAt)?  $default,) {final _that = this;
switch (_that) {
case _HouseholdDecisionDigestEntryDto() when $default != null:
return $default(_that.id,_that.channelId,_that.title,_that.closesAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()
@ApiDateTimeConverter()
class _HouseholdDecisionDigestEntryDto implements HouseholdDecisionDigestEntryDto {
  const _HouseholdDecisionDigestEntryDto({this.id = '', this.channelId = '', this.title = '', this.closesAt});
  factory _HouseholdDecisionDigestEntryDto.fromJson(Map<String, dynamic> json) => _$HouseholdDecisionDigestEntryDtoFromJson(json);

@override@JsonKey() final  String id;
@override@JsonKey() final  String channelId;
@override@JsonKey() final  String title;
@override final  DateTime? closesAt;

/// Create a copy of HouseholdDecisionDigestEntryDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HouseholdDecisionDigestEntryDtoCopyWith<_HouseholdDecisionDigestEntryDto> get copyWith => __$HouseholdDecisionDigestEntryDtoCopyWithImpl<_HouseholdDecisionDigestEntryDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$HouseholdDecisionDigestEntryDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _HouseholdDecisionDigestEntryDto&&(identical(other.id, id) || other.id == id)&&(identical(other.channelId, channelId) || other.channelId == channelId)&&(identical(other.title, title) || other.title == title)&&(identical(other.closesAt, closesAt) || other.closesAt == closesAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,channelId,title,closesAt);

@override
String toString() {
  return 'HouseholdDecisionDigestEntryDto(id: $id, channelId: $channelId, title: $title, closesAt: $closesAt)';
}


}

/// @nodoc
abstract mixin class _$HouseholdDecisionDigestEntryDtoCopyWith<$Res> implements $HouseholdDecisionDigestEntryDtoCopyWith<$Res> {
  factory _$HouseholdDecisionDigestEntryDtoCopyWith(_HouseholdDecisionDigestEntryDto value, $Res Function(_HouseholdDecisionDigestEntryDto) _then) = __$HouseholdDecisionDigestEntryDtoCopyWithImpl;
@override @useResult
$Res call({
 String id, String channelId, String title, DateTime? closesAt
});




}
/// @nodoc
class __$HouseholdDecisionDigestEntryDtoCopyWithImpl<$Res>
    implements _$HouseholdDecisionDigestEntryDtoCopyWith<$Res> {
  __$HouseholdDecisionDigestEntryDtoCopyWithImpl(this._self, this._then);

  final _HouseholdDecisionDigestEntryDto _self;
  final $Res Function(_HouseholdDecisionDigestEntryDto) _then;

/// Create a copy of HouseholdDecisionDigestEntryDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? channelId = null,Object? title = null,Object? closesAt = freezed,}) {
  return _then(_HouseholdDecisionDigestEntryDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,channelId: null == channelId ? _self.channelId : channelId // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,closesAt: freezed == closesAt ? _self.closesAt : closesAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
