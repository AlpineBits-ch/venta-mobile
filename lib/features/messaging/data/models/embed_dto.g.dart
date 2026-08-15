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
  rawType: json['type'] as String? ?? '',
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
  venta: json['venta'] == null
      ? null
      : EmbedVentaDto.fromJson(json['venta'] as Map<String, dynamic>),
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
  'venta': instance.venta,
  'flags': instance.flags,
};

const _$EmbedTypeEnumMap = {
  EmbedType.rich: 'rich',
  EmbedType.link: 'link',
  EmbedType.article: 'article',
  EmbedType.image: 'image',
  EmbedType.video: 'video',
  EmbedType.gifv: 'gifv',
  EmbedType.ventaInvite: 'venta.invite',
  EmbedType.ventaWikiPage: 'venta.wiki_page',
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
      proxyUrl: json['proxy_url'] as String?,
      width: (json['width'] as num?)?.toInt(),
      height: (json['height'] as num?)?.toInt(),
      contentType: json['content_type'] as String?,
      placeholder: json['placeholder'] as String?,
      placeholderVersion: (json['placeholder_version'] as num?)?.toInt(),
    );

Map<String, dynamic> _$EmbedMediaDtoToJson(_EmbedMediaDto instance) =>
    <String, dynamic>{
      'url': instance.url,
      'proxy_url': instance.proxyUrl,
      'width': instance.width,
      'height': instance.height,
      'content_type': instance.contentType,
      'placeholder': instance.placeholder,
      'placeholder_version': instance.placeholderVersion,
    };

_EmbedVentaDto _$EmbedVentaDtoFromJson(Map<String, dynamic> json) =>
    _EmbedVentaDto(
      kind:
          $enumDecodeNullable(
            _$EmbedVentaKindEnumMap,
            json['kind'],
            unknownValue: EmbedVentaKind.unknown,
          ) ??
          EmbedVentaKind.unknown,
      resolved: json['resolved'] as bool? ?? false,
      guildId: json['guild_id'] as String?,
      inviteCode: json['invite_code'] as String?,
      channelId: json['channel_id'] as String?,
      pageId: json['page_id'] as String?,
      expiresAt: _$JsonConverterFromJson<String, DateTime>(
        json['expires_at'],
        const ApiDateTimeConverter().fromJson,
      ),
      maxUses: (json['max_uses'] as num?)?.toInt(),
    );

Map<String, dynamic> _$EmbedVentaDtoToJson(_EmbedVentaDto instance) =>
    <String, dynamic>{
      'kind': _$EmbedVentaKindEnumMap[instance.kind]!,
      'resolved': instance.resolved,
      'guild_id': instance.guildId,
      'invite_code': instance.inviteCode,
      'channel_id': instance.channelId,
      'page_id': instance.pageId,
      'expires_at': _$JsonConverterToJson<String, DateTime>(
        instance.expiresAt,
        const ApiDateTimeConverter().toJson,
      ),
      'max_uses': instance.maxUses,
    };

const _$EmbedVentaKindEnumMap = {
  EmbedVentaKind.invite: 'invite',
  EmbedVentaKind.wikiPage: 'wiki_page',
  EmbedVentaKind.unknown: 'unknown',
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
      iconUrl: json['icon_url'] as String?,
      proxyIconUrl: json['proxy_icon_url'] as String?,
    );

Map<String, dynamic> _$EmbedAuthorDtoToJson(_EmbedAuthorDto instance) =>
    <String, dynamic>{
      'name': instance.name,
      'url': instance.url,
      'icon_url': instance.iconUrl,
      'proxy_icon_url': instance.proxyIconUrl,
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
      iconUrl: json['icon_url'] as String?,
      proxyIconUrl: json['proxy_icon_url'] as String?,
    );

Map<String, dynamic> _$EmbedFooterDtoToJson(_EmbedFooterDto instance) =>
    <String, dynamic>{
      'text': instance.text,
      'icon_url': instance.iconUrl,
      'proxy_icon_url': instance.proxyIconUrl,
    };
