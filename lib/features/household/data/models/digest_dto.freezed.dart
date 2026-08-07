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
 List<HomeStatusDto>? get homeStatus;/// What the house owes and when, from the ledger channels the caller can
/// see.
 HouseholdBillsDigestDto? get bills; HouseholdMealsDigestDto? get meals; HouseholdMaintenanceDigestDto? get maintenance;/// Who is away right now, and until when.
///
/// Beside [homeStatus] and deliberately not folded into it. Home status is
/// a decaying assertion about this minute; an absence is a dated plan the
/// rota reads. Merging them would give a fortnight in Lisbon an expiry it
/// does not have, or "back in an hour" a permanence it must not have.
 List<HouseholdAbsenceDigestDto>? get away;
/// Create a copy of HouseholdDigestDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HouseholdDigestDtoCopyWith<HouseholdDigestDto> get copyWith => _$HouseholdDigestDtoCopyWithImpl<HouseholdDigestDto>(this as HouseholdDigestDto, _$identity);

  /// Serializes this HouseholdDigestDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HouseholdDigestDto&&(identical(other.guildId, guildId) || other.guildId == guildId)&&(identical(other.chores, chores) || other.chores == chores)&&const DeepCollectionEquality().equals(other.lists, lists)&&(identical(other.pantry, pantry) || other.pantry == pantry)&&const DeepCollectionEquality().equals(other.ledger, ledger)&&(identical(other.decisions, decisions) || other.decisions == decisions)&&const DeepCollectionEquality().equals(other.homeStatus, homeStatus)&&(identical(other.bills, bills) || other.bills == bills)&&(identical(other.meals, meals) || other.meals == meals)&&(identical(other.maintenance, maintenance) || other.maintenance == maintenance)&&const DeepCollectionEquality().equals(other.away, away));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,guildId,chores,const DeepCollectionEquality().hash(lists),pantry,const DeepCollectionEquality().hash(ledger),decisions,const DeepCollectionEquality().hash(homeStatus),bills,meals,maintenance,const DeepCollectionEquality().hash(away));

@override
String toString() {
  return 'HouseholdDigestDto(guildId: $guildId, chores: $chores, lists: $lists, pantry: $pantry, ledger: $ledger, decisions: $decisions, homeStatus: $homeStatus, bills: $bills, meals: $meals, maintenance: $maintenance, away: $away)';
}


}

/// @nodoc
abstract mixin class $HouseholdDigestDtoCopyWith<$Res>  {
  factory $HouseholdDigestDtoCopyWith(HouseholdDigestDto value, $Res Function(HouseholdDigestDto) _then) = _$HouseholdDigestDtoCopyWithImpl;
@useResult
$Res call({
 String guildId, HouseholdChoresDigestDto? chores, List<HouseholdListDigestDto>? lists, HouseholdPantryDigestDto? pantry, List<HouseholdLedgerDigestDto>? ledger, HouseholdDecisionsDigestDto? decisions, List<HomeStatusDto>? homeStatus, HouseholdBillsDigestDto? bills, HouseholdMealsDigestDto? meals, HouseholdMaintenanceDigestDto? maintenance, List<HouseholdAbsenceDigestDto>? away
});


$HouseholdChoresDigestDtoCopyWith<$Res>? get chores;$HouseholdPantryDigestDtoCopyWith<$Res>? get pantry;$HouseholdDecisionsDigestDtoCopyWith<$Res>? get decisions;$HouseholdBillsDigestDtoCopyWith<$Res>? get bills;$HouseholdMealsDigestDtoCopyWith<$Res>? get meals;$HouseholdMaintenanceDigestDtoCopyWith<$Res>? get maintenance;

}
/// @nodoc
class _$HouseholdDigestDtoCopyWithImpl<$Res>
    implements $HouseholdDigestDtoCopyWith<$Res> {
  _$HouseholdDigestDtoCopyWithImpl(this._self, this._then);

  final HouseholdDigestDto _self;
  final $Res Function(HouseholdDigestDto) _then;

/// Create a copy of HouseholdDigestDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? guildId = null,Object? chores = freezed,Object? lists = freezed,Object? pantry = freezed,Object? ledger = freezed,Object? decisions = freezed,Object? homeStatus = freezed,Object? bills = freezed,Object? meals = freezed,Object? maintenance = freezed,Object? away = freezed,}) {
  return _then(_self.copyWith(
guildId: null == guildId ? _self.guildId : guildId // ignore: cast_nullable_to_non_nullable
as String,chores: freezed == chores ? _self.chores : chores // ignore: cast_nullable_to_non_nullable
as HouseholdChoresDigestDto?,lists: freezed == lists ? _self.lists : lists // ignore: cast_nullable_to_non_nullable
as List<HouseholdListDigestDto>?,pantry: freezed == pantry ? _self.pantry : pantry // ignore: cast_nullable_to_non_nullable
as HouseholdPantryDigestDto?,ledger: freezed == ledger ? _self.ledger : ledger // ignore: cast_nullable_to_non_nullable
as List<HouseholdLedgerDigestDto>?,decisions: freezed == decisions ? _self.decisions : decisions // ignore: cast_nullable_to_non_nullable
as HouseholdDecisionsDigestDto?,homeStatus: freezed == homeStatus ? _self.homeStatus : homeStatus // ignore: cast_nullable_to_non_nullable
as List<HomeStatusDto>?,bills: freezed == bills ? _self.bills : bills // ignore: cast_nullable_to_non_nullable
as HouseholdBillsDigestDto?,meals: freezed == meals ? _self.meals : meals // ignore: cast_nullable_to_non_nullable
as HouseholdMealsDigestDto?,maintenance: freezed == maintenance ? _self.maintenance : maintenance // ignore: cast_nullable_to_non_nullable
as HouseholdMaintenanceDigestDto?,away: freezed == away ? _self.away : away // ignore: cast_nullable_to_non_nullable
as List<HouseholdAbsenceDigestDto>?,
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
}/// Create a copy of HouseholdDigestDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$HouseholdBillsDigestDtoCopyWith<$Res>? get bills {
    if (_self.bills == null) {
    return null;
  }

  return $HouseholdBillsDigestDtoCopyWith<$Res>(_self.bills!, (value) {
    return _then(_self.copyWith(bills: value));
  });
}/// Create a copy of HouseholdDigestDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$HouseholdMealsDigestDtoCopyWith<$Res>? get meals {
    if (_self.meals == null) {
    return null;
  }

  return $HouseholdMealsDigestDtoCopyWith<$Res>(_self.meals!, (value) {
    return _then(_self.copyWith(meals: value));
  });
}/// Create a copy of HouseholdDigestDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$HouseholdMaintenanceDigestDtoCopyWith<$Res>? get maintenance {
    if (_self.maintenance == null) {
    return null;
  }

  return $HouseholdMaintenanceDigestDtoCopyWith<$Res>(_self.maintenance!, (value) {
    return _then(_self.copyWith(maintenance: value));
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String guildId,  HouseholdChoresDigestDto? chores,  List<HouseholdListDigestDto>? lists,  HouseholdPantryDigestDto? pantry,  List<HouseholdLedgerDigestDto>? ledger,  HouseholdDecisionsDigestDto? decisions,  List<HomeStatusDto>? homeStatus,  HouseholdBillsDigestDto? bills,  HouseholdMealsDigestDto? meals,  HouseholdMaintenanceDigestDto? maintenance,  List<HouseholdAbsenceDigestDto>? away)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _HouseholdDigestDto() when $default != null:
return $default(_that.guildId,_that.chores,_that.lists,_that.pantry,_that.ledger,_that.decisions,_that.homeStatus,_that.bills,_that.meals,_that.maintenance,_that.away);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String guildId,  HouseholdChoresDigestDto? chores,  List<HouseholdListDigestDto>? lists,  HouseholdPantryDigestDto? pantry,  List<HouseholdLedgerDigestDto>? ledger,  HouseholdDecisionsDigestDto? decisions,  List<HomeStatusDto>? homeStatus,  HouseholdBillsDigestDto? bills,  HouseholdMealsDigestDto? meals,  HouseholdMaintenanceDigestDto? maintenance,  List<HouseholdAbsenceDigestDto>? away)  $default,) {final _that = this;
switch (_that) {
case _HouseholdDigestDto():
return $default(_that.guildId,_that.chores,_that.lists,_that.pantry,_that.ledger,_that.decisions,_that.homeStatus,_that.bills,_that.meals,_that.maintenance,_that.away);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String guildId,  HouseholdChoresDigestDto? chores,  List<HouseholdListDigestDto>? lists,  HouseholdPantryDigestDto? pantry,  List<HouseholdLedgerDigestDto>? ledger,  HouseholdDecisionsDigestDto? decisions,  List<HomeStatusDto>? homeStatus,  HouseholdBillsDigestDto? bills,  HouseholdMealsDigestDto? meals,  HouseholdMaintenanceDigestDto? maintenance,  List<HouseholdAbsenceDigestDto>? away)?  $default,) {final _that = this;
switch (_that) {
case _HouseholdDigestDto() when $default != null:
return $default(_that.guildId,_that.chores,_that.lists,_that.pantry,_that.ledger,_that.decisions,_that.homeStatus,_that.bills,_that.meals,_that.maintenance,_that.away);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _HouseholdDigestDto implements HouseholdDigestDto {
  const _HouseholdDigestDto({this.guildId = '', this.chores, final  List<HouseholdListDigestDto>? lists, this.pantry, final  List<HouseholdLedgerDigestDto>? ledger, this.decisions, final  List<HomeStatusDto>? homeStatus, this.bills, this.meals, this.maintenance, final  List<HouseholdAbsenceDigestDto>? away}): _lists = lists,_ledger = ledger,_homeStatus = homeStatus,_away = away;
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

/// What the house owes and when, from the ledger channels the caller can
/// see.
@override final  HouseholdBillsDigestDto? bills;
@override final  HouseholdMealsDigestDto? meals;
@override final  HouseholdMaintenanceDigestDto? maintenance;
/// Who is away right now, and until when.
///
/// Beside [homeStatus] and deliberately not folded into it. Home status is
/// a decaying assertion about this minute; an absence is a dated plan the
/// rota reads. Merging them would give a fortnight in Lisbon an expiry it
/// does not have, or "back in an hour" a permanence it must not have.
 final  List<HouseholdAbsenceDigestDto>? _away;
/// Who is away right now, and until when.
///
/// Beside [homeStatus] and deliberately not folded into it. Home status is
/// a decaying assertion about this minute; an absence is a dated plan the
/// rota reads. Merging them would give a fortnight in Lisbon an expiry it
/// does not have, or "back in an hour" a permanence it must not have.
@override List<HouseholdAbsenceDigestDto>? get away {
  final value = _away;
  if (value == null) return null;
  if (_away is EqualUnmodifiableListView) return _away;
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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _HouseholdDigestDto&&(identical(other.guildId, guildId) || other.guildId == guildId)&&(identical(other.chores, chores) || other.chores == chores)&&const DeepCollectionEquality().equals(other._lists, _lists)&&(identical(other.pantry, pantry) || other.pantry == pantry)&&const DeepCollectionEquality().equals(other._ledger, _ledger)&&(identical(other.decisions, decisions) || other.decisions == decisions)&&const DeepCollectionEquality().equals(other._homeStatus, _homeStatus)&&(identical(other.bills, bills) || other.bills == bills)&&(identical(other.meals, meals) || other.meals == meals)&&(identical(other.maintenance, maintenance) || other.maintenance == maintenance)&&const DeepCollectionEquality().equals(other._away, _away));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,guildId,chores,const DeepCollectionEquality().hash(_lists),pantry,const DeepCollectionEquality().hash(_ledger),decisions,const DeepCollectionEquality().hash(_homeStatus),bills,meals,maintenance,const DeepCollectionEquality().hash(_away));

@override
String toString() {
  return 'HouseholdDigestDto(guildId: $guildId, chores: $chores, lists: $lists, pantry: $pantry, ledger: $ledger, decisions: $decisions, homeStatus: $homeStatus, bills: $bills, meals: $meals, maintenance: $maintenance, away: $away)';
}


}

/// @nodoc
abstract mixin class _$HouseholdDigestDtoCopyWith<$Res> implements $HouseholdDigestDtoCopyWith<$Res> {
  factory _$HouseholdDigestDtoCopyWith(_HouseholdDigestDto value, $Res Function(_HouseholdDigestDto) _then) = __$HouseholdDigestDtoCopyWithImpl;
@override @useResult
$Res call({
 String guildId, HouseholdChoresDigestDto? chores, List<HouseholdListDigestDto>? lists, HouseholdPantryDigestDto? pantry, List<HouseholdLedgerDigestDto>? ledger, HouseholdDecisionsDigestDto? decisions, List<HomeStatusDto>? homeStatus, HouseholdBillsDigestDto? bills, HouseholdMealsDigestDto? meals, HouseholdMaintenanceDigestDto? maintenance, List<HouseholdAbsenceDigestDto>? away
});


@override $HouseholdChoresDigestDtoCopyWith<$Res>? get chores;@override $HouseholdPantryDigestDtoCopyWith<$Res>? get pantry;@override $HouseholdDecisionsDigestDtoCopyWith<$Res>? get decisions;@override $HouseholdBillsDigestDtoCopyWith<$Res>? get bills;@override $HouseholdMealsDigestDtoCopyWith<$Res>? get meals;@override $HouseholdMaintenanceDigestDtoCopyWith<$Res>? get maintenance;

}
/// @nodoc
class __$HouseholdDigestDtoCopyWithImpl<$Res>
    implements _$HouseholdDigestDtoCopyWith<$Res> {
  __$HouseholdDigestDtoCopyWithImpl(this._self, this._then);

  final _HouseholdDigestDto _self;
  final $Res Function(_HouseholdDigestDto) _then;

/// Create a copy of HouseholdDigestDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? guildId = null,Object? chores = freezed,Object? lists = freezed,Object? pantry = freezed,Object? ledger = freezed,Object? decisions = freezed,Object? homeStatus = freezed,Object? bills = freezed,Object? meals = freezed,Object? maintenance = freezed,Object? away = freezed,}) {
  return _then(_HouseholdDigestDto(
guildId: null == guildId ? _self.guildId : guildId // ignore: cast_nullable_to_non_nullable
as String,chores: freezed == chores ? _self.chores : chores // ignore: cast_nullable_to_non_nullable
as HouseholdChoresDigestDto?,lists: freezed == lists ? _self._lists : lists // ignore: cast_nullable_to_non_nullable
as List<HouseholdListDigestDto>?,pantry: freezed == pantry ? _self.pantry : pantry // ignore: cast_nullable_to_non_nullable
as HouseholdPantryDigestDto?,ledger: freezed == ledger ? _self._ledger : ledger // ignore: cast_nullable_to_non_nullable
as List<HouseholdLedgerDigestDto>?,decisions: freezed == decisions ? _self.decisions : decisions // ignore: cast_nullable_to_non_nullable
as HouseholdDecisionsDigestDto?,homeStatus: freezed == homeStatus ? _self._homeStatus : homeStatus // ignore: cast_nullable_to_non_nullable
as List<HomeStatusDto>?,bills: freezed == bills ? _self.bills : bills // ignore: cast_nullable_to_non_nullable
as HouseholdBillsDigestDto?,meals: freezed == meals ? _self.meals : meals // ignore: cast_nullable_to_non_nullable
as HouseholdMealsDigestDto?,maintenance: freezed == maintenance ? _self.maintenance : maintenance // ignore: cast_nullable_to_non_nullable
as HouseholdMaintenanceDigestDto?,away: freezed == away ? _self._away : away // ignore: cast_nullable_to_non_nullable
as List<HouseholdAbsenceDigestDto>?,
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
}/// Create a copy of HouseholdDigestDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$HouseholdBillsDigestDtoCopyWith<$Res>? get bills {
    if (_self.bills == null) {
    return null;
  }

  return $HouseholdBillsDigestDtoCopyWith<$Res>(_self.bills!, (value) {
    return _then(_self.copyWith(bills: value));
  });
}/// Create a copy of HouseholdDigestDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$HouseholdMealsDigestDtoCopyWith<$Res>? get meals {
    if (_self.meals == null) {
    return null;
  }

  return $HouseholdMealsDigestDtoCopyWith<$Res>(_self.meals!, (value) {
    return _then(_self.copyWith(meals: value));
  });
}/// Create a copy of HouseholdDigestDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$HouseholdMaintenanceDigestDtoCopyWith<$Res>? get maintenance {
    if (_self.maintenance == null) {
    return null;
  }

  return $HouseholdMaintenanceDigestDtoCopyWith<$Res>(_self.maintenance!, (value) {
    return _then(_self.copyWith(maintenance: value));
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


/// @nodoc
mixin _$HouseholdBillsDigestDto {

/// Pending bills due inside the next fortnight, soonest first, with
/// anything already late at the top - an overdue bill is still a bill that
/// is due, and pulling it out to count separately would leave the most
/// urgent row off the glance.
 List<HouseholdBillDigestEntryDto> get dueSoon; int get overdueCount;/// Variable bills that came due with nobody having said what they cost.
/// Counted apart from [overdueCount] because the action is different: one
/// needs money moved, the other needs somebody to open the post.
 int get needsAmountCount;
/// Create a copy of HouseholdBillsDigestDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HouseholdBillsDigestDtoCopyWith<HouseholdBillsDigestDto> get copyWith => _$HouseholdBillsDigestDtoCopyWithImpl<HouseholdBillsDigestDto>(this as HouseholdBillsDigestDto, _$identity);

  /// Serializes this HouseholdBillsDigestDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HouseholdBillsDigestDto&&const DeepCollectionEquality().equals(other.dueSoon, dueSoon)&&(identical(other.overdueCount, overdueCount) || other.overdueCount == overdueCount)&&(identical(other.needsAmountCount, needsAmountCount) || other.needsAmountCount == needsAmountCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(dueSoon),overdueCount,needsAmountCount);

@override
String toString() {
  return 'HouseholdBillsDigestDto(dueSoon: $dueSoon, overdueCount: $overdueCount, needsAmountCount: $needsAmountCount)';
}


}

/// @nodoc
abstract mixin class $HouseholdBillsDigestDtoCopyWith<$Res>  {
  factory $HouseholdBillsDigestDtoCopyWith(HouseholdBillsDigestDto value, $Res Function(HouseholdBillsDigestDto) _then) = _$HouseholdBillsDigestDtoCopyWithImpl;
@useResult
$Res call({
 List<HouseholdBillDigestEntryDto> dueSoon, int overdueCount, int needsAmountCount
});




}
/// @nodoc
class _$HouseholdBillsDigestDtoCopyWithImpl<$Res>
    implements $HouseholdBillsDigestDtoCopyWith<$Res> {
  _$HouseholdBillsDigestDtoCopyWithImpl(this._self, this._then);

  final HouseholdBillsDigestDto _self;
  final $Res Function(HouseholdBillsDigestDto) _then;

/// Create a copy of HouseholdBillsDigestDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? dueSoon = null,Object? overdueCount = null,Object? needsAmountCount = null,}) {
  return _then(_self.copyWith(
dueSoon: null == dueSoon ? _self.dueSoon : dueSoon // ignore: cast_nullable_to_non_nullable
as List<HouseholdBillDigestEntryDto>,overdueCount: null == overdueCount ? _self.overdueCount : overdueCount // ignore: cast_nullable_to_non_nullable
as int,needsAmountCount: null == needsAmountCount ? _self.needsAmountCount : needsAmountCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [HouseholdBillsDigestDto].
extension HouseholdBillsDigestDtoPatterns on HouseholdBillsDigestDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _HouseholdBillsDigestDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _HouseholdBillsDigestDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _HouseholdBillsDigestDto value)  $default,){
final _that = this;
switch (_that) {
case _HouseholdBillsDigestDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _HouseholdBillsDigestDto value)?  $default,){
final _that = this;
switch (_that) {
case _HouseholdBillsDigestDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<HouseholdBillDigestEntryDto> dueSoon,  int overdueCount,  int needsAmountCount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _HouseholdBillsDigestDto() when $default != null:
return $default(_that.dueSoon,_that.overdueCount,_that.needsAmountCount);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<HouseholdBillDigestEntryDto> dueSoon,  int overdueCount,  int needsAmountCount)  $default,) {final _that = this;
switch (_that) {
case _HouseholdBillsDigestDto():
return $default(_that.dueSoon,_that.overdueCount,_that.needsAmountCount);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<HouseholdBillDigestEntryDto> dueSoon,  int overdueCount,  int needsAmountCount)?  $default,) {final _that = this;
switch (_that) {
case _HouseholdBillsDigestDto() when $default != null:
return $default(_that.dueSoon,_that.overdueCount,_that.needsAmountCount);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _HouseholdBillsDigestDto implements HouseholdBillsDigestDto {
  const _HouseholdBillsDigestDto({final  List<HouseholdBillDigestEntryDto> dueSoon = const <HouseholdBillDigestEntryDto>[], this.overdueCount = 0, this.needsAmountCount = 0}): _dueSoon = dueSoon;
  factory _HouseholdBillsDigestDto.fromJson(Map<String, dynamic> json) => _$HouseholdBillsDigestDtoFromJson(json);

/// Pending bills due inside the next fortnight, soonest first, with
/// anything already late at the top - an overdue bill is still a bill that
/// is due, and pulling it out to count separately would leave the most
/// urgent row off the glance.
 final  List<HouseholdBillDigestEntryDto> _dueSoon;
/// Pending bills due inside the next fortnight, soonest first, with
/// anything already late at the top - an overdue bill is still a bill that
/// is due, and pulling it out to count separately would leave the most
/// urgent row off the glance.
@override@JsonKey() List<HouseholdBillDigestEntryDto> get dueSoon {
  if (_dueSoon is EqualUnmodifiableListView) return _dueSoon;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_dueSoon);
}

@override@JsonKey() final  int overdueCount;
/// Variable bills that came due with nobody having said what they cost.
/// Counted apart from [overdueCount] because the action is different: one
/// needs money moved, the other needs somebody to open the post.
@override@JsonKey() final  int needsAmountCount;

/// Create a copy of HouseholdBillsDigestDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HouseholdBillsDigestDtoCopyWith<_HouseholdBillsDigestDto> get copyWith => __$HouseholdBillsDigestDtoCopyWithImpl<_HouseholdBillsDigestDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$HouseholdBillsDigestDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _HouseholdBillsDigestDto&&const DeepCollectionEquality().equals(other._dueSoon, _dueSoon)&&(identical(other.overdueCount, overdueCount) || other.overdueCount == overdueCount)&&(identical(other.needsAmountCount, needsAmountCount) || other.needsAmountCount == needsAmountCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_dueSoon),overdueCount,needsAmountCount);

@override
String toString() {
  return 'HouseholdBillsDigestDto(dueSoon: $dueSoon, overdueCount: $overdueCount, needsAmountCount: $needsAmountCount)';
}


}

/// @nodoc
abstract mixin class _$HouseholdBillsDigestDtoCopyWith<$Res> implements $HouseholdBillsDigestDtoCopyWith<$Res> {
  factory _$HouseholdBillsDigestDtoCopyWith(_HouseholdBillsDigestDto value, $Res Function(_HouseholdBillsDigestDto) _then) = __$HouseholdBillsDigestDtoCopyWithImpl;
@override @useResult
$Res call({
 List<HouseholdBillDigestEntryDto> dueSoon, int overdueCount, int needsAmountCount
});




}
/// @nodoc
class __$HouseholdBillsDigestDtoCopyWithImpl<$Res>
    implements _$HouseholdBillsDigestDtoCopyWith<$Res> {
  __$HouseholdBillsDigestDtoCopyWithImpl(this._self, this._then);

  final _HouseholdBillsDigestDto _self;
  final $Res Function(_HouseholdBillsDigestDto) _then;

/// Create a copy of HouseholdBillsDigestDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? dueSoon = null,Object? overdueCount = null,Object? needsAmountCount = null,}) {
  return _then(_HouseholdBillsDigestDto(
dueSoon: null == dueSoon ? _self._dueSoon : dueSoon // ignore: cast_nullable_to_non_nullable
as List<HouseholdBillDigestEntryDto>,overdueCount: null == overdueCount ? _self.overdueCount : overdueCount // ignore: cast_nullable_to_non_nullable
as int,needsAmountCount: null == needsAmountCount ? _self.needsAmountCount : needsAmountCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$HouseholdBillDigestEntryDto {

 String get id; String get channelId; String get description; DateTime? get dueAt; int? get amountMinor; String get currency;/// What this period costs the caller specifically. Null when there is no
/// total to divide yet, and also when the split no longer resolves - a
/// wrong share is worse than a missing one, because it is the number
/// somebody transfers.
 int? get myShareMinor;@JsonKey(unknownEnumValue: BillStatus.pending) BillStatus get status;
/// Create a copy of HouseholdBillDigestEntryDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HouseholdBillDigestEntryDtoCopyWith<HouseholdBillDigestEntryDto> get copyWith => _$HouseholdBillDigestEntryDtoCopyWithImpl<HouseholdBillDigestEntryDto>(this as HouseholdBillDigestEntryDto, _$identity);

  /// Serializes this HouseholdBillDigestEntryDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HouseholdBillDigestEntryDto&&(identical(other.id, id) || other.id == id)&&(identical(other.channelId, channelId) || other.channelId == channelId)&&(identical(other.description, description) || other.description == description)&&(identical(other.dueAt, dueAt) || other.dueAt == dueAt)&&(identical(other.amountMinor, amountMinor) || other.amountMinor == amountMinor)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.myShareMinor, myShareMinor) || other.myShareMinor == myShareMinor)&&(identical(other.status, status) || other.status == status));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,channelId,description,dueAt,amountMinor,currency,myShareMinor,status);

@override
String toString() {
  return 'HouseholdBillDigestEntryDto(id: $id, channelId: $channelId, description: $description, dueAt: $dueAt, amountMinor: $amountMinor, currency: $currency, myShareMinor: $myShareMinor, status: $status)';
}


}

/// @nodoc
abstract mixin class $HouseholdBillDigestEntryDtoCopyWith<$Res>  {
  factory $HouseholdBillDigestEntryDtoCopyWith(HouseholdBillDigestEntryDto value, $Res Function(HouseholdBillDigestEntryDto) _then) = _$HouseholdBillDigestEntryDtoCopyWithImpl;
@useResult
$Res call({
 String id, String channelId, String description, DateTime? dueAt, int? amountMinor, String currency, int? myShareMinor,@JsonKey(unknownEnumValue: BillStatus.pending) BillStatus status
});




}
/// @nodoc
class _$HouseholdBillDigestEntryDtoCopyWithImpl<$Res>
    implements $HouseholdBillDigestEntryDtoCopyWith<$Res> {
  _$HouseholdBillDigestEntryDtoCopyWithImpl(this._self, this._then);

  final HouseholdBillDigestEntryDto _self;
  final $Res Function(HouseholdBillDigestEntryDto) _then;

/// Create a copy of HouseholdBillDigestEntryDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? channelId = null,Object? description = null,Object? dueAt = freezed,Object? amountMinor = freezed,Object? currency = null,Object? myShareMinor = freezed,Object? status = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,channelId: null == channelId ? _self.channelId : channelId // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,dueAt: freezed == dueAt ? _self.dueAt : dueAt // ignore: cast_nullable_to_non_nullable
as DateTime?,amountMinor: freezed == amountMinor ? _self.amountMinor : amountMinor // ignore: cast_nullable_to_non_nullable
as int?,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,myShareMinor: freezed == myShareMinor ? _self.myShareMinor : myShareMinor // ignore: cast_nullable_to_non_nullable
as int?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as BillStatus,
  ));
}

}


/// Adds pattern-matching-related methods to [HouseholdBillDigestEntryDto].
extension HouseholdBillDigestEntryDtoPatterns on HouseholdBillDigestEntryDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _HouseholdBillDigestEntryDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _HouseholdBillDigestEntryDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _HouseholdBillDigestEntryDto value)  $default,){
final _that = this;
switch (_that) {
case _HouseholdBillDigestEntryDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _HouseholdBillDigestEntryDto value)?  $default,){
final _that = this;
switch (_that) {
case _HouseholdBillDigestEntryDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String channelId,  String description,  DateTime? dueAt,  int? amountMinor,  String currency,  int? myShareMinor, @JsonKey(unknownEnumValue: BillStatus.pending)  BillStatus status)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _HouseholdBillDigestEntryDto() when $default != null:
return $default(_that.id,_that.channelId,_that.description,_that.dueAt,_that.amountMinor,_that.currency,_that.myShareMinor,_that.status);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String channelId,  String description,  DateTime? dueAt,  int? amountMinor,  String currency,  int? myShareMinor, @JsonKey(unknownEnumValue: BillStatus.pending)  BillStatus status)  $default,) {final _that = this;
switch (_that) {
case _HouseholdBillDigestEntryDto():
return $default(_that.id,_that.channelId,_that.description,_that.dueAt,_that.amountMinor,_that.currency,_that.myShareMinor,_that.status);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String channelId,  String description,  DateTime? dueAt,  int? amountMinor,  String currency,  int? myShareMinor, @JsonKey(unknownEnumValue: BillStatus.pending)  BillStatus status)?  $default,) {final _that = this;
switch (_that) {
case _HouseholdBillDigestEntryDto() when $default != null:
return $default(_that.id,_that.channelId,_that.description,_that.dueAt,_that.amountMinor,_that.currency,_that.myShareMinor,_that.status);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()
@ApiDateTimeConverter()
class _HouseholdBillDigestEntryDto implements HouseholdBillDigestEntryDto {
  const _HouseholdBillDigestEntryDto({this.id = '', this.channelId = '', this.description = '', this.dueAt, this.amountMinor, this.currency = 'CHF', this.myShareMinor, @JsonKey(unknownEnumValue: BillStatus.pending) this.status = BillStatus.pending});
  factory _HouseholdBillDigestEntryDto.fromJson(Map<String, dynamic> json) => _$HouseholdBillDigestEntryDtoFromJson(json);

@override@JsonKey() final  String id;
@override@JsonKey() final  String channelId;
@override@JsonKey() final  String description;
@override final  DateTime? dueAt;
@override final  int? amountMinor;
@override@JsonKey() final  String currency;
/// What this period costs the caller specifically. Null when there is no
/// total to divide yet, and also when the split no longer resolves - a
/// wrong share is worse than a missing one, because it is the number
/// somebody transfers.
@override final  int? myShareMinor;
@override@JsonKey(unknownEnumValue: BillStatus.pending) final  BillStatus status;

/// Create a copy of HouseholdBillDigestEntryDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HouseholdBillDigestEntryDtoCopyWith<_HouseholdBillDigestEntryDto> get copyWith => __$HouseholdBillDigestEntryDtoCopyWithImpl<_HouseholdBillDigestEntryDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$HouseholdBillDigestEntryDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _HouseholdBillDigestEntryDto&&(identical(other.id, id) || other.id == id)&&(identical(other.channelId, channelId) || other.channelId == channelId)&&(identical(other.description, description) || other.description == description)&&(identical(other.dueAt, dueAt) || other.dueAt == dueAt)&&(identical(other.amountMinor, amountMinor) || other.amountMinor == amountMinor)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.myShareMinor, myShareMinor) || other.myShareMinor == myShareMinor)&&(identical(other.status, status) || other.status == status));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,channelId,description,dueAt,amountMinor,currency,myShareMinor,status);

@override
String toString() {
  return 'HouseholdBillDigestEntryDto(id: $id, channelId: $channelId, description: $description, dueAt: $dueAt, amountMinor: $amountMinor, currency: $currency, myShareMinor: $myShareMinor, status: $status)';
}


}

/// @nodoc
abstract mixin class _$HouseholdBillDigestEntryDtoCopyWith<$Res> implements $HouseholdBillDigestEntryDtoCopyWith<$Res> {
  factory _$HouseholdBillDigestEntryDtoCopyWith(_HouseholdBillDigestEntryDto value, $Res Function(_HouseholdBillDigestEntryDto) _then) = __$HouseholdBillDigestEntryDtoCopyWithImpl;
@override @useResult
$Res call({
 String id, String channelId, String description, DateTime? dueAt, int? amountMinor, String currency, int? myShareMinor,@JsonKey(unknownEnumValue: BillStatus.pending) BillStatus status
});




}
/// @nodoc
class __$HouseholdBillDigestEntryDtoCopyWithImpl<$Res>
    implements _$HouseholdBillDigestEntryDtoCopyWith<$Res> {
  __$HouseholdBillDigestEntryDtoCopyWithImpl(this._self, this._then);

  final _HouseholdBillDigestEntryDto _self;
  final $Res Function(_HouseholdBillDigestEntryDto) _then;

/// Create a copy of HouseholdBillDigestEntryDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? channelId = null,Object? description = null,Object? dueAt = freezed,Object? amountMinor = freezed,Object? currency = null,Object? myShareMinor = freezed,Object? status = null,}) {
  return _then(_HouseholdBillDigestEntryDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,channelId: null == channelId ? _self.channelId : channelId // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,dueAt: freezed == dueAt ? _self.dueAt : dueAt // ignore: cast_nullable_to_non_nullable
as DateTime?,amountMinor: freezed == amountMinor ? _self.amountMinor : amountMinor // ignore: cast_nullable_to_non_nullable
as int?,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,myShareMinor: freezed == myShareMinor ? _self.myShareMinor : myShareMinor // ignore: cast_nullable_to_non_nullable
as int?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as BillStatus,
  ));
}


}


/// @nodoc
mixin _$HouseholdMealsDigestDto {

 List<HouseholdMealDigestEntryDto> get today;/// Computed over the whole day rather than over the capped [today] list, so
/// a busy day cannot quietly answer "no" for somebody who is in fact
/// cooking.
 bool get imCookingToday;
/// Create a copy of HouseholdMealsDigestDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HouseholdMealsDigestDtoCopyWith<HouseholdMealsDigestDto> get copyWith => _$HouseholdMealsDigestDtoCopyWithImpl<HouseholdMealsDigestDto>(this as HouseholdMealsDigestDto, _$identity);

  /// Serializes this HouseholdMealsDigestDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HouseholdMealsDigestDto&&const DeepCollectionEquality().equals(other.today, today)&&(identical(other.imCookingToday, imCookingToday) || other.imCookingToday == imCookingToday));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(today),imCookingToday);

@override
String toString() {
  return 'HouseholdMealsDigestDto(today: $today, imCookingToday: $imCookingToday)';
}


}

/// @nodoc
abstract mixin class $HouseholdMealsDigestDtoCopyWith<$Res>  {
  factory $HouseholdMealsDigestDtoCopyWith(HouseholdMealsDigestDto value, $Res Function(HouseholdMealsDigestDto) _then) = _$HouseholdMealsDigestDtoCopyWithImpl;
@useResult
$Res call({
 List<HouseholdMealDigestEntryDto> today, bool imCookingToday
});




}
/// @nodoc
class _$HouseholdMealsDigestDtoCopyWithImpl<$Res>
    implements $HouseholdMealsDigestDtoCopyWith<$Res> {
  _$HouseholdMealsDigestDtoCopyWithImpl(this._self, this._then);

  final HouseholdMealsDigestDto _self;
  final $Res Function(HouseholdMealsDigestDto) _then;

/// Create a copy of HouseholdMealsDigestDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? today = null,Object? imCookingToday = null,}) {
  return _then(_self.copyWith(
today: null == today ? _self.today : today // ignore: cast_nullable_to_non_nullable
as List<HouseholdMealDigestEntryDto>,imCookingToday: null == imCookingToday ? _self.imCookingToday : imCookingToday // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [HouseholdMealsDigestDto].
extension HouseholdMealsDigestDtoPatterns on HouseholdMealsDigestDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _HouseholdMealsDigestDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _HouseholdMealsDigestDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _HouseholdMealsDigestDto value)  $default,){
final _that = this;
switch (_that) {
case _HouseholdMealsDigestDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _HouseholdMealsDigestDto value)?  $default,){
final _that = this;
switch (_that) {
case _HouseholdMealsDigestDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<HouseholdMealDigestEntryDto> today,  bool imCookingToday)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _HouseholdMealsDigestDto() when $default != null:
return $default(_that.today,_that.imCookingToday);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<HouseholdMealDigestEntryDto> today,  bool imCookingToday)  $default,) {final _that = this;
switch (_that) {
case _HouseholdMealsDigestDto():
return $default(_that.today,_that.imCookingToday);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<HouseholdMealDigestEntryDto> today,  bool imCookingToday)?  $default,) {final _that = this;
switch (_that) {
case _HouseholdMealsDigestDto() when $default != null:
return $default(_that.today,_that.imCookingToday);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _HouseholdMealsDigestDto implements HouseholdMealsDigestDto {
  const _HouseholdMealsDigestDto({final  List<HouseholdMealDigestEntryDto> today = const <HouseholdMealDigestEntryDto>[], this.imCookingToday = false}): _today = today;
  factory _HouseholdMealsDigestDto.fromJson(Map<String, dynamic> json) => _$HouseholdMealsDigestDtoFromJson(json);

 final  List<HouseholdMealDigestEntryDto> _today;
@override@JsonKey() List<HouseholdMealDigestEntryDto> get today {
  if (_today is EqualUnmodifiableListView) return _today;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_today);
}

/// Computed over the whole day rather than over the capped [today] list, so
/// a busy day cannot quietly answer "no" for somebody who is in fact
/// cooking.
@override@JsonKey() final  bool imCookingToday;

/// Create a copy of HouseholdMealsDigestDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HouseholdMealsDigestDtoCopyWith<_HouseholdMealsDigestDto> get copyWith => __$HouseholdMealsDigestDtoCopyWithImpl<_HouseholdMealsDigestDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$HouseholdMealsDigestDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _HouseholdMealsDigestDto&&const DeepCollectionEquality().equals(other._today, _today)&&(identical(other.imCookingToday, imCookingToday) || other.imCookingToday == imCookingToday));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_today),imCookingToday);

@override
String toString() {
  return 'HouseholdMealsDigestDto(today: $today, imCookingToday: $imCookingToday)';
}


}

/// @nodoc
abstract mixin class _$HouseholdMealsDigestDtoCopyWith<$Res> implements $HouseholdMealsDigestDtoCopyWith<$Res> {
  factory _$HouseholdMealsDigestDtoCopyWith(_HouseholdMealsDigestDto value, $Res Function(_HouseholdMealsDigestDto) _then) = __$HouseholdMealsDigestDtoCopyWithImpl;
@override @useResult
$Res call({
 List<HouseholdMealDigestEntryDto> today, bool imCookingToday
});




}
/// @nodoc
class __$HouseholdMealsDigestDtoCopyWithImpl<$Res>
    implements _$HouseholdMealsDigestDtoCopyWith<$Res> {
  __$HouseholdMealsDigestDtoCopyWithImpl(this._self, this._then);

  final _HouseholdMealsDigestDto _self;
  final $Res Function(_HouseholdMealsDigestDto) _then;

/// Create a copy of HouseholdMealsDigestDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? today = null,Object? imCookingToday = null,}) {
  return _then(_HouseholdMealsDigestDto(
today: null == today ? _self._today : today // ignore: cast_nullable_to_non_nullable
as List<HouseholdMealDigestEntryDto>,imCookingToday: null == imCookingToday ? _self.imCookingToday : imCookingToday // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$HouseholdMealDigestEntryDto {

 String get id; String get channelId;@JsonKey(unknownEnumValue: MealSlot.dinner) MealSlot get slot;/// The recipe's title or the entry's free text, flattened - a glance
/// renders one line either way, and most of a real week is "leftovers".
 String get title; String? get cookUserId;
/// Create a copy of HouseholdMealDigestEntryDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HouseholdMealDigestEntryDtoCopyWith<HouseholdMealDigestEntryDto> get copyWith => _$HouseholdMealDigestEntryDtoCopyWithImpl<HouseholdMealDigestEntryDto>(this as HouseholdMealDigestEntryDto, _$identity);

  /// Serializes this HouseholdMealDigestEntryDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HouseholdMealDigestEntryDto&&(identical(other.id, id) || other.id == id)&&(identical(other.channelId, channelId) || other.channelId == channelId)&&(identical(other.slot, slot) || other.slot == slot)&&(identical(other.title, title) || other.title == title)&&(identical(other.cookUserId, cookUserId) || other.cookUserId == cookUserId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,channelId,slot,title,cookUserId);

@override
String toString() {
  return 'HouseholdMealDigestEntryDto(id: $id, channelId: $channelId, slot: $slot, title: $title, cookUserId: $cookUserId)';
}


}

/// @nodoc
abstract mixin class $HouseholdMealDigestEntryDtoCopyWith<$Res>  {
  factory $HouseholdMealDigestEntryDtoCopyWith(HouseholdMealDigestEntryDto value, $Res Function(HouseholdMealDigestEntryDto) _then) = _$HouseholdMealDigestEntryDtoCopyWithImpl;
@useResult
$Res call({
 String id, String channelId,@JsonKey(unknownEnumValue: MealSlot.dinner) MealSlot slot, String title, String? cookUserId
});




}
/// @nodoc
class _$HouseholdMealDigestEntryDtoCopyWithImpl<$Res>
    implements $HouseholdMealDigestEntryDtoCopyWith<$Res> {
  _$HouseholdMealDigestEntryDtoCopyWithImpl(this._self, this._then);

  final HouseholdMealDigestEntryDto _self;
  final $Res Function(HouseholdMealDigestEntryDto) _then;

/// Create a copy of HouseholdMealDigestEntryDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? channelId = null,Object? slot = null,Object? title = null,Object? cookUserId = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,channelId: null == channelId ? _self.channelId : channelId // ignore: cast_nullable_to_non_nullable
as String,slot: null == slot ? _self.slot : slot // ignore: cast_nullable_to_non_nullable
as MealSlot,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,cookUserId: freezed == cookUserId ? _self.cookUserId : cookUserId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [HouseholdMealDigestEntryDto].
extension HouseholdMealDigestEntryDtoPatterns on HouseholdMealDigestEntryDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _HouseholdMealDigestEntryDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _HouseholdMealDigestEntryDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _HouseholdMealDigestEntryDto value)  $default,){
final _that = this;
switch (_that) {
case _HouseholdMealDigestEntryDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _HouseholdMealDigestEntryDto value)?  $default,){
final _that = this;
switch (_that) {
case _HouseholdMealDigestEntryDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String channelId, @JsonKey(unknownEnumValue: MealSlot.dinner)  MealSlot slot,  String title,  String? cookUserId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _HouseholdMealDigestEntryDto() when $default != null:
return $default(_that.id,_that.channelId,_that.slot,_that.title,_that.cookUserId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String channelId, @JsonKey(unknownEnumValue: MealSlot.dinner)  MealSlot slot,  String title,  String? cookUserId)  $default,) {final _that = this;
switch (_that) {
case _HouseholdMealDigestEntryDto():
return $default(_that.id,_that.channelId,_that.slot,_that.title,_that.cookUserId);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String channelId, @JsonKey(unknownEnumValue: MealSlot.dinner)  MealSlot slot,  String title,  String? cookUserId)?  $default,) {final _that = this;
switch (_that) {
case _HouseholdMealDigestEntryDto() when $default != null:
return $default(_that.id,_that.channelId,_that.slot,_that.title,_that.cookUserId);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _HouseholdMealDigestEntryDto implements HouseholdMealDigestEntryDto {
  const _HouseholdMealDigestEntryDto({this.id = '', this.channelId = '', @JsonKey(unknownEnumValue: MealSlot.dinner) this.slot = MealSlot.dinner, this.title = '', this.cookUserId});
  factory _HouseholdMealDigestEntryDto.fromJson(Map<String, dynamic> json) => _$HouseholdMealDigestEntryDtoFromJson(json);

@override@JsonKey() final  String id;
@override@JsonKey() final  String channelId;
@override@JsonKey(unknownEnumValue: MealSlot.dinner) final  MealSlot slot;
/// The recipe's title or the entry's free text, flattened - a glance
/// renders one line either way, and most of a real week is "leftovers".
@override@JsonKey() final  String title;
@override final  String? cookUserId;

/// Create a copy of HouseholdMealDigestEntryDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HouseholdMealDigestEntryDtoCopyWith<_HouseholdMealDigestEntryDto> get copyWith => __$HouseholdMealDigestEntryDtoCopyWithImpl<_HouseholdMealDigestEntryDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$HouseholdMealDigestEntryDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _HouseholdMealDigestEntryDto&&(identical(other.id, id) || other.id == id)&&(identical(other.channelId, channelId) || other.channelId == channelId)&&(identical(other.slot, slot) || other.slot == slot)&&(identical(other.title, title) || other.title == title)&&(identical(other.cookUserId, cookUserId) || other.cookUserId == cookUserId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,channelId,slot,title,cookUserId);

@override
String toString() {
  return 'HouseholdMealDigestEntryDto(id: $id, channelId: $channelId, slot: $slot, title: $title, cookUserId: $cookUserId)';
}


}

/// @nodoc
abstract mixin class _$HouseholdMealDigestEntryDtoCopyWith<$Res> implements $HouseholdMealDigestEntryDtoCopyWith<$Res> {
  factory _$HouseholdMealDigestEntryDtoCopyWith(_HouseholdMealDigestEntryDto value, $Res Function(_HouseholdMealDigestEntryDto) _then) = __$HouseholdMealDigestEntryDtoCopyWithImpl;
@override @useResult
$Res call({
 String id, String channelId,@JsonKey(unknownEnumValue: MealSlot.dinner) MealSlot slot, String title, String? cookUserId
});




}
/// @nodoc
class __$HouseholdMealDigestEntryDtoCopyWithImpl<$Res>
    implements _$HouseholdMealDigestEntryDtoCopyWith<$Res> {
  __$HouseholdMealDigestEntryDtoCopyWithImpl(this._self, this._then);

  final _HouseholdMealDigestEntryDto _self;
  final $Res Function(_HouseholdMealDigestEntryDto) _then;

/// Create a copy of HouseholdMealDigestEntryDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? channelId = null,Object? slot = null,Object? title = null,Object? cookUserId = freezed,}) {
  return _then(_HouseholdMealDigestEntryDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,channelId: null == channelId ? _self.channelId : channelId // ignore: cast_nullable_to_non_nullable
as String,slot: null == slot ? _self.slot : slot // ignore: cast_nullable_to_non_nullable
as MealSlot,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,cookUserId: freezed == cookUserId ? _self.cookUserId : cookUserId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$HouseholdMaintenanceDigestDto {

 int get brokenCount; int get serviceOverdueCount;/// Warranties lapsing soon. Already-lapsed ones are not counted - there is
/// nothing left to do about them.
 int get warrantyExpiringCount; List<HouseholdAssetDigestEntryDto> get attention;
/// Create a copy of HouseholdMaintenanceDigestDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HouseholdMaintenanceDigestDtoCopyWith<HouseholdMaintenanceDigestDto> get copyWith => _$HouseholdMaintenanceDigestDtoCopyWithImpl<HouseholdMaintenanceDigestDto>(this as HouseholdMaintenanceDigestDto, _$identity);

  /// Serializes this HouseholdMaintenanceDigestDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HouseholdMaintenanceDigestDto&&(identical(other.brokenCount, brokenCount) || other.brokenCount == brokenCount)&&(identical(other.serviceOverdueCount, serviceOverdueCount) || other.serviceOverdueCount == serviceOverdueCount)&&(identical(other.warrantyExpiringCount, warrantyExpiringCount) || other.warrantyExpiringCount == warrantyExpiringCount)&&const DeepCollectionEquality().equals(other.attention, attention));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,brokenCount,serviceOverdueCount,warrantyExpiringCount,const DeepCollectionEquality().hash(attention));

@override
String toString() {
  return 'HouseholdMaintenanceDigestDto(brokenCount: $brokenCount, serviceOverdueCount: $serviceOverdueCount, warrantyExpiringCount: $warrantyExpiringCount, attention: $attention)';
}


}

/// @nodoc
abstract mixin class $HouseholdMaintenanceDigestDtoCopyWith<$Res>  {
  factory $HouseholdMaintenanceDigestDtoCopyWith(HouseholdMaintenanceDigestDto value, $Res Function(HouseholdMaintenanceDigestDto) _then) = _$HouseholdMaintenanceDigestDtoCopyWithImpl;
@useResult
$Res call({
 int brokenCount, int serviceOverdueCount, int warrantyExpiringCount, List<HouseholdAssetDigestEntryDto> attention
});




}
/// @nodoc
class _$HouseholdMaintenanceDigestDtoCopyWithImpl<$Res>
    implements $HouseholdMaintenanceDigestDtoCopyWith<$Res> {
  _$HouseholdMaintenanceDigestDtoCopyWithImpl(this._self, this._then);

  final HouseholdMaintenanceDigestDto _self;
  final $Res Function(HouseholdMaintenanceDigestDto) _then;

/// Create a copy of HouseholdMaintenanceDigestDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? brokenCount = null,Object? serviceOverdueCount = null,Object? warrantyExpiringCount = null,Object? attention = null,}) {
  return _then(_self.copyWith(
brokenCount: null == brokenCount ? _self.brokenCount : brokenCount // ignore: cast_nullable_to_non_nullable
as int,serviceOverdueCount: null == serviceOverdueCount ? _self.serviceOverdueCount : serviceOverdueCount // ignore: cast_nullable_to_non_nullable
as int,warrantyExpiringCount: null == warrantyExpiringCount ? _self.warrantyExpiringCount : warrantyExpiringCount // ignore: cast_nullable_to_non_nullable
as int,attention: null == attention ? _self.attention : attention // ignore: cast_nullable_to_non_nullable
as List<HouseholdAssetDigestEntryDto>,
  ));
}

}


/// Adds pattern-matching-related methods to [HouseholdMaintenanceDigestDto].
extension HouseholdMaintenanceDigestDtoPatterns on HouseholdMaintenanceDigestDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _HouseholdMaintenanceDigestDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _HouseholdMaintenanceDigestDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _HouseholdMaintenanceDigestDto value)  $default,){
final _that = this;
switch (_that) {
case _HouseholdMaintenanceDigestDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _HouseholdMaintenanceDigestDto value)?  $default,){
final _that = this;
switch (_that) {
case _HouseholdMaintenanceDigestDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int brokenCount,  int serviceOverdueCount,  int warrantyExpiringCount,  List<HouseholdAssetDigestEntryDto> attention)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _HouseholdMaintenanceDigestDto() when $default != null:
return $default(_that.brokenCount,_that.serviceOverdueCount,_that.warrantyExpiringCount,_that.attention);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int brokenCount,  int serviceOverdueCount,  int warrantyExpiringCount,  List<HouseholdAssetDigestEntryDto> attention)  $default,) {final _that = this;
switch (_that) {
case _HouseholdMaintenanceDigestDto():
return $default(_that.brokenCount,_that.serviceOverdueCount,_that.warrantyExpiringCount,_that.attention);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int brokenCount,  int serviceOverdueCount,  int warrantyExpiringCount,  List<HouseholdAssetDigestEntryDto> attention)?  $default,) {final _that = this;
switch (_that) {
case _HouseholdMaintenanceDigestDto() when $default != null:
return $default(_that.brokenCount,_that.serviceOverdueCount,_that.warrantyExpiringCount,_that.attention);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _HouseholdMaintenanceDigestDto implements HouseholdMaintenanceDigestDto {
  const _HouseholdMaintenanceDigestDto({this.brokenCount = 0, this.serviceOverdueCount = 0, this.warrantyExpiringCount = 0, final  List<HouseholdAssetDigestEntryDto> attention = const <HouseholdAssetDigestEntryDto>[]}): _attention = attention;
  factory _HouseholdMaintenanceDigestDto.fromJson(Map<String, dynamic> json) => _$HouseholdMaintenanceDigestDtoFromJson(json);

@override@JsonKey() final  int brokenCount;
@override@JsonKey() final  int serviceOverdueCount;
/// Warranties lapsing soon. Already-lapsed ones are not counted - there is
/// nothing left to do about them.
@override@JsonKey() final  int warrantyExpiringCount;
 final  List<HouseholdAssetDigestEntryDto> _attention;
@override@JsonKey() List<HouseholdAssetDigestEntryDto> get attention {
  if (_attention is EqualUnmodifiableListView) return _attention;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_attention);
}


/// Create a copy of HouseholdMaintenanceDigestDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HouseholdMaintenanceDigestDtoCopyWith<_HouseholdMaintenanceDigestDto> get copyWith => __$HouseholdMaintenanceDigestDtoCopyWithImpl<_HouseholdMaintenanceDigestDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$HouseholdMaintenanceDigestDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _HouseholdMaintenanceDigestDto&&(identical(other.brokenCount, brokenCount) || other.brokenCount == brokenCount)&&(identical(other.serviceOverdueCount, serviceOverdueCount) || other.serviceOverdueCount == serviceOverdueCount)&&(identical(other.warrantyExpiringCount, warrantyExpiringCount) || other.warrantyExpiringCount == warrantyExpiringCount)&&const DeepCollectionEquality().equals(other._attention, _attention));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,brokenCount,serviceOverdueCount,warrantyExpiringCount,const DeepCollectionEquality().hash(_attention));

@override
String toString() {
  return 'HouseholdMaintenanceDigestDto(brokenCount: $brokenCount, serviceOverdueCount: $serviceOverdueCount, warrantyExpiringCount: $warrantyExpiringCount, attention: $attention)';
}


}

/// @nodoc
abstract mixin class _$HouseholdMaintenanceDigestDtoCopyWith<$Res> implements $HouseholdMaintenanceDigestDtoCopyWith<$Res> {
  factory _$HouseholdMaintenanceDigestDtoCopyWith(_HouseholdMaintenanceDigestDto value, $Res Function(_HouseholdMaintenanceDigestDto) _then) = __$HouseholdMaintenanceDigestDtoCopyWithImpl;
@override @useResult
$Res call({
 int brokenCount, int serviceOverdueCount, int warrantyExpiringCount, List<HouseholdAssetDigestEntryDto> attention
});




}
/// @nodoc
class __$HouseholdMaintenanceDigestDtoCopyWithImpl<$Res>
    implements _$HouseholdMaintenanceDigestDtoCopyWith<$Res> {
  __$HouseholdMaintenanceDigestDtoCopyWithImpl(this._self, this._then);

  final _HouseholdMaintenanceDigestDto _self;
  final $Res Function(_HouseholdMaintenanceDigestDto) _then;

/// Create a copy of HouseholdMaintenanceDigestDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? brokenCount = null,Object? serviceOverdueCount = null,Object? warrantyExpiringCount = null,Object? attention = null,}) {
  return _then(_HouseholdMaintenanceDigestDto(
brokenCount: null == brokenCount ? _self.brokenCount : brokenCount // ignore: cast_nullable_to_non_nullable
as int,serviceOverdueCount: null == serviceOverdueCount ? _self.serviceOverdueCount : serviceOverdueCount // ignore: cast_nullable_to_non_nullable
as int,warrantyExpiringCount: null == warrantyExpiringCount ? _self.warrantyExpiringCount : warrantyExpiringCount // ignore: cast_nullable_to_non_nullable
as int,attention: null == attention ? _self._attention : attention // ignore: cast_nullable_to_non_nullable
as List<HouseholdAssetDigestEntryDto>,
  ));
}


}


/// @nodoc
mixin _$HouseholdAssetDigestEntryDto {

 String get id; String get channelId; String get name;@JsonKey(unknownEnumValue: AssetStatus.ok) AssetStatus get status;/// The single most urgent of the attention board's tokens. One where the
/// board carries all of them: a board has room to say a machine is both
/// broken and out of warranty, a glance has room for the word that decides
/// whether anybody gets up.
 String get reason;
/// Create a copy of HouseholdAssetDigestEntryDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HouseholdAssetDigestEntryDtoCopyWith<HouseholdAssetDigestEntryDto> get copyWith => _$HouseholdAssetDigestEntryDtoCopyWithImpl<HouseholdAssetDigestEntryDto>(this as HouseholdAssetDigestEntryDto, _$identity);

  /// Serializes this HouseholdAssetDigestEntryDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HouseholdAssetDigestEntryDto&&(identical(other.id, id) || other.id == id)&&(identical(other.channelId, channelId) || other.channelId == channelId)&&(identical(other.name, name) || other.name == name)&&(identical(other.status, status) || other.status == status)&&(identical(other.reason, reason) || other.reason == reason));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,channelId,name,status,reason);

@override
String toString() {
  return 'HouseholdAssetDigestEntryDto(id: $id, channelId: $channelId, name: $name, status: $status, reason: $reason)';
}


}

/// @nodoc
abstract mixin class $HouseholdAssetDigestEntryDtoCopyWith<$Res>  {
  factory $HouseholdAssetDigestEntryDtoCopyWith(HouseholdAssetDigestEntryDto value, $Res Function(HouseholdAssetDigestEntryDto) _then) = _$HouseholdAssetDigestEntryDtoCopyWithImpl;
@useResult
$Res call({
 String id, String channelId, String name,@JsonKey(unknownEnumValue: AssetStatus.ok) AssetStatus status, String reason
});




}
/// @nodoc
class _$HouseholdAssetDigestEntryDtoCopyWithImpl<$Res>
    implements $HouseholdAssetDigestEntryDtoCopyWith<$Res> {
  _$HouseholdAssetDigestEntryDtoCopyWithImpl(this._self, this._then);

  final HouseholdAssetDigestEntryDto _self;
  final $Res Function(HouseholdAssetDigestEntryDto) _then;

/// Create a copy of HouseholdAssetDigestEntryDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? channelId = null,Object? name = null,Object? status = null,Object? reason = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,channelId: null == channelId ? _self.channelId : channelId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as AssetStatus,reason: null == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [HouseholdAssetDigestEntryDto].
extension HouseholdAssetDigestEntryDtoPatterns on HouseholdAssetDigestEntryDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _HouseholdAssetDigestEntryDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _HouseholdAssetDigestEntryDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _HouseholdAssetDigestEntryDto value)  $default,){
final _that = this;
switch (_that) {
case _HouseholdAssetDigestEntryDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _HouseholdAssetDigestEntryDto value)?  $default,){
final _that = this;
switch (_that) {
case _HouseholdAssetDigestEntryDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String channelId,  String name, @JsonKey(unknownEnumValue: AssetStatus.ok)  AssetStatus status,  String reason)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _HouseholdAssetDigestEntryDto() when $default != null:
return $default(_that.id,_that.channelId,_that.name,_that.status,_that.reason);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String channelId,  String name, @JsonKey(unknownEnumValue: AssetStatus.ok)  AssetStatus status,  String reason)  $default,) {final _that = this;
switch (_that) {
case _HouseholdAssetDigestEntryDto():
return $default(_that.id,_that.channelId,_that.name,_that.status,_that.reason);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String channelId,  String name, @JsonKey(unknownEnumValue: AssetStatus.ok)  AssetStatus status,  String reason)?  $default,) {final _that = this;
switch (_that) {
case _HouseholdAssetDigestEntryDto() when $default != null:
return $default(_that.id,_that.channelId,_that.name,_that.status,_that.reason);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _HouseholdAssetDigestEntryDto implements HouseholdAssetDigestEntryDto {
  const _HouseholdAssetDigestEntryDto({this.id = '', this.channelId = '', this.name = '', @JsonKey(unknownEnumValue: AssetStatus.ok) this.status = AssetStatus.ok, this.reason = ''});
  factory _HouseholdAssetDigestEntryDto.fromJson(Map<String, dynamic> json) => _$HouseholdAssetDigestEntryDtoFromJson(json);

@override@JsonKey() final  String id;
@override@JsonKey() final  String channelId;
@override@JsonKey() final  String name;
@override@JsonKey(unknownEnumValue: AssetStatus.ok) final  AssetStatus status;
/// The single most urgent of the attention board's tokens. One where the
/// board carries all of them: a board has room to say a machine is both
/// broken and out of warranty, a glance has room for the word that decides
/// whether anybody gets up.
@override@JsonKey() final  String reason;

/// Create a copy of HouseholdAssetDigestEntryDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HouseholdAssetDigestEntryDtoCopyWith<_HouseholdAssetDigestEntryDto> get copyWith => __$HouseholdAssetDigestEntryDtoCopyWithImpl<_HouseholdAssetDigestEntryDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$HouseholdAssetDigestEntryDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _HouseholdAssetDigestEntryDto&&(identical(other.id, id) || other.id == id)&&(identical(other.channelId, channelId) || other.channelId == channelId)&&(identical(other.name, name) || other.name == name)&&(identical(other.status, status) || other.status == status)&&(identical(other.reason, reason) || other.reason == reason));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,channelId,name,status,reason);

@override
String toString() {
  return 'HouseholdAssetDigestEntryDto(id: $id, channelId: $channelId, name: $name, status: $status, reason: $reason)';
}


}

/// @nodoc
abstract mixin class _$HouseholdAssetDigestEntryDtoCopyWith<$Res> implements $HouseholdAssetDigestEntryDtoCopyWith<$Res> {
  factory _$HouseholdAssetDigestEntryDtoCopyWith(_HouseholdAssetDigestEntryDto value, $Res Function(_HouseholdAssetDigestEntryDto) _then) = __$HouseholdAssetDigestEntryDtoCopyWithImpl;
@override @useResult
$Res call({
 String id, String channelId, String name,@JsonKey(unknownEnumValue: AssetStatus.ok) AssetStatus status, String reason
});




}
/// @nodoc
class __$HouseholdAssetDigestEntryDtoCopyWithImpl<$Res>
    implements _$HouseholdAssetDigestEntryDtoCopyWith<$Res> {
  __$HouseholdAssetDigestEntryDtoCopyWithImpl(this._self, this._then);

  final _HouseholdAssetDigestEntryDto _self;
  final $Res Function(_HouseholdAssetDigestEntryDto) _then;

/// Create a copy of HouseholdAssetDigestEntryDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? channelId = null,Object? name = null,Object? status = null,Object? reason = null,}) {
  return _then(_HouseholdAssetDigestEntryDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,channelId: null == channelId ? _self.channelId : channelId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as AssetStatus,reason: null == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$HouseholdAbsenceDigestDto {

 String get userId; DateTime? get startAt; DateTime? get endAt; String? get note;
/// Create a copy of HouseholdAbsenceDigestDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HouseholdAbsenceDigestDtoCopyWith<HouseholdAbsenceDigestDto> get copyWith => _$HouseholdAbsenceDigestDtoCopyWithImpl<HouseholdAbsenceDigestDto>(this as HouseholdAbsenceDigestDto, _$identity);

  /// Serializes this HouseholdAbsenceDigestDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HouseholdAbsenceDigestDto&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.startAt, startAt) || other.startAt == startAt)&&(identical(other.endAt, endAt) || other.endAt == endAt)&&(identical(other.note, note) || other.note == note));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,userId,startAt,endAt,note);

@override
String toString() {
  return 'HouseholdAbsenceDigestDto(userId: $userId, startAt: $startAt, endAt: $endAt, note: $note)';
}


}

/// @nodoc
abstract mixin class $HouseholdAbsenceDigestDtoCopyWith<$Res>  {
  factory $HouseholdAbsenceDigestDtoCopyWith(HouseholdAbsenceDigestDto value, $Res Function(HouseholdAbsenceDigestDto) _then) = _$HouseholdAbsenceDigestDtoCopyWithImpl;
@useResult
$Res call({
 String userId, DateTime? startAt, DateTime? endAt, String? note
});




}
/// @nodoc
class _$HouseholdAbsenceDigestDtoCopyWithImpl<$Res>
    implements $HouseholdAbsenceDigestDtoCopyWith<$Res> {
  _$HouseholdAbsenceDigestDtoCopyWithImpl(this._self, this._then);

  final HouseholdAbsenceDigestDto _self;
  final $Res Function(HouseholdAbsenceDigestDto) _then;

/// Create a copy of HouseholdAbsenceDigestDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? userId = null,Object? startAt = freezed,Object? endAt = freezed,Object? note = freezed,}) {
  return _then(_self.copyWith(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,startAt: freezed == startAt ? _self.startAt : startAt // ignore: cast_nullable_to_non_nullable
as DateTime?,endAt: freezed == endAt ? _self.endAt : endAt // ignore: cast_nullable_to_non_nullable
as DateTime?,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [HouseholdAbsenceDigestDto].
extension HouseholdAbsenceDigestDtoPatterns on HouseholdAbsenceDigestDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _HouseholdAbsenceDigestDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _HouseholdAbsenceDigestDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _HouseholdAbsenceDigestDto value)  $default,){
final _that = this;
switch (_that) {
case _HouseholdAbsenceDigestDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _HouseholdAbsenceDigestDto value)?  $default,){
final _that = this;
switch (_that) {
case _HouseholdAbsenceDigestDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String userId,  DateTime? startAt,  DateTime? endAt,  String? note)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _HouseholdAbsenceDigestDto() when $default != null:
return $default(_that.userId,_that.startAt,_that.endAt,_that.note);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String userId,  DateTime? startAt,  DateTime? endAt,  String? note)  $default,) {final _that = this;
switch (_that) {
case _HouseholdAbsenceDigestDto():
return $default(_that.userId,_that.startAt,_that.endAt,_that.note);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String userId,  DateTime? startAt,  DateTime? endAt,  String? note)?  $default,) {final _that = this;
switch (_that) {
case _HouseholdAbsenceDigestDto() when $default != null:
return $default(_that.userId,_that.startAt,_that.endAt,_that.note);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()
@ApiDateTimeConverter()
class _HouseholdAbsenceDigestDto implements HouseholdAbsenceDigestDto {
  const _HouseholdAbsenceDigestDto({this.userId = '', this.startAt, this.endAt, this.note});
  factory _HouseholdAbsenceDigestDto.fromJson(Map<String, dynamic> json) => _$HouseholdAbsenceDigestDtoFromJson(json);

@override@JsonKey() final  String userId;
@override final  DateTime? startAt;
@override final  DateTime? endAt;
@override final  String? note;

/// Create a copy of HouseholdAbsenceDigestDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HouseholdAbsenceDigestDtoCopyWith<_HouseholdAbsenceDigestDto> get copyWith => __$HouseholdAbsenceDigestDtoCopyWithImpl<_HouseholdAbsenceDigestDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$HouseholdAbsenceDigestDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _HouseholdAbsenceDigestDto&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.startAt, startAt) || other.startAt == startAt)&&(identical(other.endAt, endAt) || other.endAt == endAt)&&(identical(other.note, note) || other.note == note));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,userId,startAt,endAt,note);

@override
String toString() {
  return 'HouseholdAbsenceDigestDto(userId: $userId, startAt: $startAt, endAt: $endAt, note: $note)';
}


}

/// @nodoc
abstract mixin class _$HouseholdAbsenceDigestDtoCopyWith<$Res> implements $HouseholdAbsenceDigestDtoCopyWith<$Res> {
  factory _$HouseholdAbsenceDigestDtoCopyWith(_HouseholdAbsenceDigestDto value, $Res Function(_HouseholdAbsenceDigestDto) _then) = __$HouseholdAbsenceDigestDtoCopyWithImpl;
@override @useResult
$Res call({
 String userId, DateTime? startAt, DateTime? endAt, String? note
});




}
/// @nodoc
class __$HouseholdAbsenceDigestDtoCopyWithImpl<$Res>
    implements _$HouseholdAbsenceDigestDtoCopyWith<$Res> {
  __$HouseholdAbsenceDigestDtoCopyWithImpl(this._self, this._then);

  final _HouseholdAbsenceDigestDto _self;
  final $Res Function(_HouseholdAbsenceDigestDto) _then;

/// Create a copy of HouseholdAbsenceDigestDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? userId = null,Object? startAt = freezed,Object? endAt = freezed,Object? note = freezed,}) {
  return _then(_HouseholdAbsenceDigestDto(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,startAt: freezed == startAt ? _self.startAt : startAt // ignore: cast_nullable_to_non_nullable
as DateTime?,endAt: freezed == endAt ? _self.endAt : endAt // ignore: cast_nullable_to_non_nullable
as DateTime?,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
