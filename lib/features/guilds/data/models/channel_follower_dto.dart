import 'package:freezed_annotation/freezed_annotation.dart';

part 'channel_follower_dto.freezed.dart';
part 'channel_follower_dto.g.dart';

/// A source→target Announcement-channel follow relationship. The guide
/// doesn't pin down the exact response shape for `GET .../followers`, so
/// this only models what the client actually needs to render/unfollow one.
@freezed
sealed class ChannelFollowerDto with _$ChannelFollowerDto {
  const factory ChannelFollowerDto({
    required String id,
    required String targetChannelId,
  }) = _ChannelFollowerDto;

  factory ChannelFollowerDto.fromJson(Map<String, dynamic> json) =>
      _$ChannelFollowerDtoFromJson(json);
}
