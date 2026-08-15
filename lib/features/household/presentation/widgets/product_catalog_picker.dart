/// Choosing a product out of the shared public catalog, and offering one
/// inline.
///
/// Both things in this file exist for the same reason, which is the rule
/// `docs/pantry-vision.md` §1 turns on: **a catalog match is an offer, never a
/// fact.** A barcode scanned off a packet identifies one product. A text search
/// - whether somebody typed the words or a model read them off a photograph of
/// a shelf - identifies a list of maybes. "Oat milk" matches dozens. Writing
/// the first one's barcode would take a fuzzy remote match stacked on a guess
/// at a name and turn it into a specific EAN, which afterwards is
/// indistinguishable from a code a person actually scanned and is exactly the
/// hallucinated-barcode failure arriving by a different road.
///
/// So the only way a catalog result ever becomes a fact is that somebody looks
/// at it and taps it. [showProductCatalogPicker] is the deliberate version of
/// that (a person searching), [ProductCatalogSuggestionRow] the passing version
/// (a candidate sitting on a review row, badged, ignorable). Neither writes
/// anything; both hand the chosen match back to their caller and let it decide.
///
/// ## Two obligations that are not polish
///
/// **The credit is not optional.** The catalog is built from Open Data under
/// the Open Database License, which requires the source named wherever one of
/// its names is shown - and a list of thirty of them is very much a showing.
/// The envelope carries the blessed wording, so [ProductSourceNote] prints it
/// as it arrives. Per-row `sourceName` varies (Open Food Facts / Beauty /
/// Products / Pet Food) and is never hardcoded to any one of them.
///
/// **An empty list means "not in our catalog".** There is no live third-party
/// search behind this; only the *scan* path reaches the live source, by
/// barcode. Coverage is honestly uneven - groceries and cosmetics good,
/// cleaning products thin, Swiss retailer own-brands (M-Budget, Prix Garantie,
/// Denner) largely absent from open data. Copy that reads as "no such product"
/// would be both false and discouraging, because typing the name in by hand is
/// the ordinary ending here and has to look like one.
library;

import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/widget_styles.dart';
import '../../../../core/widgets/adaptive_progress_indicator.dart';
import '../../data/household_api_wave2.dart';
import '../../data/models/pantry_dto.dart';
import 'household_widgets.dart';

/// How long a keystroke waits before it costs a request.
///
/// The contract asks for at least 300ms and this sits just above it. The number
/// is a trade between a list that feels dead and a request per letter: at 350ms
/// somebody typing "shampoo" fires roughly once, at the pause after the word,
/// rather than five times on the way through it.
const Duration productCatalogDebounce = Duration(milliseconds: 350);

/// The one call the picker makes, injectable so the sheet can be driven from a
/// test without a network or a registered service locator.
typedef ProductCatalogSearchFn =
    Future<ProductCatalogSearchDto> Function(
      String query, {
      CancelToken? cancelToken,
    });

/// Opens the catalog picker and returns the chosen product, or null if the user
/// backed out.
///
/// Null is the expected answer roughly as often as a match is, and callers must
/// treat it as an ordinary outcome rather than a cancellation to recover from:
/// backing out means "none of these is it", which lands the item on the
/// add-by-hand path that this feature depends on staying load-bearing.
///
/// [initialQuery] prefills the field - the name a person typed, or the one a
/// model read off a photo - so the common case is a glance and a tap with no
/// keyboard at all. [title] overrides the header for callers with more context
/// than "Find a product" (a review row naming the item it is resolving).
Future<ProductCatalogMatchDto?> showProductCatalogPicker(
  BuildContext context, {
  required String initialQuery,
  String? title,
}) => showHouseSheet<ProductCatalogMatchDto>(
  context: context,
  builder: (_) =>
      ProductCatalogPickerSheet(initialQuery: initialQuery, title: title),
);

/// The picker's body. Public only so tests and any future host that is not a
/// bottom sheet can build it directly - [showProductCatalogPicker] is the way
/// to use it.
class ProductCatalogPickerSheet extends StatefulWidget {
  const ProductCatalogPickerSheet({
    super.key,
    required this.initialQuery,
    this.title,
    this.search,
  });

  final String initialQuery;
  final String? title;

  /// Defaults to the real endpoint. The language names come back in is left to
  /// `AcceptLanguageInterceptor`, which knows about the user's language setting
  /// - see [_ProductCatalogPickerSheetState._search].
  final ProductCatalogSearchFn? search;

  @override
  State<ProductCatalogPickerSheet> createState() =>
      _ProductCatalogPickerSheetState();
}

class _ProductCatalogPickerSheetState extends State<ProductCatalogPickerSheet> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.initialQuery,
  );

  Timer? _debounce;

  /// The request currently in the air, cancelled the moment a newer one is
  /// wanted. Without this, two searches race and whichever happens to land last
  /// wins - which is regularly the stale one, since a shorter prefix matches
  /// more rows and takes longer to come back.
  CancelToken? _inFlight;

  /// Rises with every search started. A reply from anything but the newest is
  /// dropped even if cancellation lost the race, because `CancelToken` only
  /// stops a request that has not already been decoded.
  int _generation = 0;

  ProductCatalogSearchDto? _envelope;
  bool _loading = false;
  Object? _error;

  /// Held so the retry button knows what to re-run: [_controller] may have
  /// moved on, and retrying a query the user has since edited would answer a
  /// question nobody is asking any more.
  String _lastAttempt = '';

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onChanged);
    // The prefilled term is the whole point of arriving here with one, so it
    // searches immediately rather than after a debounce of a keystroke that
    // never comes.
    final initial = widget.initialQuery.trim();
    if (initial.length >= productCatalogMinQueryLength) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _run(initial);
      });
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _inFlight?.cancel();
    _controller.dispose();
    super.dispose();
  }

  ProductCatalogSearchFn get _search =>
      widget.search ??
      (query, {CancelToken? cancelToken}) => householdApi.searchProductCatalog(
        query,
        // No `acceptLanguage` here on purpose. **Do not put one back.**
        // `AcceptLanguageInterceptor` now stamps the header from the user's
        // language setting, falling back to the device, and the parameter is an
        // explicit override that beats the interceptor by design. Passing the
        // device locale from here therefore does not "make sure" of anything -
        // it overrides the setting, so somebody who chose German in Settings
        // would keep getting Italian product names on an Italian phone with no
        // way to tell why. The results still say which language they actually
        // came back in, and a mismatch is still shown.
        cancelToken: cancelToken,
      );

  void _onChanged() {
    setState(() {});
    _debounce?.cancel();
    final term = _controller.text.trim();
    if (term.length < productCatalogMinQueryLength) {
      // Below the minimum there is nothing to wait for: drop whatever is in the
      // air and go back to the too-short state rather than leaving a spinner or
      // a list from a longer word standing under a shorter one.
      _inFlight?.cancel();
      _generation++;
      setState(() {
        _loading = false;
        _error = null;
        _envelope = null;
      });
      return;
    }
    _debounce = Timer(productCatalogDebounce, () => _run(term));
  }

  Future<void> _run(String term) async {
    _inFlight?.cancel();
    final token = CancelToken();
    final generation = ++_generation;
    _inFlight = token;
    setState(() {
      _loading = true;
      _error = null;
      _lastAttempt = term;
    });
    try {
      final result = await _search(term, cancelToken: token);
      if (!mounted || generation != _generation) return;
      setState(() {
        _envelope = result;
        _loading = false;
      });
    } on DioException catch (error) {
      // A cancellation is this screen's own doing, not a failure to report -
      // showing it would flash an error every time somebody types quickly.
      if (error.type == DioExceptionType.cancel) return;
      if (!mounted || generation != _generation) return;
      setState(() {
        _error = error;
        _loading = false;
      });
    } catch (error) {
      if (!mounted || generation != _generation) return;
      setState(() {
        _error = error;
        _loading = false;
      });
    }
  }

  void _choose(ProductCatalogMatchDto match) =>
      Navigator.of(context).pop(match);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurface.withValues(alpha: 0.6);
    final term = _controller.text.trim();
    final tooShort = term.length < productCatalogMinQueryLength;
    final envelope = _envelope;
    final attribution = envelope?.attribution.trim() ?? '';

    // The results area keeps one height across every state on purpose. A sheet
    // that grows when results land and shrinks on the next keystroke moves the
    // field out from under the fingers still typing into it.
    final listHeight = (MediaQuery.sizeOf(context).height * 0.45).clamp(
      240.0,
      460.0,
    );

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: AppSpacing.l,
          right: AppSpacing.l,
          top: AppSpacing.l,
          bottom: MediaQuery.viewInsetsOf(context).bottom + AppSpacing.l,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.title ?? 'Find a product',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: AppSpacing.m),
            TextField(
              controller: _controller,
              autofocus: widget.initialQuery.trim().isEmpty,
              textInputAction: TextInputAction.search,
              textCapitalization: TextCapitalization.sentences,
              onSubmitted: (value) {
                _debounce?.cancel();
                final submitted = value.trim();
                if (submitted.length >= productCatalogMinQueryLength) {
                  _run(submitted);
                }
              },
              decoration: InputDecoration(
                hintText: 'Oat milk',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _controller.text.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.close_rounded),
                        tooltip: 'Clear',
                        onPressed: _controller.clear,
                      ),
              ),
            ),
            const SizedBox(height: AppSpacing.s),
            _HeaderLine(
              tooShort: tooShort,
              loading: _loading,
              envelope: envelope,
              muted: muted,
            ),
            const SizedBox(height: AppSpacing.s),
            SizedBox(
              height: listHeight,
              child: _body(tooShort: tooShort, envelope: envelope),
            ),
            if (attribution.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.s),
              ProductSourceNote(attribution: attribution),
            ],
          ],
        ),
      ),
    );
  }

  Widget _body({
    required bool tooShort,
    required ProductCatalogSearchDto? envelope,
  }) {
    if (_error != null) {
      return _PickerError(
        message: householdErrorText(
          _error!,
          'The catalogue could not be reached just then.',
        ),
        onRetry: _lastAttempt.length >= productCatalogMinQueryLength
            ? () => _run(_lastAttempt)
            : null,
      );
    }
    if (tooShort) {
      return const HouseEmptyState(
        icon: Icons.search_rounded,
        title: 'Type a few more letters',
        body:
            'Three characters or more, and the catalogue starts looking. It '
            'searches product names, so the word on the packet works better '
            'than the shelf it lives on.',
      );
    }
    if (envelope == null) {
      return const Center(
        child: AdaptiveProgressIndicator(size: 22, strokeWidth: 2),
      );
    }
    if (envelope.isEmpty) {
      // Wording matters here more than anywhere else on the sheet. This list is
      // our own catalog and nothing else, so "no match" is a statement about
      // our coverage, not about whether the product exists.
      return const HouseEmptyState(
        icon: Icons.inventory_2_outlined,
        title: 'Nothing in the catalogue matches that',
        body:
            'Which does not mean it does not exist. The catalogue is built '
            'from open data and its coverage is patchy - good on groceries and '
            'cosmetics, thin on cleaning products, and it barely knows the '
            'supermarket own-brands at all. Adding it by hand is completely '
            'normal, and once somebody scans it the house remembers it.',
      );
    }
    return ListView.separated(
      padding: EdgeInsets.zero,
      itemCount: envelope.results.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final match = envelope.results[index];
        return _ResultRow(match: match, onTap: () => _choose(match));
      },
    );
  }
}

/// "37 matches", or what is standing in for it while there are none.
class _HeaderLine extends StatelessWidget {
  const _HeaderLine({
    required this.tooShort,
    required this.loading,
    required this.envelope,
    required this.muted,
  });

  final bool tooShort;
  final bool loading;
  final ProductCatalogSearchDto? envelope;
  final Color muted;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final String text;
    if (tooShort) {
      text = 'At least $productCatalogMinQueryLength characters';
    } else if (loading && envelope == null) {
      text = 'Searching…';
    } else if (envelope == null) {
      text = '';
    } else if (envelope!.isEmpty) {
      text = 'No matches';
    } else {
      // countLabel, not count: the server sometimes stops counting and says so,
      // and printing the bare number there states a total it declined to state.
      final label = envelope!.countLabel;
      text = envelope!.count == 1 ? '1 match' : '$label matches';
    }
    return Row(
      children: [
        Expanded(
          child: Text(
            text,
            style: theme.textTheme.labelSmall?.copyWith(color: muted),
          ),
        ),
        if (loading && envelope != null)
          const AdaptiveProgressIndicator(size: 12, strokeWidth: 2),
      ],
    );
  }
}

/// One candidate.
///
/// Everything below the name is there to tell two near-identical rows apart:
/// searching a common grocery returns the same words over and over, and the
/// brand, the pack size and which database it came from are the only things
/// distinguishing them. Laid out as a [Wrap] because household screens are read
/// at 2.35x text scale, where three chips in a `Row` do not fit on any phone.
class _ResultRow extends StatelessWidget {
  const _ResultRow({required this.match, required this.onTap});

  final ProductCatalogMatchDto match;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurface.withValues(alpha: 0.6);
    final brand = match.brand?.trim() ?? '';
    final packSize = productPackSizeLabel(match);
    final sourceName = match.sourceName.trim();

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadii.chip),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.s),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Shown whatever language it came back in. A German name on a
                  // French-speaking flat's shelf is still a name they can read
                  // off the box; no name at all is typing.
                  Text(
                    match.name,
                    style: theme.textTheme.bodyMedium,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (brand.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    // Free text straight from the source, comma-joined and
                    // inconsistent - printed as it arrives, never parsed.
                    Text(
                      brand,
                      style: theme.textTheme.bodySmall?.copyWith(color: muted),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  if (packSize != null || sourceName.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Wrap(
                      spacing: AppSpacing.s,
                      runSpacing: AppSpacing.xs,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        if (packSize != null) HousePill(label: packSize),
                        if (sourceName.isNotEmpty)
                          Text(
                            sourceName,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: muted,
                            ),
                          ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.s),
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Icon(Icons.chevron_right_rounded, size: 20, color: muted),
            ),
          ],
        ),
      ),
    );
  }
}

class _PickerError extends StatelessWidget {
  const _PickerError({required this.message, this.onRetry});

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) => HouseEmptyState(
    icon: Icons.cloud_off_rounded,
    title: 'That search did not get through',
    body: message,
    action: onRetry == null
        ? null
        : OutlinedButton(onPressed: onRetry, child: const Text('Try again')),
  );
}

/// "250 ml", or null when the pack size is unknown - which it is for roughly
/// seven groceries in eight.
///
/// Purely a label. It is the size printed on the packaging, so it belongs next
/// to a name and never in a field that counts stock: a box of cornflakes is one
/// item and 380 grams at the same time, and confusing the two is how somebody
/// ends up with 380 boxes.
String? productPackSizeLabel(ProductCatalogMatchDto match) {
  final size = match.quantity;
  if (size == null) return null;
  final unit = match.quantityUnit?.trim() ?? '';
  final number = formatQuantity(size);
  return unit.isEmpty ? number : '$number $unit';
}

/// A single catalog candidate offered inline, next to something a person is
/// already reviewing.
///
/// This is the shape §1's "candidates, offered - never applied" rule takes on a
/// review row. The name is the catalog's, not the house's, and the row has to
/// read as an *offer* the whole time it is on screen: [SuggestedNameBadge]
/// marks it, the accept is a button somebody presses rather than a default that
/// happens, and doing nothing is a complete and expected answer that leaves the
/// item to be created by name with no barcode against it.
///
/// The reason the badge is not decoration: the two kinds of name in a pantry
/// look identical and are not. One is what the flat calls the thing; the other
/// is what a stranger's database says is printed on the box. Unmarked, a
/// suggestion that is slightly wrong reads as something the house decided, and
/// nobody ever corrects it.
///
/// [onAdopt] gets the tap. It should switch the row onto the scan path with
/// this match's barcode - the one moment a catalog barcode is legitimately
/// written, because a person just looked at it and said yes.
class ProductCatalogSuggestionRow extends StatelessWidget {
  const ProductCatalogSuggestionRow({
    super.key,
    required this.match,
    required this.onAdopt,
    this.onDismiss,
  });

  final ProductCatalogMatchDto match;
  final VoidCallback onAdopt;

  /// Null leaves the offer standing. Ignoring it is already a valid answer, so
  /// a dismiss is a convenience for getting it out of the way rather than the
  /// only way to decline.
  final VoidCallback? onDismiss;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurface.withValues(alpha: 0.6);
    final brand = match.brand?.trim() ?? '';
    final packSize = productPackSizeLabel(match);
    final attribution = match.attribution.trim();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Wrapped, not a Row: at 2.35x text scale the badge and a product name
        // do not share a line on any phone, and the badge is the part that must
        // never be clipped away.
        Wrap(
          spacing: AppSpacing.s,
          runSpacing: AppSpacing.xs,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            const SuggestedNameBadge(),
            if (packSize != null) HousePill(label: packSize),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(match.name, style: theme.textTheme.bodyMedium),
        if (brand.isNotEmpty)
          Text(brand, style: theme.textTheme.bodySmall?.copyWith(color: muted)),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Suggested by a public product database, not by this house. Nothing '
          'has been changed.',
          style: theme.textTheme.labelSmall?.copyWith(
            color: muted,
            height: 1.3,
          ),
        ),
        const SizedBox(height: AppSpacing.s),
        Wrap(
          spacing: AppSpacing.s,
          runSpacing: AppSpacing.xs,
          children: [
            FilledButton.tonal(
              onPressed: onAdopt,
              child: const Text('Use this name'),
            ),
            if (onDismiss != null)
              TextButton(onPressed: onDismiss, child: const Text('No thanks')),
          ],
        ),
        if (attribution.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.s),
          ProductSourceNote(attribution: attribution),
        ],
      ],
    );
  }
}
