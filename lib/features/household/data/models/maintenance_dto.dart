import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/format/api_date_time.dart';

part 'maintenance_dto.freezed.dart';
part 'maintenance_dto.g.dart';

/// What state a piece of household equipment is in.
///
/// [broken] and [outOfService] are **not synonyms**: the first means it stopped
/// working and somebody has to deal with it, the second means the house took it
/// out of use on purpose. Only the first is urgent, and only the first is worth
/// telling anybody about.
enum AssetStatus {
  @JsonValue('Ok')
  ok,
  @JsonValue('NeedsAttention')
  needsAttention,
  @JsonValue('Broken')
  broken,
  @JsonValue('OutOfService')
  outOfService,
}

extension AssetStatusX on AssetStatus {
  String get wireValue => switch (this) {
    AssetStatus.ok => 'Ok',
    AssetStatus.needsAttention => 'NeedsAttention',
    AssetStatus.broken => 'Broken',
    AssetStatus.outOfService => 'OutOfService',
  };

  String get label => switch (this) {
    AssetStatus.ok => 'Working',
    AssetStatus.needsAttention => 'Needs a look',
    AssetStatus.broken => 'Broken',
    AssetStatus.outOfService => 'Out of use',
  };

  /// What choosing it means, for the status picker - the one place the
  /// broken/out-of-use distinction has to land.
  String get description => switch (this) {
    AssetStatus.ok => 'Nothing wrong with it',
    AssetStatus.needsAttention => 'Still usable, but somebody should look',
    AssetStatus.broken => 'It stopped working and somebody has to deal with it',
    AssetStatus.outOfService => 'The house took it out of use on purpose',
  };

  IconData get icon => switch (this) {
    AssetStatus.ok => Icons.check_circle_outline_rounded,
    AssetStatus.needsAttention => Icons.error_outline_rounded,
    AssetStatus.broken => Icons.report_gmailerrorred_rounded,
    AssetStatus.outOfService => Icons.do_not_disturb_on_outlined,
  };
}

/// A machine in the house, and everything anybody needs at 22:00 on a Sunday.
///
/// The warranty date is the one date in a flat that nobody tracks and that is
/// expensive to have missed, and the vendor's phone number is the other half of
/// the same moment. Both get real prominence in the UI for that reason.
@freezed
sealed class MaintenanceAssetDto with _$MaintenanceAssetDto {
  @ApiDateTimeConverter()
  const factory MaintenanceAssetDto({
    required String id,
    required String channelId,
    @Default('') String name,
    String? location,
    String? brand,
    String? model,
    String? serialNumber,
    DateTime? purchasedAt,
    DateTime? warrantyUntil,
    String? vendorName,
    String? vendorPhone,
    String? vendorEmail,
    String? notes,
    int? serviceIntervalDays,
    DateTime? lastServicedAt,
    DateTime? nextServiceAt,
    @Default(AssetStatus.ok)
    @JsonKey(unknownEnumValue: AssetStatus.ok)
    AssetStatus status,
    String? statusNote,

    /// Computed server-side rather than stored, so no client has to know the
    /// sweep's cutoffs or carry a clock the server disagrees with.
    @Default(false) bool isServiceOverdue,
    @Default(false) bool isWarrantyExpiring,
    @Default('') String addedByUserId,
  }) = _MaintenanceAssetDto;

  factory MaintenanceAssetDto.fromJson(Map<String, dynamic> json) =>
      _$MaintenanceAssetDtoFromJson(json);
}

extension MaintenanceAssetX on MaintenanceAssetDto {
  bool get needsSomebody =>
      status == AssetStatus.broken ||
      status == AssetStatus.needsAttention ||
      isServiceOverdue ||
      isWarrantyExpiring;

  /// Whether the warranty has already run out, as opposed to running out soon.
  bool warrantyLapsed({DateTime? now}) {
    final until = warrantyUntil;
    return until != null && until.isBefore(now ?? DateTime.now());
  }
}

/// Something that was done to an asset.
///
/// A service records **when it was actually done** and the next one is
/// scheduled from there, not from the date it was supposed to happen. It also
/// does not clear a `Broken` status: a visit is not proof it works.
@freezed
sealed class MaintenanceRecordDto with _$MaintenanceRecordDto {
  @ApiDateTimeConverter()
  const factory MaintenanceRecordDto({
    required String id,

    /// Null for work on the house rather than on one machine.
    String? assetId,
    required String channelId,
    @Default('') String title,
    String? description,
    required DateTime performedAt,
    @Default('') String performedByUserId,
    String? vendorName,

    /// Minor units, like every other amount in this app.
    int? costMinor,
    String? currency,

    /// The ledger entry it was paid through, when somebody linked one.
    String? expenseId,
  }) = _MaintenanceRecordDto;

  factory MaintenanceRecordDto.fromJson(Map<String, dynamic> json) =>
      _$MaintenanceRecordDtoFromJson(json);
}

@freezed
sealed class MaintenanceRecordPageDto with _$MaintenanceRecordPageDto {
  const factory MaintenanceRecordPageDto({
    @Default(<MaintenanceRecordDto>[]) List<MaintenanceRecordDto> items,
    String? nextCursor,
  }) = _MaintenanceRecordPageDto;

  factory MaintenanceRecordPageDto.fromJson(Map<String, dynamic> json) =>
      _$MaintenanceRecordPageDtoFromJson(json);
}

/// One row of the guild-wide attention board.
///
/// [reasons] travels with the asset rather than being re-derived here: the
/// client would have to reimplement the warranty window and the overdue cutoff
/// to get the same answer, and the two would drift the first time either
/// changed.
@freezed
sealed class MaintenanceAttentionDto with _$MaintenanceAttentionDto {
  const factory MaintenanceAttentionDto({
    required MaintenanceAssetDto asset,

    /// Stable tokens: `broken`, `needs_attention`, `service_overdue`,
    /// `warranty_expiring`. An asset can carry more than one.
    @Default(<String>[]) List<String> reasons,
  }) = _MaintenanceAttentionDto;

  factory MaintenanceAttentionDto.fromJson(Map<String, dynamic> json) =>
      _$MaintenanceAttentionDtoFromJson(json);
}

/// How an attention reason reads. Unknown tokens fall through to null so a
/// reason added server-side is skipped rather than printed raw.
String? maintenanceReasonLabel(String reason) => switch (reason) {
  'broken' => 'Broken',
  'needs_attention' => 'Needs a look',
  'service_overdue' => 'Service overdue',
  'warranty_expiring' => 'Warranty running out',
  _ => null,
};
