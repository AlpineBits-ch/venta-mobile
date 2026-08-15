import '../../../core/network/api_client.dart';
import 'models/entitlement_snapshot_dto.dart';

/// `GET /api/v1/entitlements/*` - what a subject actually resolves to.
///
/// Served by the gateway rather than by Billing, and therefore present on every
/// instance including self-hosted ones (where every key resolves to maximum and
/// `upgradesAvailable` is false). That is why it is a separate class from
/// [BillingApi] despite being read by the same screen: one of the two can be
/// absent and the other cannot, and giving them one client would invite the
/// same 404 handling to be applied to both.
///
/// The usage endpoints (`/me/usage`, `/guilds/{id}/usage`) are documented as
/// planned and are not implemented server-side, so nothing here reads a "47 of
/// 50". A ceiling with no count beside it is the honest rendering until they
/// exist.
class EntitlementApi {
  EntitlementApi({required this.client});

  final ApiClient client;

  /// This account's own ceilings, its plan, and whether this instance sells
  /// anything at all.
  Future<EntitlementSnapshotDto> getMine() async {
    final response = await client.dio.get<Map<String, dynamic>>(
      client.url('/api/v1/entitlements/me'),
    );
    return EntitlementSnapshotDto.fromJson(response.data ?? const {});
  }

  /// One server's ceilings.
  ///
  /// Members only; a non-member gets the same `404` as a server that does not
  /// exist. Not called per server on the plan screen - a member of two hundred
  /// servers would pay two hundred round-trips to draw a list - but it is the
  /// call a server's own settings screen would make, and leaving it out would
  /// mean the next caller writes a second entitlement client.
  Future<EntitlementSnapshotDto> getForGuild(String guildId) async {
    final response = await client.dio.get<Map<String, dynamic>>(
      client.url('/api/v1/entitlements/guilds/$guildId'),
    );
    return EntitlementSnapshotDto.fromJson(response.data ?? const {});
  }
}
