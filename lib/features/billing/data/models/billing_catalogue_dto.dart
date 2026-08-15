/// `GET /api/v1/billing/catalogue` - which plans exist and what each includes.
///
/// **No prices, anywhere in this file.** The wire carries `priceMinorUnits` and
/// a `currency` on every plan and they are deliberately not modelled: this
/// client cannot sell anything, and a price with no way to act on it is the
/// precise shape of the thing Apple's anti-steering rules are about. What a
/// plan *includes* is the payload this screen exists for, and it is the half
/// that answers the question a person actually has.
///
/// `purchasable` and `enabled` are not modelled either, and the reason is one
/// step further on than "there is no buy button to gate". They are the wire's
/// answer to *could this be obtained*, and nothing on this platform may turn on
/// that - not a control, not a marker, not the presence of a section. This file
/// describes what exists. Whether any of it is attainable is not a question
/// this client asks or answers.
///
/// `description` is not modelled, and that omission covers a different risk: it
/// is free text written by whoever operates the instance, so a plan could
/// arrive carrying a sentence inviting the reader to go and buy it. A client
/// that renders operator prose onto a plan list has no control over what that
/// list says, and no test can guard copy that arrives at runtime. Plan names
/// are short labels and stay; sentences do not.
library;

import 'package:freezed_annotation/freezed_annotation.dart';

import 'entitlement_value.dart';

part 'billing_catalogue_dto.freezed.dart';
part 'billing_catalogue_dto.g.dart';

/// One plan, and what it resolves to.
@freezed
sealed class BillingPlanDto with _$BillingPlanDto {
  const factory BillingPlanDto({
    /// The key. Stable, and the thing to match a subscription or a snapshot's
    /// plan against. Never rendered.
    @Default('') String name,
    @Default('') String displayName,
    @Default(0) int versionNumber,

    /// Lowercase `guild` or `user`. `free`/`plus`/`pro` are server plans;
    /// `free_user`/`venta_plus` are account plans, and the two are never listed
    /// together.
    @Default('') String subjectKind,

    /// Byte-identical in shape to the entitlement snapshot's own
    /// `entitlements`, and typed as the same value so one renderer serves both.
    @Default(<String, EntitlementValueDto>{})
    Map<String, EntitlementValueDto> entitlements,
  }) = _BillingPlanDto;

  factory BillingPlanDto.fromJson(Map<String, dynamic> json) =>
      _$BillingPlanDtoFromJson(json);
}

/// The catalogue envelope.
@freezed
sealed class BillingCatalogueDto with _$BillingCatalogueDto {
  const factory BillingCatalogueDto({
    /// In the order the server sent them, which is the only order this client
    /// has and the only one it uses.
    ///
    /// Deliberately not re-sorted, and deliberately not sorted *by* anything
    /// here. The server happens to order by price; with no prices rendered and
    /// every row drawn identically, that is a stable list rather than a
    /// progression. Re-ordering it to put anything at the top or the bottom is
    /// how a list becomes a ladder.
    @Default(<BillingPlanDto>[]) List<BillingPlanDto> plans,
  }) = _BillingCatalogueDto;

  factory BillingCatalogueDto.fromJson(Map<String, dynamic> json) =>
      _$BillingCatalogueDtoFromJson(json);
}
