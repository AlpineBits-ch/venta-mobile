/// The `GET /api/v1/status/summary` payload.
///
/// Every enum here carries an explicit `unknown` member and every field that
/// reads one is annotated `unknownEnumValue: ....unknown`.
///
/// The spec is emphatic about this: "Treat every one as open: a value you do
/// not recognise must fall back to the least alarming rendering you have, never
/// to a crash and never to major outage." Without the member, a
/// `json_serializable` decode of a value added after this build shipped throws,
/// and one new component status would take the whole status feature offline on
/// every older client - the exact moment it is most worth having. With it, the
/// rendering degrades to a neutral dot and the server's own banner copy, which
/// is the part that was never going to be stale anyway.
library;

import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/format/api_date_time.dart';

part 'platform_status_dto.freezed.dart';
part 'platform_status_dto.g.dart';

/// The instance-wide roll-up. Drives the settings header; the banner is driven
/// by [PlatformStatusDto.banner] instead - see [PlatformStatusDto.hasBanner].
enum StatusIndicator {
  @JsonValue('operational')
  operational,
  @JsonValue('degraded')
  degraded,
  @JsonValue('partial_outage')
  partialOutage,
  @JsonValue('major_outage')
  majorOutage,
  @JsonValue('maintenance')
  maintenance,
  unknown,
}

/// How loud the banner is allowed to be. Maps onto the app palette in
/// `PlatformStatusBanner`; nothing else reads it.
enum StatusSeverity {
  @JsonValue('info')
  info,
  @JsonValue('warning')
  warning,
  @JsonValue('critical')
  critical,
  unknown,
}

/// One component's own state.
enum ComponentStatus {
  @JsonValue('operational')
  operational,
  @JsonValue('degraded_performance')
  degradedPerformance,
  @JsonValue('partial_outage')
  partialOutage,
  @JsonValue('major_outage')
  majorOutage,
  @JsonValue('under_maintenance')
  underMaintenance,
  unknown,
}

enum IncidentKind {
  @JsonValue('incident')
  incident,
  @JsonValue('maintenance')
  maintenance,
  unknown,
}

enum IncidentImpact {
  @JsonValue('none')
  none,
  @JsonValue('minor')
  minor,
  @JsonValue('major')
  major,
  @JsonValue('critical')
  critical,
  unknown,
}

/// The lifecycle of an incident *or* of a maintenance window.
///
/// One enum for both because they arrive on the same `status` property of the
/// same object shape, and which set of values applies depends on `kind`. Two
/// enums would mean deciding the type of a field from the value of a sibling
/// field, which `json_serializable` cannot express and which buys nothing:
/// nothing here needs to reject "a maintenance window that says
/// `investigating`", it only needs to render whatever arrived.
enum IncidentStatus {
  @JsonValue('investigating')
  investigating,
  @JsonValue('identified')
  identified,
  @JsonValue('monitoring')
  monitoring,
  @JsonValue('resolved')
  resolved,
  @JsonValue('scheduled')
  scheduled,
  @JsonValue('in_progress')
  inProgress,
  @JsonValue('completed')
  completed,
  @JsonValue('cancelled')
  cancelled,
  unknown,
}

extension StatusIndicatorX on StatusIndicator {
  /// The settings header's one line. Deliberately short and non-technical -
  /// the *why* is the server's banner copy, never this.
  String get label => switch (this) {
    StatusIndicator.operational => 'All systems operational',
    StatusIndicator.degraded => 'Degraded performance',
    StatusIndicator.partialOutage => 'Partial outage',
    StatusIndicator.majorOutage => 'Major outage',
    StatusIndicator.maintenance => 'Maintenance in progress',
    // Not "outage". An indicator this build doesn't know about says nothing
    // about severity, and guessing upwards is the one direction the spec rules
    // out.
    StatusIndicator.unknown => 'Status unknown',
  };
}

extension ComponentStatusX on ComponentStatus {
  String get label => switch (this) {
    ComponentStatus.operational => 'Operational',
    ComponentStatus.degradedPerformance => 'Degraded performance',
    ComponentStatus.partialOutage => 'Partial outage',
    ComponentStatus.majorOutage => 'Major outage',
    ComponentStatus.underMaintenance => 'Under maintenance',
    ComponentStatus.unknown => 'Unknown',
  };

  /// What a feature-level hint keys off - "is this thing working" rather than
  /// "how badly is it not".
  bool get isOperational => this == ComponentStatus.operational;
}

extension IncidentStatusX on IncidentStatus {
  String get label => switch (this) {
    IncidentStatus.investigating => 'Investigating',
    IncidentStatus.identified => 'Identified',
    IncidentStatus.monitoring => 'Monitoring',
    IncidentStatus.resolved => 'Resolved',
    IncidentStatus.scheduled => 'Scheduled',
    IncidentStatus.inProgress => 'In progress',
    IncidentStatus.completed => 'Completed',
    IncidentStatus.cancelled => 'Cancelled',
    IncidentStatus.unknown => 'Update',
  };
}

/// The whole of `GET /api/v1/status/summary`.
///
/// Anonymous, CORS-open, cached 15s server-side. Everything a client renders
/// about platform health comes from this one object - see `StatusApi`.
@freezed
sealed class PlatformStatusDto with _$PlatformStatusDto {
  @ApiDateTimeConverter()
  const factory PlatformStatusDto({
    @JsonKey(unknownEnumValue: StatusIndicator.unknown)
    @Default(StatusIndicator.operational)
    StatusIndicator indicator,
    DateTime? updatedAt,

    /// Present only when [indicator] is not `operational`, and the only thing
    /// the client is allowed to render as prose - see [StatusBannerDto].
    StatusBannerDto? banner,

    /// One per component, already in display order. Never re-sorted here.
    @Default(<StatusComponentDto>[]) List<StatusComponentDto> components,

    /// Open incidents. `kind == incident`.
    @Default(<StatusIncidentDto>[]) List<StatusIncidentDto> incidents,

    /// Active and upcoming maintenance windows. `kind == maintenance`.
    @Default(<StatusIncidentDto>[]) List<StatusIncidentDto> maintenance,

    /// The last 7 resolved, with `updates` omitted by the server.
    @Default(<StatusIncidentDto>[]) List<StatusIncidentDto> recent,
  }) = _PlatformStatusDto;

  const PlatformStatusDto._();

  factory PlatformStatusDto.fromJson(Map<String, dynamic> json) =>
      _$PlatformStatusDtoFromJson(json);

  /// Whether there is anything to put in front of the user.
  ///
  /// Keyed on the banner's presence rather than on `indicator != operational`,
  /// which the spec words it as. The two are the same statement on a server
  /// that keeps its contract, and this half of it is the one that stays right
  /// when the server adds an indicator value this build has never heard of:
  /// falling back to the least alarming rendering must not mean silently
  /// swallowing copy the server explicitly sent to be shown.
  bool get hasBanner => banner != null && banner!.title.isNotEmpty;

  /// Everything currently open, incidents and maintenance together.
  List<StatusIncidentDto> get open => [...incidents, ...maintenance];

  /// The incident the banner is about, or null when the banner spans several
  /// (or when the reference names something not in this response).
  StatusIncidentDto? get bannerIncident {
    final reference = banner?.incidentReference;
    if (reference == null || reference.isEmpty) return null;
    for (final incident in open) {
      if (incident.reference == reference) return incident;
    }
    return null;
  }
}

/// The banner copy, written by the server.
///
/// **Never composed client-side.** How technical a status message is allowed to
/// be is a decision the server makes once; a client that builds its own
/// sentence out of a component name and a status enum re-implements that
/// decision, and the day it drifts is the day a user reads "identity 5xx rate
/// 31%" instead of "some people may not be able to sign in". [template] exists
/// so a translation can be substituted (§6) - not so the English can be
/// rebuilt.
@freezed
sealed class StatusBannerDto with _$StatusBannerDto {
  const factory StatusBannerDto({
    @Default('') String title,
    @Default('') String body,
    @JsonKey(unknownEnumValue: StatusSeverity.unknown)
    @Default(StatusSeverity.info)
    StatusSeverity severity,
    String? incidentReference,

    /// Where the public status page describes this one. Opened in the system
    /// browser; `StatusRepository.bannerUrl` supplies a fallback if absent.
    String? url,

    /// Non-null for a generated incident, whose copy comes from a fixed table
    /// and could be translated client-side. Null for staff-written incidents,
    /// which are free text in the instance's own language and have no
    /// translation path.
    String? template,

    /// Null when more than one component is affected.
    String? componentKey,
  }) = _StatusBannerDto;

  factory StatusBannerDto.fromJson(Map<String, dynamic> json) =>
      _$StatusBannerDtoFromJson(json);
}

/// One piece of the platform, in the instance's own display order.
@freezed
sealed class StatusComponentDto with _$StatusComponentDto {
  @ApiDateTimeConverter()
  const factory StatusComponentDto({
    /// Stable and safe to switch on - `accounts`, `voice`, `previews`. The
    /// display [name] is not; it is prose and may be translated or reworded.
    @Default('') String key,
    @Default('') String name,
    String? description,
    @JsonKey(unknownEnumValue: ComponentStatus.unknown)
    @Default(ComponentStatus.operational)
    ComponentStatus status,
    DateTime? statusSince,

    /// A fraction, not a percentage: `0.9987` is 99.87%.
    double? uptime90d,
  }) = _StatusComponentDto;

  factory StatusComponentDto.fromJson(Map<String, dynamic> json) =>
      _$StatusComponentDtoFromJson(json);
}

/// One incident or maintenance window. Same shape for both - [kind] says which.
@freezed
sealed class StatusIncidentDto with _$StatusIncidentDto {
  @ApiDateTimeConverter()
  const factory StatusIncidentDto({
    /// `VNT-4KQ7M2XB`. The identity of an incident across responses and across
    /// the hub event, and what a dismissal is keyed on.
    @Default('') String reference,
    @JsonKey(unknownEnumValue: IncidentKind.unknown)
    @Default(IncidentKind.incident)
    IncidentKind kind,
    @Default('') String title,
    @JsonKey(unknownEnumValue: IncidentImpact.unknown)
    @Default(IncidentImpact.none)
    IncidentImpact impact,
    @JsonKey(unknownEnumValue: IncidentStatus.unknown)
    @Default(IncidentStatus.unknown)
    IncidentStatus status,

    /// Component *keys*, matching [StatusComponentDto.key].
    @Default(<String>[]) List<String> components,
    DateTime? startedAt,
    DateTime? resolvedAt,

    /// Maintenance only.
    DateTime? scheduledFor,
    DateTime? scheduledUntil,
    String? template,
    String? url,

    /// Newest first, per the spec - but nothing here relies on that; see
    /// [newestUpdateAt].
    @Default(<StatusIncidentUpdateDto>[]) List<StatusIncidentUpdateDto> updates,
  }) = _StatusIncidentDto;

  const StatusIncidentDto._();

  factory StatusIncidentDto.fromJson(Map<String, dynamic> json) =>
      _$StatusIncidentDtoFromJson(json);

  /// When this incident last said anything.
  ///
  /// Computed as a maximum rather than read off `updates.first`, even though
  /// the server documents the list as newest-first. This value is half of the
  /// dismissal key: if the ordering ever changes, trusting position would pin
  /// the key to an *older* update, and a genuinely new one would then match the
  /// dismissal and never re-raise the banner - a silent failure of the one
  /// rule the dismissal exists to honour.
  DateTime? get newestUpdateAt {
    DateTime? newest;
    for (final update in updates) {
      final postedAt = update.postedAt;
      if (postedAt == null) continue;
      if (newest == null || postedAt.isAfter(newest)) newest = postedAt;
    }
    return newest;
  }

  /// The most recent thing said about it, for a one-line summary.
  StatusIncidentUpdateDto? get latestUpdate {
    StatusIncidentUpdateDto? latest;
    for (final update in updates) {
      if (latest == null) {
        latest = update;
        continue;
      }
      final a = update.postedAt;
      final b = latest.postedAt;
      if (a != null && (b == null || a.isAfter(b))) latest = update;
    }
    return latest;
  }
}

/// One posted update on an incident's timeline.
@freezed
sealed class StatusIncidentUpdateDto with _$StatusIncidentUpdateDto {
  @ApiDateTimeConverter()
  const factory StatusIncidentUpdateDto({
    @JsonKey(unknownEnumValue: IncidentStatus.unknown)
    @Default(IncidentStatus.unknown)
    IncidentStatus status,
    @Default('') String body,
    String? template,
    DateTime? postedAt,
  }) = _StatusIncidentUpdateDto;

  factory StatusIncidentUpdateDto.fromJson(Map<String, dynamic> json) =>
      _$StatusIncidentUpdateDtoFromJson(json);
}
