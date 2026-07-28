// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'server_configuration.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ServerConfiguration _$ServerConfigurationFromJson(Map<String, dynamic> json) =>
    _ServerConfiguration(
      isRegisterEnabled: json['isRegisterEnabled'] as bool,
      isLoginEnabled: json['isLoginEnabled'] as bool,
    );

Map<String, dynamic> _$ServerConfigurationToJson(
  _ServerConfiguration instance,
) => <String, dynamic>{
  'isRegisterEnabled': instance.isRegisterEnabled,
  'isLoginEnabled': instance.isLoginEnabled,
};
