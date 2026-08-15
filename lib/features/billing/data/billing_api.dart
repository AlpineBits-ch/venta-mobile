import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';
import 'models/billing_catalogue_dto.dart';
import 'models/subscription_dto.dart';

/// Thrown when the billing service is not part of this instance.
///
/// A self-hosted instance never has one: Billing refuses to start under
/// `LICENSE_MODE=selfhost` and the gateway filters the whole `/api/v1/billing`
/// prefix out, so both routes below answer `404`.
///
/// **This is not an error to show.** The plan surface has to be *absent* on
/// such an instance rather than empty: a blank plan card or a zero is a
/// statement about somebody's account, and "this instance has no billing" is a
/// statement about the instance. The two are different sentences and only one
/// of them is true.
///
/// Named for the deployment rather than for what the reader can do. "Not
/// deployed" is a fact about the server; anything phrased around availability
/// would name the one thing this feature must never have an opinion about.
class BillingNotDeployedException implements Exception {
  const BillingNotDeployedException();

  @override
  String toString() => 'BillingNotDeployedException';
}

/// The two read routes of the billing surface, and deliberately nothing else.
///
/// `billing-checkout-api-contract.md` documents eleven endpoints. Nine of them
/// create a subscription, cancel one, resume one, preview and apply a plan
/// change, attach a card, set a default card, detach a card, and list invoices.
/// **None of them is here, and none of them may be added.** This app displays;
/// it does not sell. The absence is the compliance posture, not an unfinished
/// feature, and the cheapest way to keep a purchase path out of a mobile build
/// is for the client to have no method that could start one.
///
/// The `billing` segment is part of the public path - the gateway strips it
/// before the service sees it - and the base URL is read per call through
/// [ApiClient.url] rather than captured, because this client is pointed at
/// arbitrary instances at runtime.
class BillingApi {
  BillingApi({required this.client});

  final ApiClient client;

  String get _base => client.url('/api/v1/billing');

  /// Every plan and what each includes.
  ///
  /// Throws [BillingNotDeployedException] on a `404`, which is how an instance
  /// with no billing service answers.
  Future<BillingCatalogueDto> getCatalogue() async {
    return _read(() async {
      final response = await client.dio.get<Map<String, dynamic>>(
        '$_base/catalogue',
      );
      return BillingCatalogueDto.fromJson(response.data ?? const {});
    });
  }

  /// What this account pays for, plus what sits on the servers it manages.
  ///
  /// Includes ended subscriptions - see `subscription_dto.dart`.
  Future<List<SubscriptionDto>> listSubscriptions() async {
    return _read(() async {
      final response = await client.dio.get<List<dynamic>>(
        '$_base/subscriptions',
      );
      return (response.data ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(SubscriptionDto.fromJson)
          .toList(growable: false);
    });
  }

  /// Runs [read], converting the one status that means "not on this instance".
  ///
  /// Only `404`. Every other failure is left as the [DioException] it was: a
  /// `500` or a dropped connection is a request that should be retried and
  /// reported, and folding it in here would render a temporary outage as a
  /// permanent absence - which is the same screen, silently telling the user
  /// their instance does not sell anything.
  static Future<T> _read<T>(Future<T> Function() read) async {
    try {
      return await read();
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw const BillingNotDeployedException();
      }
      rethrow;
    }
  }
}
