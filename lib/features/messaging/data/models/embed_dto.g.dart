// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'embed_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_EmbedDto _$EmbedDtoFromJson(Map<String, dynamic> json) => _EmbedDto(
  type:
      $enumDecodeNullable(
        _$EmbedTypeEnumMap,
        json['type'],
        unknownValue: EmbedType.unknown,
      ) ??
      EmbedType.link,
  title: json['title'] as String?,
  description: json['description'] as String?,
  url: json['url'] as String?,
  timestamp: _$JsonConverterFromJson<String, DateTime>(
    json['timestamp'],
    const ApiDateTimeConverter().fromJson,
  ),
  color: json['color'] as String?,
  provider: json['provider'] == null
      ? null
      : EmbedProviderDto.fromJson(json['provider'] as Map<String, dynamic>),
  author: json['author'] == null
      ? null
      : EmbedAuthorDto.fromJson(json['author'] as Map<String, dynamic>),
  thumbnail: json['thumbnail'] == null
      ? null
      : EmbedMediaDto.fromJson(json['thumbnail'] as Map<String, dynamic>),
  image: json['image'] == null
      ? null
      : EmbedMediaDto.fromJson(json['image'] as Map<String, dynamic>),
  video: json['video'] == null
      ? null
      : EmbedMediaDto.fromJson(json['video'] as Map<String, dynamic>),
  fields:
      (json['fields'] as List<dynamic>?)
          ?.map((e) => EmbedFieldDto.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <EmbedFieldDto>[],
  footer: json['footer'] == null
      ? null
      : EmbedFooterDto.fromJson(json['footer'] as Map<String, dynamic>),
  flags: (json['flags'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$EmbedDtoToJson(_EmbedDto instance) => <String, dynamic>{
  'type': _$EmbedTypeEnumMap[instance.type]!,
  'title': instance.title,
  'description': instance.description,
  'url': instance.url,
  'timestamp': _$JsonConverterToJson<String, DateTime>(
    instance.timestamp,
    const ApiDateTimeConverter().toJson,
  ),
  'color': instance.color,
  'provider': instance.provider,
  'author': instance.author,
  'thumbnail': instance.thumbnail,
  'image': instance.image,
  'video': instance.video,
  'fields': instance.fields,
  'footer': instance.footer,
  'flags': instance.flags,
};

const _$EmbedTypeEnumMap = {
  EmbedType.rich: 'rich',
  EmbedType.link: 'link',
  EmbedType.article: 'article',
  EmbedType.image: 'image',
  EmbedType.video: 'video',
  EmbedType.gifv: 'gifv',
  EmbedType.unknown: 'unknown',
};

Value? _$JsonConverterFromJson<Json, Value>(
  Object? json,
  Value? Function(Json json) fromJson,
) => json == null ? null : fromJson(json as Json);

Json? _$JsonConverterToJson<Json, Value>(
  Value? value,
  Json? Function(Value value) toJson,
) => value == null ? null : toJson(value);

_EmbedMediaDto _$EmbedMediaDtoFromJson(Map<String, dynamic> json) =>
    _EmbedMediaDto(
      url: json['url'] as String?,
      proxyUrl: json['proxyUrl'] as String?,
      width: (json['width'] as num?)?.toInt(),
      height: (json['height'] as num?)?.toInt(),
      contentType: json['contentType'] as String?,
      placeholder: json['placeholder'] as String?,
      placeholderVersion: (json['placeholderVersion'] as num?)?.toInt(),
    );

Map<String, dynamic> _$EmbedMediaDtoToJson(_EmbedMediaDto instance) =>
    <String, dynamic>{
      'url': instance.url,
      'proxyUrl': instance.proxyUrl,
      'width': instance.width,
      'height': instance.height,
      'contentType': instance.contentType,
      'placeholder': instance.placeholder,
      'placeholderVersion': instance.placeholderVersion,
    };

_EmbedFieldDto _$EmbedFieldDtoFromJson(Map<String, dynamic> json) =>
    _EmbedFieldDto(
      name: json['name'] as String? ?? '',
      value: json['value'] as String? ?? '',
      inline: json['inline'] as bool? ?? false,
    );

Map<String, dynamic> _$EmbedFieldDtoToJson(_EmbedFieldDto instance) =>
    <String, dynamic>{
      'name': instance.name,
      'value': instance.value,
      'inline': instance.inline,
    };

_EmbedAuthorDto _$EmbedAuthorDtoFromJson(Map<String, dynamic> json) =>
    _EmbedAuthorDto(
      name: json['name'] as String? ?? '',
      url: json['url'] as String?,
      iconUrl: json['iconUrl'] as String?,
      proxyIconUrl: json['proxyIconUrl'] as String?,
    );

Map<String, dynamic> _$EmbedAuthorDtoToJson(_EmbedAuthorDto instance) =>
    <String, dynamic>{
      'name': instance.name,
      'url': instance.url,
      'iconUrl': instance.iconUrl,
      'proxyIconUrl': instance.proxyIconUrl,
    };

_EmbedProviderDto _$EmbedProviderDtoFromJson(Map<String, dynamic> json) =>
    _EmbedProviderDto(
      name: json['name'] as String? ?? '',
      url: json['url'] as String?,
    );

Map<String, dynamic> _$EmbedProviderDtoToJson(_EmbedProviderDto instance) =>
    <String, dynamic>{'name': instance.name, 'url': instance.url};

_EmbedFooterDto _$EmbedFooterDtoFromJson(Map<String, dynamic> json) =>
    _EmbedFooterDto(
      text: json['text'] as String? ?? '',
      iconUrl: json['iconUrl'] as String?,
      proxyIconUrl: json['proxyIconUrl'] as String?,
    );

Map<String, dynamic> _$EmbedFooterDtoToJson(_EmbedFooterDto instance) =>
    <String, dynamic>{
      'text': instance.text,
      'iconUrl': instance.iconUrl,
      'proxyIconUrl': instance.proxyIconUrl,
    };
