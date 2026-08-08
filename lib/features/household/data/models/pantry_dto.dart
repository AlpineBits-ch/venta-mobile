import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/format/api_date_time.dart';

part 'pantry_dto.freezed.dart';
part 'pantry_dto.g.dart';

/// Stock in one pantry location (a `Pantry` channel is a fridge, a freezer, a
/// cellar - one channel per place).
///
/// [quantity] is decimal here, unlike a list item's free-text quantity: it's
/// compared against [lowThreshold] to drive the restock loop.
@freezed
sealed class PantryItemDto with _$PantryItemDto {
  @ApiDateTimeConverter()
  const factory PantryItemDto({
    required String id,
    required String channelId,
    required String name,
    @Default(0) double quantity,
    String? unit,

    /// `null` turns restock tracking off for this item specifically.
    double? lowThreshold,
    DateTime? expiresAt,
    @Default(false) bool isLow,

    /// Non-null while this item is sitting on the shopping list. It's the
    /// idempotency guard for the restock loop, not a timestamp anyone needs
    /// to read - released when the quantity climbs back above the threshold
    /// or the list line is bought/cleared.
    DateTime? restockedAt,
    @Default('') String addedByUserId,

    /// The code scanned off the packet.
    ///
    /// Two different things can put a name against it and they are not
    /// interchangeable: this house's own name, which always wins when there is
    /// one, and failing that a suggestion from a shared public product catalog.
    /// Only when both come up empty does a scan ask somebody to type one.
    String? barcode,
  }) = _PantryItemDto;

  factory PantryItemDto.fromJson(Map<String, dynamic> json) =>
      _$PantryItemDtoFromJson(json);
}

/// What a scan did, which the item alone cannot say.
///
/// [created] separates "topped up the jar you already had" from "added a new
/// row".
///
/// [learned] and [catalog] answer different questions and must not be collapsed
/// into one. [learned] means *this house* stated a name, which is now theirs and
/// wins over everything from then on. [catalog] means a public database
/// suggested one and **the house has not agreed to it yet** - so it is shown,
/// it is credited, and correcting it is one tap. The two are mutually exclusive
/// by design: a catalog hit deliberately teaches the house nothing, because a
/// suggestion nobody has confirmed is not the house's word for anything.
@freezed
sealed class ScanResultDto with _$ScanResultDto {
  const factory ScanResultDto({
    required PantryItemDto item,
    @Default(false) bool created,
    @Default(false) bool learned,
    ProductCatalogMatchDto? catalog,
  }) = _ScanResultDto;

  factory ScanResultDto.fromJson(Map<String, dynamic> json) =>
      _$ScanResultDtoFromJson(json);
}

/// A name a shared public product catalog supplied, and who to credit for it.
///
/// The credit is not decoration and not optional. The catalog is built from
/// Open Food Facts, published under the Open Database License; showing one of
/// its names without naming the licence and crediting the source is the breach.
/// That is why the server sends the strings with the name instead of leaving a
/// client to remember them - render [attribution] as it arrives, since it is
/// the wording the licence itself blesses.
///
/// [quantity] is the pack size printed on the packet ("380 g"), **not** how
/// much this scan added. They are two different numbers about the same box, and
/// the server deliberately never writes one into the other - a box of
/// cornflakes is one scan and 380 grams at the same time.
@freezed
sealed class ProductCatalogMatchDto with _$ProductCatalogMatchDto {
  @ApiDateTimeConverter()
  const factory ProductCatalogMatchDto({
    @Default('') String name,

    /// Which language the name actually came from, which is not always the one
    /// asked for: a French-speaking flat scanning a product the catalog only
    /// holds in German gets the German name, and this says so rather than
    /// pretending.
    @Default('') String language,

    /// Free text exactly as the source database holds it, which is not a clean
    /// field: it is sometimes a manufacturer, sometimes a retailer, and
    /// sometimes several comma-joined ("Nutella, Ferrero"). It is shown as it
    /// arrives and **never split, titlecased or otherwise tidied** - every rule
    /// that would tidy one row mangles another, and the string's only job is to
    /// tell two nearly identical names apart.
    String? brand,

    /// The pack size printed on the packaging - 250 and `ml`, not 250 of them.
    ///
    /// Null roughly seven times in eight for groceries, so nothing may depend
    /// on it being there. It is offered as a suggestion for a unit field and is
    /// never written silently: the number a person means when they add a jar is
    /// how many jars, and quietly filling 380 into a stock count is the one
    /// mistake this field is capable of causing.
    double? quantity,
    String? quantityUnit,

    /// The code the catalog holds this product under.
    ///
    /// Search returns it; the scan response now carries it too, since the scan
    /// already knew the code it was asked about. It is what makes a *chosen*
    /// search result usable - adopting one turns a typed name into the scan
    /// path with a real code behind it. Null when a response predates the field
    /// rather than meaning "no code exists", so a caller that needs one checks
    /// before assuming.
    ///
    /// **A search result's barcode is never adopted without somebody tapping
    /// it.** "Oat milk" matches dozens of products; taking the first and writing
    /// its code is a fuzzy match promoted to a fact, and it is indistinguishable
    /// afterwards from a code somebody actually scanned.
    String? barcode,
    @Default('') String source,
    @Default('') String sourceName,
    @Default('') String sourceUrl,
    @Default('') String license,
    @Default('') String licenseUrl,
    @Default('') String attribution,
    DateTime? importedAt,
  }) = _ProductCatalogMatchDto;

  factory ProductCatalogMatchDto.fromJson(Map<String, dynamic> json) =>
      _$ProductCatalogMatchDtoFromJson(json);
}

/// One page of catalog search results, and the credit the whole page owes.
///
/// The licence strings sit here rather than only on each row because that is
/// where the obligation actually lands: ODbL asks for the source named wherever
/// its names are shown, and a list is one showing. [attribution] is the wording
/// the licence itself blesses, printed as it arrives - see [ProductSourceNote].
/// Per-row `sourceName` still varies (Open Food Facts / Beauty / Products / Pet
/// Food) and is not interchangeable with this.
///
/// **An empty [results] means "not in our catalog", never "no such product".**
/// There is no live third-party lookup behind search - only the *scan* path
/// reaches the live source, and then only by barcode. Coverage is honestly
/// uneven: groceries and cosmetics good, cleaning products thin, Swiss retailer
/// own-brands (M-Budget, Prix Garantie, Denner) largely absent from open data.
/// Copy over an empty list that implies the product does not exist is therefore
/// wrong on the facts as well as unhelpful, because adding it by hand is the
/// normal ending and has to read like one.
///
/// [count] is how many matched, not how many came back; [countIsLowerBound]
/// says the server stopped counting, so it renders `500+`. Ordering is stable
/// (by barcode), which is what makes [offset] paging safe to page through
/// without rows shuffling underneath.
@freezed
sealed class ProductCatalogSearchDto with _$ProductCatalogSearchDto {
  const factory ProductCatalogSearchDto({
    /// Echoed back, so a late response can be matched against what is in the
    /// field now rather than assumed to be about it.
    @Default('') String query,
    @Default(<ProductCatalogMatchDto>[]) List<ProductCatalogMatchDto> results,
    @Default(0) int count,
    @Default(false) bool countIsLowerBound,
    @Default(25) int limit,
    @Default(0) int offset,
    @Default('') String attribution,
    @Default('') String license,
    @Default('') String licenseUrl,
  }) = _ProductCatalogSearchDto;

  factory ProductCatalogSearchDto.fromJson(Map<String, dynamic> json) =>
      _$ProductCatalogSearchDtoFromJson(json);
}

/// The shortest query the catalog will look at.
///
/// Below this the server answers an empty result set rather than an error, so
/// firing anyway is not *wrong* - it is just a round trip whose answer is known
/// before it leaves, on a field somebody is still typing into. The client stops
/// short instead.
const int productCatalogMinQueryLength = 3;

extension ProductCatalogSearchX on ProductCatalogSearchDto {
  /// `37`, or `500+` when the server gave up counting.
  ///
  /// Printing the bare number in that case states a total the server explicitly
  /// declined to state, and "500 matches" invites somebody to page to the end
  /// of a list that does not end there.
  String get countLabel => countIsLowerBound ? '$count+' : '$count';

  bool get isEmpty => results.isEmpty;
}

/// What stating a name for a barcode changed.
///
/// [renamedItems] is the part a client cannot work out for itself. Teaching a
/// barcode is guild-scoped, so the jars still showing the catalog's suggestion
/// are corrected with it - possibly in a pantry the caller is not looking at.
/// An empty list is the normal case rather than a failure: it means every item
/// carrying that code already had a name somebody typed, which the server does
/// not overwrite.
@freezed
sealed class TeachBarcodeResultDto with _$TeachBarcodeResultDto {
  const factory TeachBarcodeResultDto({
    required PantryBarcodeDto barcode,
    @Default(false) bool learned,
    @Default(<PantryItemDto>[]) List<PantryItemDto> renamedItems,
  }) = _TeachBarcodeResultDto;

  factory TeachBarcodeResultDto.fromJson(Map<String, dynamic> json) =>
      _$TeachBarcodeResultDtoFromJson(json);
}

/// One barcode this house has learned, for completions.
@freezed
sealed class PantryBarcodeDto with _$PantryBarcodeDto {
  @ApiDateTimeConverter()
  const factory PantryBarcodeDto({
    @Default('') String barcode,
    @Default('') String name,
    String? unit,
    @Default(1) double defaultQuantity,
    double? lowThreshold,
    @Default(0) int timesSeen,
    DateTime? lastUsedAt,
  }) = _PantryBarcodeDto;

  factory PantryBarcodeDto.fromJson(Map<String, dynamic> json) =>
      _$PantryBarcodeDtoFromJson(json);
}

extension PantryItemX on PantryItemDto {
  /// On the shopping list right now, because the pantry put it there.
  bool get isAwaitingRestock => restockedAt != null;

  /// Expiring within [days], or already gone off.
  bool isExpiringWithin(int days, {DateTime? now}) {
    final expiry = expiresAt;
    if (expiry == null) return false;
    final reference = now ?? DateTime.now();
    return expiry.toLocal().isBefore(reference.add(Duration(days: days)));
  }

  bool isExpired({DateTime? now}) =>
      expiresAt != null && expiresAt!.toLocal().isBefore(now ?? DateTime.now());
}

/// Per-channel pantry settings.
///
/// With [restockListChannelId] null the whole restock loop is off, whatever
/// individual item thresholds say - worth saying out loud in the UI, because
/// setting a threshold and seeing nothing happen is otherwise a mystery.
@freezed
sealed class PantryConfigDto with _$PantryConfigDto {
  const factory PantryConfigDto({
    @Default('') String channelId,

    /// Must be a `List` channel in the same guild.
    String? restockListChannelId,

    /// 1-90.
    @Default(3) int expiryWarningDays,
  }) = _PantryConfigDto;

  factory PantryConfigDto.fromJson(Map<String, dynamic> json) =>
      _$PantryConfigDtoFromJson(json);
}
