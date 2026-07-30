import 'package:freezed_annotation/freezed_annotation.dart';

part 'attachment_dto.freezed.dart';
part 'attachment_dto.g.dart';

/// Server-side processing state for an uploaded attachment - see
/// `MessageApi.pollAttachment`, which polls `GET .../attachments/{id}` until
/// this reaches `complete`. The server only ever reports these two values
/// (verified against `Messaging.Domain.Enums.AttachmentState`) - there's no
/// `Failed` state, so a stuck `pending` is handled with a client-side
/// timeout rather than waiting for a terminal error state that never comes.
enum AttachmentState {
  @JsonValue('Pending')
  pending,
  @JsonValue('Complete')
  complete,
}

/// Covers both the minimal shape embedded on a `MessageDto` (id, fileName,
/// contentType, thumbnailUrl - notably **no `url`**) and the fuller
/// standalone shape returned by `GET .../attachments/{id}` while polling
/// upload status (adds `state`, `sizeBytes`, and a populated `url`) - one
/// model, extra fields nullable where a given caller doesn't populate them.
/// Callers needing a download link for a message-embedded attachment must
/// build it from [id] via `MessageApi.downloadUrl`/`thumbnailUrl`, since the
/// message payload doesn't carry an absolute url for the full file.
@freezed
sealed class AttachmentDto with _$AttachmentDto {
  const factory AttachmentDto({
    required String id,
    required String fileName,
    required String contentType,
    @Default(AttachmentState.complete) AttachmentState state,
    int? sizeBytes,
    String? url,
    String? thumbnailUrl,
  }) = _AttachmentDto;

  factory AttachmentDto.fromJson(Map<String, dynamic> json) =>
      _$AttachmentDtoFromJson(json);
}

extension AttachmentDtoX on AttachmentDto {
  bool get isImage => contentType.startsWith('image/');
}
