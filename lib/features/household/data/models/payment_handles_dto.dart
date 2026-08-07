import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/format/api_date_time.dart';

part 'payment_handles_dto.freezed.dart';
part 'payment_handles_dto.g.dart';

/// `GET /api/v1/guild/guilds/{guildId}/payment-handles`, of which this client
/// reads exactly one half.
///
/// The response also carries a `members` array of **sealed** payment handles -
/// IBANs and the like, encrypted to each reader's device and accompanied by a
/// `wrappedKey`, a `nonce` and a roster version. Opening one needs
/// device-scoped crypto this app does not have yet, and a half-implemented
/// attempt at it would be worse than none: a handle that fails to decrypt and
/// renders as a blank line is indistinguishable on screen from a flatmate who
/// never entered an IBAN.
///
/// So `members` is not modelled. `json_serializable` ignores keys it has no
/// field for, which means the seam is genuinely clean - when the crypto lands,
/// a `members` field and a `SealedPaymentHandleDto` are added here and nothing
/// above this file has to move. The one thing not to do is model it now and
/// leave it unused, because then the first person to touch it inherits a
/// half-built thing with no tests.
///
/// The phone half needs no crypto at all: the numbers arrive as plain text,
/// because that is how they are stored.
@freezed
sealed class PaymentHandlesDto with _$PaymentHandlesDto {
  const factory PaymentHandlesDto({
    /// Whether **the caller** is sharing their own number with this household.
    ///
    /// Read from the `SharePhoneForPayments` flag on the caller's membership
    /// row, not from whether a number exists - so this can still be `true`
    /// for somebody whose account has no number at all, in which case they
    /// appear in nobody's [phoneNumbers] and adding a number republishes it
    /// here with no further action.
    ///
    /// That combination is now rare rather than routine: removing a number
    /// clears this flag in every household, so only accounts that removed
    /// theirs before Identity started publishing the revocation are still in
    /// it. The server stays the authority either way. See `PhoneSharingCard`.
    @Default(false) bool sharingPhoneNumber,

    /// One entry per member who has both opted in *and* has a number.
    ///
    /// A member who opted out and a member with no number are field-for-field
    /// identical on the wire - both are simply absent - and the server has a
    /// test asserting exactly that. Nothing in this app may render a sentence
    /// that distinguishes them, because every available phrasing ("Anna hasn't
    /// shared her number") asserts that Anna has one.
    @Default(<SharedPhoneNumberDto>[]) List<SharedPhoneNumberDto> phoneNumbers,
  }) = _PaymentHandlesDto;

  factory PaymentHandlesDto.fromJson(Map<String, dynamic> json) =>
      _$PaymentHandlesDtoFromJson(json);
}

@freezed
sealed class SharedPhoneNumberDto with _$SharedPhoneNumberDto {
  @ApiDateTimeConverter()
  const factory SharedPhoneNumberDto({
    required String userId,

    /// E.164, normalised by Identity on write. Plain text, readable by the
    /// server, and checked by nothing.
    required String phoneNumber,

    /// The account's last-updated stamp rather than a phone-specific one, so
    /// it moves when anything about the account moves. Not shown as "number
    /// last changed", which it isn't.
    DateTime? updatedAt,
  }) = _SharedPhoneNumberDto;

  factory SharedPhoneNumberDto.fromJson(Map<String, dynamic> json) =>
      _$SharedPhoneNumberDtoFromJson(json);
}

extension PaymentHandlesX on PaymentHandlesDto {
  /// The number [userId] is showing this household, or null - where null is
  /// "nothing to show", and deliberately not "they haven't shared one".
  String? phoneNumberFor(String userId) => phoneNumbers
      .where((entry) => entry.userId == userId)
      .firstOrNull
      ?.phoneNumber;
}
