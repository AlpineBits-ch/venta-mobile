/// Filling or emptying a cupboard from a photograph of it.
///
/// The barcode scanner next door is the fast path for things that carry a code
/// and are held one at a time. This is the other half: a shelf of loose jars, a
/// vegetable drawer, a bag already unpacked onto the counter - things nobody is
/// going to scan one by one. One photograph, a list, and a person checking it
/// against the shelf in front of them.
///
/// ## Review is the feature, not the model
///
/// Everything above [_analyse] is a guess made by a third party from a picture,
/// and everything below [_apply] is a shared cupboard several people rely on.
/// The review stage is the whole of what sits between them, so it is written to
/// be *checked* rather than skimmed:
///
/// * every row is badged [SuggestedNameBadge], exactly as a catalog-suggested
///   name is. An AI guess gets no more authority than a stranger's database;
/// * every count lands on the same `- N +` stepper the scanner uses, because
///   the prompt counts the front row only and the person holding the phone is
///   the only one who can see behind it;
/// * a row that would **lower** stock while stocking up says so in as many
///   words and puts "Add instead" one tap away. Six tins with three behind
///   photographs as three, and a silent `set` would remove three of somebody
///   else's;
/// * `unreadable` is printed plainly. A list of six confident rows that quietly
///   omits "and four I could not read" is a list people stop checking, and
///   after that the feature is writing into a shared pantry unsupervised.
///
/// ## Why the catalog is picked from and never taken from
///
/// Rung 3 fills rows in before anybody sees them: the catalog is searched for
/// every row that would otherwise create a brand new pantry item, and a second
/// model call picks the best candidate for each of them or abstains. What that
/// call is never allowed to do is take `results[0]`. Searching "oat milk"
/// returns dozens of products, and the first of them is a fuzzy remote match
/// stacked on a model's guess at a name - writing its EAN out of the other end
/// is the hallucinated-barcode failure the whole schema was shaped to prevent,
/// arriving by a different road.
///
/// Two things keep that difference real. The matcher answers with a *position
/// in the list it was shown* and has no field to put a code in, so the barcode
/// on an adopted row is always looked up from a row our own search returned -
/// `catalog_matcher.dart` owns that guarantee. And a pre-filled row is an
/// offer, not a decision: it is badged like any other suggestion, it says what
/// the photo called it before the swap, and it carries one control to keep the
/// catalog's name and one to go back to the model's. Nothing is written either
/// way until somebody confirms the plan.
///
/// The step is optional in the strongest sense. An abstention, a search that
/// failed, a match call that was rate-limited, cancelled or never configured -
/// all of them leave the row exactly as it arrived before any of this existed,
/// with "Find in the catalogue" one tap away. Losing a photo pass somebody paid
/// for because an enrichment did not come back would be absurd. See
/// `docs/pantry-vision.md` §1, "Rung 3: the model picks, but it can only pick".
///
/// ## Waiting, and stopping waiting
///
/// A read is 5-15 seconds per photo and there can be several, so this screen
/// borrows the scanner's discipline wholesale: one [_StatusStrip] that is
/// always on screen and always in exactly one of four states, a bounded
/// deadline per photo, a real cancel once the wait has gone on long enough to
/// deserve one, and failures that name what actually happened rather than
/// fading. A rejected key and a rate limit need completely different things
/// from the user, and "something went wrong" tells them neither.
///
/// ## Both directions
///
/// [PantryScanMode] flips which way the photo is read, exactly as it does for
/// the scanner, and nothing else changes: stocking up, the photo is what is on
/// the shelf; using up, it is what went in the bin. The plan layer takes it
/// from there.
library;

import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/ai/ai_key_store.dart';
import '../../../../core/ai/ai_provider.dart';
import '../../../../core/ai/catalog_matcher.dart';
import '../../../../core/ai/pantry_vision_models.dart';
import '../../../../core/ai/vision_client.dart';
import '../../../../core/ai/vision_image_prep.dart';
import '../../../../core/di/injector.dart';
import '../../../../core/locale/app_language.dart';
import '../../../../core/locale/locale_cubit.dart';
import '../../../../core/routing/route_paths.dart';
import '../../../../core/theme/widget_styles.dart';
import '../../../settings/presentation/screens/ai_settings_screen.dart';
import '../../data/household_api_wave2.dart';
import '../../data/models/pantry_dto.dart';
import '../../data/pantry_vision_plan.dart';
import '../widgets/household_widgets.dart';
import '../widgets/product_catalog_picker.dart';
import 'pantry_scanner_screen.dart';

/// Which of the three things this screen is doing.
///
/// Deliberately separate from [_Phase], which is about whether a request is in
/// flight. The two are orthogonal - a write can be running during [review] and
/// a read during [capture] - and folding them into one enum is how a screen
/// ends up with a "working" state that has no idea what it is working on.
enum _Stage {
  /// Photographing compartments. Nothing has left the device yet.
  capture,

  /// The plan is on screen and nothing has been written.
  review,

  /// The writes have been attempted and every row has an answer.
  applied,
}

/// What the screen is doing, in the terms the person standing at the cupboard
/// needs to hear it. The scanner's four states, for the same reasons.
enum _Phase {
  /// Nothing in flight.
  idle,

  /// A read or a write is out. **Wait.**
  working,

  /// The last thing worked.
  done,

  /// The last thing did not, and this does not clear itself.
  failed,
}

/// The single answer to "what is happening" - one of these is on screen at all
/// times.
///
/// Immutable and replaced wholesale rather than a handful of independent flags,
/// because the states are genuinely exclusive: a `bool busy` beside a
/// `String? error` can hold "working" and "failed" at once and renders whichever
/// one the layout reaches first.
class _Status {
  const _Status.idle([this.message])
    : phase = _Phase.idle,
      detail = null,
      failure = null,
      canRetry = false;

  const _Status.working(this.message)
    : phase = _Phase.working,
      detail = null,
      failure = null,
      canRetry = false;

  const _Status.done(this.message)
    : phase = _Phase.done,
      detail = null,
      failure = null,
      canRetry = false;

  /// [failure] is what turns a failure into a *specific* offer: no key routes
  /// to settings, a rejected key says the key was rejected, and neither of
  /// those is worth a "Try again" that is certain to fail the same way.
  const _Status.failed(
    this.message, {
    this.detail,
    this.failure,
    this.canRetry = false,
  }) : phase = _Phase.failed;

  final _Phase phase;
  final String? message;

  /// The provider's own words, when it gave any. Under the headline, never
  /// instead of it - ours would be a guess and theirs is the thing worth
  /// pasting into a bug report.
  final String? detail;

  final AiFailureKind? failure;
  final bool canRetry;
}

/// One photograph, already prepared for sending.
///
/// Preparation happens at capture rather than at analyse, which is not the
/// obvious order. Three reasons, and the third is the one that matters:
/// spreading the decode-and-downscale cost over the seconds between shots keeps
/// it off the moment somebody is waiting; the prepared bytes are a 1568px JPEG
/// that makes a cheap thumbnail, where the raw 12-megapixel original does not;
/// and EXIF - GPS coordinates, timestamp, camera serial - is stripped here, so
/// the only copy of the photograph this screen ever holds is the one already
/// safe to send.
class _Shot {
  _Shot({required this.id, required this.image});

  /// Stable across removals, so the strip's widget keys do not shuffle when a
  /// photo in the middle is dropped.
  final int id;

  final VisionImage image;
}

/// Everything rung 3 produced for one plan, as one value.
///
/// Returned rather than written into state directly so the whole enrichment
/// lands in a single `setState` alongside the plan it belongs to. A review
/// sheet that rendered between the plan arriving and its matches arriving would
/// show a row as "pick one" and then swap a name in under somebody already
/// reading it, which is the one thing a screen built to be *checked* must not
/// do.
class _CatalogEnrichment {
  const _CatalogEnrichment({
    required this.plan,
    required this.adopted,
    required this.matched,
    required this.attribution,
  });

  /// The pass where nothing was matched: no key, no candidates, no network, or
  /// somebody stopped waiting. Every row falls through to the manual picker,
  /// which is exactly what this screen offered before rung 3 existed.
  const _CatalogEnrichment.none(this.plan)
    : adopted = const {},
      matched = const {},
      attribution = null;

  final PantryVisionPlan plan;
  final Map<int, ProductCatalogMatchDto> adopted;
  final Map<int, PantryVisionCatalogMatch> matched;
  final String? attribution;
}

class PantryVisionScreen extends StatefulWidget {
  const PantryVisionScreen({
    super.key,
    required this.channelId,
    required this.channelName,
    required this.guildId,
    this.mode = PantryScanMode.stockUp,
  });

  final String channelId;

  /// `#fridge`, for the line of context every stage carries.
  final String channelName;

  /// Learned barcodes are taught to the *house*, not to one cupboard - a code
  /// means the same product in the freezer as in the cellar - so the top rung
  /// of the resolution ladder is guild-scoped and this screen needs the guild
  /// to reach it.
  final String guildId;

  final PantryScanMode mode;

  @override
  State<PantryVisionScreen> createState() => _PantryVisionScreenState();
}

class _PantryVisionScreenState extends State<PantryVisionScreen> {
  final _keys = getIt<AiKeyStore>();
  final _client = getIt<PantryVisionClient>();
  final _picker = ImagePicker();

  /// One photo's whole read, the client's own 30s deadline included.
  ///
  /// Slightly longer than the client's, on purpose: this is the belt to its
  /// braces, and setting it shorter would mean this screen reporting a timeout
  /// while the client was still perfectly well able to answer.
  static const _photoDeadline = Duration(seconds: 35);

  /// The pantry read that follows a successful vision read. Matches the
  /// scanner's `_scanDeadline` - it is the same class of call.
  static const _fetchDeadline = Duration(seconds: 18);

  /// When a wait stops being "a moment" and starts owing an explanation and an
  /// exit. Longer than the scanner's four seconds because a vision read is
  /// *expected* to take five to fifteen, and a "still going" line that fires on
  /// every single healthy read is a line nobody reads.
  static const _slowAfter = Duration(seconds: 7);

  /// How many catalog searches rung 3 keeps in the air at once.
  ///
  /// A cupboard can easily produce twenty unresolved rows, and one
  /// `Future.wait` over twenty is twenty simultaneous requests from a phone to
  /// one endpoint - which is how an optional enrichment gets a household rate
  /// limited out of the search that the *manual* picker depends on. One at a
  /// time is the other extreme and turns a step nobody asked for into twenty
  /// round trips of waiting. Four keeps the tail short while behaving like a
  /// client rather than a load test.
  static const _catalogSearchConcurrency = 4;

  final _shots = <_Shot>[];
  var _nextShotId = 0;

  AiProviderConfig? _config;

  _Stage _stage = _Stage.capture;
  _Status _status = const _Status.idle();

  /// Flips [_slow] once a wait has gone on long enough to deserve saying so.
  Timer? _slowTimer;
  bool _slow = false;

  /// Clears a success back to idle. Only ever set for [_Phase.done] - a failure
  /// that times itself out is a failure nobody sees.
  Timer? _clearTimer;

  /// The live read, so the deadline and the person both have something to
  /// actually cancel rather than merely stop looking at.
  CancelToken? _inFlight;

  /// Which read pass is current.
  ///
  /// [_inFlight] answers "is this request still wanted", which is the right
  /// question up to the point the photos have been read. After that it stops
  /// being enough: the catalog step retires the read's token for one of its
  /// own, and cancelling *that* must still land on the review sheet rather than
  /// throw away a read somebody paid for - so "was I cancelled" and "has the
  /// screen moved on" have to be two different questions with two different
  /// answers.
  int _pass = 0;

  PantryVisionPlan? _plan;

  /// What the pantry held when the plan was built, kept so an edit in review
  /// can be re-run through the same ladder rather than a second copy of it. See
  /// [_resolve].
  List<PantryItemDto> _pantry = const [];
  List<PantryBarcodeDto> _learned = const [];

  /// Rows where somebody chose a catalog product, by row index. Two jobs: the
  /// credit its licence requires, and remembering that the barcode on that row
  /// was deliberately adopted rather than derived - so a later rename does not
  /// throw it away.
  final _adopted = <int, ProductCatalogMatchDto>{};

  /// Rows the matcher adopted a catalog product onto and **nobody has answered
  /// for yet**, by row index.
  ///
  /// A strict subset of [_adopted], and the distinction is the whole of what
  /// makes a pre-filled row an offer rather than a decision: while a row is in
  /// here it shows what the photo originally said and the two ways to settle
  /// it. A row leaves the moment a person acts on it - keeping the name,
  /// dropping back to the model's, typing their own, or picking a different
  /// product out of the catalogue - because after any of those the row is
  /// something somebody chose and there is nothing left to offer.
  final _matched = <int, PantryVisionCatalogMatch>{};

  /// The credit the catalog searches came back asking for.
  ///
  /// Only a fallback for the per-row [ProductCatalogMatchDto.attribution], which
  /// is what [_buildReview] prints. Kept because the obligation is on the
  /// *envelope* - a row that arrived with an empty attribution field is still a
  /// name out of the same database, and the licence does not care which field
  /// carried the sentence.
  String? _catalogAttribution;

  /// Rows somebody typed a name onto. Those stop being proposals, so they lose
  /// the badge; everything else keeps it.
  final _named = <int>{};

  List<PantryVisionOutcome>? _outcomes;
  bool _applying = false;

  PantryVisionDirection get _direction => widget.mode.isStockUp
      ? PantryVisionDirection.stockUp
      : PantryVisionDirection.useUp;

  bool get _busy => _status.phase == _Phase.working;

  @override
  void initState() {
    super.initState();
    unawaited(_loadConfig());
  }

  @override
  void dispose() {
    _slowTimer?.cancel();
    _clearTimer?.cancel();
    // The photograph is somebody's kitchen and the read is somebody's money.
    // Leaving either running behind a screen that has gone is not a saving.
    _inFlight?.cancel('screen closed');
    super.dispose();
  }

  Future<void> _loadConfig() async {
    final config = await _keys.readConfig();
    if (mounted) setState(() => _config = config);
  }

  /// Opens AI settings and re-reads the configuration on the way back.
  ///
  /// Every route to here exists because something was missing, so coming back
  /// to the same "no provider" line somebody just fixed is the one outcome
  /// worth spending a state read to avoid.
  Future<void> _openSettings() async {
    await context.push(RoutePaths.aiSettings);
    if (!mounted) return;
    await _loadConfig();
    if (mounted && _status.failure == AiFailureKind.notConfigured) {
      _setStatus(const _Status.idle('Nothing has been sent yet'));
    }
  }

  /// Every status change goes through here so the auto-clear timer can never
  /// outlive the thing it was started for - a success timer still ticking when
  /// a failure lands would wipe the failure two seconds later.
  void _setStatus(_Status status) {
    _clearTimer?.cancel();
    _slowTimer?.cancel();
    if (!mounted) return;
    setState(() {
      _status = status;
      _slow = false;
    });

    switch (status.phase) {
      case _Phase.done:
        _clearTimer = Timer(const Duration(milliseconds: 2400), () {
          if (mounted && identical(_status, status)) {
            setState(() => _status = _Status.idle(_idleMessage));
          }
        });
      case _Phase.working:
        _slowTimer = Timer(_slowAfter, () {
          if (mounted && _status.phase == _Phase.working) {
            setState(() => _slow = true);
          }
        });
      case _Phase.idle:
      case _Phase.failed:
        break;
    }
  }

  /// What "nothing is happening" means at this point in the flow.
  ///
  /// Worth wording per stage rather than saying "Ready" three times: on the
  /// capture stage the useful fact is that no photo has left the device, and in
  /// review it is that nothing has been written. Both are the promises this
  /// feature is built on, and a resting state is a free place to keep saying
  /// them.
  String get _idleMessage => switch (_stage) {
    _Stage.capture => 'Nothing has been sent yet',
    _Stage.review => 'Nothing has been written yet',
    _Stage.applied => 'Finished',
  };

  // ------------------------------------------------------------------ capture

  /// Consent, then the picker, then preparation - in that order and no other.
  ///
  /// The consent question is "may a photograph of your kitchen be sent to a
  /// named third party", and asking it *after* somebody has taken the photo is
  /// asking at the exact moment it is hardest to say no. It is also why a
  /// missing provider is caught here rather than at [_analyse]: taking four
  /// photos and then being told there is no key is four photos wasted.
  Future<void> _addPhoto(ImageSource source) async {
    if (_busy) return;

    final provider = _config?.provider;
    if (provider == null) {
      _setStatus(
        _Status.failed(
          const AiFailure(
            AiFailureKind.notConfigured,
          ).message(AiProvider.anthropic),
          detail:
              'Photos are read by an AI provider you choose and pay for. Set '
              'one up and come back.',
          failure: AiFailureKind.notConfigured,
        ),
      );
      return;
    }

    final consented = await ensureVisionConsent(context, provider, _keys);
    if (!consented || !mounted) return;

    XFile? file;
    try {
      file = await _picker.pickImage(source: source);
    } catch (error) {
      // A picker that threw is almost always a permission the system refused,
      // and swallowing it leaves a button that visibly does nothing.
      if (mounted) {
        _setStatus(
          _Status.failed(
            source == ImageSource.camera
                ? 'The camera could not be opened.'
                : 'That photo could not be opened.',
            detail: '$error',
          ),
        );
      }
      return;
    }
    if (file == null || !mounted) return;

    _setStatus(const _Status.working('Getting the photo ready…'));
    try {
      final bytes = await file.readAsBytes();
      // Off-thread: decoding and downscaling a 12-megapixel photo on the UI
      // isolate stalls it long enough to look like the app has hung, at exactly
      // the moment somebody is waiting to see whether the shot was any good.
      final image = await prepareVisionImageOffThread(bytes);
      if (!mounted) return;
      setState(() => _shots.add(_Shot(id: _nextShotId++, image: image)));
      _setStatus(_Status.idle(_idleMessage));
    } catch (error) {
      if (mounted) {
        _setStatus(
          _Status.failed('That photo could not be read.', detail: '$error'),
        );
      }
    }
  }

  void _removeShot(_Shot shot) {
    setState(() => _shots.remove(shot));
    // Dropping the last photo unwinds any failure that was about reading them.
    if (_shots.isEmpty && _status.phase == _Phase.failed) {
      _setStatus(_Status.idle(_idleMessage));
    }
  }

  // ------------------------------------------------------------------- read

  /// Reads every photo, folds the answers together, and reconciles them against
  /// what the pantry actually holds.
  ///
  /// **One request per photo rather than one request carrying all of them.**
  /// The client would take a list, and the saving would be one system prompt
  /// per photo - about 0.6k tokens against roughly 1.6k for the image, so a
  /// fifth of the bill at most. What it buys is worth more than that: the
  /// status strip can count the photos off as they land instead of showing one
  /// undifferentiated forty-second wait, and [PantryVisionResult.merge] gets
  /// per-photo answers to fold, which is what makes "count the front row only"
  /// add up across two photos of one wide cupboard rather than being averaged
  /// into one guess.
  ///
  /// **A photo that fails takes the whole pass with it.** Keeping the ones that
  /// worked would produce a review sheet that looks exactly like a complete one
  /// while silently missing a shelf, and nobody can tell which shelf from the
  /// list. The retry pays for the earlier photos a second time, which is the
  /// cheaper of the two mistakes - nothing has been written, so the only thing
  /// actually lost is a few cents and a few seconds.
  ///
  /// **The catalog step at the end is the exact opposite.** Once the plan
  /// exists the pass is no longer losable: [_matchCatalogue] cannot throw,
  /// cannot fail the pass, and cannot be cancelled into losing it. Everything
  /// after the plan is built is refinement of an answer that is already good
  /// enough to review.
  Future<void> _analyse() async {
    if (_busy || _shots.isEmpty) return;

    final provider = _config?.provider;
    if (provider == null) {
      _setStatus(
        _Status.failed(
          const AiFailure(
            AiFailureKind.notConfigured,
          ).message(AiProvider.anthropic),
          failure: AiFailureKind.notConfigured,
        ),
      );
      return;
    }

    // Read once, at the top, and carried through the whole pass by hand. Two
    // reasons, and neither is style: the reads and the catalog searches are a
    // long chain of awaits and `context` is not safe to touch across them, and
    // the model's language and the catalog's have to be the *same* language or
    // every match abstains - which is impossible to guarantee if two places
    // resolve it independently at two different moments. See [AppLanguage].
    final language = context.read<LocaleCubit>().effective;

    final pass = ++_pass;
    final token = CancelToken();
    _inFlight = token;
    CancelToken? enrichment;
    final results = <PantryVisionResult>[];

    try {
      for (var i = 0; i < _shots.length; i++) {
        if (!mounted || token.isCancelled) return;
        _setStatus(
          _Status.working(
            _shots.length == 1
                ? 'Reading the photo…'
                : 'Reading photo ${i + 1} of ${_shots.length}…',
          ),
        );
        results.add(
          await _client
              .read([_shots[i].image], language: language, cancelToken: token)
              .timeout(_photoDeadline),
        );
      }

      if (!mounted || !identical(_inFlight, token)) return;
      _setStatus(const _Status.working('Checking what is already in there…'));

      // Fatal if it fails, unlike the learned barcodes below: without the
      // current stock every single row resolves to "not in the pantry" and the
      // plan becomes a pile of duplicate rows for things already on the shelf.
      final pantry = await householdApi
          .getPantryItems(widget.channelId)
          .timeout(_fetchDeadline);

      // Not fatal. Losing these costs the top rung of the ladder - a photo-read
      // row is created by name instead of picking up the house's own name and
      // learned default - which is a worse plan, not a wrong one. Failing the
      // whole pass here would throw away a read somebody has already paid for.
      var learned = const <PantryBarcodeDto>[];
      try {
        learned = await householdApi
            .getLearnedBarcodes(widget.guildId)
            .timeout(_fetchDeadline);
      } catch (_) {}

      if (!mounted || !identical(_inFlight, token)) return;

      final vision = PantryVisionResult.merge(results);
      final plan = _lowConfidenceFirst(
        buildPantryVisionPlan(
          vision: vision,
          pantry: pantry,
          learnedBarcodes: learned,
          direction: _direction,
        ),
      );

      if (plan.isEmpty) {
        // Not an error - the request worked - but the only honest thing to do
        // with an empty plan is say so and hand the camera back, because an
        // empty review sheet reads as a bug.
        _setStatus(
          _Status.failed(
            _shots.length == 1
                ? 'Nothing in that photo could be named.'
                : 'Nothing in those photos could be named.',
            detail: plan.unreadable > 0
                ? '${plan.unreadable} things were visible but not readable. '
                      'Closer, or with more light on the labels, usually fixes '
                      'it.'
                : 'Try again closer to the shelf, or with more light on the '
                      'labels.',
            canRetry: true,
          ),
        );
        return;
      }

      // From here the pass cannot be lost, so it stops being cancellable in the
      // sense the read was. The catalog step gets its own token - the one
      // "Stop waiting" will reach for - and the read's is retired, because
      // cancelling an optional enrichment must land on the review sheet rather
      // than throw away photos somebody has already paid to have read.
      enrichment = CancelToken();
      _inFlight = enrichment;
      final enriched = await _matchCatalogue(
        plan,
        enrichment,
        language: language,
        pantry: pantry,
        learned: learned,
      );
      if (!mounted || pass != _pass) return;

      setState(() {
        _pantry = pantry;
        _learned = learned;
        _plan = enriched.plan;
        _adopted
          ..clear()
          ..addAll(enriched.adopted);
        _matched
          ..clear()
          ..addAll(enriched.matched);
        _catalogAttribution = enriched.attribution;
        _named.clear();
        _stage = _Stage.review;
      });
      _setStatus(const _Status.idle('Nothing has been written yet'));
    } on AiFailure catch (failure) {
      // A cancel arrives here as a timeout - the client cannot tell the two
      // apart and does not try - so a read the person already gave up on says
      // nothing at all. See `_cancel`, which clears `_inFlight` itself.
      if (!mounted || !identical(_inFlight, token)) return;
      _setStatus(
        _Status.failed(
          failure.message(provider),
          detail: failure.detail,
          failure: failure.kind,
          canRetry: failure.kind != AiFailureKind.notConfigured,
        ),
      );
    } on TimeoutException {
      if (!mounted || !identical(_inFlight, token)) return;
      _setStatus(
        const _Status.failed(
          'That took too long.',
          detail:
              'Nothing was written. Your photos are still here - try again, or '
              'drop one and read fewer at a time.',
          canRetry: true,
        ),
      );
    } catch (error) {
      if (!mounted || !identical(_inFlight, token)) return;
      if (error is DioException && CancelToken.isCancel(error)) {
        _setStatus(_Status.idle(_idleMessage));
        return;
      }
      _setStatus(
        _Status.failed(
          householdErrorText(error, 'Could not check what is in the pantry.'),
          detail:
              'The photos were read, but this pantry could not be loaded to '
              'compare them against. Nothing was written.',
          canRetry: true,
        ),
      );
    } finally {
      // Either token can be the live one by now, depending on how far the pass
      // got. Clearing only the read's would leave a retired enrichment token
      // standing as the thing "Stop waiting" cancels.
      if (identical(_inFlight, token) ||
          (enrichment != null && identical(_inFlight, enrichment))) {
        _inFlight = null;
      }
      if (mounted && _status.phase == _Phase.working) {
        _setStatus(_Status.idle(_idleMessage));
      }
    }
  }

  /// The way out of a wait that has gone on too long. Deliberately not styled
  /// as an error afterwards: nothing failed, somebody chose to stop waiting.
  void _cancel() {
    _inFlight?.cancel('cancelled by the person photographing');
    _inFlight = null;
    _setStatus(_Status.idle(_idleMessage));
  }

  void _dismissStatus() => _setStatus(_Status.idle(_idleMessage));

  /// Puts the rows worth a second look at the top.
  ///
  /// Confidence is advisory and never gates anything, but it is the model's own
  /// answer to "which of these did I struggle with", and those are exactly the
  /// rows a person should reach before their attention runs out. Ties keep the
  /// order the model listed them in - `List.sort` is not stable, so the
  /// original index is carried as the tiebreak rather than hoped for.
  static PantryVisionPlan _lowConfidenceFirst(PantryVisionPlan plan) {
    final indexed = <(int, PantryVisionRow)>[
      for (var i = 0; i < plan.rows.length; i++) (i, plan.rows[i]),
    ];
    indexed.sort((a, b) {
      final byConfidence = _confidenceRank(
        a.$2.proposal.confidence,
      ).compareTo(_confidenceRank(b.$2.proposal.confidence));
      return byConfidence != 0 ? byConfidence : a.$1.compareTo(b.$1);
    });
    return PantryVisionPlan(
      rows: [for (final entry in indexed) entry.$2],
      unreadable: plan.unreadable,
    );
  }

  static int _confidenceRank(VisionConfidence confidence) => switch (confidence) {
    VisionConfidence.low => 0,
    VisionConfidence.medium => 1,
    VisionConfidence.high => 2,
  };

  // --------------------------------------------------------- rung 3, catalog

  /// Searches the catalog for the rows that need it and lets the model pick.
  ///
  /// **Total.** Nothing thrown escapes and no failure reaches the caller, which
  /// is not defensiveness: [_analyse]'s failure paths report a failed pass and
  /// drop the plan, and a rate-limited *optional* second step must never end
  /// there. Every way this can go wrong - no key, no network, a search that
  /// 500s, a model that abstained on everything, somebody tapping "Stop
  /// waiting" - returns the plan exactly as it arrived, which is a review sheet
  /// with "Find in the catalogue" on every unresolved row. That is precisely
  /// what this screen did before rung 3 existed.
  ///
  /// The status gets a phase of its own rather than extending "reading the
  /// photo", because this adds seconds to a wait that is already five to
  /// fifteen a photo and an unexplained pause is how a working screen gets
  /// closed. [PantryVisionClient.matchCatalog] is one call for the whole batch;
  /// see `catalog_matcher.dart` for why it is not one per row.
  Future<_CatalogEnrichment> _matchCatalogue(
    PantryVisionPlan plan,
    CancelToken token, {
    required AppLanguage language,
    required List<PantryItemDto> pantry,
    required List<PantryBarcodeDto> learned,
  }) async {
    final wanted = <int>[
      for (var i = 0; i < plan.rows.length; i++)
        if (_worthSearching(plan.rows[i])) i,
    ];
    if (wanted.isEmpty) return _CatalogEnrichment.none(plan);

    _setStatus(const _Status.working('Matching against the catalogue…'));

    try {
      final envelopes = await _searchCatalogue(wanted, plan, token, language);
      if (!mounted || token.isCancelled) return _CatalogEnrichment.none(plan);

      // Rows with nothing to choose between are left out of the batch entirely
      // rather than sent as empty lists: they abstain for free, and paying for
      // them in prompt tokens buys an answer that is already known.
      final items = <CatalogMatchCandidates>[];
      final rows = <int>[];
      for (final index in wanted) {
        final results =
            envelopes[index]?.results ?? const <ProductCatalogMatchDto>[];
        if (results.isEmpty) continue;
        items.add(
          CatalogMatchCandidates(
            proposal: plan.rows[index].proposal,
            candidates: results,
          ),
        );
        rows.add(index);
      }
      if (items.isEmpty) return _CatalogEnrichment.none(plan);

      final choices = await _client.matchCatalog(
        items,
        language: language,
        cancelToken: token,
      );
      if (!mounted || token.isCancelled) return _CatalogEnrichment.none(plan);

      var enriched = plan;
      final adopted = <int, ProductCatalogMatchDto>{};
      final matched = <int, PantryVisionCatalogMatch>{};

      // One choice per input, in order - the matcher's contract, and the reason
      // this can index `rows` by position. Guarded anyway, because a length
      // mismatch here would adopt a product onto the wrong row, which is the
      // one mistake this whole ladder is built to make impossible.
      for (var i = 0; i < choices.length && i < rows.length; i++) {
        final choice = choices[i];
        final match = choice.match;
        if (match == null) continue;

        final index = rows[i];
        final row = enriched.rows[index];
        adopted[index] = match;
        matched[index] = PantryVisionCatalogMatch(
          photoName: row.name,
          confidence: choice.confidence,
          reason: choice.reason,
        );
        enriched = enriched.replaceRow(
          index,
          // The same adoption the picker performs, not a second copy of it.
          // `pantry` and `learned` are passed explicitly because this runs
          // before either has been published to state.
          _adopt(row, match, pantry: pantry, learned: learned),
        );
      }

      return _CatalogEnrichment(
        plan: enriched,
        adopted: adopted,
        matched: matched,
        attribution: envelopes.values
            .map((envelope) => envelope.attribution.trim())
            .where((text) => text.isNotEmpty)
            .firstOrNull,
      );
    } catch (_) {
      // Deliberately bare. Whatever this was, it happened to a refinement of an
      // answer that is already on the table, and the honest response is to put
      // the unrefined answer on screen.
      return _CatalogEnrichment.none(plan);
    }
  }

  /// Whether rung 3 is worth a request for this row.
  ///
  /// Only rows that would otherwise be created fresh, and the reasoning is not
  /// obvious enough to leave implicit - this is a request per row on a step
  /// nobody asked for.
  ///
  /// A row that already matched a pantry item writes to *that* row, and the
  /// name the house gave it beats anything a catalog can offer. Adopting a code
  /// onto it does not even unlock the scan path:
  /// [PantryVisionRow.canScanIn] requires `existing == null || existing.barcode
  /// == barcode`, so a row whose item carries no code still goes through
  /// `updatePantryItem` afterwards. The search would cost a request and buy
  /// nothing.
  ///
  /// A row that already has a barcode is rung 1 - a code this house taught
  /// itself - and that is a better answer than the catalog's by definition,
  /// since somebody here scanned the packet. Overwriting it with a stranger's
  /// pick would be a downgrade.
  ///
  /// The length floor is the catalog's own minimum. Below it the server answers
  /// an empty set, so the request is a round trip whose reply is known before
  /// it leaves.
  ///
  /// `create` is only ever reached while stocking up, so this spends nothing at
  /// all on a use-up pass. That is on purpose and is not a gap: an unrecognised
  /// row on the way out writes nothing, and the one thing a code could do for
  /// it - land it on a pantry item the house holds under another name - is
  /// still one tap away on the picker, on a row somebody is already looking at
  /// because it says "not in this pantry".
  static bool _worthSearching(PantryVisionRow row) =>
      row.existing == null &&
      row.action == PantryVisionAction.create &&
      (row.barcode ?? '').isEmpty &&
      row.name.trim().length >= productCatalogMinQueryLength;

  /// One catalog search per row, at most [_catalogSearchConcurrency] at a time.
  ///
  /// A row whose search failed, timed out or came back empty is simply absent
  /// from the result - it has nothing to choose between, which is an ordinary
  /// answer and lands it back on the manual picker. Failing the batch for it
  /// would let one 500 cost the other eleven rows their match.
  Future<Map<int, ProductCatalogSearchDto>> _searchCatalogue(
    List<int> indices,
    PantryVisionPlan plan,
    CancelToken token,
    AppLanguage language,
  ) async {
    final envelopes = <int, ProductCatalogSearchDto>{};
    var next = 0;

    Future<void> worker() async {
      while (!token.isCancelled) {
        // Safe without a lock: this is one isolate, and the read and the
        // increment are one synchronous statement with no await between them.
        final at = next++;
        if (at >= indices.length) return;
        final index = indices[at];
        try {
          envelopes[index] = await householdApi
              .searchProductCatalog(
                plan.rows[index].name,
                // The cap the matcher applies anyway - see
                // [maxCatalogCandidates]. Asking for the picker's twenty-five
                // would be rows nobody, model or person, ever looks at.
                limit: maxCatalogCandidates,
                // No `acceptLanguage` on purpose. `AcceptLanguageInterceptor`
                // already sends the chosen language for every request, and it
                // sends a better header than this call could: the choice at
                // `q=1` with the handset's own preferences trailing it, so a
                // German-speaking user on an Italian phone gets a German name
                // where the catalog has one and an Italian - not English - one
                // where it does not. An explicit value here would be a single
                // bare tag that *overrode* all of that, which is precisely the
                // bug the picker had.
                //
                // What must stay true is that these candidates come back in the
                // same language the photo was read in: they are about to be
                // compared against those names by a model told both sides are
                // one language, and a mismatch abstains on every row while
                // looking exactly like a catalog with no coverage. One setting
                // feeds both ends - see [AppLanguage].
                cancelToken: token,
              )
              .timeout(_fetchDeadline);
        } catch (_) {
          // No candidates for this row. Never fatal - see the doc above.
        }
      }
    }

    await Future.wait([
      for (var i = 0; i < _catalogSearchConcurrency && i < indices.length; i++)
        worker(),
    ]);
    return envelopes;
  }

  // ----------------------------------------------------------------- review

  /// Re-runs the resolution ladder for a row somebody edited.
  ///
  /// Renaming a row is not a cosmetic change: "Oat drink" corrected to "Oat
  /// milk" may now match a row this pantry already has, and
  /// [PantryVisionRow.copyWith] would keep the old resolution and create a
  /// second one. So the edit goes back through [buildPantryVisionPlan] - the
  /// tested ladder, with the same pantry and the same learned codes - rather
  /// than through a second copy of the matching rules living up here in the UI.
  ///
  /// [barcode] overrides what the ladder found, and is only ever passed for a
  /// code adopted from the catalogue - by somebody tapping a result, or by the
  /// matcher picking one for them. A deliberate choice must survive a later
  /// rename; a code the ladder inferred from the old name must not.
  ///
  /// [pantry] and [learned] default to what this screen holds and are passed
  /// explicitly by exactly one caller: [_matchCatalogue], which adopts before
  /// either has been published to state. Reading the fields there would resolve
  /// every row against the *previous* pass's pantry - empty on the first read -
  /// and quietly turn every match into a create.
  PantryVisionRow _resolve(
    PantryVisionItem proposal, {
    required PantryVisionRow like,
    String? barcode,
    List<PantryItemDto>? pantry,
    List<PantryBarcodeDto>? learned,
  }) {
    final items = pantry ?? _pantry;
    final fresh = buildPantryVisionPlan(
      vision: PantryVisionResult(items: [proposal]),
      pantry: items,
      learnedBarcodes: learned ?? _learned,
      direction: _direction,
    ).rows;
    final resolved = fresh.isEmpty ? like : fresh.first;

    // An adopted code that a row in this pantry already carries is that row -
    // that is the whole point of adopting one. Falling back to whatever the
    // name matched is what stops an adoption silently retargeting a row at some
    // other item.
    final existing = barcode == null
        ? resolved.existing
        : _itemWithBarcode(items, barcode) ?? resolved.existing;

    return PantryVisionRow.resolve(
      proposal: proposal,
      existing: existing,
      barcode: barcode ?? resolved.barcode,
      direction: _direction,
      action: like.action,
      included: like.included,
    );
  }

  /// Puts a catalog product onto a plan row.
  ///
  /// The only adoption path there is, reached both by somebody choosing a
  /// result in the picker and by the matcher choosing one for them. Deliberately
  /// one function: adoption is the moment a stranger's name and a real barcode
  /// land on a row that will be written into a shared cupboard, and the rules
  /// around it - an empty catalog name never overwrites the model's, a code that
  /// already sits on a pantry item *is* that item - are exactly the kind that
  /// get fixed in one copy and left broken in the other.
  PantryVisionRow _adopt(
    PantryVisionRow row,
    ProductCatalogMatchDto match, {
    List<PantryItemDto>? pantry,
    List<PantryBarcodeDto>? learned,
  }) {
    final name = match.name.trim();
    final code = match.barcode;
    return _resolve(
      row.proposal.copyWith(name: name.isEmpty ? row.name : name),
      like: row,
      barcode: code == null || code.isEmpty ? null : code,
      pantry: pantry,
      learned: learned,
    );
  }

  static PantryItemDto? _itemWithBarcode(
    List<PantryItemDto> pantry,
    String barcode,
  ) {
    for (final item in pantry) {
      if (item.barcode == barcode) return item;
    }
    return null;
  }

  void _replaceRow(int index, PantryVisionRow row) {
    final plan = _plan;
    if (plan == null) return;
    setState(() => _plan = plan.replaceRow(index, row));
  }

  /// One more of something, or one fewer, without going back to the shelf.
  ///
  /// Clamped at one rather than zero: a row with no count is a row that means
  /// nothing, and "none of these" is what dropping the row is for - which sits
  /// right beside this.
  void _adjustCount(int index, int delta) {
    final row = _plan?.rows[index];
    if (row == null) return;
    final next = (row.proposal.count + delta).clamp(1, 99);
    if (next == row.proposal.count) return;
    _replaceRow(index, row.copyWith(count: next));
  }

  void _toggleIncluded(int index) {
    final row = _plan?.rows[index];
    if (row == null) return;
    _replaceRow(index, row.copyWith(included: !row.included));
  }

  /// Flips a matched row between landing on a number and adding to it.
  ///
  /// `set` is the default because a photo is a stocktake, not a delivery note -
  /// photographing the same shelf twice must leave three cartons as three. But
  /// the person holding the phone is the only one who can see that there are
  /// three more behind the three in the picture, and this is how they say so.
  void _flipAction(int index) {
    final row = _plan?.rows[index];
    if (row == null) return;
    _replaceRow(
      index,
      row.copyWith(
        action: row.action == PantryVisionAction.add
            ? PantryVisionAction.set
            : PantryVisionAction.add,
      ),
    );
  }

  /// Correcting what the model called something.
  ///
  /// The same sheet the scanner uses, for the same reason: two ways to fix a
  /// name is one too many, and a wrong name that is awkward to fix is worse
  /// than no name at all. A typed name is the person's own, so the row stops
  /// being a proposal and loses its badge.
  Future<void> _rename(int index) async {
    final row = _plan?.rows[index];
    if (row == null) return;
    final adopted = _adopted[index];

    final typed = await showHouseSheet<String>(
      context: context,
      builder: (_) => ProductNameSheet(
        initialName: row.name,
        suggestion: adopted?.name,
        brand: adopted?.brand,
        attribution: adopted?.attribution,
      ),
    );

    final name = typed?.trim();
    if (name == null || name.isEmpty || name == row.name || !mounted) return;

    setState(() {
      _plan = _plan?.replaceRow(
        index,
        _resolve(
          row.proposal.copyWith(name: name),
          like: row,
          // A code somebody adopted survives the rename; one the ladder guessed
          // from the old name does not.
          barcode: adopted?.barcode,
        ),
      );
      _named.add(index);
      // A name somebody typed settles the row. Leaving the matcher's offer
      // standing underneath it would ask them to choose between two names,
      // neither of which is the one now on the row.
      _matched.remove(index);
    });
  }

  /// Rung three by hand: the picker, for a row the matcher abstained on or was
  /// never able to reach.
  ///
  /// This opens a sheet and does exactly nothing until somebody taps a result.
  /// The whole reason the response schema has no barcode field is that a
  /// confident wrong EAN does not fail loudly - it writes a product that does
  /// not exist into a shared pantry and teaches the house its name for good -
  /// and taking `results[0]` from a fuzzy name search would reintroduce that by
  /// the back door. The matcher does not reintroduce it either: it answers with
  /// a position in a list rather than a code. See the library doc, and
  /// `docs/pantry-vision.md` §1.
  Future<void> _findInCatalogue(int index) async {
    final row = _plan?.rows[index];
    if (row == null) return;

    final match = await showProductCatalogPicker(
      context,
      initialQuery: row.name,
      title: 'Find ${row.name}',
    );
    if (match == null || !mounted) return;

    setState(() {
      _adopted[index] = match;
      // The catalogue's name replaces the model's, so the row is still a
      // proposal - a different stranger's guess, badged the same way.
      _named.remove(index);
      // Somebody has just looked at a list of candidates and picked one, which
      // is a stronger answer than the matcher's and settles the row.
      _matched.remove(index);
      _plan = _plan?.replaceRow(index, _adopt(row, match));
    });
  }

  /// Taking the matcher's pick.
  ///
  /// It changes no data at all - the name and the code are already on the row,
  /// which is what "pre-filled" means - and only puts the offer away. That is
  /// the point rather than a shortcoming: a suggestion somebody has read and
  /// accepted should stop asking, and a row that keeps asking after being
  /// answered is a row people learn to scroll past. Nothing is written here;
  /// the plan is still applied by the button at the bottom.
  void _keepMatch(int index) {
    if (!_matched.containsKey(index)) return;
    setState(() => _matched.remove(index));
  }

  /// Putting back what the photo said.
  ///
  /// The row returns to exactly the state it would have been in had the matcher
  /// never run: the model's name, no adopted code, and the ladder re-run over
  /// that name so a learned barcode it happens to hit is picked up again. Count
  /// and included edits survive, because they were about the thing on the
  /// shelf rather than about which product it is.
  void _dropMatch(int index) {
    final row = _plan?.rows[index];
    final match = _matched[index];
    if (row == null || match == null) return;

    setState(() {
      _matched.remove(index);
      _adopted.remove(index);
      _plan = _plan?.replaceRow(
        index,
        _resolve(row.proposal.copyWith(name: match.photoName), like: row),
      );
    });
  }

  /// Rows that would land on the same pantry item as another included row.
  ///
  /// Two `set` rows onto one item is the second one silently overwriting the
  /// first, and it is reachable from review: renaming one row onto another
  /// row's product does it. [buildPantryVisionPlan] folds duplicates when it
  /// builds the plan and cannot fold them again afterwards, so review flags
  /// them instead and leaves the choice - dropping one, or merging the counts
  /// by hand - to somebody who can see both.
  Set<int> get _duplicateTargets {
    final plan = _plan;
    if (plan == null) return const {};
    final seen = <String, int>{};
    final duplicates = <int>{};
    for (var i = 0; i < plan.rows.length; i++) {
      final row = plan.rows[i];
      final id = row.existing?.id;
      if (!row.willWrite || id == null) continue;
      final first = seen[id];
      if (first == null) {
        seen[id] = i;
      } else {
        duplicates
          ..add(first)
          ..add(i);
      }
    }
    return duplicates;
  }

  // ------------------------------------------------------------------ apply

  Future<void> _apply() async {
    final plan = _plan;
    if (plan == null || _applying || plan.writeCount == 0) return;

    setState(() => _applying = true);
    _setStatus(
      _Status.working(
        widget.mode.isStockUp
            ? 'Putting ${_things(plan.writeCount)} away…'
            : 'Using up ${_things(plan.writeCount)}…',
      ),
    );

    try {
      final outcomes = await applyPantryVisionPlan(
        plan,
        channelId: widget.channelId,
        writer: HouseholdPantryVisionWriter(householdApi),
      );
      if (!mounted) return;

      final landed = outcomes.where((o) => o.succeeded).length;
      // Only on success, and only once. A phone that buzzes at a failure
      // teaches people the buzz means nothing.
      if (landed > 0) houseHaptic();

      setState(() {
        _outcomes = outcomes;
        _stage = _Stage.applied;
      });
      _setStatus(
        landed == outcomes.length
            ? _Status.done(
                widget.mode.isStockUp
                    ? '${_things(landed)} put away'
                    : '${_things(landed)} used up',
              )
            : _Status.failed(
                '$landed of ${outcomes.length} went in.',
                detail: 'The rest are listed below with what went wrong.',
              ),
      );
    } catch (error) {
      // `applyPantryVisionPlan` is written not to let anything escape, so this
      // is the seam where a change to it would otherwise become an unhandled
      // exception on a screen that had a perfectly good failure state.
      if (!mounted) return;
      _setStatus(
        _Status.failed(householdErrorText(error, 'Nothing could be written.')),
      );
    } finally {
      if (mounted) setState(() => _applying = false);
    }
  }

  /// A second attempt at the rows that were **refused**, never at the ones that
  /// ran out of time.
  ///
  /// A refused write did not happen, so repeating it is safe. A timed-out write
  /// was abandoned, not undone - it may well have landed server-side - and
  /// offering "try again" on one of those is how a shelf gets counted into the
  /// pantry twice. Those get a look at the pantry instead, which is the only
  /// thing that actually answers the question.
  Future<void> _retryRefused() async {
    final outcomes = _outcomes;
    if (outcomes == null || _applying) return;

    final refused = [
      for (final outcome in outcomes)
        if (!outcome.succeeded && !outcome.timedOut) outcome.row,
    ];
    if (refused.isEmpty) return;

    setState(() => _applying = true);
    _setStatus(_Status.working('Trying ${_things(refused.length)} again…'));

    try {
      final again = await applyPantryVisionPlan(
        PantryVisionPlan(rows: refused),
        channelId: widget.channelId,
        writer: HouseholdPantryVisionWriter(householdApi),
      );
      if (!mounted) return;

      // Rows come back by identity, so the second pass slots straight into the
      // first one's list rather than being appended to it - the outcome list is
      // a record of what happened to each row, not of how many attempts it took.
      final replacements = {for (final outcome in again) outcome.row: outcome};
      final merged = [
        for (final outcome in outcomes) replacements[outcome.row] ?? outcome,
      ];
      final landed = merged.where((o) => o.succeeded).length;
      if (again.any((o) => o.succeeded)) houseHaptic();

      setState(() => _outcomes = merged);
      _setStatus(
        landed == merged.length
            ? _Status.done('All ${merged.length} went in')
            : _Status.failed('$landed of ${merged.length} went in.'),
      );
    } finally {
      if (mounted) setState(() => _applying = false);
    }
  }

  /// What the screen hands back: **rows that landed**, not counts.
  ///
  /// A row is one product, and one product is what the pantry behind this
  /// screen says a sentence about. Summing the counts would say "eleven things
  /// put away" for a stocktake that changed three rows, which is not what
  /// happened to the cupboard.
  int get _movedCount =>
      _outcomes?.where((o) => o.succeeded).length ?? 0;

  static String _things(int count) => count == 1 ? '1 thing' : '$count things';

  // ------------------------------------------------------------------ build

  @override
  Widget build(BuildContext context) {
    // Backing out with the system gesture has to return the same count the
    // Done button does, or the pantry behind this screen says nothing about
    // writes that definitely happened.
    return PopScope<int?>(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        Navigator.of(context).pop(_movedCount);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            widget.mode.isStockUp
                ? 'Filling ${widget.channelName}'
                : 'Using up from ${widget.channelName}',
            overflow: TextOverflow.ellipsis,
          ),
          actions: [
            // Up here on purpose, against the rule the rest of these screens
            // follow. Starting over throws away photos somebody paid to have
            // read, so it wants to be deliberate and hard to hit by accident -
            // which is exactly what an app-bar corner is good for.
            if (_stage == _Stage.review && !_applying)
              TextButton(
                onPressed: () => setState(() {
                  _stage = _Stage.capture;
                  _plan = null;
                  _adopted.clear();
                  _matched.clear();
                  _catalogAttribution = null;
                  _named.clear();
                  _status = const _Status.idle('Nothing has been sent yet');
                }),
                child: const Text('Start again'),
              ),
          ],
        ),
        body: switch (_stage) {
          _Stage.capture => _buildCapture(),
          _Stage.review => _buildReview(),
          _Stage.applied => _buildApplied(),
        },
        bottomNavigationBar: HouseActionBar(
          // Always on screen, always the same shape. A strip that appears and
          // disappears moves the button under somebody's thumb mid-tap, and
          // "nothing has been written yet" is itself worth being able to read
          // at a glance.
          secondary: _StatusStrip(
            status: _status,
            slow: _slow,
            onCancel: _cancel,
            onRetry: _status.canRetry && _stage == _Stage.capture
                ? () => unawaited(_analyse())
                : null,
            onOpenSettings: _status.failure == AiFailureKind.notConfigured
                ? () => unawaited(_openSettings())
                : null,
            onDismiss: _dismissStatus,
          ),
          child: _buildActions(),
        ),
      ),
    );
  }

  Widget _buildActions() => switch (_stage) {
    _Stage.capture => Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Expanded(
              child: HouseSecondaryButton(
                label: _shots.isEmpty ? 'Take a photo' : 'Add another',
                icon: Icons.photo_camera_outlined,
                onPressed: _busy
                    ? null
                    : () => unawaited(_addPhoto(ImageSource.camera)),
              ),
            ),
            const SizedBox(width: AppSpacing.s),
            Tooltip(
              message: 'Choose a photo',
              child: SizedBox(
                height: 52,
                width: 52,
                child: OutlinedButton(
                  onPressed: _busy
                      ? null
                      : () => unawaited(_addPhoto(ImageSource.gallery)),
                  style: OutlinedButton.styleFrom(padding: EdgeInsets.zero),
                  child: const Icon(Icons.photo_library_outlined),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.s),
        HousePrimaryButton(
          label: _shots.length <= 1
              ? 'Read the photo'
              : 'Read ${_shots.length} photos',
          icon: Icons.auto_awesome_outlined,
          busy: _busy,
          onPressed: _shots.isEmpty || _busy ? null : () => unawaited(_analyse()),
        ),
      ],
    ),
    _Stage.review => HousePrimaryButton(
      label: switch ((widget.mode.isStockUp, _plan?.writeCount ?? 0)) {
        (_, 0) => 'Nothing to write',
        (true, final n) => 'Put ${_things(n)} away',
        (false, final n) => 'Use ${_things(n)} up',
      },
      icon: Icons.check_rounded,
      busy: _applying,
      onPressed: (_plan?.writeCount ?? 0) == 0 || _applying
          ? null
          : () => unawaited(_apply()),
    ),
    _Stage.applied => HousePrimaryButton(
      label: 'Done',
      icon: Icons.check_rounded,
      onPressed: () => Navigator.of(context).pop(_movedCount),
    ),
  };

  Widget _buildCapture() {
    final theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.m,
        AppSpacing.m,
        AppSpacing.m,
        AppSpacing.l,
      ),
      children: [
        _ProviderLine(
          config: _config,
          onTap: () => unawaited(_openSettings()),
        ),
        const SizedBox(height: AppSpacing.m),
        Text(
          widget.mode.isStockUp
              ? 'Photograph the shelf. One picture per compartment is usually '
                    'better than one wide shot - the labels have to be '
                    'readable. You check everything before a single thing is '
                    'written down.'
              : 'Photograph what you have used - the empty packets, the bin, '
                    'whatever is in your hand. Nothing comes out of the pantry '
                    'until you have checked the list.',
          style: theme.textTheme.bodyMedium?.copyWith(height: 1.4),
        ),
        const SizedBox(height: AppSpacing.l),
        if (_shots.isEmpty)
          const HouseEmptyState(
            icon: Icons.photo_camera_outlined,
            title: 'No photos yet',
            body:
                'Take one and it lands here. Add as many as you need - a '
                'cupboard usually wants one per shelf - and they are read '
                'together.',
          )
        else ...[
          HouseSectionHeader(
            label: _shots.length == 1 ? '1 photo' : '${_shots.length} photos',
            trailing: Text(
              _shots.length == 1 ? 'about 5-15s' : 'about ${_shots.length * 10}s',
            ),
          ),
          _ShotStrip(shots: _shots, onRemove: _busy ? null : _removeShot),
        ],
      ],
    );
  }

  /// The credit the review list owes, or null when it owes none.
  ///
  /// One notice for the whole list rather than one per row: it is the same
  /// sentence every time, the per-row badge is what says which lines it covers,
  /// and a stack of identical legal notices is a list nobody reads.
  ///
  /// Owed exactly when a catalog-supplied name is on screen, which is what
  /// [_adopted] being non-empty means - by hand or by the matcher, ODbL does
  /// not distinguish. The wording is the row's own, falling back to the search
  /// envelope's: `sourceName` varies per row (Open Food Facts / Beauty /
  /// Products / Pet Food), so neither is ever assembled here.
  String? get _reviewAttribution {
    if (_adopted.isEmpty) return null;
    for (final match in _adopted.values) {
      final text = match.attribution.trim();
      if (text.isNotEmpty) return text;
    }
    final envelope = _catalogAttribution?.trim();
    return envelope == null || envelope.isEmpty ? null : envelope;
  }

  Widget _buildReview() {
    final plan = _plan;
    if (plan == null) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final duplicates = _duplicateTargets;

    final attribution = _reviewAttribution;

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.m,
        AppSpacing.m,
        AppSpacing.m,
        AppSpacing.l,
      ),
      children: [
        Text(
          widget.mode.isStockUp
              ? 'Put away ${_things(plan.writeCount)}'
              : 'Use up ${_things(plan.writeCount)}',
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Check these against the shelf. Counts are what the photo showed, '
          'not what is behind it.',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.65),
            height: 1.4,
          ),
        ),
        if (plan.unreadable > 0) ...[
          const SizedBox(height: AppSpacing.s),
          // Plain, unstyled, and not buried. This is the only signal that the
          // list is incomplete, and a review sheet that hides it is one people
          // stop checking.
          Text(
            plan.unreadable == 1
                ? '1 more thing in the photo could not be identified.'
                : '${plan.unreadable} more things in the photo could not be '
                      'identified.',
            style: theme.textTheme.bodySmall?.copyWith(height: 1.4),
          ),
        ],
        const SizedBox(height: AppSpacing.m),
        for (var i = 0; i < plan.rows.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.s),
            child: PantryVisionReviewRow(
              row: plan.rows[i],
              // Every row is a proposal until somebody types over it - an AI
              // guess gets exactly the treatment a catalog guess gets.
              suggested: !_named.contains(i),
              duplicated: duplicates.contains(i),
              // Null on every row nobody was matched for, which is what turns
              // the offer block off. An abstention is not a state the review
              // sheet renders - it is the absence of one.
              catalogMatch: _matched[i],
              onCount: (delta) => _adjustCount(i, delta),
              onRename: () => unawaited(_rename(i)),
              onToggleIncluded: () => _toggleIncluded(i),
              onFlipAction: () => _flipAction(i),
              onFindInCatalogue: () => unawaited(_findInCatalogue(i)),
              onKeepCatalogMatch: () => _keepMatch(i),
              onDropCatalogMatch: () => _dropMatch(i),
            ),
          ),
        if (attribution != null) ...[
          const SizedBox(height: AppSpacing.s),
          ProductSourceNote(attribution: attribution),
        ],
      ],
    );
  }

  Widget _buildApplied() {
    final outcomes = _outcomes ?? const <PantryVisionOutcome>[];
    final landed = [for (final o in outcomes) if (o.succeeded) o];
    final refused = [
      for (final o in outcomes)
        if (!o.succeeded && !o.timedOut) o,
    ];
    final abandoned = [for (final o in outcomes) if (o.timedOut) o];

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.m,
        AppSpacing.m,
        AppSpacing.m,
        AppSpacing.l,
      ),
      children: [
        if (landed.isNotEmpty) ...[
          HouseSectionHeader(
            label: widget.mode.isStockUp ? 'Put away' : 'Used up',
            trailing: Text('${landed.length}'),
          ),
          for (final outcome in landed) _OutcomeRow(outcome: outcome),
        ],
        if (abandoned.isNotEmpty) ...[
          HouseSectionHeader(
            label: 'Ran out of time',
            color: Theme.of(context).colorScheme.tertiary,
            trailing: Text('${abandoned.length}'),
          ),
          _AbandonedNotice(
            onCheckPantry: () => Navigator.of(context).pop(_movedCount),
          ),
          for (final outcome in abandoned) _OutcomeRow(outcome: outcome),
        ],
        if (refused.isNotEmpty) ...[
          HouseSectionHeader(
            label: 'Did not go in',
            color: Theme.of(context).colorScheme.error,
            trailing: Text('${refused.length}'),
          ),
          for (final outcome in refused) _OutcomeRow(outcome: outcome),
          const SizedBox(height: AppSpacing.s),
          Align(
            alignment: Alignment.centerLeft,
            child: OutlinedButton.icon(
              onPressed: _applying ? null : () => unawaited(_retryRefused()),
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: Text(
                refused.length == 1
                    ? 'Try that one again'
                    : 'Try those ${refused.length} again',
              ),
            ),
          ),
        ],
      ],
    );
  }
}

/// Which third party is about to be shown a photograph of somebody's kitchen.
///
/// Required by `docs/pantry-vision.md` §5 and not negotiable: the consent sheet
/// is shown once per provider and then never again, so this is what stops the
/// answer to "who is looking at my cupboard" being something a person agreed to
/// months ago and has no way to check now. It is also the shortest route to
/// changing it, which is why the whole line is a button.
class _ProviderLine extends StatelessWidget {
  const _ProviderLine({required this.config, required this.onTap});

  final AiProviderConfig? config;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final provider = config?.provider;

    return HouseCard(
      tint: provider == null ? scheme.error : null,
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            provider == null
                ? Icons.error_outline_rounded
                : Icons.cloud_upload_outlined,
            size: 20,
            color: provider == null
                ? scheme.error
                : scheme.onSurface.withValues(alpha: 0.6),
          ),
          const SizedBox(width: AppSpacing.m),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  provider == null
                      ? 'No AI provider set up yet'
                      : 'Photos go to ${provider.label}',
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 2),
                Text(
                  provider == null
                      ? 'Photos are read by a provider you choose and pay for. '
                            'Tap to set one up.'
                      : 'Straight from this phone, using your key. Not '
                            'end-to-end encrypted, unlike your messages'
                            '${config?.model == null ? '' : ' · ${config!.model}'}',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: scheme.onSurface.withValues(alpha: 0.65),
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// The photos taken so far, and the way to drop one.
///
/// A strip rather than a list because the only question it answers is "have I
/// covered the whole cupboard", which is answered by looking. Remove is on
/// every tile: a blurred shot or one of the wrong shelf is money about to be
/// spent on a wrong answer, and noticing that is exactly what this is for.
class _ShotStrip extends StatelessWidget {
  const _ShotStrip({required this.shots, required this.onRemove});

  final List<_Shot> shots;

  /// Null while a read is in flight - the photos are the input to it.
  final void Function(_Shot)? onRemove;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Wrap(
      spacing: AppSpacing.s,
      runSpacing: AppSpacing.s,
      children: [
        for (var i = 0; i < shots.length; i++)
          SizedBox(
            key: ValueKey('vision-shot-${shots[i].id}'),
            width: 96,
            height: 96,
            child: Stack(
              fit: StackFit.expand,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadii.card),
                  child: Image.memory(
                    shots[i].image.bytes,
                    fit: BoxFit.cover,
                    // The bytes are a 1568px JPEG; decoding all of that for a
                    // 96pt tile is a few megabytes per photo of nothing.
                    cacheWidth: 240,
                    errorBuilder: (context, _, _) => ColoredBox(
                      color: theme.colorScheme.surfaceContainerHighest,
                      child: const Center(
                        child: Icon(Icons.image_not_supported_outlined),
                      ),
                    ),
                  ),
                ),
                if (onRemove != null)
                  Align(
                    alignment: Alignment.topRight,
                    child: Material(
                      color: Colors.black.withValues(alpha: 0.55),
                      shape: const CircleBorder(),
                      child: IconButton(
                        onPressed: () => onRemove!(shots[i]),
                        visualDensity: VisualDensity.compact,
                        iconSize: 16,
                        color: Colors.white,
                        tooltip: 'Remove photo ${i + 1}',
                        icon: const Icon(Icons.close_rounded),
                      ),
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}

/// The single answer to "what is happening", in words.
///
/// The scanner's strip, with the same four states and the same rules. Idle is
/// nearly invisible but still says something true. Working says wait, and once
/// the wait has gone on long enough to feel wrong it says that too and offers a
/// way out - which matters more here than there, because a read of four photos
/// is the better part of a minute even when everything is working. Failure does
/// not leave on its own, and it carries the *specific* offer its cause deserves:
/// no key routes to settings, and a rate limit gets no "Try again" that is
/// certain to fail the same way.
class _StatusStrip extends StatelessWidget {
  const _StatusStrip({
    required this.status,
    required this.slow,
    required this.onCancel,
    required this.onRetry,
    required this.onOpenSettings,
    required this.onDismiss,
  });

  final _Status status;

  /// Whether the wait has gone on long enough to owe an explanation.
  final bool slow;

  final VoidCallback onCancel;
  final VoidCallback? onRetry;
  final VoidCallback? onOpenSettings;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final (background, foreground) = switch (status.phase) {
      _Phase.idle => (
        scheme.surfaceContainerHighest,
        scheme.onSurface.withValues(alpha: 0.7),
      ),
      _Phase.working => (scheme.secondaryContainer, scheme.onSecondaryContainer),
      _Phase.done => (scheme.primary, scheme.onPrimary),
      _Phase.failed => (scheme.errorContainer, scheme.onErrorContainer),
    };

    return Semantics(
      liveRegion: true,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: double.infinity,
        constraints: const BoxConstraints(minHeight: 52),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.m,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(AppRadii.card),
        ),
        // Actions under the message rather than beside it. A "Try again" on the
        // same line as a provider's own error wording is fine at normal size
        // and runs off the edge of a 390pt phone at the largest accessibility
        // step - which is the population most likely to be reading an error
        // rather than skimming past it.
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: _leading(foreground),
                ),
                const SizedBox(width: AppSpacing.s),
                Expanded(child: _text(theme, foreground)),
              ],
            ),
            if (_actions(foreground) case final actions when actions.isNotEmpty)
              Wrap(
                alignment: WrapAlignment.end,
                spacing: AppSpacing.xs,
                children: actions,
              ),
          ],
        ),
      ),
    );
  }

  Widget _leading(Color foreground) => switch (status.phase) {
    _Phase.working => SizedBox(
      width: 18,
      height: 18,
      child: CircularProgressIndicator(
        strokeWidth: 2,
        valueColor: AlwaysStoppedAnimation<Color>(foreground),
      ),
    ),
    _Phase.done => Icon(Icons.check_rounded, size: 18, color: foreground),
    _Phase.failed => Icon(
      Icons.error_outline_rounded,
      size: 18,
      color: foreground,
    ),
    _Phase.idle => Icon(Icons.lock_outline_rounded, size: 18, color: foreground),
  };

  Widget _text(ThemeData theme, Color foreground) {
    final message = status.message ?? 'Ready';

    final detail = switch (status.phase) {
      // Deliberately not phrased as a problem. Five to fifteen seconds a photo
      // is the normal cost of this feature, and telling somebody their
      // connection is broken when it is not is how a working screen gets closed.
      _Phase.working when slow =>
        'Still reading. A photo takes 5-15 seconds, and a slow connection '
            'makes it longer. Nothing has been written.',
      _Phase.working => null,
      _ => status.detail,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          message,
          style: theme.textTheme.bodyMedium?.copyWith(color: foreground),
        ),
        if (detail != null)
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              detail,
              style: theme.textTheme.labelSmall?.copyWith(
                color: foreground.withValues(alpha: 0.8),
                height: 1.35,
              ),
            ),
          ),
      ],
    );
  }

  List<Widget> _actions(Color foreground) {
    if (status.phase == _Phase.working) {
      // Nothing offered until waiting has actually become unreasonable: a
      // Cancel on the two-second path is a button nobody needs and everybody
      // reads.
      if (!slow) return const [];
      return [
        TextButton(
          onPressed: onCancel,
          style: TextButton.styleFrom(foregroundColor: foreground),
          child: const Text('Stop waiting'),
        ),
      ];
    }

    if (status.phase == _Phase.failed) {
      return [
        if (onOpenSettings != null)
          TextButton(
            onPressed: onOpenSettings,
            style: TextButton.styleFrom(foregroundColor: foreground),
            child: const Text('Set up a key'),
          ),
        if (onRetry != null)
          TextButton(
            onPressed: onRetry,
            style: TextButton.styleFrom(foregroundColor: foreground),
            child: const Text('Try again'),
          ),
        IconButton(
          onPressed: onDismiss,
          visualDensity: VisualDensity.compact,
          iconSize: 18,
          color: foreground,
          tooltip: 'Dismiss',
          icon: const Icon(Icons.close_rounded),
        ),
      ];
    }

    return const [];
  }
}

/// One reviewable line: what the model thinks it saw, what that resolves to,
/// and exactly what confirming it will do to the cupboard.
///
/// Public so it can be pumped at 390pt and 2.35x in `household_layout_test`.
/// It is the densest row in the feature - a name, a badge, a consequence, up to
/// three pills, a stepper and two buttons - and it is read one-handed at an open
/// fridge by somebody comparing it against a shelf, so "it fits at the largest
/// text size" is a correctness property rather than a polish one.
///
/// Everything stacks vertically rather than sitting in one row for that reason.
/// The scanner's tally can get away with a single line because it is a receipt;
/// this is a decision, and a decision that has to be scrolled sideways to read
/// is a decision nobody makes properly.
/// A catalog product the matcher put on a row before anybody saw it, in the
/// terms the row has to present it.
///
/// It exists so the review row can render an *offer* rather than a fact. The
/// name and the barcode are already on the [PantryVisionRow] - that is what
/// pre-filled means - and this is the rest of what a person needs in order to
/// disagree: what the photo said before the swap, and how sure the model was
/// about making it.
class PantryVisionCatalogMatch {
  const PantryVisionCatalogMatch({
    required this.photoName,
    this.confidence = VisionConfidence.low,
    this.reason,
  });

  /// What the model read off the packet, before the catalog name replaced it.
  ///
  /// Shown on the row whenever it differs, and it regularly does - "Oat milk"
  /// becoming "Oatly Havredryck Barista Edition" is the ordinary case. A swap
  /// nobody can see is a swap nobody can disagree with, and this is a screen
  /// built to be disagreed with.
  final String photoName;

  /// How sure the matcher says it is. Advisory exactly as the vision row's
  /// confidence is: it decides whether [reason] is worth the space, and it
  /// never gates anything.
  final VisionConfidence confidence;

  /// The matcher's one clause on why it picked this one.
  ///
  /// Shown below high confidence and hidden at it. On a confident match the
  /// sentence is a restatement of the two names already on screen, and a line
  /// of noise on every row is how the rows that genuinely need a second look
  /// stop standing out.
  final String? reason;

  /// Whether the catalog actually changed the name, comparing the way the whole
  /// feature compares names. "Barilla Penne Rigate" arriving as "Barilla penne
  /// rigate" is the same reading, and printing "the photo said" under it would
  /// invite somebody to look for a difference that is not there.
  bool renamed(String current) =>
      normaliseProductName(photoName) != normaliseProductName(current);
}

class PantryVisionReviewRow extends StatelessWidget {
  const PantryVisionReviewRow({
    super.key,
    required this.row,
    required this.suggested,
    required this.duplicated,
    required this.onCount,
    required this.onRename,
    required this.onToggleIncluded,
    required this.onFlipAction,
    required this.onFindInCatalogue,
    this.catalogMatch,
    this.onKeepCatalogMatch,
    this.onDropCatalogMatch,
  });

  final PantryVisionRow row;

  /// Whether the name on this row is still somebody else's guess - the model's,
  /// or a catalogue's. Cleared when a person types one.
  final bool suggested;

  /// Another included row lands on the same pantry item. Two `set` writes onto
  /// one item is the second silently overwriting the first.
  final bool duplicated;

  /// `+1` / `-1`, in whole units of the thing on the shelf.
  final ValueChanged<int> onCount;

  final VoidCallback onRename;
  final VoidCallback onToggleIncluded;

  /// Flips between landing on a number and adding to it.
  final VoidCallback onFlipAction;

  final VoidCallback onFindInCatalogue;

  /// The catalog product the matcher chose for this row, or null - which is
  /// both an abstention and a step that never ran, deliberately: the two are
  /// the same thing to somebody reviewing, and a row that could tell them apart
  /// would be showing a state nobody can act on.
  final PantryVisionCatalogMatch? catalogMatch;

  /// Accepting the match. Only puts the offer away - the name is already here.
  final VoidCallback? onKeepCatalogMatch;

  /// Going back to what the photo said, code and all.
  final VoidCallback? onDropCatalogMatch;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final muted = scheme.onSurface.withValues(alpha: 0.6);

    final dropped = !row.included && !row.isUnmatched;
    final note = row.proposal.note?.trim();
    final lowConfidence = row.proposal.confidence == VisionConfidence.low;

    // Offered wherever there is no code yet, in both directions. Even on a row
    // that matched nothing on the way out, adopting one can land it on a pantry
    // item held under a different name - which turns "not in this pantry" into
    // a real write.
    final canSearch = (row.barcode ?? '').isEmpty;
    final pills = _pills(context);

    return HouseCard(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.m,
        AppSpacing.s,
        AppSpacing.s,
        AppSpacing.s,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: InkWell(
                  onTap: onRename,
                  borderRadius: BorderRadius.circular(AppRadii.badge),
                  child: Semantics(
                    button: true,
                    label: suggested
                        ? '${row.name}, suggested name, tap to change it'
                        : '${row.name}, tap to change the name',
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Row(
                        children: [
                          Flexible(
                            child: Text(
                              row.proposal.displayName,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                decoration: dropped
                                    ? TextDecoration.lineThrough
                                    : null,
                                color: dropped ? muted : null,
                              ),
                            ),
                          ),
                          if (suggested) ...[
                            const SizedBox(width: 6),
                            // Flexible, not fixed: at the largest text size the
                            // word "Suggested" is wider than the slot a long
                            // product name leaves it, and a pill that cannot
                            // shrink takes the whole row over the edge with it.
                            const Flexible(child: SuggestedNameBadge()),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              // Unmatched rows have no drop control on purpose: they write
              // nothing either way, and a button that does nothing is worse
              // than no button.
              if (!row.isUnmatched)
                IconButton(
                  onPressed: onToggleIncluded,
                  visualDensity: VisualDensity.compact,
                  iconSize: 18,
                  tooltip: row.included
                      ? 'Leave ${row.name} out'
                      : 'Put ${row.name} back in',
                  icon: Icon(
                    row.included ? Icons.close_rounded : Icons.undo_rounded,
                  ),
                ),
            ],
          ),
          Text(
            _consequence(row),
            style: theme.textTheme.labelMedium?.copyWith(
              color: dropped || row.isUnmatched ? muted : scheme.onSurface,
              height: 1.35,
            ),
          ),
          if (note != null && note.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              note,
              style: theme.textTheme.labelSmall?.copyWith(
                color: muted,
                height: 1.35,
              ),
            ),
          ],
          if (catalogMatch case final match?) ...[
            const SizedBox(height: AppSpacing.xs),
            _CatalogMatchOffer(
              match: match,
              name: row.name,
              onKeep: onKeepCatalogMatch,
              onDrop: onDropCatalogMatch,
            ),
          ],
          if (pills.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.xs),
            Wrap(
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xs,
              children: pills,
            ),
          ],
          if (row.reducesStock) ...[
            const SizedBox(height: AppSpacing.xs),
            // The honest cost of "a photo is a stocktake" meeting "count the
            // front row only". Spelled out rather than left to the pill,
            // because getting this wrong takes stock off a shared cupboard that
            // is physically still there and nobody finds out until they cook.
            Text(
              'The photo showed fewer than the pantry records. If there are '
              'more behind them, add instead.',
              style: theme.textTheme.labelSmall?.copyWith(
                color: scheme.error,
                height: 1.35,
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.xs),
          Wrap(
            spacing: AppSpacing.s,
            runSpacing: AppSpacing.xs,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              _CountStepper(
                count: row.proposal.count,
                label: row.name,
                stockUp: row.direction.isStockUp,
                onLess: row.proposal.count <= 1 ? null : () => onCount(-1),
                onMore: () => onCount(1),
              ),
              // Only where the plan layer will actually honour it: `add` is
              // meaningless without a row to add to, and on the way out a flip
              // to `add` would be putting stock back in.
              if (row.existing != null && row.direction.isStockUp)
                TextButton.icon(
                  onPressed: onFlipAction,
                  style: row.reducesStock
                      ? TextButton.styleFrom(foregroundColor: scheme.error)
                      : null,
                  icon: Icon(
                    row.action == PantryVisionAction.add
                        ? Icons.exposure_zero_rounded
                        : Icons.add_rounded,
                    size: 18,
                  ),
                  label: Text(
                    row.action == PantryVisionAction.add
                        ? 'Set instead'
                        : 'Add instead',
                  ),
                ),
              if (canSearch)
                TextButton.icon(
                  onPressed: onFindInCatalogue,
                  icon: const Icon(Icons.search_rounded, size: 18),
                  label: const Text('Find in the catalogue'),
                ),
            ],
          ),
          if (lowConfidence && (note == null || note.isEmpty))
            Text(
              'The label was hard to read. Worth a second look.',
              style: theme.textTheme.labelSmall?.copyWith(
                color: muted,
                height: 1.35,
              ),
            ),
        ],
      ),
    );
  }

  List<Widget> _pills(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return [
      if (row.reducesStock)
        HousePill(
          label: 'Takes stock off',
          icon: Icons.trending_down_rounded,
          color: scheme.error,
        ),
      if (duplicated)
        HousePill(
          label: 'Also on another line',
          icon: Icons.copy_all_rounded,
          color: scheme.error,
        ),
      if (row.predictedIsLow == true && row.willWrite)
        HousePill(
          label: 'Goes on the shopping list',
          icon: Icons.playlist_add_check_circle_outlined,
          color: scheme.tertiary,
        ),
      if (row.proposal.confidence == VisionConfidence.low)
        HousePill(
          label: 'Not sure',
          icon: Icons.help_outline_rounded,
          color: scheme.tertiary,
          filled: false,
        ),
    ];
  }

  /// Exactly what confirming this row does, as a level rather than a delta.
  ///
  /// A level is the thing a person can check against the shelf in front of
  /// them: "3, was 1" is verifiable by looking, "+2" is arithmetic somebody has
  /// to do while holding a phone. The unit comes from the pantry row rather
  /// than the model - the model's unit describes the pack size printed on the
  /// label ("1 l"), and rendering "3 l" for three one-litre cartons is a wrong
  /// number rather than a missing one.
  static String _consequence(PantryVisionRow row) {
    if (!row.included && !row.isUnmatched) return 'Not going in';

    final unit = row.existing?.unit?.trim();
    String amount(double value) => unit == null || unit.isEmpty
        ? formatQuantity(value)
        : '${formatQuantity(value)} $unit';

    return switch (row.action) {
      PantryVisionAction.unmatched =>
        'Not in this pantry - nothing will be written',
      PantryVisionAction.create => 'Add - ${amount(row.targetQuantity)}',
      PantryVisionAction.add =>
        'Adds ${amount(row.proposal.count.toDouble())} → '
            '${amount(row.targetQuantity)}, was ${amount(row.currentQuantity)}',
      PantryVisionAction.set =>
        '→ ${amount(row.targetQuantity)}, was ${amount(row.currentQuantity)}',
    };
  }
}

/// The matcher's pick, presented as something to answer rather than something
/// that has happened.
///
/// Adopting is not confirming. The row above already carries the catalog's name
/// and its barcode, and nothing is written until the plan is applied - so this
/// block's whole job is to make that reversible in one tap and obvious without
/// one. Three things it must do, each because of a way the alternative fails:
///
/// It says a swap took place, and what was swapped. A row that silently reads
/// "Oatly Havredryck Barista Edition" when the photo said "oat milk" is a row
/// nobody can check against the shelf they are looking at.
///
/// It offers both answers as buttons of equal weight rather than an accept and
/// a dismissal. "No thanks" on a suggestion is a fine shape for an offer nobody
/// has acted on yet; here the offer is already applied, so the second control
/// is a real undo and is worded as one.
///
/// It lays them out in a [Wrap]. Two buttons and a sentence do not share a line
/// at 2.35x on a 390pt phone, and this sits inside the densest card in the
/// feature.
class _CatalogMatchOffer extends StatelessWidget {
  const _CatalogMatchOffer({
    required this.match,
    required this.name,
    required this.onKeep,
    required this.onDrop,
  });

  final PantryVisionCatalogMatch match;

  /// The name the row is showing now - the catalog's.
  final String name;

  final VoidCallback? onKeep;
  final VoidCallback? onDrop;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurface.withValues(alpha: 0.6);
    final reason = match.reason?.trim();
    final showReason =
        match.confidence != VisionConfidence.high &&
        reason != null &&
        reason.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          match.renamed(name)
              ? 'Matched to a product in the catalogue. The photo said '
                    '"${match.photoName}".'
              : 'Matched to a product in the catalogue.',
          style: theme.textTheme.labelSmall?.copyWith(
            color: muted,
            height: 1.35,
          ),
        ),
        if (showReason)
          Text(
            reason,
            style: theme.textTheme.labelSmall?.copyWith(
              color: muted,
              height: 1.35,
            ),
          ),
        const SizedBox(height: AppSpacing.xs),
        Wrap(
          spacing: AppSpacing.s,
          runSpacing: AppSpacing.xs,
          children: [
            FilledButton.tonal(
              onPressed: onKeep,
              child: const Text('Keep this name'),
            ),
            TextButton(
              onPressed: onDrop,
              child: const Text('Use what the photo said'),
            ),
          ],
        ),
      ],
    );
  }
}

/// How many of one product the photo showed, and the two ways to correct it
/// without going back to the shelf.
///
/// The scanner's stepper, in the same shape and with the same reasoning: the
/// prompt counts the front row only, so this is the control that exists to be
/// used, not an edge case. It moves in whole units of the thing on the shelf,
/// which is what the model counted and what a person recounts.
class _CountStepper extends StatelessWidget {
  const _CountStepper({
    required this.count,
    required this.label,
    required this.stockUp,
    required this.onLess,
    required this.onMore,
  });

  final int count;
  final String label;
  final bool stockUp;
  final VoidCallback? onLess;
  final VoidCallback onMore;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          onPressed: onLess,
          visualDensity: VisualDensity.compact,
          iconSize: 18,
          tooltip: 'One fewer $label',
          icon: const Icon(Icons.remove_circle_outline),
        ),
        ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 26),
          child: Semantics(
            label: stockUp ? '$count $label on the shelf' : '$count $label used',
            child: Text(
              '$count',
              textAlign: TextAlign.center,
              style: theme.textTheme.titleSmall,
            ),
          ),
        ),
        IconButton(
          onPressed: onMore,
          visualDensity: VisualDensity.compact,
          iconSize: 18,
          tooltip: 'One more $label',
          icon: const Icon(Icons.add_circle_outline),
        ),
      ],
    );
  }
}

/// What happened to one row, once the writing is over.
///
/// Failures carry the error rather than a shrug, because the person who took
/// the photo is the only one who can put it right and "some items failed" tells
/// them nothing about which or why.
class _OutcomeRow extends StatelessWidget {
  const _OutcomeRow({required this.outcome});

  final PantryVisionOutcome outcome;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final muted = scheme.onSurface.withValues(alpha: 0.6);
    final item = outcome.item;

    final (icon, tint) = switch (outcome) {
      final o when o.succeeded => (Icons.check_rounded, scheme.primary),
      final o when o.timedOut => (Icons.schedule_rounded, scheme.tertiary),
      _ => (Icons.error_outline_rounded, scheme.error),
    };

    final detail = switch (outcome) {
      final o when o.succeeded && item != null =>
        '${formatQuantity(item.quantity)}'
            '${(item.unit ?? '').trim().isEmpty ? '' : ' ${item.unit!.trim()}'}'
            ' in stock',
      final o when o.timedOut =>
        'No answer came back. It may or may not have gone in.',
      _ => householdErrorText(outcome.error ?? '', 'That one did not go in.'),
    };

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Icon(icon, size: 16, color: tint),
          ),
          const SizedBox(width: AppSpacing.s),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  item?.name ?? outcome.row.name,
                  style: theme.textTheme.bodyMedium,
                ),
                Text(
                  detail,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: muted,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// The one outcome that must not be offered a retry.
///
/// A timed-out write was abandoned, not undone: the request left, the answer
/// did not come back, and the server may well have applied it. "Try again"
/// there is how a shelf gets counted into a shared pantry twice, and the second
/// count is invisible afterwards. The only thing that answers the question is
/// looking at the pantry, so that is what is offered.
class _AbandonedNotice extends StatelessWidget {
  const _AbandonedNotice({required this.onCheckPantry});

  final VoidCallback onCheckPantry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tint = theme.colorScheme.tertiary;
    return HouseCard(
      tint: tint,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'These ran out of time rather than being refused, so they may have '
            'gone in anyway. Trying them again could count them twice - have a '
            'look at the pantry instead.',
            style: theme.textTheme.bodySmall?.copyWith(height: 1.4),
          ),
          const SizedBox(height: AppSpacing.s),
          Align(
            alignment: Alignment.centerLeft,
            child: FilledButton.icon(
              onPressed: onCheckPantry,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Check the pantry'),
            ),
          ),
        ],
      ),
    );
  }
}
