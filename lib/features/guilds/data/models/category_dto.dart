import 'package:freezed_annotation/freezed_annotation.dart';

import 'channel_dto.dart';

part 'category_dto.freezed.dart';
part 'category_dto.g.dart';

@freezed
sealed class CategoryDto with _$CategoryDto {
  const factory CategoryDto({
    required String id,
    required String name,
    String? description,
    @Default(<ChannelPermissionDto>[]) List<ChannelPermissionDto> permissions,
    @Default(0) int position,
  }) = _CategoryDto;

  factory CategoryDto.fromJson(Map<String, dynamic> json) =>
      _$CategoryDtoFromJson(json);
}
