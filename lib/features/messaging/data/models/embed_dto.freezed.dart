// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'embed_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$EmbedDto implements DiagnosticableTreeMixin {

@JsonKey(unknownEnumValue: EmbedType.unknown) EmbedType get type;/// `type` again, unparsed.
///
/// Needed because a `venta.*` kind added after this build decodes to
/// [EmbedType.unknown], which is indistinguishable from any other unknown
/// type once the enum has swallowed the string - and the two want opposite
/// treatment: an unknown ordinary type falls back to the link card, an
/// unknown internal-link type draws nothing at all.
@JsonKey(name: 'type', includeToJson: false) String get rawType; String? get title; String? get description; String? get url;/// The *content's* own date (a publication date, say) - not when the
/// preview was generated.
 DateTime? get timestamp;/// `#rrggbb`, and the card's left accent bar. Null for most generated
/// previews; bots set it deliberately.
 String? get color; EmbedProviderDto? get provider; EmbedAuthorDto? get author;/// Small, beside the text. Doubles as the poster frame for [video].
 EmbedMediaDto? get thumbnail;/// Large, full-width below the text.
 EmbedMediaDto? get image;/// A player-capable provider (YouTube/Vimeo/Twitch/Spotify). [url] here is
/// an embeddable iframe document, which this client has no sandboxed frame
/// to put it in - see `MessageEmbedsView`, which degrades to a play badge
/// that opens the original externally.
 EmbedMediaDto? get video; List<EmbedFieldDto> get fields; EmbedFooterDto? get footer;/// The identifiers behind a `venta.*` card.
///
/// **Only trustworthy when [EmbedDtoX.isGenerated].** A bot authors its own
/// embeds and may put any `venta` block it likes in one; see
/// [EmbedDtoX.isServerVouchedVenta].
 EmbedVentaDto? get venta;/// Bitfield. Bit 16 (65536) marks a card the server unfurled from a link
/// rather than one its author wrote.
 int get flags;
/// Create a copy of EmbedDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EmbedDtoCopyWith<EmbedDto> get copyWith => _$EmbedDtoCopyWithImpl<EmbedDto>(this as EmbedDto, _$identity);

  /// Serializes this EmbedDto to a JSON map.
  Map<String, dynamic> toJson();

@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'EmbedDto'))
    ..add(DiagnosticsProperty('type', type))..add(DiagnosticsProperty('rawType', rawType))..add(DiagnosticsProperty('title', title))..add(DiagnosticsProperty('description', description))..add(DiagnosticsProperty('url', url))..add(DiagnosticsProperty('timestamp', timestamp))..add(DiagnosticsProperty('color', color))..add(DiagnosticsProperty('provider', provider))..add(DiagnosticsProperty('author', author))..add(DiagnosticsProperty('thumbnail', thumbnail))..add(DiagnosticsProperty('image', image))..add(DiagnosticsProperty('video', video))..add(DiagnosticsProperty('fields', fields))..add(DiagnosticsProperty('footer', footer))..add(DiagnosticsProperty('venta', venta))..add(DiagnosticsProperty('flags', flags));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EmbedDto&&(identical(other.type, type) || other.type == type)&&(identical(other.rawType, rawType) || other.rawType == rawType)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.url, url) || other.url == url)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp)&&(identical(other.color, color) || other.color == color)&&(identical(other.provider, provider) || other.provider == provider)&&(identical(other.author, author) || other.author == author)&&(identical(other.thumbnail, thumbnail) || other.thumbnail == thumbnail)&&(identical(other.image, image) || other.image == image)&&(identical(other.video, video) || other.video == video)&&const DeepCollectionEquality().equals(other.fields, fields)&&(identical(other.footer, footer) || other.footer == footer)&&(identical(other.venta, venta) || other.venta == venta)&&(identical(other.flags, flags) || other.flags == flags));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,type,rawType,title,description,url,timestamp,color,provider,author,thumbnail,image,video,const DeepCollectionEquality().hash(fields),footer,venta,flags);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'EmbedDto(type: $type, rawType: $rawType, title: $title, description: $description, url: $url, timestamp: $timestamp, color: $color, provider: $provider, author: $author, thumbnail: $thumbnail, image: $image, video: $video, fields: $fields, footer: $footer, venta: $venta, flags: $flags)';
}


}

/// @nodoc
abstract mixin class $EmbedDtoCopyWith<$Res>  {
  factory $EmbedDtoCopyWith(EmbedDto value, $Res Function(EmbedDto) _then) = _$EmbedDtoCopyWithImpl;
@useResult
$Res call({
@JsonKey(unknownEnumValue: EmbedType.unknown) EmbedType type,@JsonKey(name: 'type', includeToJson: false) String rawType, String? title, String? description, String? url, DateTime? timestamp, String? color, EmbedProviderDto? provider, EmbedAuthorDto? author, EmbedMediaDto? thumbnail, EmbedMediaDto? image, EmbedMediaDto? video, List<EmbedFieldDto> fields, EmbedFooterDto? footer, EmbedVentaDto? venta, int flags
});


$EmbedProviderDtoCopyWith<$Res>? get provider;$EmbedAuthorDtoCopyWith<$Res>? get author;$EmbedMediaDtoCopyWith<$Res>? get thumbnail;$EmbedMediaDtoCopyWith<$Res>? get image;$EmbedMediaDtoCopyWith<$Res>? get video;$EmbedFooterDtoCopyWith<$Res>? get footer;$EmbedVentaDtoCopyWith<$Res>? get venta;

}
/// @nodoc
class _$EmbedDtoCopyWithImpl<$Res>
    implements $EmbedDtoCopyWith<$Res> {
  _$EmbedDtoCopyWithImpl(this._self, this._then);

  final EmbedDto _self;
  final $Res Function(EmbedDto) _then;

/// Create a copy of EmbedDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? type = null,Object? rawType = null,Object? title = freezed,Object? description = freezed,Object? url = freezed,Object? timestamp = freezed,Object? color = freezed,Object? provider = freezed,Object? author = freezed,Object? thumbnail = freezed,Object? image = freezed,Object? video = freezed,Object? fields = null,Object? footer = freezed,Object? venta = freezed,Object? flags = null,}) {
  return _then(_self.copyWith(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as EmbedType,rawType: null == rawType ? _self.rawType : rawType // ignore: cast_nullable_to_non_nullable
as String,title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,url: freezed == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String?,timestamp: freezed == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as DateTime?,color: freezed == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as String?,provider: freezed == provider ? _self.provider : provider // ignore: cast_nullable_to_non_nullable
as EmbedProviderDto?,author: freezed == author ? _self.author : author // ignore: cast_nullable_to_non_nullable
as EmbedAuthorDto?,thumbnail: freezed == thumbnail ? _self.thumbnail : thumbnail // ignore: cast_nullable_to_non_nullable
as EmbedMediaDto?,image: freezed == image ? _self.image : image // ignore: cast_nullable_to_non_nullable
as EmbedMediaDto?,video: freezed == video ? _self.video : video // ignore: cast_nullable_to_non_nullable
as EmbedMediaDto?,fields: null == fields ? _self.fields : fields // ignore: cast_nullable_to_non_nullable
as List<EmbedFieldDto>,footer: freezed == footer ? _self.footer : footer // ignore: cast_nullable_to_non_nullable
as EmbedFooterDto?,venta: freezed == venta ? _self.venta : venta // ignore: cast_nullable_to_non_nullable
as EmbedVentaDto?,flags: null == flags ? _self.flags : flags // ignore: cast_nullable_to_non_nullable
as int,
  ));
}
/// Create a copy of EmbedDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$EmbedProviderDtoCopyWith<$Res>? get provider {
    if (_self.provider == null) {
    return null;
  }

  return $EmbedProviderDtoCopyWith<$Res>(_self.provider!, (value) {
    return _then(_self.copyWith(provider: value));
  });
}/// Create a copy of EmbedDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$EmbedAuthorDtoCopyWith<$Res>? get author {
    if (_self.author == null) {
    return null;
  }

  return $EmbedAuthorDtoCopyWith<$Res>(_self.author!, (value) {
    return _then(_self.copyWith(author: value));
  });
}/// Create a copy of EmbedDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$EmbedMediaDtoCopyWith<$Res>? get thumbnail {
    if (_self.thumbnail == null) {
    return null;
  }

  return $EmbedMediaDtoCopyWith<$Res>(_self.thumbnail!, (value) {
    return _then(_self.copyWith(thumbnail: value));
  });
}/// Create a copy of EmbedDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$EmbedMediaDtoCopyWith<$Res>? get image {
    if (_self.image == null) {
    return null;
  }

  return $EmbedMediaDtoCopyWith<$Res>(_self.image!, (value) {
    return _then(_self.copyWith(image: value));
  });
}/// Create a copy of EmbedDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$EmbedMediaDtoCopyWith<$Res>? get video {
    if (_self.video == null) {
    return null;
  }

  return $EmbedMediaDtoCopyWith<$Res>(_self.video!, (value) {
    return _then(_self.copyWith(video: value));
  });
}/// Create a copy of EmbedDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$EmbedFooterDtoCopyWith<$Res>? get footer {
    if (_self.footer == null) {
    return null;
  }

  return $EmbedFooterDtoCopyWith<$Res>(_self.footer!, (value) {
    return _then(_self.copyWith(footer: value));
  });
}/// Create a copy of EmbedDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$EmbedVentaDtoCopyWith<$Res>? get venta {
    if (_self.venta == null) {
    return null;
  }

  return $EmbedVentaDtoCopyWith<$Res>(_self.venta!, (value) {
    return _then(_self.copyWith(venta: value));
  });
}
}


/// Adds pattern-matching-related methods to [EmbedDto].
extension EmbedDtoPatterns on EmbedDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _EmbedDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _EmbedDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _EmbedDto value)  $default,){
final _that = this;
switch (_that) {
case _EmbedDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _EmbedDto value)?  $default,){
final _that = this;
switch (_that) {
case _EmbedDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(unknownEnumValue: EmbedType.unknown)  EmbedType type, @JsonKey(name: 'type', includeToJson: false)  String rawType,  String? title,  String? description,  String? url,  DateTime? timestamp,  String? color,  EmbedProviderDto? provider,  EmbedAuthorDto? author,  EmbedMediaDto? thumbnail,  EmbedMediaDto? image,  EmbedMediaDto? video,  List<EmbedFieldDto> fields,  EmbedFooterDto? footer,  EmbedVentaDto? venta,  int flags)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EmbedDto() when $default != null:
return $default(_that.type,_that.rawType,_that.title,_that.description,_that.url,_that.timestamp,_that.color,_that.provider,_that.author,_that.thumbnail,_that.image,_that.video,_that.fields,_that.footer,_that.venta,_that.flags);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(unknownEnumValue: EmbedType.unknown)  EmbedType type, @JsonKey(name: 'type', includeToJson: false)  String rawType,  String? title,  String? description,  String? url,  DateTime? timestamp,  String? color,  EmbedProviderDto? provider,  EmbedAuthorDto? author,  EmbedMediaDto? thumbnail,  EmbedMediaDto? image,  EmbedMediaDto? video,  List<EmbedFieldDto> fields,  EmbedFooterDto? footer,  EmbedVentaDto? venta,  int flags)  $default,) {final _that = this;
switch (_that) {
case _EmbedDto():
return $default(_that.type,_that.rawType,_that.title,_that.description,_that.url,_that.timestamp,_that.color,_that.provider,_that.author,_that.thumbnail,_that.image,_that.video,_that.fields,_that.footer,_that.venta,_that.flags);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(unknownEnumValue: EmbedType.unknown)  EmbedType type, @JsonKey(name: 'type', includeToJson: false)  String rawType,  String? title,  String? description,  String? url,  DateTime? timestamp,  String? color,  EmbedProviderDto? provider,  EmbedAuthorDto? author,  EmbedMediaDto? thumbnail,  EmbedMediaDto? image,  EmbedMediaDto? video,  List<EmbedFieldDto> fields,  EmbedFooterDto? footer,  EmbedVentaDto? venta,  int flags)?  $default,) {final _that = this;
switch (_that) {
case _EmbedDto() when $default != null:
return $default(_that.type,_that.rawType,_that.title,_that.description,_that.url,_that.timestamp,_that.color,_that.provider,_that.author,_that.thumbnail,_that.image,_that.video,_that.fields,_that.footer,_that.venta,_that.flags);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()
@ApiDateTimeConverter()
class _EmbedDto with DiagnosticableTreeMixin implements EmbedDto {
  const _EmbedDto({@JsonKey(unknownEnumValue: EmbedType.unknown) this.type = EmbedType.link, @JsonKey(name: 'type', includeToJson: false) this.rawType = '', this.title, this.description, this.url, this.timestamp, this.color, this.provider, this.author, this.thumbnail, this.image, this.video, final  List<EmbedFieldDto> fields = const <EmbedFieldDto>[], this.footer, this.venta, this.flags = 0}): _fields = fields;
  factory _EmbedDto.fromJson(Map<String, dynamic> json) => _$EmbedDtoFromJson(json);

@override@JsonKey(unknownEnumValue: EmbedType.unknown) final  EmbedType type;
/// `type` again, unparsed.
///
/// Needed because a `venta.*` kind added after this build decodes to
/// [EmbedType.unknown], which is indistinguishable from any other unknown
/// type once the enum has swallowed the string - and the two want opposite
/// treatment: an unknown ordinary type falls back to the link card, an
/// unknown internal-link type draws nothing at all.
@override@JsonKey(name: 'type', includeToJson: false) final  String rawType;
@override final  String? title;
@override final  String? description;
@override final  String? url;
/// The *content's* own date (a publication date, say) - not when the
/// preview was generated.
@override final  DateTime? timestamp;
/// `#rrggbb`, and the card's left accent bar. Null for most generated
/// previews; bots set it deliberately.
@override final  String? color;
@override final  EmbedProviderDto? provider;
@override final  EmbedAuthorDto? author;
/// Small, beside the text. Doubles as the poster frame for [video].
@override final  EmbedMediaDto? thumbnail;
/// Large, full-width below the text.
@override final  EmbedMediaDto? image;
/// A player-capable provider (YouTube/Vimeo/Twitch/Spotify). [url] here is
/// an embeddable iframe document, which this client has no sandboxed frame
/// to put it in - see `MessageEmbedsView`, which degrades to a play badge
/// that opens the original externally.
@override final  EmbedMediaDto? video;
 final  List<EmbedFieldDto> _fields;
@override@JsonKey() List<EmbedFieldDto> get fields {
  if (_fields is EqualUnmodifiableListView) return _fields;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_fields);
}

@override final  EmbedFooterDto? footer;
/// The identifiers behind a `venta.*` card.
///
/// **Only trustworthy when [EmbedDtoX.isGenerated].** A bot authors its own
/// embeds and may put any `venta` block it likes in one; see
/// [EmbedDtoX.isServerVouchedVenta].
@override final  EmbedVentaDto? venta;
/// Bitfield. Bit 16 (65536) marks a card the server unfurled from a link
/// rather than one its author wrote.
@override@JsonKey() final  int flags;

/// Create a copy of EmbedDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EmbedDtoCopyWith<_EmbedDto> get copyWith => __$EmbedDtoCopyWithImpl<_EmbedDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$EmbedDtoToJson(this, );
}
@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'EmbedDto'))
    ..add(DiagnosticsProperty('type', type))..add(DiagnosticsProperty('rawType', rawType))..add(DiagnosticsProperty('title', title))..add(DiagnosticsProperty('description', description))..add(DiagnosticsProperty('url', url))..add(DiagnosticsProperty('timestamp', timestamp))..add(DiagnosticsProperty('color', color))..add(DiagnosticsProperty('provider', provider))..add(DiagnosticsProperty('author', author))..add(DiagnosticsProperty('thumbnail', thumbnail))..add(DiagnosticsProperty('image', image))..add(DiagnosticsProperty('video', video))..add(DiagnosticsProperty('fields', fields))..add(DiagnosticsProperty('footer', footer))..add(DiagnosticsProperty('venta', venta))..add(DiagnosticsProperty('flags', flags));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _EmbedDto&&(identical(other.type, type) || other.type == type)&&(identical(other.rawType, rawType) || other.rawType == rawType)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.url, url) || other.url == url)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp)&&(identical(other.color, color) || other.color == color)&&(identical(other.provider, provider) || other.provider == provider)&&(identical(other.author, author) || other.author == author)&&(identical(other.thumbnail, thumbnail) || other.thumbnail == thumbnail)&&(identical(other.image, image) || other.image == image)&&(identical(other.video, video) || other.video == video)&&const DeepCollectionEquality().equals(other._fields, _fields)&&(identical(other.footer, footer) || other.footer == footer)&&(identical(other.venta, venta) || other.venta == venta)&&(identical(other.flags, flags) || other.flags == flags));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,type,rawType,title,description,url,timestamp,color,provider,author,thumbnail,image,video,const DeepCollectionEquality().hash(_fields),footer,venta,flags);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'EmbedDto(type: $type, rawType: $rawType, title: $title, description: $description, url: $url, timestamp: $timestamp, color: $color, provider: $provider, author: $author, thumbnail: $thumbnail, image: $image, video: $video, fields: $fields, footer: $footer, venta: $venta, flags: $flags)';
}


}

/// @nodoc
abstract mixin class _$EmbedDtoCopyWith<$Res> implements $EmbedDtoCopyWith<$Res> {
  factory _$EmbedDtoCopyWith(_EmbedDto value, $Res Function(_EmbedDto) _then) = __$EmbedDtoCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(unknownEnumValue: EmbedType.unknown) EmbedType type,@JsonKey(name: 'type', includeToJson: false) String rawType, String? title, String? description, String? url, DateTime? timestamp, String? color, EmbedProviderDto? provider, EmbedAuthorDto? author, EmbedMediaDto? thumbnail, EmbedMediaDto? image, EmbedMediaDto? video, List<EmbedFieldDto> fields, EmbedFooterDto? footer, EmbedVentaDto? venta, int flags
});


@override $EmbedProviderDtoCopyWith<$Res>? get provider;@override $EmbedAuthorDtoCopyWith<$Res>? get author;@override $EmbedMediaDtoCopyWith<$Res>? get thumbnail;@override $EmbedMediaDtoCopyWith<$Res>? get image;@override $EmbedMediaDtoCopyWith<$Res>? get video;@override $EmbedFooterDtoCopyWith<$Res>? get footer;@override $EmbedVentaDtoCopyWith<$Res>? get venta;

}
/// @nodoc
class __$EmbedDtoCopyWithImpl<$Res>
    implements _$EmbedDtoCopyWith<$Res> {
  __$EmbedDtoCopyWithImpl(this._self, this._then);

  final _EmbedDto _self;
  final $Res Function(_EmbedDto) _then;

/// Create a copy of EmbedDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? type = null,Object? rawType = null,Object? title = freezed,Object? description = freezed,Object? url = freezed,Object? timestamp = freezed,Object? color = freezed,Object? provider = freezed,Object? author = freezed,Object? thumbnail = freezed,Object? image = freezed,Object? video = freezed,Object? fields = null,Object? footer = freezed,Object? venta = freezed,Object? flags = null,}) {
  return _then(_EmbedDto(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as EmbedType,rawType: null == rawType ? _self.rawType : rawType // ignore: cast_nullable_to_non_nullable
as String,title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,url: freezed == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String?,timestamp: freezed == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as DateTime?,color: freezed == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as String?,provider: freezed == provider ? _self.provider : provider // ignore: cast_nullable_to_non_nullable
as EmbedProviderDto?,author: freezed == author ? _self.author : author // ignore: cast_nullable_to_non_nullable
as EmbedAuthorDto?,thumbnail: freezed == thumbnail ? _self.thumbnail : thumbnail // ignore: cast_nullable_to_non_nullable
as EmbedMediaDto?,image: freezed == image ? _self.image : image // ignore: cast_nullable_to_non_nullable
as EmbedMediaDto?,video: freezed == video ? _self.video : video // ignore: cast_nullable_to_non_nullable
as EmbedMediaDto?,fields: null == fields ? _self._fields : fields // ignore: cast_nullable_to_non_nullable
as List<EmbedFieldDto>,footer: freezed == footer ? _self.footer : footer // ignore: cast_nullable_to_non_nullable
as EmbedFooterDto?,venta: freezed == venta ? _self.venta : venta // ignore: cast_nullable_to_non_nullable
as EmbedVentaDto?,flags: null == flags ? _self.flags : flags // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

/// Create a copy of EmbedDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$EmbedProviderDtoCopyWith<$Res>? get provider {
    if (_self.provider == null) {
    return null;
  }

  return $EmbedProviderDtoCopyWith<$Res>(_self.provider!, (value) {
    return _then(_self.copyWith(provider: value));
  });
}/// Create a copy of EmbedDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$EmbedAuthorDtoCopyWith<$Res>? get author {
    if (_self.author == null) {
    return null;
  }

  return $EmbedAuthorDtoCopyWith<$Res>(_self.author!, (value) {
    return _then(_self.copyWith(author: value));
  });
}/// Create a copy of EmbedDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$EmbedMediaDtoCopyWith<$Res>? get thumbnail {
    if (_self.thumbnail == null) {
    return null;
  }

  return $EmbedMediaDtoCopyWith<$Res>(_self.thumbnail!, (value) {
    return _then(_self.copyWith(thumbnail: value));
  });
}/// Create a copy of EmbedDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$EmbedMediaDtoCopyWith<$Res>? get image {
    if (_self.image == null) {
    return null;
  }

  return $EmbedMediaDtoCopyWith<$Res>(_self.image!, (value) {
    return _then(_self.copyWith(image: value));
  });
}/// Create a copy of EmbedDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$EmbedMediaDtoCopyWith<$Res>? get video {
    if (_self.video == null) {
    return null;
  }

  return $EmbedMediaDtoCopyWith<$Res>(_self.video!, (value) {
    return _then(_self.copyWith(video: value));
  });
}/// Create a copy of EmbedDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$EmbedFooterDtoCopyWith<$Res>? get footer {
    if (_self.footer == null) {
    return null;
  }

  return $EmbedFooterDtoCopyWith<$Res>(_self.footer!, (value) {
    return _then(_self.copyWith(footer: value));
  });
}/// Create a copy of EmbedDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$EmbedVentaDtoCopyWith<$Res>? get venta {
    if (_self.venta == null) {
    return null;
  }

  return $EmbedVentaDtoCopyWith<$Res>(_self.venta!, (value) {
    return _then(_self.copyWith(venta: value));
  });
}
}


/// @nodoc
mixin _$EmbedMediaDto implements DiagnosticableTreeMixin {

/// The origin's own URL. Never rendered directly - see [displayUrl].
 String? get url;/// Our re-hosted copy: absolute, unauthenticated, immutable. Render this.
@JsonKey(name: 'proxy_url') String? get proxyUrl;/// True measured pixels, used to reserve layout space before the bytes
/// land so an arriving card doesn't reflow the timeline.
 int? get width; int? get height;@JsonKey(name: 'content_type') String? get contentType;/// BlurHash, shown blurred underneath the image while it loads.
 String? get placeholder;/// Which encoding [placeholder] uses. `1` is BlurHash, and the only one
/// this build can decode - see [blurHash].
@JsonKey(name: 'placeholder_version') int? get placeholderVersion;
/// Create a copy of EmbedMediaDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EmbedMediaDtoCopyWith<EmbedMediaDto> get copyWith => _$EmbedMediaDtoCopyWithImpl<EmbedMediaDto>(this as EmbedMediaDto, _$identity);

  /// Serializes this EmbedMediaDto to a JSON map.
  Map<String, dynamic> toJson();

@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'EmbedMediaDto'))
    ..add(DiagnosticsProperty('url', url))..add(DiagnosticsProperty('proxyUrl', proxyUrl))..add(DiagnosticsProperty('width', width))..add(DiagnosticsProperty('height', height))..add(DiagnosticsProperty('contentType', contentType))..add(DiagnosticsProperty('placeholder', placeholder))..add(DiagnosticsProperty('placeholderVersion', placeholderVersion));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EmbedMediaDto&&(identical(other.url, url) || other.url == url)&&(identical(other.proxyUrl, proxyUrl) || other.proxyUrl == proxyUrl)&&(identical(other.width, width) || other.width == width)&&(identical(other.height, height) || other.height == height)&&(identical(other.contentType, contentType) || other.contentType == contentType)&&(identical(other.placeholder, placeholder) || other.placeholder == placeholder)&&(identical(other.placeholderVersion, placeholderVersion) || other.placeholderVersion == placeholderVersion));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,url,proxyUrl,width,height,contentType,placeholder,placeholderVersion);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'EmbedMediaDto(url: $url, proxyUrl: $proxyUrl, width: $width, height: $height, contentType: $contentType, placeholder: $placeholder, placeholderVersion: $placeholderVersion)';
}


}

/// @nodoc
abstract mixin class $EmbedMediaDtoCopyWith<$Res>  {
  factory $EmbedMediaDtoCopyWith(EmbedMediaDto value, $Res Function(EmbedMediaDto) _then) = _$EmbedMediaDtoCopyWithImpl;
@useResult
$Res call({
 String? url,@JsonKey(name: 'proxy_url') String? proxyUrl, int? width, int? height,@JsonKey(name: 'content_type') String? contentType, String? placeholder,@JsonKey(name: 'placeholder_version') int? placeholderVersion
});




}
/// @nodoc
class _$EmbedMediaDtoCopyWithImpl<$Res>
    implements $EmbedMediaDtoCopyWith<$Res> {
  _$EmbedMediaDtoCopyWithImpl(this._self, this._then);

  final EmbedMediaDto _self;
  final $Res Function(EmbedMediaDto) _then;

/// Create a copy of EmbedMediaDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? url = freezed,Object? proxyUrl = freezed,Object? width = freezed,Object? height = freezed,Object? contentType = freezed,Object? placeholder = freezed,Object? placeholderVersion = freezed,}) {
  return _then(_self.copyWith(
url: freezed == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String?,proxyUrl: freezed == proxyUrl ? _self.proxyUrl : proxyUrl // ignore: cast_nullable_to_non_nullable
as String?,width: freezed == width ? _self.width : width // ignore: cast_nullable_to_non_nullable
as int?,height: freezed == height ? _self.height : height // ignore: cast_nullable_to_non_nullable
as int?,contentType: freezed == contentType ? _self.contentType : contentType // ignore: cast_nullable_to_non_nullable
as String?,placeholder: freezed == placeholder ? _self.placeholder : placeholder // ignore: cast_nullable_to_non_nullable
as String?,placeholderVersion: freezed == placeholderVersion ? _self.placeholderVersion : placeholderVersion // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [EmbedMediaDto].
extension EmbedMediaDtoPatterns on EmbedMediaDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _EmbedMediaDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _EmbedMediaDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _EmbedMediaDto value)  $default,){
final _that = this;
switch (_that) {
case _EmbedMediaDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _EmbedMediaDto value)?  $default,){
final _that = this;
switch (_that) {
case _EmbedMediaDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? url, @JsonKey(name: 'proxy_url')  String? proxyUrl,  int? width,  int? height, @JsonKey(name: 'content_type')  String? contentType,  String? placeholder, @JsonKey(name: 'placeholder_version')  int? placeholderVersion)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EmbedMediaDto() when $default != null:
return $default(_that.url,_that.proxyUrl,_that.width,_that.height,_that.contentType,_that.placeholder,_that.placeholderVersion);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? url, @JsonKey(name: 'proxy_url')  String? proxyUrl,  int? width,  int? height, @JsonKey(name: 'content_type')  String? contentType,  String? placeholder, @JsonKey(name: 'placeholder_version')  int? placeholderVersion)  $default,) {final _that = this;
switch (_that) {
case _EmbedMediaDto():
return $default(_that.url,_that.proxyUrl,_that.width,_that.height,_that.contentType,_that.placeholder,_that.placeholderVersion);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? url, @JsonKey(name: 'proxy_url')  String? proxyUrl,  int? width,  int? height, @JsonKey(name: 'content_type')  String? contentType,  String? placeholder, @JsonKey(name: 'placeholder_version')  int? placeholderVersion)?  $default,) {final _that = this;
switch (_that) {
case _EmbedMediaDto() when $default != null:
return $default(_that.url,_that.proxyUrl,_that.width,_that.height,_that.contentType,_that.placeholder,_that.placeholderVersion);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _EmbedMediaDto with DiagnosticableTreeMixin implements EmbedMediaDto {
  const _EmbedMediaDto({this.url, @JsonKey(name: 'proxy_url') this.proxyUrl, this.width, this.height, @JsonKey(name: 'content_type') this.contentType, this.placeholder, @JsonKey(name: 'placeholder_version') this.placeholderVersion});
  factory _EmbedMediaDto.fromJson(Map<String, dynamic> json) => _$EmbedMediaDtoFromJson(json);

/// The origin's own URL. Never rendered directly - see [displayUrl].
@override final  String? url;
/// Our re-hosted copy: absolute, unauthenticated, immutable. Render this.
@override@JsonKey(name: 'proxy_url') final  String? proxyUrl;
/// True measured pixels, used to reserve layout space before the bytes
/// land so an arriving card doesn't reflow the timeline.
@override final  int? width;
@override final  int? height;
@override@JsonKey(name: 'content_type') final  String? contentType;
/// BlurHash, shown blurred underneath the image while it loads.
@override final  String? placeholder;
/// Which encoding [placeholder] uses. `1` is BlurHash, and the only one
/// this build can decode - see [blurHash].
@override@JsonKey(name: 'placeholder_version') final  int? placeholderVersion;

/// Create a copy of EmbedMediaDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EmbedMediaDtoCopyWith<_EmbedMediaDto> get copyWith => __$EmbedMediaDtoCopyWithImpl<_EmbedMediaDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$EmbedMediaDtoToJson(this, );
}
@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'EmbedMediaDto'))
    ..add(DiagnosticsProperty('url', url))..add(DiagnosticsProperty('proxyUrl', proxyUrl))..add(DiagnosticsProperty('width', width))..add(DiagnosticsProperty('height', height))..add(DiagnosticsProperty('contentType', contentType))..add(DiagnosticsProperty('placeholder', placeholder))..add(DiagnosticsProperty('placeholderVersion', placeholderVersion));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _EmbedMediaDto&&(identical(other.url, url) || other.url == url)&&(identical(other.proxyUrl, proxyUrl) || other.proxyUrl == proxyUrl)&&(identical(other.width, width) || other.width == width)&&(identical(other.height, height) || other.height == height)&&(identical(other.contentType, contentType) || other.contentType == contentType)&&(identical(other.placeholder, placeholder) || other.placeholder == placeholder)&&(identical(other.placeholderVersion, placeholderVersion) || other.placeholderVersion == placeholderVersion));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,url,proxyUrl,width,height,contentType,placeholder,placeholderVersion);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'EmbedMediaDto(url: $url, proxyUrl: $proxyUrl, width: $width, height: $height, contentType: $contentType, placeholder: $placeholder, placeholderVersion: $placeholderVersion)';
}


}

/// @nodoc
abstract mixin class _$EmbedMediaDtoCopyWith<$Res> implements $EmbedMediaDtoCopyWith<$Res> {
  factory _$EmbedMediaDtoCopyWith(_EmbedMediaDto value, $Res Function(_EmbedMediaDto) _then) = __$EmbedMediaDtoCopyWithImpl;
@override @useResult
$Res call({
 String? url,@JsonKey(name: 'proxy_url') String? proxyUrl, int? width, int? height,@JsonKey(name: 'content_type') String? contentType, String? placeholder,@JsonKey(name: 'placeholder_version') int? placeholderVersion
});




}
/// @nodoc
class __$EmbedMediaDtoCopyWithImpl<$Res>
    implements _$EmbedMediaDtoCopyWith<$Res> {
  __$EmbedMediaDtoCopyWithImpl(this._self, this._then);

  final _EmbedMediaDto _self;
  final $Res Function(_EmbedMediaDto) _then;

/// Create a copy of EmbedMediaDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? url = freezed,Object? proxyUrl = freezed,Object? width = freezed,Object? height = freezed,Object? contentType = freezed,Object? placeholder = freezed,Object? placeholderVersion = freezed,}) {
  return _then(_EmbedMediaDto(
url: freezed == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String?,proxyUrl: freezed == proxyUrl ? _self.proxyUrl : proxyUrl // ignore: cast_nullable_to_non_nullable
as String?,width: freezed == width ? _self.width : width // ignore: cast_nullable_to_non_nullable
as int?,height: freezed == height ? _self.height : height // ignore: cast_nullable_to_non_nullable
as int?,contentType: freezed == contentType ? _self.contentType : contentType // ignore: cast_nullable_to_non_nullable
as String?,placeholder: freezed == placeholder ? _self.placeholder : placeholder // ignore: cast_nullable_to_non_nullable
as String?,placeholderVersion: freezed == placeholderVersion ? _self.placeholderVersion : placeholderVersion // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}


/// @nodoc
mixin _$EmbedVentaDto implements DiagnosticableTreeMixin {

@JsonKey(unknownEnumValue: EmbedVentaKind.unknown) EmbedVentaKind get kind;/// Whether the server filled the human-readable fields in from the real
/// record, or deliberately left them out. False means the card is a stub -
/// see the wiki card, where a title is refused by design.
 bool get resolved;@JsonKey(name: 'guild_id') String? get guildId;/// The invite's short shareable code, not its id. Always the canonical
/// generated code even when the pasted link was a vanity URL, so it
/// survives a vanity rename.
@JsonKey(name: 'invite_code') String? get inviteCode;/// Invite: the channel a joiner lands on, when the invite names one. Voice
/// invite: the channel being asked into. An id, never a name - except on a
/// voice invite, which also carries [channelName].
@JsonKey(name: 'channel_id') String? get channelId;@JsonKey(name: 'page_id') String? get pageId;/// Absent for an invite that never expires, and for a voice invitation that
/// was sent as a plain message rather than as a ring - see the standing
/// case in `_VentaVoiceInviteCard`, which is why "no expiry" must never be
/// read as "expired". On a ring it is always present and is about a minute
/// after the message was sent, which is what decides whether [ringId] still
/// means anything.
///
/// Safe to freeze into the card: an absolute instant does not go stale the
/// way a stored "expired" boolean does.
@JsonKey(name: 'expires_at') DateTime? get expiresAt;/// Absent for unlimited. The running *use* count is deliberately not
/// carried - re-resolve if you want to show it.
@JsonKey(name: 'max_uses') int? get maxUses;/// Voice invite only: the ring this card was written for.
///
/// Live only until [expiresAt]. Past that, treat it as absent rather than
/// as something to call - the ring no longer exists and accepting it
/// answers `409`. The honest affordance there is the ordinary join, which
/// accepts nothing.
@JsonKey(name: 'ring_id') String? get ringId;/// Voice invite only: who did the asking.
///
/// The same person as the message's author today; carried so the card keeps
/// meaning what it says if it is ever quoted. It is also what tells the
/// *inviter* they are reading their own invitation, so the card can drop
/// the Join button for the channel they are already sitting in.
@JsonKey(name: 'inviter_id') String? get inviterId;/// Voice invite only: the channel's name when the invitation was sent.
///
/// The one place a `venta.*` card carries a name rather than only an id.
/// The invite kind can leave it out because a client re-resolves it from
/// the code, and the wiki kind *must* leave it out because the audience for
/// a title is narrower than the audience for the message. Neither applies
/// here: the recipient was checked for `ViewChannel` before the ring was
/// allowed at all, and there is no later lookup that would let them fill it
/// in. Render it; do not go and fetch a fresher one.
@JsonKey(name: 'channel_name') String? get channelName;
/// Create a copy of EmbedVentaDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EmbedVentaDtoCopyWith<EmbedVentaDto> get copyWith => _$EmbedVentaDtoCopyWithImpl<EmbedVentaDto>(this as EmbedVentaDto, _$identity);

  /// Serializes this EmbedVentaDto to a JSON map.
  Map<String, dynamic> toJson();

@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'EmbedVentaDto'))
    ..add(DiagnosticsProperty('kind', kind))..add(DiagnosticsProperty('resolved', resolved))..add(DiagnosticsProperty('guildId', guildId))..add(DiagnosticsProperty('inviteCode', inviteCode))..add(DiagnosticsProperty('channelId', channelId))..add(DiagnosticsProperty('pageId', pageId))..add(DiagnosticsProperty('expiresAt', expiresAt))..add(DiagnosticsProperty('maxUses', maxUses))..add(DiagnosticsProperty('ringId', ringId))..add(DiagnosticsProperty('inviterId', inviterId))..add(DiagnosticsProperty('channelName', channelName));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EmbedVentaDto&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.resolved, resolved) || other.resolved == resolved)&&(identical(other.guildId, guildId) || other.guildId == guildId)&&(identical(other.inviteCode, inviteCode) || other.inviteCode == inviteCode)&&(identical(other.channelId, channelId) || other.channelId == channelId)&&(identical(other.pageId, pageId) || other.pageId == pageId)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt)&&(identical(other.maxUses, maxUses) || other.maxUses == maxUses)&&(identical(other.ringId, ringId) || other.ringId == ringId)&&(identical(other.inviterId, inviterId) || other.inviterId == inviterId)&&(identical(other.channelName, channelName) || other.channelName == channelName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,kind,resolved,guildId,inviteCode,channelId,pageId,expiresAt,maxUses,ringId,inviterId,channelName);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'EmbedVentaDto(kind: $kind, resolved: $resolved, guildId: $guildId, inviteCode: $inviteCode, channelId: $channelId, pageId: $pageId, expiresAt: $expiresAt, maxUses: $maxUses, ringId: $ringId, inviterId: $inviterId, channelName: $channelName)';
}


}

/// @nodoc
abstract mixin class $EmbedVentaDtoCopyWith<$Res>  {
  factory $EmbedVentaDtoCopyWith(EmbedVentaDto value, $Res Function(EmbedVentaDto) _then) = _$EmbedVentaDtoCopyWithImpl;
@useResult
$Res call({
@JsonKey(unknownEnumValue: EmbedVentaKind.unknown) EmbedVentaKind kind, bool resolved,@JsonKey(name: 'guild_id') String? guildId,@JsonKey(name: 'invite_code') String? inviteCode,@JsonKey(name: 'channel_id') String? channelId,@JsonKey(name: 'page_id') String? pageId,@JsonKey(name: 'expires_at') DateTime? expiresAt,@JsonKey(name: 'max_uses') int? maxUses,@JsonKey(name: 'ring_id') String? ringId,@JsonKey(name: 'inviter_id') String? inviterId,@JsonKey(name: 'channel_name') String? channelName
});




}
/// @nodoc
class _$EmbedVentaDtoCopyWithImpl<$Res>
    implements $EmbedVentaDtoCopyWith<$Res> {
  _$EmbedVentaDtoCopyWithImpl(this._self, this._then);

  final EmbedVentaDto _self;
  final $Res Function(EmbedVentaDto) _then;

/// Create a copy of EmbedVentaDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? kind = null,Object? resolved = null,Object? guildId = freezed,Object? inviteCode = freezed,Object? channelId = freezed,Object? pageId = freezed,Object? expiresAt = freezed,Object? maxUses = freezed,Object? ringId = freezed,Object? inviterId = freezed,Object? channelName = freezed,}) {
  return _then(_self.copyWith(
kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as EmbedVentaKind,resolved: null == resolved ? _self.resolved : resolved // ignore: cast_nullable_to_non_nullable
as bool,guildId: freezed == guildId ? _self.guildId : guildId // ignore: cast_nullable_to_non_nullable
as String?,inviteCode: freezed == inviteCode ? _self.inviteCode : inviteCode // ignore: cast_nullable_to_non_nullable
as String?,channelId: freezed == channelId ? _self.channelId : channelId // ignore: cast_nullable_to_non_nullable
as String?,pageId: freezed == pageId ? _self.pageId : pageId // ignore: cast_nullable_to_non_nullable
as String?,expiresAt: freezed == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime?,maxUses: freezed == maxUses ? _self.maxUses : maxUses // ignore: cast_nullable_to_non_nullable
as int?,ringId: freezed == ringId ? _self.ringId : ringId // ignore: cast_nullable_to_non_nullable
as String?,inviterId: freezed == inviterId ? _self.inviterId : inviterId // ignore: cast_nullable_to_non_nullable
as String?,channelName: freezed == channelName ? _self.channelName : channelName // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [EmbedVentaDto].
extension EmbedVentaDtoPatterns on EmbedVentaDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _EmbedVentaDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _EmbedVentaDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _EmbedVentaDto value)  $default,){
final _that = this;
switch (_that) {
case _EmbedVentaDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _EmbedVentaDto value)?  $default,){
final _that = this;
switch (_that) {
case _EmbedVentaDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(unknownEnumValue: EmbedVentaKind.unknown)  EmbedVentaKind kind,  bool resolved, @JsonKey(name: 'guild_id')  String? guildId, @JsonKey(name: 'invite_code')  String? inviteCode, @JsonKey(name: 'channel_id')  String? channelId, @JsonKey(name: 'page_id')  String? pageId, @JsonKey(name: 'expires_at')  DateTime? expiresAt, @JsonKey(name: 'max_uses')  int? maxUses, @JsonKey(name: 'ring_id')  String? ringId, @JsonKey(name: 'inviter_id')  String? inviterId, @JsonKey(name: 'channel_name')  String? channelName)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EmbedVentaDto() when $default != null:
return $default(_that.kind,_that.resolved,_that.guildId,_that.inviteCode,_that.channelId,_that.pageId,_that.expiresAt,_that.maxUses,_that.ringId,_that.inviterId,_that.channelName);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(unknownEnumValue: EmbedVentaKind.unknown)  EmbedVentaKind kind,  bool resolved, @JsonKey(name: 'guild_id')  String? guildId, @JsonKey(name: 'invite_code')  String? inviteCode, @JsonKey(name: 'channel_id')  String? channelId, @JsonKey(name: 'page_id')  String? pageId, @JsonKey(name: 'expires_at')  DateTime? expiresAt, @JsonKey(name: 'max_uses')  int? maxUses, @JsonKey(name: 'ring_id')  String? ringId, @JsonKey(name: 'inviter_id')  String? inviterId, @JsonKey(name: 'channel_name')  String? channelName)  $default,) {final _that = this;
switch (_that) {
case _EmbedVentaDto():
return $default(_that.kind,_that.resolved,_that.guildId,_that.inviteCode,_that.channelId,_that.pageId,_that.expiresAt,_that.maxUses,_that.ringId,_that.inviterId,_that.channelName);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(unknownEnumValue: EmbedVentaKind.unknown)  EmbedVentaKind kind,  bool resolved, @JsonKey(name: 'guild_id')  String? guildId, @JsonKey(name: 'invite_code')  String? inviteCode, @JsonKey(name: 'channel_id')  String? channelId, @JsonKey(name: 'page_id')  String? pageId, @JsonKey(name: 'expires_at')  DateTime? expiresAt, @JsonKey(name: 'max_uses')  int? maxUses, @JsonKey(name: 'ring_id')  String? ringId, @JsonKey(name: 'inviter_id')  String? inviterId, @JsonKey(name: 'channel_name')  String? channelName)?  $default,) {final _that = this;
switch (_that) {
case _EmbedVentaDto() when $default != null:
return $default(_that.kind,_that.resolved,_that.guildId,_that.inviteCode,_that.channelId,_that.pageId,_that.expiresAt,_that.maxUses,_that.ringId,_that.inviterId,_that.channelName);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()
@ApiDateTimeConverter()
class _EmbedVentaDto with DiagnosticableTreeMixin implements EmbedVentaDto {
  const _EmbedVentaDto({@JsonKey(unknownEnumValue: EmbedVentaKind.unknown) this.kind = EmbedVentaKind.unknown, this.resolved = false, @JsonKey(name: 'guild_id') this.guildId, @JsonKey(name: 'invite_code') this.inviteCode, @JsonKey(name: 'channel_id') this.channelId, @JsonKey(name: 'page_id') this.pageId, @JsonKey(name: 'expires_at') this.expiresAt, @JsonKey(name: 'max_uses') this.maxUses, @JsonKey(name: 'ring_id') this.ringId, @JsonKey(name: 'inviter_id') this.inviterId, @JsonKey(name: 'channel_name') this.channelName});
  factory _EmbedVentaDto.fromJson(Map<String, dynamic> json) => _$EmbedVentaDtoFromJson(json);

@override@JsonKey(unknownEnumValue: EmbedVentaKind.unknown) final  EmbedVentaKind kind;
/// Whether the server filled the human-readable fields in from the real
/// record, or deliberately left them out. False means the card is a stub -
/// see the wiki card, where a title is refused by design.
@override@JsonKey() final  bool resolved;
@override@JsonKey(name: 'guild_id') final  String? guildId;
/// The invite's short shareable code, not its id. Always the canonical
/// generated code even when the pasted link was a vanity URL, so it
/// survives a vanity rename.
@override@JsonKey(name: 'invite_code') final  String? inviteCode;
/// Invite: the channel a joiner lands on, when the invite names one. Voice
/// invite: the channel being asked into. An id, never a name - except on a
/// voice invite, which also carries [channelName].
@override@JsonKey(name: 'channel_id') final  String? channelId;
@override@JsonKey(name: 'page_id') final  String? pageId;
/// Absent for an invite that never expires, and for a voice invitation that
/// was sent as a plain message rather than as a ring - see the standing
/// case in `_VentaVoiceInviteCard`, which is why "no expiry" must never be
/// read as "expired". On a ring it is always present and is about a minute
/// after the message was sent, which is what decides whether [ringId] still
/// means anything.
///
/// Safe to freeze into the card: an absolute instant does not go stale the
/// way a stored "expired" boolean does.
@override@JsonKey(name: 'expires_at') final  DateTime? expiresAt;
/// Absent for unlimited. The running *use* count is deliberately not
/// carried - re-resolve if you want to show it.
@override@JsonKey(name: 'max_uses') final  int? maxUses;
/// Voice invite only: the ring this card was written for.
///
/// Live only until [expiresAt]. Past that, treat it as absent rather than
/// as something to call - the ring no longer exists and accepting it
/// answers `409`. The honest affordance there is the ordinary join, which
/// accepts nothing.
@override@JsonKey(name: 'ring_id') final  String? ringId;
/// Voice invite only: who did the asking.
///
/// The same person as the message's author today; carried so the card keeps
/// meaning what it says if it is ever quoted. It is also what tells the
/// *inviter* they are reading their own invitation, so the card can drop
/// the Join button for the channel they are already sitting in.
@override@JsonKey(name: 'inviter_id') final  String? inviterId;
/// Voice invite only: the channel's name when the invitation was sent.
///
/// The one place a `venta.*` card carries a name rather than only an id.
/// The invite kind can leave it out because a client re-resolves it from
/// the code, and the wiki kind *must* leave it out because the audience for
/// a title is narrower than the audience for the message. Neither applies
/// here: the recipient was checked for `ViewChannel` before the ring was
/// allowed at all, and there is no later lookup that would let them fill it
/// in. Render it; do not go and fetch a fresher one.
@override@JsonKey(name: 'channel_name') final  String? channelName;

/// Create a copy of EmbedVentaDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EmbedVentaDtoCopyWith<_EmbedVentaDto> get copyWith => __$EmbedVentaDtoCopyWithImpl<_EmbedVentaDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$EmbedVentaDtoToJson(this, );
}
@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'EmbedVentaDto'))
    ..add(DiagnosticsProperty('kind', kind))..add(DiagnosticsProperty('resolved', resolved))..add(DiagnosticsProperty('guildId', guildId))..add(DiagnosticsProperty('inviteCode', inviteCode))..add(DiagnosticsProperty('channelId', channelId))..add(DiagnosticsProperty('pageId', pageId))..add(DiagnosticsProperty('expiresAt', expiresAt))..add(DiagnosticsProperty('maxUses', maxUses))..add(DiagnosticsProperty('ringId', ringId))..add(DiagnosticsProperty('inviterId', inviterId))..add(DiagnosticsProperty('channelName', channelName));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _EmbedVentaDto&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.resolved, resolved) || other.resolved == resolved)&&(identical(other.guildId, guildId) || other.guildId == guildId)&&(identical(other.inviteCode, inviteCode) || other.inviteCode == inviteCode)&&(identical(other.channelId, channelId) || other.channelId == channelId)&&(identical(other.pageId, pageId) || other.pageId == pageId)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt)&&(identical(other.maxUses, maxUses) || other.maxUses == maxUses)&&(identical(other.ringId, ringId) || other.ringId == ringId)&&(identical(other.inviterId, inviterId) || other.inviterId == inviterId)&&(identical(other.channelName, channelName) || other.channelName == channelName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,kind,resolved,guildId,inviteCode,channelId,pageId,expiresAt,maxUses,ringId,inviterId,channelName);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'EmbedVentaDto(kind: $kind, resolved: $resolved, guildId: $guildId, inviteCode: $inviteCode, channelId: $channelId, pageId: $pageId, expiresAt: $expiresAt, maxUses: $maxUses, ringId: $ringId, inviterId: $inviterId, channelName: $channelName)';
}


}

/// @nodoc
abstract mixin class _$EmbedVentaDtoCopyWith<$Res> implements $EmbedVentaDtoCopyWith<$Res> {
  factory _$EmbedVentaDtoCopyWith(_EmbedVentaDto value, $Res Function(_EmbedVentaDto) _then) = __$EmbedVentaDtoCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(unknownEnumValue: EmbedVentaKind.unknown) EmbedVentaKind kind, bool resolved,@JsonKey(name: 'guild_id') String? guildId,@JsonKey(name: 'invite_code') String? inviteCode,@JsonKey(name: 'channel_id') String? channelId,@JsonKey(name: 'page_id') String? pageId,@JsonKey(name: 'expires_at') DateTime? expiresAt,@JsonKey(name: 'max_uses') int? maxUses,@JsonKey(name: 'ring_id') String? ringId,@JsonKey(name: 'inviter_id') String? inviterId,@JsonKey(name: 'channel_name') String? channelName
});




}
/// @nodoc
class __$EmbedVentaDtoCopyWithImpl<$Res>
    implements _$EmbedVentaDtoCopyWith<$Res> {
  __$EmbedVentaDtoCopyWithImpl(this._self, this._then);

  final _EmbedVentaDto _self;
  final $Res Function(_EmbedVentaDto) _then;

/// Create a copy of EmbedVentaDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? kind = null,Object? resolved = null,Object? guildId = freezed,Object? inviteCode = freezed,Object? channelId = freezed,Object? pageId = freezed,Object? expiresAt = freezed,Object? maxUses = freezed,Object? ringId = freezed,Object? inviterId = freezed,Object? channelName = freezed,}) {
  return _then(_EmbedVentaDto(
kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as EmbedVentaKind,resolved: null == resolved ? _self.resolved : resolved // ignore: cast_nullable_to_non_nullable
as bool,guildId: freezed == guildId ? _self.guildId : guildId // ignore: cast_nullable_to_non_nullable
as String?,inviteCode: freezed == inviteCode ? _self.inviteCode : inviteCode // ignore: cast_nullable_to_non_nullable
as String?,channelId: freezed == channelId ? _self.channelId : channelId // ignore: cast_nullable_to_non_nullable
as String?,pageId: freezed == pageId ? _self.pageId : pageId // ignore: cast_nullable_to_non_nullable
as String?,expiresAt: freezed == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime?,maxUses: freezed == maxUses ? _self.maxUses : maxUses // ignore: cast_nullable_to_non_nullable
as int?,ringId: freezed == ringId ? _self.ringId : ringId // ignore: cast_nullable_to_non_nullable
as String?,inviterId: freezed == inviterId ? _self.inviterId : inviterId // ignore: cast_nullable_to_non_nullable
as String?,channelName: freezed == channelName ? _self.channelName : channelName // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$EmbedFieldDto implements DiagnosticableTreeMixin {

 String get name; String get value; bool get inline;
/// Create a copy of EmbedFieldDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EmbedFieldDtoCopyWith<EmbedFieldDto> get copyWith => _$EmbedFieldDtoCopyWithImpl<EmbedFieldDto>(this as EmbedFieldDto, _$identity);

  /// Serializes this EmbedFieldDto to a JSON map.
  Map<String, dynamic> toJson();

@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'EmbedFieldDto'))
    ..add(DiagnosticsProperty('name', name))..add(DiagnosticsProperty('value', value))..add(DiagnosticsProperty('inline', inline));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EmbedFieldDto&&(identical(other.name, name) || other.name == name)&&(identical(other.value, value) || other.value == value)&&(identical(other.inline, inline) || other.inline == inline));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,value,inline);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'EmbedFieldDto(name: $name, value: $value, inline: $inline)';
}


}

/// @nodoc
abstract mixin class $EmbedFieldDtoCopyWith<$Res>  {
  factory $EmbedFieldDtoCopyWith(EmbedFieldDto value, $Res Function(EmbedFieldDto) _then) = _$EmbedFieldDtoCopyWithImpl;
@useResult
$Res call({
 String name, String value, bool inline
});




}
/// @nodoc
class _$EmbedFieldDtoCopyWithImpl<$Res>
    implements $EmbedFieldDtoCopyWith<$Res> {
  _$EmbedFieldDtoCopyWithImpl(this._self, this._then);

  final EmbedFieldDto _self;
  final $Res Function(EmbedFieldDto) _then;

/// Create a copy of EmbedFieldDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? value = null,Object? inline = null,}) {
  return _then(_self.copyWith(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as String,inline: null == inline ? _self.inline : inline // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [EmbedFieldDto].
extension EmbedFieldDtoPatterns on EmbedFieldDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _EmbedFieldDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _EmbedFieldDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _EmbedFieldDto value)  $default,){
final _that = this;
switch (_that) {
case _EmbedFieldDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _EmbedFieldDto value)?  $default,){
final _that = this;
switch (_that) {
case _EmbedFieldDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  String value,  bool inline)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EmbedFieldDto() when $default != null:
return $default(_that.name,_that.value,_that.inline);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  String value,  bool inline)  $default,) {final _that = this;
switch (_that) {
case _EmbedFieldDto():
return $default(_that.name,_that.value,_that.inline);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  String value,  bool inline)?  $default,) {final _that = this;
switch (_that) {
case _EmbedFieldDto() when $default != null:
return $default(_that.name,_that.value,_that.inline);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _EmbedFieldDto with DiagnosticableTreeMixin implements EmbedFieldDto {
  const _EmbedFieldDto({this.name = '', this.value = '', this.inline = false});
  factory _EmbedFieldDto.fromJson(Map<String, dynamic> json) => _$EmbedFieldDtoFromJson(json);

@override@JsonKey() final  String name;
@override@JsonKey() final  String value;
@override@JsonKey() final  bool inline;

/// Create a copy of EmbedFieldDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EmbedFieldDtoCopyWith<_EmbedFieldDto> get copyWith => __$EmbedFieldDtoCopyWithImpl<_EmbedFieldDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$EmbedFieldDtoToJson(this, );
}
@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'EmbedFieldDto'))
    ..add(DiagnosticsProperty('name', name))..add(DiagnosticsProperty('value', value))..add(DiagnosticsProperty('inline', inline));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _EmbedFieldDto&&(identical(other.name, name) || other.name == name)&&(identical(other.value, value) || other.value == value)&&(identical(other.inline, inline) || other.inline == inline));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,value,inline);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'EmbedFieldDto(name: $name, value: $value, inline: $inline)';
}


}

/// @nodoc
abstract mixin class _$EmbedFieldDtoCopyWith<$Res> implements $EmbedFieldDtoCopyWith<$Res> {
  factory _$EmbedFieldDtoCopyWith(_EmbedFieldDto value, $Res Function(_EmbedFieldDto) _then) = __$EmbedFieldDtoCopyWithImpl;
@override @useResult
$Res call({
 String name, String value, bool inline
});




}
/// @nodoc
class __$EmbedFieldDtoCopyWithImpl<$Res>
    implements _$EmbedFieldDtoCopyWith<$Res> {
  __$EmbedFieldDtoCopyWithImpl(this._self, this._then);

  final _EmbedFieldDto _self;
  final $Res Function(_EmbedFieldDto) _then;

/// Create a copy of EmbedFieldDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? value = null,Object? inline = null,}) {
  return _then(_EmbedFieldDto(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as String,inline: null == inline ? _self.inline : inline // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$EmbedAuthorDto implements DiagnosticableTreeMixin {

 String get name; String? get url;@JsonKey(name: 'icon_url') String? get iconUrl;@JsonKey(name: 'proxy_icon_url') String? get proxyIconUrl;
/// Create a copy of EmbedAuthorDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EmbedAuthorDtoCopyWith<EmbedAuthorDto> get copyWith => _$EmbedAuthorDtoCopyWithImpl<EmbedAuthorDto>(this as EmbedAuthorDto, _$identity);

  /// Serializes this EmbedAuthorDto to a JSON map.
  Map<String, dynamic> toJson();

@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'EmbedAuthorDto'))
    ..add(DiagnosticsProperty('name', name))..add(DiagnosticsProperty('url', url))..add(DiagnosticsProperty('iconUrl', iconUrl))..add(DiagnosticsProperty('proxyIconUrl', proxyIconUrl));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EmbedAuthorDto&&(identical(other.name, name) || other.name == name)&&(identical(other.url, url) || other.url == url)&&(identical(other.iconUrl, iconUrl) || other.iconUrl == iconUrl)&&(identical(other.proxyIconUrl, proxyIconUrl) || other.proxyIconUrl == proxyIconUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,url,iconUrl,proxyIconUrl);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'EmbedAuthorDto(name: $name, url: $url, iconUrl: $iconUrl, proxyIconUrl: $proxyIconUrl)';
}


}

/// @nodoc
abstract mixin class $EmbedAuthorDtoCopyWith<$Res>  {
  factory $EmbedAuthorDtoCopyWith(EmbedAuthorDto value, $Res Function(EmbedAuthorDto) _then) = _$EmbedAuthorDtoCopyWithImpl;
@useResult
$Res call({
 String name, String? url,@JsonKey(name: 'icon_url') String? iconUrl,@JsonKey(name: 'proxy_icon_url') String? proxyIconUrl
});




}
/// @nodoc
class _$EmbedAuthorDtoCopyWithImpl<$Res>
    implements $EmbedAuthorDtoCopyWith<$Res> {
  _$EmbedAuthorDtoCopyWithImpl(this._self, this._then);

  final EmbedAuthorDto _self;
  final $Res Function(EmbedAuthorDto) _then;

/// Create a copy of EmbedAuthorDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? url = freezed,Object? iconUrl = freezed,Object? proxyIconUrl = freezed,}) {
  return _then(_self.copyWith(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,url: freezed == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String?,iconUrl: freezed == iconUrl ? _self.iconUrl : iconUrl // ignore: cast_nullable_to_non_nullable
as String?,proxyIconUrl: freezed == proxyIconUrl ? _self.proxyIconUrl : proxyIconUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [EmbedAuthorDto].
extension EmbedAuthorDtoPatterns on EmbedAuthorDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _EmbedAuthorDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _EmbedAuthorDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _EmbedAuthorDto value)  $default,){
final _that = this;
switch (_that) {
case _EmbedAuthorDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _EmbedAuthorDto value)?  $default,){
final _that = this;
switch (_that) {
case _EmbedAuthorDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  String? url, @JsonKey(name: 'icon_url')  String? iconUrl, @JsonKey(name: 'proxy_icon_url')  String? proxyIconUrl)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EmbedAuthorDto() when $default != null:
return $default(_that.name,_that.url,_that.iconUrl,_that.proxyIconUrl);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  String? url, @JsonKey(name: 'icon_url')  String? iconUrl, @JsonKey(name: 'proxy_icon_url')  String? proxyIconUrl)  $default,) {final _that = this;
switch (_that) {
case _EmbedAuthorDto():
return $default(_that.name,_that.url,_that.iconUrl,_that.proxyIconUrl);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  String? url, @JsonKey(name: 'icon_url')  String? iconUrl, @JsonKey(name: 'proxy_icon_url')  String? proxyIconUrl)?  $default,) {final _that = this;
switch (_that) {
case _EmbedAuthorDto() when $default != null:
return $default(_that.name,_that.url,_that.iconUrl,_that.proxyIconUrl);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _EmbedAuthorDto with DiagnosticableTreeMixin implements EmbedAuthorDto {
  const _EmbedAuthorDto({this.name = '', this.url, @JsonKey(name: 'icon_url') this.iconUrl, @JsonKey(name: 'proxy_icon_url') this.proxyIconUrl});
  factory _EmbedAuthorDto.fromJson(Map<String, dynamic> json) => _$EmbedAuthorDtoFromJson(json);

@override@JsonKey() final  String name;
@override final  String? url;
@override@JsonKey(name: 'icon_url') final  String? iconUrl;
@override@JsonKey(name: 'proxy_icon_url') final  String? proxyIconUrl;

/// Create a copy of EmbedAuthorDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EmbedAuthorDtoCopyWith<_EmbedAuthorDto> get copyWith => __$EmbedAuthorDtoCopyWithImpl<_EmbedAuthorDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$EmbedAuthorDtoToJson(this, );
}
@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'EmbedAuthorDto'))
    ..add(DiagnosticsProperty('name', name))..add(DiagnosticsProperty('url', url))..add(DiagnosticsProperty('iconUrl', iconUrl))..add(DiagnosticsProperty('proxyIconUrl', proxyIconUrl));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _EmbedAuthorDto&&(identical(other.name, name) || other.name == name)&&(identical(other.url, url) || other.url == url)&&(identical(other.iconUrl, iconUrl) || other.iconUrl == iconUrl)&&(identical(other.proxyIconUrl, proxyIconUrl) || other.proxyIconUrl == proxyIconUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,url,iconUrl,proxyIconUrl);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'EmbedAuthorDto(name: $name, url: $url, iconUrl: $iconUrl, proxyIconUrl: $proxyIconUrl)';
}


}

/// @nodoc
abstract mixin class _$EmbedAuthorDtoCopyWith<$Res> implements $EmbedAuthorDtoCopyWith<$Res> {
  factory _$EmbedAuthorDtoCopyWith(_EmbedAuthorDto value, $Res Function(_EmbedAuthorDto) _then) = __$EmbedAuthorDtoCopyWithImpl;
@override @useResult
$Res call({
 String name, String? url,@JsonKey(name: 'icon_url') String? iconUrl,@JsonKey(name: 'proxy_icon_url') String? proxyIconUrl
});




}
/// @nodoc
class __$EmbedAuthorDtoCopyWithImpl<$Res>
    implements _$EmbedAuthorDtoCopyWith<$Res> {
  __$EmbedAuthorDtoCopyWithImpl(this._self, this._then);

  final _EmbedAuthorDto _self;
  final $Res Function(_EmbedAuthorDto) _then;

/// Create a copy of EmbedAuthorDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? url = freezed,Object? iconUrl = freezed,Object? proxyIconUrl = freezed,}) {
  return _then(_EmbedAuthorDto(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,url: freezed == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String?,iconUrl: freezed == iconUrl ? _self.iconUrl : iconUrl // ignore: cast_nullable_to_non_nullable
as String?,proxyIconUrl: freezed == proxyIconUrl ? _self.proxyIconUrl : proxyIconUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$EmbedProviderDto implements DiagnosticableTreeMixin {

 String get name; String? get url;
/// Create a copy of EmbedProviderDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EmbedProviderDtoCopyWith<EmbedProviderDto> get copyWith => _$EmbedProviderDtoCopyWithImpl<EmbedProviderDto>(this as EmbedProviderDto, _$identity);

  /// Serializes this EmbedProviderDto to a JSON map.
  Map<String, dynamic> toJson();

@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'EmbedProviderDto'))
    ..add(DiagnosticsProperty('name', name))..add(DiagnosticsProperty('url', url));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EmbedProviderDto&&(identical(other.name, name) || other.name == name)&&(identical(other.url, url) || other.url == url));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,url);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'EmbedProviderDto(name: $name, url: $url)';
}


}

/// @nodoc
abstract mixin class $EmbedProviderDtoCopyWith<$Res>  {
  factory $EmbedProviderDtoCopyWith(EmbedProviderDto value, $Res Function(EmbedProviderDto) _then) = _$EmbedProviderDtoCopyWithImpl;
@useResult
$Res call({
 String name, String? url
});




}
/// @nodoc
class _$EmbedProviderDtoCopyWithImpl<$Res>
    implements $EmbedProviderDtoCopyWith<$Res> {
  _$EmbedProviderDtoCopyWithImpl(this._self, this._then);

  final EmbedProviderDto _self;
  final $Res Function(EmbedProviderDto) _then;

/// Create a copy of EmbedProviderDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? url = freezed,}) {
  return _then(_self.copyWith(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,url: freezed == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [EmbedProviderDto].
extension EmbedProviderDtoPatterns on EmbedProviderDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _EmbedProviderDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _EmbedProviderDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _EmbedProviderDto value)  $default,){
final _that = this;
switch (_that) {
case _EmbedProviderDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _EmbedProviderDto value)?  $default,){
final _that = this;
switch (_that) {
case _EmbedProviderDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  String? url)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EmbedProviderDto() when $default != null:
return $default(_that.name,_that.url);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  String? url)  $default,) {final _that = this;
switch (_that) {
case _EmbedProviderDto():
return $default(_that.name,_that.url);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  String? url)?  $default,) {final _that = this;
switch (_that) {
case _EmbedProviderDto() when $default != null:
return $default(_that.name,_that.url);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _EmbedProviderDto with DiagnosticableTreeMixin implements EmbedProviderDto {
  const _EmbedProviderDto({this.name = '', this.url});
  factory _EmbedProviderDto.fromJson(Map<String, dynamic> json) => _$EmbedProviderDtoFromJson(json);

@override@JsonKey() final  String name;
@override final  String? url;

/// Create a copy of EmbedProviderDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EmbedProviderDtoCopyWith<_EmbedProviderDto> get copyWith => __$EmbedProviderDtoCopyWithImpl<_EmbedProviderDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$EmbedProviderDtoToJson(this, );
}
@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'EmbedProviderDto'))
    ..add(DiagnosticsProperty('name', name))..add(DiagnosticsProperty('url', url));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _EmbedProviderDto&&(identical(other.name, name) || other.name == name)&&(identical(other.url, url) || other.url == url));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,url);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'EmbedProviderDto(name: $name, url: $url)';
}


}

/// @nodoc
abstract mixin class _$EmbedProviderDtoCopyWith<$Res> implements $EmbedProviderDtoCopyWith<$Res> {
  factory _$EmbedProviderDtoCopyWith(_EmbedProviderDto value, $Res Function(_EmbedProviderDto) _then) = __$EmbedProviderDtoCopyWithImpl;
@override @useResult
$Res call({
 String name, String? url
});




}
/// @nodoc
class __$EmbedProviderDtoCopyWithImpl<$Res>
    implements _$EmbedProviderDtoCopyWith<$Res> {
  __$EmbedProviderDtoCopyWithImpl(this._self, this._then);

  final _EmbedProviderDto _self;
  final $Res Function(_EmbedProviderDto) _then;

/// Create a copy of EmbedProviderDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? url = freezed,}) {
  return _then(_EmbedProviderDto(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,url: freezed == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$EmbedFooterDto implements DiagnosticableTreeMixin {

 String get text;@JsonKey(name: 'icon_url') String? get iconUrl;@JsonKey(name: 'proxy_icon_url') String? get proxyIconUrl;
/// Create a copy of EmbedFooterDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EmbedFooterDtoCopyWith<EmbedFooterDto> get copyWith => _$EmbedFooterDtoCopyWithImpl<EmbedFooterDto>(this as EmbedFooterDto, _$identity);

  /// Serializes this EmbedFooterDto to a JSON map.
  Map<String, dynamic> toJson();

@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'EmbedFooterDto'))
    ..add(DiagnosticsProperty('text', text))..add(DiagnosticsProperty('iconUrl', iconUrl))..add(DiagnosticsProperty('proxyIconUrl', proxyIconUrl));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EmbedFooterDto&&(identical(other.text, text) || other.text == text)&&(identical(other.iconUrl, iconUrl) || other.iconUrl == iconUrl)&&(identical(other.proxyIconUrl, proxyIconUrl) || other.proxyIconUrl == proxyIconUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,text,iconUrl,proxyIconUrl);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'EmbedFooterDto(text: $text, iconUrl: $iconUrl, proxyIconUrl: $proxyIconUrl)';
}


}

/// @nodoc
abstract mixin class $EmbedFooterDtoCopyWith<$Res>  {
  factory $EmbedFooterDtoCopyWith(EmbedFooterDto value, $Res Function(EmbedFooterDto) _then) = _$EmbedFooterDtoCopyWithImpl;
@useResult
$Res call({
 String text,@JsonKey(name: 'icon_url') String? iconUrl,@JsonKey(name: 'proxy_icon_url') String? proxyIconUrl
});




}
/// @nodoc
class _$EmbedFooterDtoCopyWithImpl<$Res>
    implements $EmbedFooterDtoCopyWith<$Res> {
  _$EmbedFooterDtoCopyWithImpl(this._self, this._then);

  final EmbedFooterDto _self;
  final $Res Function(EmbedFooterDto) _then;

/// Create a copy of EmbedFooterDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? text = null,Object? iconUrl = freezed,Object? proxyIconUrl = freezed,}) {
  return _then(_self.copyWith(
text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,iconUrl: freezed == iconUrl ? _self.iconUrl : iconUrl // ignore: cast_nullable_to_non_nullable
as String?,proxyIconUrl: freezed == proxyIconUrl ? _self.proxyIconUrl : proxyIconUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [EmbedFooterDto].
extension EmbedFooterDtoPatterns on EmbedFooterDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _EmbedFooterDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _EmbedFooterDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _EmbedFooterDto value)  $default,){
final _that = this;
switch (_that) {
case _EmbedFooterDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _EmbedFooterDto value)?  $default,){
final _that = this;
switch (_that) {
case _EmbedFooterDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String text, @JsonKey(name: 'icon_url')  String? iconUrl, @JsonKey(name: 'proxy_icon_url')  String? proxyIconUrl)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EmbedFooterDto() when $default != null:
return $default(_that.text,_that.iconUrl,_that.proxyIconUrl);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String text, @JsonKey(name: 'icon_url')  String? iconUrl, @JsonKey(name: 'proxy_icon_url')  String? proxyIconUrl)  $default,) {final _that = this;
switch (_that) {
case _EmbedFooterDto():
return $default(_that.text,_that.iconUrl,_that.proxyIconUrl);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String text, @JsonKey(name: 'icon_url')  String? iconUrl, @JsonKey(name: 'proxy_icon_url')  String? proxyIconUrl)?  $default,) {final _that = this;
switch (_that) {
case _EmbedFooterDto() when $default != null:
return $default(_that.text,_that.iconUrl,_that.proxyIconUrl);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _EmbedFooterDto with DiagnosticableTreeMixin implements EmbedFooterDto {
  const _EmbedFooterDto({this.text = '', @JsonKey(name: 'icon_url') this.iconUrl, @JsonKey(name: 'proxy_icon_url') this.proxyIconUrl});
  factory _EmbedFooterDto.fromJson(Map<String, dynamic> json) => _$EmbedFooterDtoFromJson(json);

@override@JsonKey() final  String text;
@override@JsonKey(name: 'icon_url') final  String? iconUrl;
@override@JsonKey(name: 'proxy_icon_url') final  String? proxyIconUrl;

/// Create a copy of EmbedFooterDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EmbedFooterDtoCopyWith<_EmbedFooterDto> get copyWith => __$EmbedFooterDtoCopyWithImpl<_EmbedFooterDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$EmbedFooterDtoToJson(this, );
}
@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'EmbedFooterDto'))
    ..add(DiagnosticsProperty('text', text))..add(DiagnosticsProperty('iconUrl', iconUrl))..add(DiagnosticsProperty('proxyIconUrl', proxyIconUrl));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _EmbedFooterDto&&(identical(other.text, text) || other.text == text)&&(identical(other.iconUrl, iconUrl) || other.iconUrl == iconUrl)&&(identical(other.proxyIconUrl, proxyIconUrl) || other.proxyIconUrl == proxyIconUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,text,iconUrl,proxyIconUrl);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'EmbedFooterDto(text: $text, iconUrl: $iconUrl, proxyIconUrl: $proxyIconUrl)';
}


}

/// @nodoc
abstract mixin class _$EmbedFooterDtoCopyWith<$Res> implements $EmbedFooterDtoCopyWith<$Res> {
  factory _$EmbedFooterDtoCopyWith(_EmbedFooterDto value, $Res Function(_EmbedFooterDto) _then) = __$EmbedFooterDtoCopyWithImpl;
@override @useResult
$Res call({
 String text,@JsonKey(name: 'icon_url') String? iconUrl,@JsonKey(name: 'proxy_icon_url') String? proxyIconUrl
});




}
/// @nodoc
class __$EmbedFooterDtoCopyWithImpl<$Res>
    implements _$EmbedFooterDtoCopyWith<$Res> {
  __$EmbedFooterDtoCopyWithImpl(this._self, this._then);

  final _EmbedFooterDto _self;
  final $Res Function(_EmbedFooterDto) _then;

/// Create a copy of EmbedFooterDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? text = null,Object? iconUrl = freezed,Object? proxyIconUrl = freezed,}) {
  return _then(_EmbedFooterDto(
text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,iconUrl: freezed == iconUrl ? _self.iconUrl : iconUrl // ignore: cast_nullable_to_non_nullable
as String?,proxyIconUrl: freezed == proxyIconUrl ? _self.proxyIconUrl : proxyIconUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
