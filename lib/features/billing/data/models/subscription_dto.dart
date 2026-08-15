/// `GET /api/v1/billing/subscriptions` - the plans behind this account and the
/// servers it manages.
///
/// The list returns subscriptions the caller **pays for** plus those on servers
/// where they hold Manage Server, and it **includes ended ones**. A subject can
/// legitimately have both an ended subscription and a live one, so anything
/// picking "the" subscription for a subject has to prefer the non-ended one
/// rather than the first - see [pickForSubject].
///
/// **No prices.** `priceMinorUnits` and `currency` are on the wire and are not
/// modelled, for the reason set out in `billing_catalogue_dto.dart`.
library;

import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/format/api_date_time.dart';
import '../../../../core/format/date_time_format.dart';

part 'subscription_dto.freezed.dart';
part 'subscription_dto.g.dart';

/// The four answers a screen can actually branch on.
enum SubscriptionStanding {
  /// The subject has what they paid for.
  live,

  /// A payment is in flight and nothing is decided.
  pending,

  /// Money is owed, or collection has stopped. Also the answer for every
  /// status this build does not recognise.
  attention,

  /// Over, and not coming back under this subscription.
  ended,
}

extension SubscriptionStandingX on SubscriptionStanding {
  String get label => switch (this) {
    SubscriptionStanding.live => 'Active',
    SubscriptionStanding.pending => 'Starting',
    SubscriptionStanding.attention => 'Needs attention',
    SubscriptionStanding.ended => 'Ended',
  };
}

/// Which of the four a raw status is.
///
/// `status` is Stripe's own vocabulary, passed through by the server unchanged
/// rather than remapped, and Stripe adds to it. The default arm is the
/// load-bearing one: an unrecognised status is `attention`, never `live` and
/// never a crash. Guessing `live` would tell somebody they have a tier on the
/// strength of a string nobody in this build has ever seen.
SubscriptionStanding subscriptionStanding(String status) => switch (status) {
  'active' || 'trialing' => SubscriptionStanding.live,
  'incomplete' => SubscriptionStanding.pending,
  'incomplete_expired' || 'canceled' => SubscriptionStanding.ended,
  _ => SubscriptionStanding.attention,
};

/// One recurring relationship, as its customer reads it.
@freezed
sealed class SubscriptionDto with _$SubscriptionDto {
  @ApiDateTimeConverter()
  const factory SubscriptionDto({
    @Default('') String id,

    /// Lowercase `guild` or `user`.
    @Default('') String subjectKind,
    @Default('') String subjectId,

    /// The key, for matching against the catalogue. [planDisplayName] is what
    /// gets rendered.
    @Default('') String planName,
    @Default('') String planDisplayName,
    @Default(0) int versionNumber,

    /// Stripe's own vocabulary. Classify with [subscriptionStanding] rather
    /// than switching on it.
    @Default('') String status,
    DateTime? currentPeriodEnd,

    /// True after a cancellation. Nothing has ended yet, which is why the copy
    /// has to say when access actually stops.
    @Default(false) bool cancelAtPeriodEnd,

    /// Non-null means a payment failed and the tier is being held until this
    /// moment. The single most important field here for somebody whose card
    /// expired, and it needs a plain sentence with a date, not a status chip.
    DateTime? gracePeriodEndsAt,

    /// How often the plan bills.
    ///
    /// **Nullable, and absent entirely from servers that predate it.** The
    /// field was added after the first clients were written, and an older
    /// service during a rolling deploy is a real case rather than a
    /// hypothetical one. It is also genuinely null in one live case: the plan
    /// version behind the subscription could not be resolved. Both fall back
    /// through [renewalLine] rather than rendering a period nobody sent.
    String? interval,

    /// False means the caller manages the server but somebody else's card is
    /// behind it. On this client that changes nothing anybody can do - there is
    /// nothing here to do - and it is read so the copy does not imply the
    /// reader is the one paying.
    @Default(false) bool isPayer,
  }) = _SubscriptionDto;

  const SubscriptionDto._();

  factory SubscriptionDto.fromJson(Map<String, dynamic> json) =>
      _$SubscriptionDtoFromJson(json);

  SubscriptionStanding get standing => subscriptionStanding(status);

  bool get hasEnded => standing == SubscriptionStanding.ended;

  /// The one line under the plan name about when this next moves.
  ///
  /// Three renderings and a null, in order of how much the payload actually
  /// said:
  ///
  /// 1. Cancelled: when access stops, which is the only thing that matters to
  ///    somebody who just cancelled and is the sentence a bare "Cancelled"
  ///    chip fails to give them.
  /// 2. [interval] present: the cadence, which is the whole reason the field
  ///    was added.
  /// 3. [interval] null or absent: the renewal date on its own. This is the
  ///    documented fallback and it conveys the cadence indirectly rather than
  ///    inventing one - "per null" and "per month" are equally wrong when the
  ///    server did not say.
  /// 4. Neither: null, and the caller renders no line at all.
  String? get renewalLine {
    final endsAt = currentPeriodEnd;

    if (cancelAtPeriodEnd) {
      return endsAt == null
          ? 'Ends at the end of the current period'
          : 'Ends ${formatShortDateTime(endsAt)}';
    }

    final cadence = switch (interval) {
      'month' => 'Renews monthly',
      'year' => 'Renews yearly',
      'week' => 'Renews weekly',
      'day' => 'Renews daily',
      // A cadence this build has no word for is still a cadence. Rendering the
      // server's own token beats dropping the line, and beats guessing.
      final String other when other.trim().isNotEmpty =>
        'Renews every ${other.trim()}',
      _ => null,
    };

    if (cadence != null) {
      return endsAt == null
          ? cadence
          : '$cadence, next on ${formatShortDateTime(endsAt)}';
    }

    return endsAt == null ? null : 'Renews ${formatShortDateTime(endsAt)}';
  }

  /// The sentence a failed payment is owed. Null when nothing has failed.
  String? get gracePeriodLine {
    final until = gracePeriodEndsAt;
    if (until == null) return null;
    return 'A payment did not go through. This plan is held until '
        '${formatShortDateTime(until)}.';
  }
}

/// The subscription that describes a subject right now, or null if none does.
///
/// Prefers a live one over an ended one, because the list carries both and the
/// first in the list is not necessarily the current one. Among several live
/// ones - which the server's unique index makes near-impossible - the last
/// wins, on the grounds that it is the most recently created.
SubscriptionDto? pickForSubject(
  Iterable<SubscriptionDto> subscriptions,
  String kind,
  String id,
) {
  SubscriptionDto? ended;
  SubscriptionDto? current;

  for (final subscription in subscriptions) {
    if (subscription.subjectId != id) continue;
    if (subscription.subjectKind.toLowerCase() != kind.toLowerCase()) continue;
    if (subscription.hasEnded) {
      ended ??= subscription;
    } else {
      current = subscription;
    }
  }

  return current ?? ended;
}
