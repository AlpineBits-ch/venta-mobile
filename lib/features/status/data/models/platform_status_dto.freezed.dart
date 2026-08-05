// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'platform_status_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PlatformStatusDto {

@JsonKey(unknownEnumValue: StatusIndicator.unknown) StatusIndicator get indicator; DateTime? get updatedAt;/// Present only when [indicator] is not `operational`, and the only thing
/// the client is allowed to render as prose - see [StatusBannerDto].
 StatusBannerDto? get banner;/// One per component, already in display order. Never re-sorted here.
 List<StatusComponentDto> get components;/// Open incidents. `kind == incident`.
 List<StatusIncidentDto> get incidents;/// Active and upcoming maintenance windows. `kind == maintenance`.
 List<StatusIncidentDto> get maintenance;/// The last 7 resolved, with `updates` omitted by the server.
 List<StatusIncidentDto> get recent;
/// Create a copy of PlatformStatusDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PlatformStatusDtoCopyWith<PlatformStatusDto> get copyWith => _$PlatformStatusDtoCopyWithImpl<PlatformStatusDto>(this as PlatformStatusDto, _$identity);

  /// Serializes this PlatformStatusDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PlatformStatusDto&&(identical(other.indicator, indicator) || other.indicator == indicator)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.banner, banner) || other.banner == banner)&&const DeepCollectionEquality().equals(other.components, components)&&const DeepCollectionEquality().equals(other.incidents, incidents)&&const DeepCollectionEquality().equals(other.maintenance, maintenance)&&const DeepCollectionEquality().equals(other.recent, recent));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,indicator,updatedAt,banner,const DeepCollectionEquality().hash(components),const DeepCollectionEquality().hash(incidents),const DeepCollectionEquality().hash(maintenance),const DeepCollectionEquality().hash(recent));

@override
String toString() {
  return 'PlatformStatusDto(indicator: $indicator, updatedAt: $updatedAt, banner: $banner, components: $components, incidents: $incidents, maintenance: $maintenance, recent: $recent)';
}


}

/// @nodoc
abstract mixin class $PlatformStatusDtoCopyWith<$Res>  {
  factory $PlatformStatusDtoCopyWith(PlatformStatusDto value, $Res Function(PlatformStatusDto) _then) = _$PlatformStatusDtoCopyWithImpl;
@useResult
$Res call({
@JsonKey(unknownEnumValue: StatusIndicator.unknown) StatusIndicator indicator, DateTime? updatedAt, StatusBannerDto? banner, List<StatusComponentDto> components, List<StatusIncidentDto> incidents, List<StatusIncidentDto> maintenance, List<StatusIncidentDto> recent
});


$StatusBannerDtoCopyWith<$Res>? get banner;

}
/// @nodoc
class _$PlatformStatusDtoCopyWithImpl<$Res>
    implements $PlatformStatusDtoCopyWith<$Res> {
  _$PlatformStatusDtoCopyWithImpl(this._self, this._then);

  final PlatformStatusDto _self;
  final $Res Function(PlatformStatusDto) _then;

/// Create a copy of PlatformStatusDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? indicator = null,Object? updatedAt = freezed,Object? banner = freezed,Object? components = null,Object? incidents = null,Object? maintenance = null,Object? recent = null,}) {
  return _then(_self.copyWith(
indicator: null == indicator ? _self.indicator : indicator // ignore: cast_nullable_to_non_nullable
as StatusIndicator,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,banner: freezed == banner ? _self.banner : banner // ignore: cast_nullable_to_non_nullable
as StatusBannerDto?,components: null == components ? _self.components : components // ignore: cast_nullable_to_non_nullable
as List<StatusComponentDto>,incidents: null == incidents ? _self.incidents : incidents // ignore: cast_nullable_to_non_nullable
as List<StatusIncidentDto>,maintenance: null == maintenance ? _self.maintenance : maintenance // ignore: cast_nullable_to_non_nullable
as List<StatusIncidentDto>,recent: null == recent ? _self.recent : recent // ignore: cast_nullable_to_non_nullable
as List<StatusIncidentDto>,
  ));
}
/// Create a copy of PlatformStatusDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$StatusBannerDtoCopyWith<$Res>? get banner {
    if (_self.banner == null) {
    return null;
  }

  return $StatusBannerDtoCopyWith<$Res>(_self.banner!, (value) {
    return _then(_self.copyWith(banner: value));
  });
}
}


/// Adds pattern-matching-related methods to [PlatformStatusDto].
extension PlatformStatusDtoPatterns on PlatformStatusDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PlatformStatusDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PlatformStatusDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PlatformStatusDto value)  $default,){
final _that = this;
switch (_that) {
case _PlatformStatusDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PlatformStatusDto value)?  $default,){
final _that = this;
switch (_that) {
case _PlatformStatusDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(unknownEnumValue: StatusIndicator.unknown)  StatusIndicator indicator,  DateTime? updatedAt,  StatusBannerDto? banner,  List<StatusComponentDto> components,  List<StatusIncidentDto> incidents,  List<StatusIncidentDto> maintenance,  List<StatusIncidentDto> recent)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PlatformStatusDto() when $default != null:
return $default(_that.indicator,_that.updatedAt,_that.banner,_that.components,_that.incidents,_that.maintenance,_that.recent);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(unknownEnumValue: StatusIndicator.unknown)  StatusIndicator indicator,  DateTime? updatedAt,  StatusBannerDto? banner,  List<StatusComponentDto> components,  List<StatusIncidentDto> incidents,  List<StatusIncidentDto> maintenance,  List<StatusIncidentDto> recent)  $default,) {final _that = this;
switch (_that) {
case _PlatformStatusDto():
return $default(_that.indicator,_that.updatedAt,_that.banner,_that.components,_that.incidents,_that.maintenance,_that.recent);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(unknownEnumValue: StatusIndicator.unknown)  StatusIndicator indicator,  DateTime? updatedAt,  StatusBannerDto? banner,  List<StatusComponentDto> components,  List<StatusIncidentDto> incidents,  List<StatusIncidentDto> maintenance,  List<StatusIncidentDto> recent)?  $default,) {final _that = this;
switch (_that) {
case _PlatformStatusDto() when $default != null:
return $default(_that.indicator,_that.updatedAt,_that.banner,_that.components,_that.incidents,_that.maintenance,_that.recent);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()
@ApiDateTimeConverter()
class _PlatformStatusDto extends PlatformStatusDto {
  const _PlatformStatusDto({@JsonKey(unknownEnumValue: StatusIndicator.unknown) this.indicator = StatusIndicator.operational, this.updatedAt, this.banner, final  List<StatusComponentDto> components = const <StatusComponentDto>[], final  List<StatusIncidentDto> incidents = const <StatusIncidentDto>[], final  List<StatusIncidentDto> maintenance = const <StatusIncidentDto>[], final  List<StatusIncidentDto> recent = const <StatusIncidentDto>[]}): _components = components,_incidents = incidents,_maintenance = maintenance,_recent = recent,super._();
  factory _PlatformStatusDto.fromJson(Map<String, dynamic> json) => _$PlatformStatusDtoFromJson(json);

@override@JsonKey(unknownEnumValue: StatusIndicator.unknown) final  StatusIndicator indicator;
@override final  DateTime? updatedAt;
/// Present only when [indicator] is not `operational`, and the only thing
/// the client is allowed to render as prose - see [StatusBannerDto].
@override final  StatusBannerDto? banner;
/// One per component, already in display order. Never re-sorted here.
 final  List<StatusComponentDto> _components;
/// One per component, already in display order. Never re-sorted here.
@override@JsonKey() List<StatusComponentDto> get components {
  if (_components is EqualUnmodifiableListView) return _components;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_components);
}

/// Open incidents. `kind == incident`.
 final  List<StatusIncidentDto> _incidents;
/// Open incidents. `kind == incident`.
@override@JsonKey() List<StatusIncidentDto> get incidents {
  if (_incidents is EqualUnmodifiableListView) return _incidents;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_incidents);
}

/// Active and upcoming maintenance windows. `kind == maintenance`.
 final  List<StatusIncidentDto> _maintenance;
/// Active and upcoming maintenance windows. `kind == maintenance`.
@override@JsonKey() List<StatusIncidentDto> get maintenance {
  if (_maintenance is EqualUnmodifiableListView) return _maintenance;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_maintenance);
}

/// The last 7 resolved, with `updates` omitted by the server.
 final  List<StatusIncidentDto> _recent;
/// The last 7 resolved, with `updates` omitted by the server.
@override@JsonKey() List<StatusIncidentDto> get recent {
  if (_recent is EqualUnmodifiableListView) return _recent;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_recent);
}


/// Create a copy of PlatformStatusDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PlatformStatusDtoCopyWith<_PlatformStatusDto> get copyWith => __$PlatformStatusDtoCopyWithImpl<_PlatformStatusDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PlatformStatusDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PlatformStatusDto&&(identical(other.indicator, indicator) || other.indicator == indicator)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.banner, banner) || other.banner == banner)&&const DeepCollectionEquality().equals(other._components, _components)&&const DeepCollectionEquality().equals(other._incidents, _incidents)&&const DeepCollectionEquality().equals(other._maintenance, _maintenance)&&const DeepCollectionEquality().equals(other._recent, _recent));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,indicator,updatedAt,banner,const DeepCollectionEquality().hash(_components),const DeepCollectionEquality().hash(_incidents),const DeepCollectionEquality().hash(_maintenance),const DeepCollectionEquality().hash(_recent));

@override
String toString() {
  return 'PlatformStatusDto(indicator: $indicator, updatedAt: $updatedAt, banner: $banner, components: $components, incidents: $incidents, maintenance: $maintenance, recent: $recent)';
}


}

/// @nodoc
abstract mixin class _$PlatformStatusDtoCopyWith<$Res> implements $PlatformStatusDtoCopyWith<$Res> {
  factory _$PlatformStatusDtoCopyWith(_PlatformStatusDto value, $Res Function(_PlatformStatusDto) _then) = __$PlatformStatusDtoCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(unknownEnumValue: StatusIndicator.unknown) StatusIndicator indicator, DateTime? updatedAt, StatusBannerDto? banner, List<StatusComponentDto> components, List<StatusIncidentDto> incidents, List<StatusIncidentDto> maintenance, List<StatusIncidentDto> recent
});


@override $StatusBannerDtoCopyWith<$Res>? get banner;

}
/// @nodoc
class __$PlatformStatusDtoCopyWithImpl<$Res>
    implements _$PlatformStatusDtoCopyWith<$Res> {
  __$PlatformStatusDtoCopyWithImpl(this._self, this._then);

  final _PlatformStatusDto _self;
  final $Res Function(_PlatformStatusDto) _then;

/// Create a copy of PlatformStatusDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? indicator = null,Object? updatedAt = freezed,Object? banner = freezed,Object? components = null,Object? incidents = null,Object? maintenance = null,Object? recent = null,}) {
  return _then(_PlatformStatusDto(
indicator: null == indicator ? _self.indicator : indicator // ignore: cast_nullable_to_non_nullable
as StatusIndicator,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,banner: freezed == banner ? _self.banner : banner // ignore: cast_nullable_to_non_nullable
as StatusBannerDto?,components: null == components ? _self._components : components // ignore: cast_nullable_to_non_nullable
as List<StatusComponentDto>,incidents: null == incidents ? _self._incidents : incidents // ignore: cast_nullable_to_non_nullable
as List<StatusIncidentDto>,maintenance: null == maintenance ? _self._maintenance : maintenance // ignore: cast_nullable_to_non_nullable
as List<StatusIncidentDto>,recent: null == recent ? _self._recent : recent // ignore: cast_nullable_to_non_nullable
as List<StatusIncidentDto>,
  ));
}

/// Create a copy of PlatformStatusDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$StatusBannerDtoCopyWith<$Res>? get banner {
    if (_self.banner == null) {
    return null;
  }

  return $StatusBannerDtoCopyWith<$Res>(_self.banner!, (value) {
    return _then(_self.copyWith(banner: value));
  });
}
}


/// @nodoc
mixin _$StatusBannerDto {

 String get title; String get body;@JsonKey(unknownEnumValue: StatusSeverity.unknown) StatusSeverity get severity; String? get incidentReference;/// Where the public status page describes this one. Opened in the system
/// browser; `StatusRepository.bannerUrl` supplies a fallback if absent.
 String? get url;/// Non-null for a generated incident, whose copy comes from a fixed table
/// and could be translated client-side. Null for staff-written incidents,
/// which are free text in the instance's own language and have no
/// translation path.
 String? get template;/// Null when more than one component is affected.
 String? get componentKey;
/// Create a copy of StatusBannerDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StatusBannerDtoCopyWith<StatusBannerDto> get copyWith => _$StatusBannerDtoCopyWithImpl<StatusBannerDto>(this as StatusBannerDto, _$identity);

  /// Serializes this StatusBannerDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StatusBannerDto&&(identical(other.title, title) || other.title == title)&&(identical(other.body, body) || other.body == body)&&(identical(other.severity, severity) || other.severity == severity)&&(identical(other.incidentReference, incidentReference) || other.incidentReference == incidentReference)&&(identical(other.url, url) || other.url == url)&&(identical(other.template, template) || other.template == template)&&(identical(other.componentKey, componentKey) || other.componentKey == componentKey));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,title,body,severity,incidentReference,url,template,componentKey);

@override
String toString() {
  return 'StatusBannerDto(title: $title, body: $body, severity: $severity, incidentReference: $incidentReference, url: $url, template: $template, componentKey: $componentKey)';
}


}

/// @nodoc
abstract mixin class $StatusBannerDtoCopyWith<$Res>  {
  factory $StatusBannerDtoCopyWith(StatusBannerDto value, $Res Function(StatusBannerDto) _then) = _$StatusBannerDtoCopyWithImpl;
@useResult
$Res call({
 String title, String body,@JsonKey(unknownEnumValue: StatusSeverity.unknown) StatusSeverity severity, String? incidentReference, String? url, String? template, String? componentKey
});




}
/// @nodoc
class _$StatusBannerDtoCopyWithImpl<$Res>
    implements $StatusBannerDtoCopyWith<$Res> {
  _$StatusBannerDtoCopyWithImpl(this._self, this._then);

  final StatusBannerDto _self;
  final $Res Function(StatusBannerDto) _then;

/// Create a copy of StatusBannerDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? title = null,Object? body = null,Object? severity = null,Object? incidentReference = freezed,Object? url = freezed,Object? template = freezed,Object? componentKey = freezed,}) {
  return _then(_self.copyWith(
title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,body: null == body ? _self.body : body // ignore: cast_nullable_to_non_nullable
as String,severity: null == severity ? _self.severity : severity // ignore: cast_nullable_to_non_nullable
as StatusSeverity,incidentReference: freezed == incidentReference ? _self.incidentReference : incidentReference // ignore: cast_nullable_to_non_nullable
as String?,url: freezed == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String?,template: freezed == template ? _self.template : template // ignore: cast_nullable_to_non_nullable
as String?,componentKey: freezed == componentKey ? _self.componentKey : componentKey // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [StatusBannerDto].
extension StatusBannerDtoPatterns on StatusBannerDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _StatusBannerDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _StatusBannerDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _StatusBannerDto value)  $default,){
final _that = this;
switch (_that) {
case _StatusBannerDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _StatusBannerDto value)?  $default,){
final _that = this;
switch (_that) {
case _StatusBannerDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String title,  String body, @JsonKey(unknownEnumValue: StatusSeverity.unknown)  StatusSeverity severity,  String? incidentReference,  String? url,  String? template,  String? componentKey)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _StatusBannerDto() when $default != null:
return $default(_that.title,_that.body,_that.severity,_that.incidentReference,_that.url,_that.template,_that.componentKey);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String title,  String body, @JsonKey(unknownEnumValue: StatusSeverity.unknown)  StatusSeverity severity,  String? incidentReference,  String? url,  String? template,  String? componentKey)  $default,) {final _that = this;
switch (_that) {
case _StatusBannerDto():
return $default(_that.title,_that.body,_that.severity,_that.incidentReference,_that.url,_that.template,_that.componentKey);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String title,  String body, @JsonKey(unknownEnumValue: StatusSeverity.unknown)  StatusSeverity severity,  String? incidentReference,  String? url,  String? template,  String? componentKey)?  $default,) {final _that = this;
switch (_that) {
case _StatusBannerDto() when $default != null:
return $default(_that.title,_that.body,_that.severity,_that.incidentReference,_that.url,_that.template,_that.componentKey);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _StatusBannerDto implements StatusBannerDto {
  const _StatusBannerDto({this.title = '', this.body = '', @JsonKey(unknownEnumValue: StatusSeverity.unknown) this.severity = StatusSeverity.info, this.incidentReference, this.url, this.template, this.componentKey});
  factory _StatusBannerDto.fromJson(Map<String, dynamic> json) => _$StatusBannerDtoFromJson(json);

@override@JsonKey() final  String title;
@override@JsonKey() final  String body;
@override@JsonKey(unknownEnumValue: StatusSeverity.unknown) final  StatusSeverity severity;
@override final  String? incidentReference;
/// Where the public status page describes this one. Opened in the system
/// browser; `StatusRepository.bannerUrl` supplies a fallback if absent.
@override final  String? url;
/// Non-null for a generated incident, whose copy comes from a fixed table
/// and could be translated client-side. Null for staff-written incidents,
/// which are free text in the instance's own language and have no
/// translation path.
@override final  String? template;
/// Null when more than one component is affected.
@override final  String? componentKey;

/// Create a copy of StatusBannerDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StatusBannerDtoCopyWith<_StatusBannerDto> get copyWith => __$StatusBannerDtoCopyWithImpl<_StatusBannerDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$StatusBannerDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _StatusBannerDto&&(identical(other.title, title) || other.title == title)&&(identical(other.body, body) || other.body == body)&&(identical(other.severity, severity) || other.severity == severity)&&(identical(other.incidentReference, incidentReference) || other.incidentReference == incidentReference)&&(identical(other.url, url) || other.url == url)&&(identical(other.template, template) || other.template == template)&&(identical(other.componentKey, componentKey) || other.componentKey == componentKey));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,title,body,severity,incidentReference,url,template,componentKey);

@override
String toString() {
  return 'StatusBannerDto(title: $title, body: $body, severity: $severity, incidentReference: $incidentReference, url: $url, template: $template, componentKey: $componentKey)';
}


}

/// @nodoc
abstract mixin class _$StatusBannerDtoCopyWith<$Res> implements $StatusBannerDtoCopyWith<$Res> {
  factory _$StatusBannerDtoCopyWith(_StatusBannerDto value, $Res Function(_StatusBannerDto) _then) = __$StatusBannerDtoCopyWithImpl;
@override @useResult
$Res call({
 String title, String body,@JsonKey(unknownEnumValue: StatusSeverity.unknown) StatusSeverity severity, String? incidentReference, String? url, String? template, String? componentKey
});




}
/// @nodoc
class __$StatusBannerDtoCopyWithImpl<$Res>
    implements _$StatusBannerDtoCopyWith<$Res> {
  __$StatusBannerDtoCopyWithImpl(this._self, this._then);

  final _StatusBannerDto _self;
  final $Res Function(_StatusBannerDto) _then;

/// Create a copy of StatusBannerDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? title = null,Object? body = null,Object? severity = null,Object? incidentReference = freezed,Object? url = freezed,Object? template = freezed,Object? componentKey = freezed,}) {
  return _then(_StatusBannerDto(
title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,body: null == body ? _self.body : body // ignore: cast_nullable_to_non_nullable
as String,severity: null == severity ? _self.severity : severity // ignore: cast_nullable_to_non_nullable
as StatusSeverity,incidentReference: freezed == incidentReference ? _self.incidentReference : incidentReference // ignore: cast_nullable_to_non_nullable
as String?,url: freezed == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String?,template: freezed == template ? _self.template : template // ignore: cast_nullable_to_non_nullable
as String?,componentKey: freezed == componentKey ? _self.componentKey : componentKey // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$StatusComponentDto {

/// Stable and safe to switch on - `accounts`, `voice`, `previews`. The
/// display [name] is not; it is prose and may be translated or reworded.
 String get key; String get name; String? get description;@JsonKey(unknownEnumValue: ComponentStatus.unknown) ComponentStatus get status; DateTime? get statusSince;/// A fraction, not a percentage: `0.9987` is 99.87%.
 double? get uptime90d;
/// Create a copy of StatusComponentDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StatusComponentDtoCopyWith<StatusComponentDto> get copyWith => _$StatusComponentDtoCopyWithImpl<StatusComponentDto>(this as StatusComponentDto, _$identity);

  /// Serializes this StatusComponentDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StatusComponentDto&&(identical(other.key, key) || other.key == key)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.status, status) || other.status == status)&&(identical(other.statusSince, statusSince) || other.statusSince == statusSince)&&(identical(other.uptime90d, uptime90d) || other.uptime90d == uptime90d));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,key,name,description,status,statusSince,uptime90d);

@override
String toString() {
  return 'StatusComponentDto(key: $key, name: $name, description: $description, status: $status, statusSince: $statusSince, uptime90d: $uptime90d)';
}


}

/// @nodoc
abstract mixin class $StatusComponentDtoCopyWith<$Res>  {
  factory $StatusComponentDtoCopyWith(StatusComponentDto value, $Res Function(StatusComponentDto) _then) = _$StatusComponentDtoCopyWithImpl;
@useResult
$Res call({
 String key, String name, String? description,@JsonKey(unknownEnumValue: ComponentStatus.unknown) ComponentStatus status, DateTime? statusSince, double? uptime90d
});




}
/// @nodoc
class _$StatusComponentDtoCopyWithImpl<$Res>
    implements $StatusComponentDtoCopyWith<$Res> {
  _$StatusComponentDtoCopyWithImpl(this._self, this._then);

  final StatusComponentDto _self;
  final $Res Function(StatusComponentDto) _then;

/// Create a copy of StatusComponentDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? key = null,Object? name = null,Object? description = freezed,Object? status = null,Object? statusSince = freezed,Object? uptime90d = freezed,}) {
  return _then(_self.copyWith(
key: null == key ? _self.key : key // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ComponentStatus,statusSince: freezed == statusSince ? _self.statusSince : statusSince // ignore: cast_nullable_to_non_nullable
as DateTime?,uptime90d: freezed == uptime90d ? _self.uptime90d : uptime90d // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}

}


/// Adds pattern-matching-related methods to [StatusComponentDto].
extension StatusComponentDtoPatterns on StatusComponentDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _StatusComponentDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _StatusComponentDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _StatusComponentDto value)  $default,){
final _that = this;
switch (_that) {
case _StatusComponentDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _StatusComponentDto value)?  $default,){
final _that = this;
switch (_that) {
case _StatusComponentDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String key,  String name,  String? description, @JsonKey(unknownEnumValue: ComponentStatus.unknown)  ComponentStatus status,  DateTime? statusSince,  double? uptime90d)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _StatusComponentDto() when $default != null:
return $default(_that.key,_that.name,_that.description,_that.status,_that.statusSince,_that.uptime90d);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String key,  String name,  String? description, @JsonKey(unknownEnumValue: ComponentStatus.unknown)  ComponentStatus status,  DateTime? statusSince,  double? uptime90d)  $default,) {final _that = this;
switch (_that) {
case _StatusComponentDto():
return $default(_that.key,_that.name,_that.description,_that.status,_that.statusSince,_that.uptime90d);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String key,  String name,  String? description, @JsonKey(unknownEnumValue: ComponentStatus.unknown)  ComponentStatus status,  DateTime? statusSince,  double? uptime90d)?  $default,) {final _that = this;
switch (_that) {
case _StatusComponentDto() when $default != null:
return $default(_that.key,_that.name,_that.description,_that.status,_that.statusSince,_that.uptime90d);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()
@ApiDateTimeConverter()
class _StatusComponentDto implements StatusComponentDto {
  const _StatusComponentDto({this.key = '', this.name = '', this.description, @JsonKey(unknownEnumValue: ComponentStatus.unknown) this.status = ComponentStatus.operational, this.statusSince, this.uptime90d});
  factory _StatusComponentDto.fromJson(Map<String, dynamic> json) => _$StatusComponentDtoFromJson(json);

/// Stable and safe to switch on - `accounts`, `voice`, `previews`. The
/// display [name] is not; it is prose and may be translated or reworded.
@override@JsonKey() final  String key;
@override@JsonKey() final  String name;
@override final  String? description;
@override@JsonKey(unknownEnumValue: ComponentStatus.unknown) final  ComponentStatus status;
@override final  DateTime? statusSince;
/// A fraction, not a percentage: `0.9987` is 99.87%.
@override final  double? uptime90d;

/// Create a copy of StatusComponentDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StatusComponentDtoCopyWith<_StatusComponentDto> get copyWith => __$StatusComponentDtoCopyWithImpl<_StatusComponentDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$StatusComponentDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _StatusComponentDto&&(identical(other.key, key) || other.key == key)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.status, status) || other.status == status)&&(identical(other.statusSince, statusSince) || other.statusSince == statusSince)&&(identical(other.uptime90d, uptime90d) || other.uptime90d == uptime90d));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,key,name,description,status,statusSince,uptime90d);

@override
String toString() {
  return 'StatusComponentDto(key: $key, name: $name, description: $description, status: $status, statusSince: $statusSince, uptime90d: $uptime90d)';
}


}

/// @nodoc
abstract mixin class _$StatusComponentDtoCopyWith<$Res> implements $StatusComponentDtoCopyWith<$Res> {
  factory _$StatusComponentDtoCopyWith(_StatusComponentDto value, $Res Function(_StatusComponentDto) _then) = __$StatusComponentDtoCopyWithImpl;
@override @useResult
$Res call({
 String key, String name, String? description,@JsonKey(unknownEnumValue: ComponentStatus.unknown) ComponentStatus status, DateTime? statusSince, double? uptime90d
});




}
/// @nodoc
class __$StatusComponentDtoCopyWithImpl<$Res>
    implements _$StatusComponentDtoCopyWith<$Res> {
  __$StatusComponentDtoCopyWithImpl(this._self, this._then);

  final _StatusComponentDto _self;
  final $Res Function(_StatusComponentDto) _then;

/// Create a copy of StatusComponentDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? key = null,Object? name = null,Object? description = freezed,Object? status = null,Object? statusSince = freezed,Object? uptime90d = freezed,}) {
  return _then(_StatusComponentDto(
key: null == key ? _self.key : key // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ComponentStatus,statusSince: freezed == statusSince ? _self.statusSince : statusSince // ignore: cast_nullable_to_non_nullable
as DateTime?,uptime90d: freezed == uptime90d ? _self.uptime90d : uptime90d // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}


}


/// @nodoc
mixin _$StatusIncidentDto {

/// `VNT-4KQ7M2XB`. The identity of an incident across responses and across
/// the hub event, and what a dismissal is keyed on.
 String get reference;@JsonKey(unknownEnumValue: IncidentKind.unknown) IncidentKind get kind; String get title;@JsonKey(unknownEnumValue: IncidentImpact.unknown) IncidentImpact get impact;@JsonKey(unknownEnumValue: IncidentStatus.unknown) IncidentStatus get status;/// Component *keys*, matching [StatusComponentDto.key].
 List<String> get components; DateTime? get startedAt; DateTime? get resolvedAt;/// Maintenance only.
 DateTime? get scheduledFor; DateTime? get scheduledUntil; String? get template; String? get url;/// Newest first, per the spec - but nothing here relies on that; see
/// [newestUpdateAt].
 List<StatusIncidentUpdateDto> get updates;
/// Create a copy of StatusIncidentDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StatusIncidentDtoCopyWith<StatusIncidentDto> get copyWith => _$StatusIncidentDtoCopyWithImpl<StatusIncidentDto>(this as StatusIncidentDto, _$identity);

  /// Serializes this StatusIncidentDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StatusIncidentDto&&(identical(other.reference, reference) || other.reference == reference)&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.title, title) || other.title == title)&&(identical(other.impact, impact) || other.impact == impact)&&(identical(other.status, status) || other.status == status)&&const DeepCollectionEquality().equals(other.components, components)&&(identical(other.startedAt, startedAt) || other.startedAt == startedAt)&&(identical(other.resolvedAt, resolvedAt) || other.resolvedAt == resolvedAt)&&(identical(other.scheduledFor, scheduledFor) || other.scheduledFor == scheduledFor)&&(identical(other.scheduledUntil, scheduledUntil) || other.scheduledUntil == scheduledUntil)&&(identical(other.template, template) || other.template == template)&&(identical(other.url, url) || other.url == url)&&const DeepCollectionEquality().equals(other.updates, updates));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,reference,kind,title,impact,status,const DeepCollectionEquality().hash(components),startedAt,resolvedAt,scheduledFor,scheduledUntil,template,url,const DeepCollectionEquality().hash(updates));

@override
String toString() {
  return 'StatusIncidentDto(reference: $reference, kind: $kind, title: $title, impact: $impact, status: $status, components: $components, startedAt: $startedAt, resolvedAt: $resolvedAt, scheduledFor: $scheduledFor, scheduledUntil: $scheduledUntil, template: $template, url: $url, updates: $updates)';
}


}

/// @nodoc
abstract mixin class $StatusIncidentDtoCopyWith<$Res>  {
  factory $StatusIncidentDtoCopyWith(StatusIncidentDto value, $Res Function(StatusIncidentDto) _then) = _$StatusIncidentDtoCopyWithImpl;
@useResult
$Res call({
 String reference,@JsonKey(unknownEnumValue: IncidentKind.unknown) IncidentKind kind, String title,@JsonKey(unknownEnumValue: IncidentImpact.unknown) IncidentImpact impact,@JsonKey(unknownEnumValue: IncidentStatus.unknown) IncidentStatus status, List<String> components, DateTime? startedAt, DateTime? resolvedAt, DateTime? scheduledFor, DateTime? scheduledUntil, String? template, String? url, List<StatusIncidentUpdateDto> updates
});




}
/// @nodoc
class _$StatusIncidentDtoCopyWithImpl<$Res>
    implements $StatusIncidentDtoCopyWith<$Res> {
  _$StatusIncidentDtoCopyWithImpl(this._self, this._then);

  final StatusIncidentDto _self;
  final $Res Function(StatusIncidentDto) _then;

/// Create a copy of StatusIncidentDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? reference = null,Object? kind = null,Object? title = null,Object? impact = null,Object? status = null,Object? components = null,Object? startedAt = freezed,Object? resolvedAt = freezed,Object? scheduledFor = freezed,Object? scheduledUntil = freezed,Object? template = freezed,Object? url = freezed,Object? updates = null,}) {
  return _then(_self.copyWith(
reference: null == reference ? _self.reference : reference // ignore: cast_nullable_to_non_nullable
as String,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as IncidentKind,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,impact: null == impact ? _self.impact : impact // ignore: cast_nullable_to_non_nullable
as IncidentImpact,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as IncidentStatus,components: null == components ? _self.components : components // ignore: cast_nullable_to_non_nullable
as List<String>,startedAt: freezed == startedAt ? _self.startedAt : startedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,resolvedAt: freezed == resolvedAt ? _self.resolvedAt : resolvedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,scheduledFor: freezed == scheduledFor ? _self.scheduledFor : scheduledFor // ignore: cast_nullable_to_non_nullable
as DateTime?,scheduledUntil: freezed == scheduledUntil ? _self.scheduledUntil : scheduledUntil // ignore: cast_nullable_to_non_nullable
as DateTime?,template: freezed == template ? _self.template : template // ignore: cast_nullable_to_non_nullable
as String?,url: freezed == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String?,updates: null == updates ? _self.updates : updates // ignore: cast_nullable_to_non_nullable
as List<StatusIncidentUpdateDto>,
  ));
}

}


/// Adds pattern-matching-related methods to [StatusIncidentDto].
extension StatusIncidentDtoPatterns on StatusIncidentDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _StatusIncidentDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _StatusIncidentDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _StatusIncidentDto value)  $default,){
final _that = this;
switch (_that) {
case _StatusIncidentDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _StatusIncidentDto value)?  $default,){
final _that = this;
switch (_that) {
case _StatusIncidentDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String reference, @JsonKey(unknownEnumValue: IncidentKind.unknown)  IncidentKind kind,  String title, @JsonKey(unknownEnumValue: IncidentImpact.unknown)  IncidentImpact impact, @JsonKey(unknownEnumValue: IncidentStatus.unknown)  IncidentStatus status,  List<String> components,  DateTime? startedAt,  DateTime? resolvedAt,  DateTime? scheduledFor,  DateTime? scheduledUntil,  String? template,  String? url,  List<StatusIncidentUpdateDto> updates)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _StatusIncidentDto() when $default != null:
return $default(_that.reference,_that.kind,_that.title,_that.impact,_that.status,_that.components,_that.startedAt,_that.resolvedAt,_that.scheduledFor,_that.scheduledUntil,_that.template,_that.url,_that.updates);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String reference, @JsonKey(unknownEnumValue: IncidentKind.unknown)  IncidentKind kind,  String title, @JsonKey(unknownEnumValue: IncidentImpact.unknown)  IncidentImpact impact, @JsonKey(unknownEnumValue: IncidentStatus.unknown)  IncidentStatus status,  List<String> components,  DateTime? startedAt,  DateTime? resolvedAt,  DateTime? scheduledFor,  DateTime? scheduledUntil,  String? template,  String? url,  List<StatusIncidentUpdateDto> updates)  $default,) {final _that = this;
switch (_that) {
case _StatusIncidentDto():
return $default(_that.reference,_that.kind,_that.title,_that.impact,_that.status,_that.components,_that.startedAt,_that.resolvedAt,_that.scheduledFor,_that.scheduledUntil,_that.template,_that.url,_that.updates);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String reference, @JsonKey(unknownEnumValue: IncidentKind.unknown)  IncidentKind kind,  String title, @JsonKey(unknownEnumValue: IncidentImpact.unknown)  IncidentImpact impact, @JsonKey(unknownEnumValue: IncidentStatus.unknown)  IncidentStatus status,  List<String> components,  DateTime? startedAt,  DateTime? resolvedAt,  DateTime? scheduledFor,  DateTime? scheduledUntil,  String? template,  String? url,  List<StatusIncidentUpdateDto> updates)?  $default,) {final _that = this;
switch (_that) {
case _StatusIncidentDto() when $default != null:
return $default(_that.reference,_that.kind,_that.title,_that.impact,_that.status,_that.components,_that.startedAt,_that.resolvedAt,_that.scheduledFor,_that.scheduledUntil,_that.template,_that.url,_that.updates);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()
@ApiDateTimeConverter()
class _StatusIncidentDto extends StatusIncidentDto {
  const _StatusIncidentDto({this.reference = '', @JsonKey(unknownEnumValue: IncidentKind.unknown) this.kind = IncidentKind.incident, this.title = '', @JsonKey(unknownEnumValue: IncidentImpact.unknown) this.impact = IncidentImpact.none, @JsonKey(unknownEnumValue: IncidentStatus.unknown) this.status = IncidentStatus.unknown, final  List<String> components = const <String>[], this.startedAt, this.resolvedAt, this.scheduledFor, this.scheduledUntil, this.template, this.url, final  List<StatusIncidentUpdateDto> updates = const <StatusIncidentUpdateDto>[]}): _components = components,_updates = updates,super._();
  factory _StatusIncidentDto.fromJson(Map<String, dynamic> json) => _$StatusIncidentDtoFromJson(json);

/// `VNT-4KQ7M2XB`. The identity of an incident across responses and across
/// the hub event, and what a dismissal is keyed on.
@override@JsonKey() final  String reference;
@override@JsonKey(unknownEnumValue: IncidentKind.unknown) final  IncidentKind kind;
@override@JsonKey() final  String title;
@override@JsonKey(unknownEnumValue: IncidentImpact.unknown) final  IncidentImpact impact;
@override@JsonKey(unknownEnumValue: IncidentStatus.unknown) final  IncidentStatus status;
/// Component *keys*, matching [StatusComponentDto.key].
 final  List<String> _components;
/// Component *keys*, matching [StatusComponentDto.key].
@override@JsonKey() List<String> get components {
  if (_components is EqualUnmodifiableListView) return _components;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_components);
}

@override final  DateTime? startedAt;
@override final  DateTime? resolvedAt;
/// Maintenance only.
@override final  DateTime? scheduledFor;
@override final  DateTime? scheduledUntil;
@override final  String? template;
@override final  String? url;
/// Newest first, per the spec - but nothing here relies on that; see
/// [newestUpdateAt].
 final  List<StatusIncidentUpdateDto> _updates;
/// Newest first, per the spec - but nothing here relies on that; see
/// [newestUpdateAt].
@override@JsonKey() List<StatusIncidentUpdateDto> get updates {
  if (_updates is EqualUnmodifiableListView) return _updates;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_updates);
}


/// Create a copy of StatusIncidentDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StatusIncidentDtoCopyWith<_StatusIncidentDto> get copyWith => __$StatusIncidentDtoCopyWithImpl<_StatusIncidentDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$StatusIncidentDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _StatusIncidentDto&&(identical(other.reference, reference) || other.reference == reference)&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.title, title) || other.title == title)&&(identical(other.impact, impact) || other.impact == impact)&&(identical(other.status, status) || other.status == status)&&const DeepCollectionEquality().equals(other._components, _components)&&(identical(other.startedAt, startedAt) || other.startedAt == startedAt)&&(identical(other.resolvedAt, resolvedAt) || other.resolvedAt == resolvedAt)&&(identical(other.scheduledFor, scheduledFor) || other.scheduledFor == scheduledFor)&&(identical(other.scheduledUntil, scheduledUntil) || other.scheduledUntil == scheduledUntil)&&(identical(other.template, template) || other.template == template)&&(identical(other.url, url) || other.url == url)&&const DeepCollectionEquality().equals(other._updates, _updates));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,reference,kind,title,impact,status,const DeepCollectionEquality().hash(_components),startedAt,resolvedAt,scheduledFor,scheduledUntil,template,url,const DeepCollectionEquality().hash(_updates));

@override
String toString() {
  return 'StatusIncidentDto(reference: $reference, kind: $kind, title: $title, impact: $impact, status: $status, components: $components, startedAt: $startedAt, resolvedAt: $resolvedAt, scheduledFor: $scheduledFor, scheduledUntil: $scheduledUntil, template: $template, url: $url, updates: $updates)';
}


}

/// @nodoc
abstract mixin class _$StatusIncidentDtoCopyWith<$Res> implements $StatusIncidentDtoCopyWith<$Res> {
  factory _$StatusIncidentDtoCopyWith(_StatusIncidentDto value, $Res Function(_StatusIncidentDto) _then) = __$StatusIncidentDtoCopyWithImpl;
@override @useResult
$Res call({
 String reference,@JsonKey(unknownEnumValue: IncidentKind.unknown) IncidentKind kind, String title,@JsonKey(unknownEnumValue: IncidentImpact.unknown) IncidentImpact impact,@JsonKey(unknownEnumValue: IncidentStatus.unknown) IncidentStatus status, List<String> components, DateTime? startedAt, DateTime? resolvedAt, DateTime? scheduledFor, DateTime? scheduledUntil, String? template, String? url, List<StatusIncidentUpdateDto> updates
});




}
/// @nodoc
class __$StatusIncidentDtoCopyWithImpl<$Res>
    implements _$StatusIncidentDtoCopyWith<$Res> {
  __$StatusIncidentDtoCopyWithImpl(this._self, this._then);

  final _StatusIncidentDto _self;
  final $Res Function(_StatusIncidentDto) _then;

/// Create a copy of StatusIncidentDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? reference = null,Object? kind = null,Object? title = null,Object? impact = null,Object? status = null,Object? components = null,Object? startedAt = freezed,Object? resolvedAt = freezed,Object? scheduledFor = freezed,Object? scheduledUntil = freezed,Object? template = freezed,Object? url = freezed,Object? updates = null,}) {
  return _then(_StatusIncidentDto(
reference: null == reference ? _self.reference : reference // ignore: cast_nullable_to_non_nullable
as String,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as IncidentKind,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,impact: null == impact ? _self.impact : impact // ignore: cast_nullable_to_non_nullable
as IncidentImpact,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as IncidentStatus,components: null == components ? _self._components : components // ignore: cast_nullable_to_non_nullable
as List<String>,startedAt: freezed == startedAt ? _self.startedAt : startedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,resolvedAt: freezed == resolvedAt ? _self.resolvedAt : resolvedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,scheduledFor: freezed == scheduledFor ? _self.scheduledFor : scheduledFor // ignore: cast_nullable_to_non_nullable
as DateTime?,scheduledUntil: freezed == scheduledUntil ? _self.scheduledUntil : scheduledUntil // ignore: cast_nullable_to_non_nullable
as DateTime?,template: freezed == template ? _self.template : template // ignore: cast_nullable_to_non_nullable
as String?,url: freezed == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String?,updates: null == updates ? _self._updates : updates // ignore: cast_nullable_to_non_nullable
as List<StatusIncidentUpdateDto>,
  ));
}


}


/// @nodoc
mixin _$StatusIncidentUpdateDto {

@JsonKey(unknownEnumValue: IncidentStatus.unknown) IncidentStatus get status; String get body; String? get template; DateTime? get postedAt;
/// Create a copy of StatusIncidentUpdateDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StatusIncidentUpdateDtoCopyWith<StatusIncidentUpdateDto> get copyWith => _$StatusIncidentUpdateDtoCopyWithImpl<StatusIncidentUpdateDto>(this as StatusIncidentUpdateDto, _$identity);

  /// Serializes this StatusIncidentUpdateDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StatusIncidentUpdateDto&&(identical(other.status, status) || other.status == status)&&(identical(other.body, body) || other.body == body)&&(identical(other.template, template) || other.template == template)&&(identical(other.postedAt, postedAt) || other.postedAt == postedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,status,body,template,postedAt);

@override
String toString() {
  return 'StatusIncidentUpdateDto(status: $status, body: $body, template: $template, postedAt: $postedAt)';
}


}

/// @nodoc
abstract mixin class $StatusIncidentUpdateDtoCopyWith<$Res>  {
  factory $StatusIncidentUpdateDtoCopyWith(StatusIncidentUpdateDto value, $Res Function(StatusIncidentUpdateDto) _then) = _$StatusIncidentUpdateDtoCopyWithImpl;
@useResult
$Res call({
@JsonKey(unknownEnumValue: IncidentStatus.unknown) IncidentStatus status, String body, String? template, DateTime? postedAt
});




}
/// @nodoc
class _$StatusIncidentUpdateDtoCopyWithImpl<$Res>
    implements $StatusIncidentUpdateDtoCopyWith<$Res> {
  _$StatusIncidentUpdateDtoCopyWithImpl(this._self, this._then);

  final StatusIncidentUpdateDto _self;
  final $Res Function(StatusIncidentUpdateDto) _then;

/// Create a copy of StatusIncidentUpdateDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? status = null,Object? body = null,Object? template = freezed,Object? postedAt = freezed,}) {
  return _then(_self.copyWith(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as IncidentStatus,body: null == body ? _self.body : body // ignore: cast_nullable_to_non_nullable
as String,template: freezed == template ? _self.template : template // ignore: cast_nullable_to_non_nullable
as String?,postedAt: freezed == postedAt ? _self.postedAt : postedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [StatusIncidentUpdateDto].
extension StatusIncidentUpdateDtoPatterns on StatusIncidentUpdateDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _StatusIncidentUpdateDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _StatusIncidentUpdateDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _StatusIncidentUpdateDto value)  $default,){
final _that = this;
switch (_that) {
case _StatusIncidentUpdateDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _StatusIncidentUpdateDto value)?  $default,){
final _that = this;
switch (_that) {
case _StatusIncidentUpdateDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(unknownEnumValue: IncidentStatus.unknown)  IncidentStatus status,  String body,  String? template,  DateTime? postedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _StatusIncidentUpdateDto() when $default != null:
return $default(_that.status,_that.body,_that.template,_that.postedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(unknownEnumValue: IncidentStatus.unknown)  IncidentStatus status,  String body,  String? template,  DateTime? postedAt)  $default,) {final _that = this;
switch (_that) {
case _StatusIncidentUpdateDto():
return $default(_that.status,_that.body,_that.template,_that.postedAt);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(unknownEnumValue: IncidentStatus.unknown)  IncidentStatus status,  String body,  String? template,  DateTime? postedAt)?  $default,) {final _that = this;
switch (_that) {
case _StatusIncidentUpdateDto() when $default != null:
return $default(_that.status,_that.body,_that.template,_that.postedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()
@ApiDateTimeConverter()
class _StatusIncidentUpdateDto implements StatusIncidentUpdateDto {
  const _StatusIncidentUpdateDto({@JsonKey(unknownEnumValue: IncidentStatus.unknown) this.status = IncidentStatus.unknown, this.body = '', this.template, this.postedAt});
  factory _StatusIncidentUpdateDto.fromJson(Map<String, dynamic> json) => _$StatusIncidentUpdateDtoFromJson(json);

@override@JsonKey(unknownEnumValue: IncidentStatus.unknown) final  IncidentStatus status;
@override@JsonKey() final  String body;
@override final  String? template;
@override final  DateTime? postedAt;

/// Create a copy of StatusIncidentUpdateDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StatusIncidentUpdateDtoCopyWith<_StatusIncidentUpdateDto> get copyWith => __$StatusIncidentUpdateDtoCopyWithImpl<_StatusIncidentUpdateDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$StatusIncidentUpdateDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _StatusIncidentUpdateDto&&(identical(other.status, status) || other.status == status)&&(identical(other.body, body) || other.body == body)&&(identical(other.template, template) || other.template == template)&&(identical(other.postedAt, postedAt) || other.postedAt == postedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,status,body,template,postedAt);

@override
String toString() {
  return 'StatusIncidentUpdateDto(status: $status, body: $body, template: $template, postedAt: $postedAt)';
}


}

/// @nodoc
abstract mixin class _$StatusIncidentUpdateDtoCopyWith<$Res> implements $StatusIncidentUpdateDtoCopyWith<$Res> {
  factory _$StatusIncidentUpdateDtoCopyWith(_StatusIncidentUpdateDto value, $Res Function(_StatusIncidentUpdateDto) _then) = __$StatusIncidentUpdateDtoCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(unknownEnumValue: IncidentStatus.unknown) IncidentStatus status, String body, String? template, DateTime? postedAt
});




}
/// @nodoc
class __$StatusIncidentUpdateDtoCopyWithImpl<$Res>
    implements _$StatusIncidentUpdateDtoCopyWith<$Res> {
  __$StatusIncidentUpdateDtoCopyWithImpl(this._self, this._then);

  final _StatusIncidentUpdateDto _self;
  final $Res Function(_StatusIncidentUpdateDto) _then;

/// Create a copy of StatusIncidentUpdateDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? status = null,Object? body = null,Object? template = freezed,Object? postedAt = freezed,}) {
  return _then(_StatusIncidentUpdateDto(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as IncidentStatus,body: null == body ? _self.body : body // ignore: cast_nullable_to_non_nullable
as String,template: freezed == template ? _self.template : template // ignore: cast_nullable_to_non_nullable
as String?,postedAt: freezed == postedAt ? _self.postedAt : postedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
