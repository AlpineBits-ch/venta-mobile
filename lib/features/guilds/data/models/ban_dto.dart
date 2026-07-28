import 'package:freezed_annotation/freezed_annotation.dart';

part 'ban_dto.freezed.dart';
part 'ban_dto.g.dart';

@freezed
sealed class BanDto with _$BanDto {
  const factory BanDto({
    required String id,
    required String guildId,
    required String bannedUserId,
    String? bannedByUserId,
    String? reason,
    DateTime? createdAt,
  }) = _BanDto;

  factory BanDto.fromJson(Map<String, dynamic> json) => _$BanDtoFromJson(json);
}
