import 'household_api.dart';
import 'models/payment_handles_dto.dart';

/// How a flatmate actually hands money over, which the ledger itself never
/// does - it records that a payment happened, and this is the part that tells
/// somebody where to send it.
///
/// Its own file rather than more methods on [HouseholdApi] or another block in
/// `household_api_wave2.dart`, because the endpoint behind it is going to grow
/// a second, very different half: sealed per-device payment handles (IBANs)
/// that need client-side crypto. Keeping the phone half here means that lands
/// next to it instead of in the middle of the shopping list.
///
/// Both routes are gated on `GuildFeatures.Ledger` and on membership, and both
/// answer `403` with an empty body when either fails - the same
/// module-is-off rule as every other household endpoint.
extension HouseholdApiPayments on HouseholdApi {
  String get _base => client.url('/api/v1/guild');

  /// Everyone in this household who is showing the caller a phone number, plus
  /// whether the caller is showing one back.
  ///
  /// Also requires a registered `X-Device-Id`, because the sealed half of the
  /// same response is addressed to a device - the header goes on every request
  /// this app makes (`DeviceIdInterceptor`), but a `400` here rather than a
  /// `403` means that is what went missing.
  Future<PaymentHandlesDto> getPaymentHandles(String guildId) async {
    final response = await client.dio.get<Map<String, dynamic>>(
      '$_base/guilds/$guildId/payment-handles',
    );
    return PaymentHandlesDto.fromJson(response.data!);
  }

  /// Turns the caller's own sharing on or off for **this** household only.
  ///
  /// An explicit boolean rather than a toggle, so a retry after a dropped
  /// connection lands where the tap intended instead of undoing it. Returns
  /// the state the server now holds.
  ///
  /// This never touches the number itself. Switching it off leaves the number
  /// on the account, and deleting the number leaves this switch on - the two
  /// live in different services and neither reaches across.
  Future<bool> setPhoneSharing(String guildId, {required bool share}) async {
    final response = await client.dio.put<Map<String, dynamic>>(
      '$_base/guilds/$guildId/payment-handles/phone-sharing',
      data: {'share': share},
    );
    return response.data?['sharingPhoneNumber'] as bool? ?? share;
  }
}
