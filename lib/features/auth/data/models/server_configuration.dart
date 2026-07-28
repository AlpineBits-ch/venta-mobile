import 'package:freezed_annotation/freezed_annotation.dart';

part 'server_configuration.freezed.dart';
part 'server_configuration.g.dart';

@freezed
sealed class ServerConfiguration with _$ServerConfiguration {
  const factory ServerConfiguration({
    required bool isRegisterEnabled,
    required bool isLoginEnabled,
  }) = _ServerConfiguration;

  factory ServerConfiguration.fromJson(Map<String, dynamic> json) =>
      _$ServerConfigurationFromJson(json);
}
