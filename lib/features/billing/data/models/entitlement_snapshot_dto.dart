/// `GET /api/v1/entitlements/me` - what this account is entitled to, and which
/// plan resolved it.
///
/// A deliberately partial model of the documented payload. Six fields on the
/// wire are not here and each omission is a decision:
///
/// * `stripePublishableKey` - the key a checkout mounts against. This client
///   has no checkout and must not grow one, and a field nobody reads is the
///   first half of somebody adding the second half.
/// * `remedy` and `actorCanRemedy` - "what would fix this" and "can you do
///   it". They are the server's answer to which purchasing control to draw,
///   which is the one thing this screen exists not to draw. See
///   `entitlement_degradation_dto.dart` for the same omission on the same two
///   fields.
/// * `licenseMode` and `upgradesAvailable` - what kind of instance this is, and
///   whether anything can be bought on it.
///
///   **Neither is modelled, and that is the point.** Nothing on this platform
///   may turn on whether the reader could obtain a different plan - including
///   whether a settings row exists. A row conditioned on purchasability is
///   itself a statement that purchasing is possible, which is the same class of
///   thing as a button. What decides whether this surface exists is whether the
///   instance has a plan catalogue to describe, which is a fact about the
///   instance rather than about the reader. See `PlanRepository.ensureProbed`.
/// * `ladders` - every rung of every ladder with its pixel and framerate
///   metrics. Read by a quality picker that clamps itself, and this client has
///   none: the camera publishes at one capture size and the server clamps it
///   and says so. Modelling metrics nothing reads would be the first half of
///   somebody inventing the rung-to-resolution mapping the server owns.
/// * `resolvedAt` - when the server resolved it. `EntitlementReader` times its
///   own entries from when they arrived, which is the number that decides
///   whether it may still be used.
///
/// [ttlSeconds] and [version] *are* modelled, and were not until something
/// cached: they are the caching contract, and a cache that ignores them is the
/// specific failure the contract exists to prevent. The plan screen still
/// reads a fresh snapshot per open and uses neither.
library;

import 'package:freezed_annotation/freezed_annotation.dart';

import 'entitlement_value.dart';

part 'entitlement_snapshot_dto.freezed.dart';
part 'entitlement_snapshot_dto.g.dart';

/// Whose entitlements these are.
///
/// Not decoration. This client points at arbitrary instances and switches
/// accounts at runtime, so a response that does not say what it is about gets
/// filed against whatever the user has since switched to.
@freezed
sealed class EntitlementSubjectDto with _$EntitlementSubjectDto {
  const factory EntitlementSubjectDto({
    /// Lowercase `user` or `guild`. Compare with [sameSubjectKind] rather than
    /// `==`: this build talks to instances running older services, and a
    /// subscription that arrives as `Guild` should still land on the servers
    /// section rather than nowhere.
    @Default('') String kind,
    @Default('') String id,
  }) = _EntitlementSubjectDto;

  factory EntitlementSubjectDto.fromJson(Map<String, dynamic> json) =>
      _$EntitlementSubjectDtoFromJson(json);
}

/// The two sides of the product a plan can be sold against.
abstract final class SubjectKinds {
  static const user = 'user';
  static const guild = 'guild';
}

/// Whether two subject kinds name the same side of the product, whatever case
/// they arrived in.
///
/// Blank is never equal to blank: an absent kind is not evidence that two
/// payloads are about the same thing, and treating it as one puts server plans
/// on the account section.
bool sameSubjectKind(String? left, String? right) {
  final a = left?.trim().toLowerCase() ?? '';
  final b = right?.trim().toLowerCase() ?? '';
  return a.isNotEmpty && a == b;
}

/// Which plan resolved these numbers.
///
/// **Absent means no plan, and no plan is a real state.** An instance with none
/// configured resolves every key to its catalogue default, and a self-hosted
/// instance resolves everything to maximum with no billing service deployed at
/// all. Neither has a plan to name, and inventing a "Free" would put a tier
/// boundary on the screen of somebody nobody is charging.
@freezed
sealed class EntitlementPlanDto with _$EntitlementPlanDto {
  const factory EntitlementPlanDto({
    /// The key. Stable, and the thing to match on. Never rendered.
    @Default('') String name,

    /// What to render. The server never sends this null - a plan an operator
    /// gave no display name reports its own name - so nothing has to choose
    /// between two fields.
    @Default('') String displayName,

    /// The version this subject is actually on, which is not necessarily the
    /// current one.
    int? version,

    /// The plan's newest version, when the catalogue publishes versions.
    int? currentVersion,
  }) = _EntitlementPlanDto;

  const EntitlementPlanDto._();

  factory EntitlementPlanDto.fromJson(Map<String, dynamic> json) =>
      _$EntitlementPlanDtoFromJson(json);

  /// Held on terms the plan has since moved away from.
  ///
  /// The comparison is the contract, and it is the only honest way to tell: an
  /// unpinned subject is resolved through whatever is current and therefore
  /// reports that number, so [version] alone cannot distinguish "kept on older
  /// terms" from "on the newest terms". Both null together on an instance whose
  /// plans are configuration rather than rows, which has never heard of a plan
  /// version - and null is not version zero.
  bool get isGrandfathered =>
      version != null && currentVersion != null && version! < currentVersion!;
}

/// One subject's effective entitlements, as this screen reads them.
@freezed
sealed class EntitlementSnapshotDto with _$EntitlementSnapshotDto {
  const factory EntitlementSnapshotDto({
    @Default(EntitlementSubjectDto()) EntitlementSubjectDto subject,

    /// Null when no plan resolved these numbers. See [EntitlementPlanDto].
    EntitlementPlanDto? plan,

    /// How long this may be held for. Never longer than the server's own cache
    /// backstop, which is what makes a dropped event self-heal: caching past it
    /// keeps a repaired value broken locally for as long as the entry lives.
    @Default(60) int ttlSeconds,

    /// Monotonic per subject. `0` on every instance until Billing owns a
    /// counter; comparing it is still correct and starts working the day it
    /// moves, which is why a late response is discarded against it now rather
    /// than after somebody notices.
    @Default(0) int version,

    /// Ceilings only, never consumption. How many emoji slots a server has and
    /// how many are used are two different payloads with opposite caching
    /// properties, and the usage half is not implemented server-side yet.
    @Default(<String, EntitlementValueDto>{})
    Map<String, EntitlementValueDto> entitlements,
  }) = _EntitlementSnapshotDto;

  factory EntitlementSnapshotDto.fromJson(Map<String, dynamic> json) =>
      _$EntitlementSnapshotDtoFromJson(json);
}
