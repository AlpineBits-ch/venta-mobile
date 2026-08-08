import 'dart:async';
import 'dart:math' as math;

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../../core/media/camera_permission.dart';
import '../../../../core/theme/widget_styles.dart';
import '../../data/household_api_wave2.dart';
import '../../data/models/pantry_dto.dart';
import '../widgets/household_widgets.dart';

/// Filling the pantry by camera, a bagful at a time.
///
/// This is the one screen where a phone beats a laptop outright, and it is
/// built around the actual moment: somebody standing at an open cupboard with a
/// shopping bag, unpacking with one hand. So the camera stays live and the
/// screen never navigates away between items. A scan confirms by feel - a
/// haptic tick and a line sliding onto the tally - and the next packet can go
/// straight under the lens.
///
/// **There is exactly one interruption left, and it is now a rare one**: a code
/// that neither this house nor a shared public product catalog can put a name
/// to. The house's own name always wins. Failing that the catalog may suggest
/// one, which arrives on the scan itself, so the first packet of a common
/// grocery goes in without a keyboard. Failing both, somebody types a name once
/// and the house owns it from then on - still the normal outcome for cleaning
/// products and toiletries, where public coverage is close to nothing.
///
/// A suggestion is never forced on anybody. It is badged as a suggestion, it
/// carries the credit its licence requires, and one tap on the line opens the
/// same sheet the typing prompt uses - because a wrong name that is awkward to
/// fix is worse than no name at all.
///
/// The tally is not decoration either. Batch entry with no visible record is
/// how people end up scanning the same jar twice or missing one and not
/// knowing, so what this session added stays on screen and every line can be
/// taken back.
///
/// ## Saying what is happening
///
/// A scanner is the worst place in an app to be vague, because the person is
/// holding something and the only question they have is whether to move their
/// hand. So there is exactly one place that answers it - [_StatusStrip], which
/// is always on screen and always in one of four states - and the reticle
/// echoes the same state in colour, because that is where the eyes already
/// are.
///
/// Two of those states are the reason this exists. **Working** is not a mood,
/// it is an instruction: it names the code being looked up, it says in so many
/// words to hold still, and if it outlasts a few seconds it admits that and
/// offers a way out. **Failed** does not fade. A confirmation that disappears
/// is fine, because the tally behind it is the real record; a failure that
/// disappears is how somebody walks away believing a jar went in.
///
/// ## Not being able to hang
///
/// The scan request is the one call in this feature a person stands and waits
/// for, and it has more ways to be slow than a screen can guess at: fifteen
/// seconds of client timeout per attempt, up to three of those behind a `429`
/// backoff, and a catalog lookup on top. Nothing about that is wrong, but the
/// sum of it is a minute of "Putting it away…" - which is indistinguishable
/// from a bug and gets the app closed. So the wait is bounded here, by
/// [_scanDeadline], and the request is genuinely cancelled rather than left
/// running behind a screen that stopped caring - either by the deadline or by
/// the person, who gets a way out of it once it has gone on long enough to be
/// worth offering.
///
/// ## Both directions
///
/// The same screen runs backwards, and it has to. Filling a pantry is a burst
/// of ten minutes once a week; emptying one is every day for the rest of the
/// week, and doing that by hunting a named row down a list of fifty and hitting
/// a small minus button is the interaction that gets an inventory abandoned.
/// The packet is already in somebody's hand on the way to the bin. Pointing the
/// phone at it is the whole gesture.
///
/// So [PantryScanMode] swaps which call a scan makes and the words around it,
/// and nothing else: the camera, the frame, the status, the tally and the undo
/// are one screen because they are one interaction seen from either end.
enum PantryScanMode {
  /// Unpacking a bag. A scan adds stock, and an unknown code is worth stopping
  /// to name, because naming it is how the pantry learns.
  stockUp,

  /// Using things up. A scan takes one off, and an unknown code is simply not
  /// in this pantry - there is nothing to name and nothing to ask.
  useUp;

  bool get isStockUp => this == PantryScanMode.stockUp;
}

class PantryScannerScreen extends StatefulWidget {
  const PantryScannerScreen({
    super.key,
    required this.channelId,
    required this.channelName,
    required this.guildId,
    this.mode = PantryScanMode.stockUp,
  });

  final String channelId;

  /// `#fridge`, for the one line of context the camera view has room for.
  final String channelName;

  /// Correcting a name teaches the *house*, not this fridge: a code means the
  /// same product in the freezer as in the cellar, so the route behind it is
  /// guild-scoped and this screen needs the guild to reach it.
  final String guildId;

  final PantryScanMode mode;

  @override
  State<PantryScannerScreen> createState() => _PantryScannerScreenState();
}

/// One product this session moved, kept so it can be moved further or taken
/// back.
///
/// **One of these per product, not per scan.** Four identical yoghurts out of
/// one bag are one line saying four, because that is what is in the fridge and
/// what somebody checking their work is counting. Four identical lines is a
/// list nobody can read and a count nobody can trust.
class _Scanned {
  _Scanned({
    required this.item,
    required this.created,
    required this.quantityBefore,
    required this.step,
    this.catalog,
  });

  PantryItemDto item;

  /// Whether the first scan of this product added a row or topped up one that
  /// was already there - which is what "undo" has to mean two different things
  /// about.
  final bool created;

  /// The stock before this session touched it. Both the floor the stepper works
  /// down to and what undo restores.
  final double quantityBefore;

  /// What one scan of this product is worth.
  ///
  /// Not always one. A pantry that has learned "a pack of six" moves six per
  /// scan, and the stepper has to speak in the same units the camera does -
  /// otherwise tapping `+` after scanning adds a different amount than scanning
  /// again would, which is the sort of thing that makes people stop trusting a
  /// count.
  final double step;

  /// Set when a public catalog is what named this line, and cleared the moment
  /// somebody corrects it: from then on the name is the house's own and there
  /// is nothing left to attribute.
  ProductCatalogMatchDto? catalog;

  bool undone = false;

  /// How much of this product this session has moved, always positive.
  double get moved => (item.quantity - quantityBefore).abs();

  /// The same, counted in scans - what the stepper shows and what somebody
  /// standing at a cupboard is actually counting.
  int get count => step <= 0 ? 1 : (moved / step).round().clamp(1, 9999);
}

/// What the screen is doing, as the person holding the packet needs to hear it.
enum _Phase {
  /// Camera live, nothing in flight. Waiting for a barcode.
  idle,

  /// A request is out, or a name is being asked for. **Hold still.**
  working,

  /// The last scan went in.
  done,

  /// The last scan did not, and this does not clear itself.
  failed,
}

/// The single answer to "what is happening" - one of these is on screen at all
/// times.
///
/// Immutable and replaced wholesale rather than a handful of independent flags,
/// because the states are genuinely exclusive and the old shape (a `bool busy`
/// beside a `String? toast`) could hold "working" and "succeeded" at once and
/// show whichever one the layout happened to reach first.
class _Status {
  const _Status.idle() : phase = _Phase.idle, message = null, barcode = null;

  const _Status.working(this.message, {this.barcode}) : phase = _Phase.working;

  const _Status.done(this.message) : phase = _Phase.done, barcode = null;

  /// [barcode] is what makes "Try again" possible; without one - a failure that
  /// was not about a particular code - the strip is dismissible and nothing
  /// more.
  const _Status.failed(this.message, {this.barcode}) : phase = _Phase.failed;

  final _Phase phase;
  final String? message;

  /// The code this is about, when there is one.
  final String? barcode;
}

class _PantryScannerScreenState extends State<PantryScannerScreen> {
  /// `autoStart: false` so the camera only opens once permission has actually
  /// been granted - otherwise the plugin races the prompt and shows its own
  /// error view over the top.
  ///
  /// `DetectionSpeed.normal` rather than `noDuplicates`: a shopping bag holds
  /// four identical yoghurts, and refusing to read the same code twice would
  /// silently drop three of them. The repeat guard is [_recent], which is
  /// time-based and forgets.
  ///
  /// The rest of it is the difference between a scanner that reads a crumpled
  /// packet and one that does not:
  ///
  /// * `cameraResolution` - Android otherwise analyses **640x480**, which is
  ///   fine for a QR code held up deliberately and far too coarse for the thin
  ///   bars of an EAN-13 on a soup tin at arm's length. This is the single
  ///   biggest knob on this screen.
  /// * `formats` - a grocery barcode is one of six things. Naming them stops
  ///   the detector spending every frame also looking for QR, Aztec, PDF417
  ///   and Data Matrix, and stops it occasionally deciding that a fold in a
  ///   crisp packet is one of them.
  /// * `autoZoom` - the common failure is holding the packet too far back.
  ///   Android can close that gap itself, and does it faster than a person
  ///   reading a hint.
  /// * `lensType` - `any` means "first camera facing this way", which on
  ///   phones with several is sometimes the ultra-wide, whose minimum focus
  ///   distance makes small print hopeless.
  /// * `detectionTimeoutMs` - the throttle between detections. The default
  ///   250ms is set for memory headroom on old devices; 150 is still gentle and
  ///   takes a noticeable beat out of every single scan.
  final _controller = MobileScannerController(
    autoStart: false,
    detectionSpeed: DetectionSpeed.normal,
    detectionTimeoutMs: 150,
    cameraResolution: const Size(1920, 1080),
    lensType: CameraLensType.normal,
    autoZoom: true,
    formats: const [
      BarcodeFormat.ean13,
      BarcodeFormat.ean8,
      BarcodeFormat.upcA,
      BarcodeFormat.upcE,
      BarcodeFormat.code128,
      BarcodeFormat.itf14,
    ],
  );

  final _scanned = <_Scanned>[];

  /// Codes read in the last moment, so one packet held under the lens is not
  /// counted five times a second. Long enough to move a hand, short enough that
  /// the second identical yoghurt still goes in.
  final _recent = <String, DateTime>{};
  static const _repeatWindow = Duration(seconds: 3);

  /// The whole wait, not one attempt: the client already bounds a single
  /// request, and this bounds a request plus whatever backoff and catalog time
  /// ends up stacked on it. Long enough that a slow but working scan still
  /// lands, short enough that a person is never left guessing.
  static const _scanDeadline = Duration(seconds: 18);

  /// When a wait stops being "a moment" and starts needing an explanation and
  /// an exit.
  static const _slowAfter = Duration(seconds: 4);

  bool _permissionDenied = false;
  bool _cameraReady = false;

  _Status _status = const _Status.idle();

  /// Set while a scan is in flight or a name is being asked for. Detection
  /// keeps running underneath; this only stops a second request being queued
  /// behind the first, which is what turns one busy moment into five.
  bool get _busy => _status.phase == _Phase.working;

  /// Clears a success back to idle. Only ever set for [_Phase.done] - a failure
  /// that times itself out is a failure nobody sees.
  Timer? _clearTimer;

  /// Flips [_slow] once a wait has gone on long enough to deserve saying so.
  Timer? _slowTimer;
  bool _slow = false;

  /// The live request, so the deadline and the person both have something to
  /// actually cancel rather than just stop looking at.
  CancelToken? _inFlight;

  bool get _useUp => widget.mode == PantryScanMode.useUp;

  /// What this pantry holds, by barcode - loaded once in [PantryScanMode.useUp]
  /// and kept current from every response after that.
  ///
  /// Taking something out is a local lookup followed by one call, rather than
  /// the server-side resolution a scan-in does, because there is nothing to
  /// resolve: either this pantry has that code or it does not, and "it does
  /// not" is an answer better given instantly than after a round trip.
  final _byBarcode = <String, PantryItemDto>{};
  bool _stockLoaded = false;

  /// Tapping `+` four times is one intent, not four requests - the same rule
  /// the pantry list itself plays by, and for the same reason.
  final _commitTimers = <String, Timer>{};
  final _pendingQuantity = <String, double>{};
  static const _commitDelay = Duration(milliseconds: 600);

  @override
  void initState() {
    super.initState();
    unawaited(_requestCamera());
    if (_useUp) unawaited(_loadStock());
  }

  @override
  void dispose() {
    _clearTimer?.cancel();
    _slowTimer?.cancel();
    _inFlight?.cancel();
    for (final timer in _commitTimers.values) {
      timer.cancel();
    }
    // Fire and forget, exactly as the pantry list does on the way out: there is
    // no state left to reconcile against, and closing the camera a moment after
    // the last `+` is the most normal way there is to leave this screen.
    for (final entry in _pendingQuantity.entries) {
      householdApi
          .updatePantryItem(entry.key, quantity: entry.value)
          .then((_) {}, onError: (Object _) {});
    }
    unawaited(_controller.dispose());
    super.dispose();
  }

  Future<void> _requestCamera() async {
    final granted = await ensureCameraPermission();
    if (!mounted) return;
    if (!granted) {
      setState(() => _permissionDenied = true);
      return;
    }
    setState(() => _cameraReady = true);
    await _startCamera();
  }

  Future<void> _startCamera() async {
    try {
      await _controller.start();
    } catch (_) {
      // MobileScanner's own errorBuilder renders the failure in place from the
      // controller's error state, and there is nothing useful to add on top of
      // it beyond the retry that view already offers.
    }
  }

  /// Every status change goes through here so that the auto-clear timer can
  /// never outlive the thing it was started for - a success timer still ticking
  /// when a failure lands would wipe the failure two seconds later.
  ///
  /// [autoClear] is for the one kind of failure that is not about a jar - a
  /// frame the decoder choked on. Nothing was lost, nobody has to do anything,
  /// and leaving it up until dismissed would put a stale red bar under a
  /// scanner that is working perfectly well.
  void _setStatus(_Status status, {bool autoClear = false}) {
    _clearTimer?.cancel();
    _slowTimer?.cancel();
    if (!mounted) return;
    setState(() {
      _status = status;
      _slow = false;
    });

    switch (status.phase) {
      case _Phase.failed when autoClear:
      case _Phase.done:
        _clearTimer = Timer(const Duration(milliseconds: 2400), () {
          if (mounted && identical(_status, status)) {
            setState(() => _status = const _Status.idle());
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

  void _onDetect(BarcodeCapture capture) {
    if (_busy) return;

    final value = bestBarcodeOf(capture.barcodes);
    if (value == null) return;

    final now = DateTime.now();
    final last = _recent[value];
    if (last != null && now.difference(last) < _repeatWindow) return;

    // Cheap, but the map is otherwise append-only for the life of a session
    // that is deliberately long.
    _recent.removeWhere((_, at) => now.difference(at) > _repeatWindow);
    _recent[value] = now;

    unawaited(_scan(value));
  }

  /// This pantry's stock, for the lookup a scan-out does locally.
  ///
  /// A failure here is not fatal and deliberately not loud: the first scan will
  /// say plainly that it cannot find the code, which is the same sentence at
  /// the moment it actually matters.
  Future<void> _loadStock() async {
    try {
      final items = await householdApi
          .getPantryItems(widget.channelId)
          .timeout(_scanDeadline);
      if (!mounted) return;
      setState(() {
        for (final item in items) {
          final barcode = item.barcode;
          if (barcode != null && barcode.isNotEmpty) _byBarcode[barcode] = item;
        }
        _stockLoaded = true;
      });
    } catch (_) {
      if (mounted) setState(() => _stockLoaded = true);
    }
  }

  Future<void> _scan(String barcode, {String? name}) async {
    if (_useUp) return _scanOut(barcode);

    final token = CancelToken();
    _inFlight = token;
    _setStatus(_Status.working('Putting it away…', barcode: barcode));

    try {
      final existing = _entryFor(barcode);
      // Taps made in the last half-second have not reached the server yet, and
      // a scan is relative to what the server holds. Sending it first is what
      // stops "tap +, then scan again" quietly losing the scan.
      await _flushPending(existing);
      final result = await householdApi
          .scanPantryItem(
            widget.channelId,
            barcode: barcode,
            name: name,
            cancelToken: token,
          )
          .timeout(_scanDeadline, onTimeout: () {
            token.cancel('deadline');
            throw TimeoutException('scan');
          });
      if (!mounted) return;
      houseHaptic();
      _record(
        existing: existing,
        item: result.item,
        created: result.created,
        catalog: result.catalog,
        // Only meaningful on the first scan of a product; afterwards the line
        // already knows what one scan is worth.
        fallbackBefore: result.item.quantity - 1,
      );
      _setStatus(_Status.done(_doneMessage(_entryFor(barcode))));
    } on PantryNameRequired {
      if (!mounted) return;
      await _askForName(barcode);
    } on TimeoutException {
      // Nothing came back, so nobody knows whether the jar went in. Forget the
      // repeat guard: presenting the same packet again has to be allowed to do
      // something, and a duplicate is a line the tally can take back out
      // whereas a silently dropped item is not.
      _recent.remove(barcode);
      if (!mounted || !identical(_inFlight, token)) return;
      _setStatus(
        const _Status.failed(
          'That took too long. Check the tally before scanning it again.',
        ),
      );
    } catch (error) {
      _recent.remove(barcode);

      // A scan that has already been given up on says nothing. The person
      // stopped waiting, scanned the next packet, and the abandoned request's
      // cancellation lands here a moment later - reporting it now would wipe
      // the status of the scan they are actually watching and let the camera
      // fire a second request into the one already in flight.
      if (!mounted || !identical(_inFlight, token)) return;

      // A cancel the person asked for is not a failure to report back at them
      // either, even when it is still the current one.
      if (error is DioException && CancelToken.isCancel(error)) {
        _setStatus(const _Status.idle());
        return;
      }
      _setStatus(
        _Status.failed(
          householdErrorText(error, 'That one did not go in.'),
          barcode: barcode,
        ),
      );
    } finally {
      // Read before clearing: everything below is about whether *this* scan is
      // still the one on screen.
      final current = identical(_inFlight, token);
      if (current) _inFlight = null;

      // Any path that left the status on `working` - the name prompt returning,
      // a `!mounted` bail - has to hand the camera back.
      if (current && mounted && _status.phase == _Phase.working) {
        _setStatus(const _Status.idle());
      }
    }
  }

  /// Taking one off, by camera.
  ///
  /// Shorter than a scan-in and different in kind: there is no catalog to ask,
  /// no name to learn and nothing to create. Either this pantry has the code or
  /// the answer is "not here", and that answer is worth giving instantly rather
  /// than after a round trip - which is why the stock is held locally.
  Future<void> _scanOut(String barcode) async {
    final known = _byBarcode[barcode];
    if (known == null) {
      // Deliberately not offered as "shall I add it?". Somebody who came here
      // to empty a cupboard and is told the thing in their hand is not in it
      // wants that fact, not a different job.
      _setStatus(
        _Status.failed(
          _stockLoaded
              ? 'Nothing in ${widget.channelName} has that barcode.'
              : 'Still reading what is in ${widget.channelName} - try that '
                    'one again in a moment.',
          barcode: _stockLoaded ? null : barcode,
        ),
      );
      return;
    }

    if (known.quantity <= 0) {
      _setStatus(_Status.failed('${known.name} is already at nothing.'));
      return;
    }

    _setStatus(_Status.working('Taking it out…', barcode: barcode));
    try {
      final existing = _entryFor(barcode);
      await _flushPending(existing);
      final updated = await householdApi
          .consumePantryItem(known.id, amount: 1)
          .timeout(_scanDeadline, onTimeout: () => throw TimeoutException('use'));
      if (!mounted) return;
      houseHaptic();
      _byBarcode[barcode] = updated;
      _record(
        existing: existing,
        item: updated,
        created: false,
        fallbackBefore: known.quantity,
      );
      _setStatus(_Status.done(_doneMessage(_entryFor(barcode))));
    } on TimeoutException {
      _recent.remove(barcode);
      if (!mounted) return;
      _setStatus(
        const _Status.failed(
          'That took too long. Check the tally before scanning it again.',
        ),
      );
    } catch (error) {
      _recent.remove(barcode);
      if (!mounted) return;
      _setStatus(
        _Status.failed(
          householdErrorText(error, 'That one did not come out.'),
          barcode: barcode,
        ),
      );
    } finally {
      if (mounted && _status.phase == _Phase.working) {
        _setStatus(const _Status.idle());
      }
    }
  }

  _Scanned? _entryFor(String barcode) => _scanned
      .where((s) => !s.undone && s.item.barcode == barcode)
      .firstOrNull;

  /// Folds a scan into the tally - onto the line this product already has, or
  /// onto a new one.
  ///
  /// The folding is the point. Four identical yoghurts are one line saying
  /// four; the alternative is four lines nobody reads and a "put away" count
  /// that has to be added up by eye.
  void _record({
    required _Scanned? existing,
    required PantryItemDto item,
    required bool created,
    required double fallbackBefore,
    ProductCatalogMatchDto? catalog,
  }) {
    setState(() {
      if (existing != null) {
        existing.item = item;
        // A line already on the tally is moved back to the top, because the
        // thing just scanned is the thing being confirmed.
        _scanned
          ..remove(existing)
          ..insert(0, existing);
        return;
      }

      final before = fallbackBefore;
      _scanned.insert(
        0,
        _Scanned(
          item: item,
          created: created,
          quantityBefore: before,
          // What the server actually moved, which is not always one: a pantry
          // that has learned "a pack of six" moves six.
          step: (item.quantity - before).abs().clamp(1.0, 999999.0),
          catalog: catalog,
        ),
      );
    });
  }

  String _doneMessage(_Scanned? entry) {
    if (entry == null) return _useUp ? 'Taken out' : 'Put away';
    final unit = entry.item.unit?.trim();
    final stock =
        '${formatQuantity(entry.item.quantity)}'
        '${unit == null || unit.isEmpty ? '' : ' $unit'}';

    // The count is only worth saying once there is one to say. "Oat milk ×1" is
    // noise; "Oat milk ×4" is the whole reason somebody is looking.
    final times = entry.count > 1 ? ' ×${entry.count}' : '';
    return _useUp
        ? '${entry.item.name}$times · $stock left'
        : '${entry.item.name}$times · $stock';
  }

  /// One more of something already on the tally, or one fewer, without finding
  /// the packet again.
  ///
  /// This is what stops a bag of six yoghurts being six scans - and, going the
  /// other way, what stops "I took two" being a trip back to the list. It moves
  /// in whole scans rather than whole units so that `+` and the camera always
  /// mean the same thing.
  void _adjustEntry(_Scanned entry, int direction) {
    if (entry.undone) return;

    final delta = entry.step * direction * (_useUp ? -1 : 1);
    var next = entry.item.quantity + delta;

    // The floor is where this session found things, not zero: below that the
    // line would be claiming to have moved stock in the opposite direction,
    // and "put it back the way it was" is what undo is for.
    final floor = _useUp
        ? 0.0
        : entry.quantityBefore;
    final ceiling = _useUp ? entry.quantityBefore : 999999.0;
    next = next.clamp(floor, ceiling).toDouble();

    if (next == entry.item.quantity) return;

    houseHaptic();
    setState(() {
      entry.item = entry.item.copyWith(
        quantity: next,
        // Predicted locally so the pantry's own list is not the first place
        // somebody learns this dropped low.
        isLow: entry.item.lowThreshold != null &&
            next <= entry.item.lowThreshold!,
      );
    });

    final barcode = entry.item.barcode;
    if (barcode != null) _byBarcode[barcode] = entry.item;

    _commitTimers[entry.item.id]?.cancel();
    _pendingQuantity[entry.item.id] = next;
    _commitTimers[entry.item.id] = Timer(
      _commitDelay,
      () => unawaited(_commitQuantity(entry, next)),
    );
  }

  /// Sends a debounced change now, if there is one waiting.
  ///
  /// Called before every scan of a product that already has a line, because a
  /// scan is relative to what the *server* holds: a `+` still sitting in the
  /// debounce would be overwritten by the scan's response and vanish.
  Future<void> _flushPending(_Scanned? entry) async {
    if (entry == null) return;
    final id = entry.item.id;
    final pending = _pendingQuantity[id];
    if (pending == null) return;
    _commitTimers.remove(id)?.cancel();
    await _commitQuantity(entry, pending);
  }

  Future<void> _commitQuantity(_Scanned entry, double quantity) async {
    final id = entry.item.id;
    _pendingQuantity.remove(id);
    try {
      final updated = await householdApi
          .updatePantryItem(id, quantity: quantity)
          .timeout(_scanDeadline);
      if (!mounted) return;
      // Only if nothing has moved on since: a slow response landing on top of
      // taps made while it was in flight would silently undo them.
      if (_pendingQuantity.containsKey(id)) return;
      setState(() => entry.item = updated);
      final barcode = updated.barcode;
      if (barcode != null) _byBarcode[barcode] = updated;
    } catch (error) {
      if (!mounted) return;
      _setStatus(
        _Status.failed(householdErrorText(error, 'That count did not save.')),
      );
    }
  }

  /// The way out of a wait that has gone on too long. Deliberately not styled
  /// as an error afterwards: nothing failed, somebody chose to stop waiting.
  void _cancelScan() {
    _inFlight?.cancel('cancelled by the person scanning');
    _setStatus(const _Status.idle());
  }

  void _dismissStatus() => _setStatus(const _Status.idle());

  /// Re-runs whatever the failure was about, without asking somebody to find
  /// the packet and line it up a second time.
  void _retryLast() {
    final barcode = _status.barcode;
    if (barcode == null || _busy) return;
    _recent.remove(barcode);
    unawaited(_scan(barcode));
  }

  /// The detector itself failing - a frame it could not process, a decoder that
  /// threw. Rare, and previously swallowed by the plugin's default handler,
  /// which is how "nothing happens when I point it at things" becomes
  /// unreportable.
  void _onDetectError(Object error, StackTrace stackTrace) {
    if (_status.phase != _Phase.idle) return;
    _setStatus(
      const _Status.failed('That code could not be read.'),
      autoClear: true,
    );
  }

  /// Where the aiming frame goes, in the scanner's own coordinates.
  ///
  /// Wide and short rather than square: barcodes are wide, and a square reticle
  /// invites people to hold the packet too far back for the lens to focus. The
  /// cap keeps it sane on a tablet, where 86% of the width would be a frame
  /// wider than any packet.
  static Rect _reticleRect(Size size) {
    final width = math.min(size.width * 0.86, 420.0);
    final height = math.min(width / 2.0, size.height * 0.32);
    return Rect.fromCenter(
      center: Offset(size.width / 2, size.height * 0.42),
      width: width,
      height: height,
    );
  }

  /// The frame, loosened. See the note at the call site: the platform filter
  /// discards any code not *wholly* inside, so the window a person aims at has
  /// to be smaller than the window that counts.
  static Rect _scanWindowFor(Rect frame) => Rect.fromCenter(
    center: frame.center,
    width: frame.width * 1.15,
    height: frame.height * 1.8,
  );

  /// The only thing that stops the camera, and only when nothing at all could
  /// name the code.
  Future<void> _askForName(String barcode) async {
    _setStatus(_Status.working('Needs a name', barcode: barcode));
    final name = await _promptForName();
    if (name == null) {
      // Not an error, but not a success either, and it is the one outcome where
      // nothing at all reached the pantry - so it stays on screen until the
      // next scan rather than fading. The code is kept so "Try again" reopens
      // the prompt instead of asking somebody to find the packet again.
      _setStatus(
        _Status.failed(
          'Skipped - that one still needs a name',
          barcode: barcode,
        ),
      );
      return;
    }
    await _scan(barcode, name: name);
  }

  /// Correcting a name the catalog suggested, or one somebody typed earlier.
  ///
  /// Deliberately **not** a second scan. A scan would add stock nobody bought,
  /// could not be asked to add none, and would rewrite the learned default
  /// quantity from whatever the correction happened to carry; the dedicated
  /// route moves no stock at all. It also teaches the house, which is the whole
  /// point: from here on this flat's word beats the suggestion every time.
  Future<void> _rename(_Scanned entry) async {
    final barcode = entry.item.barcode;
    if (barcode == null || barcode.isEmpty) return;

    final suggestion = entry.catalog;

    // Held for the whole correction, not just the request. The camera is
    // stopped while the sheet is up, but the scan that was already in flight
    // when the row was tapped is not, and two writes about one barcode arriving
    // in either order is not a race worth having.
    _setStatus(_Status.working('Renaming…', barcode: barcode));

    try {
      final name = await _promptForName(
        initialName: entry.item.name,
        suggestion: suggestion?.name,
        brand: suggestion?.brand,
        attribution: suggestion?.attribution,
      );
      if (name == null || name == entry.item.name) return;
      _setStatus(_Status.working('Teaching the house…', barcode: barcode));

      // Bounded for the same reason the scan is: this one blocks the camera
      // while it runs, so a request that never answers is a scanner that never
      // scans again.
      final result = await householdApi
          .teachPantryBarcode(widget.guildId, barcode, name: name)
          .timeout(_scanDeadline);
      if (!mounted) return;

      // The server renames the jars still carrying the suggestion, in every
      // pantry of this house. Ours is usually among them, but not when somebody
      // had already given it a name of its own - so the tally follows what came
      // back rather than assuming.
      final renamed = result.renamedItems
          .where((item) => item.id == entry.item.id)
          .firstOrNull;

      houseHaptic();
      setState(() {
        if (renamed != null) entry.item = renamed;
        entry.catalog = null;
      });
      _setStatus(_Status.done('This house calls it $name now'));
    } on TimeoutException {
      if (mounted) {
        _setStatus(
          const _Status.failed(
            'That took too long. The name may or may not have stuck.',
          ),
        );
      }
    } catch (error) {
      if (mounted) {
        _setStatus(
          _Status.failed(
            householdErrorText(error, 'That name did not stick.'),
          ),
        );
      }
    } finally {
      // Cancelling out of the sheet leaves the status on `working` with nothing
      // behind it, which would wedge the scanner shut.
      if (mounted && _status.phase == _Phase.working) {
        _setStatus(const _Status.idle());
      }
    }
  }

  /// Stops the camera, asks, starts it again. Every prompt in this screen goes
  /// through here so that none of them can leave the scanner reading barcodes
  /// behind a keyboard.
  Future<String?> _promptForName({
    String? initialName,
    String? suggestion,
    String? brand,
    String? attribution,
  }) async {
    // Neither a stop that throws nor one that never answers may take the prompt
    // down with it. This is a platform call into a camera that may be mid-start,
    // and it is awaited *before* the only sheet on this screen - so on the day
    // it does not come back, the symptom is a live camera sitting under a
    // status that never changes and a person with no way forward. A scanner
    // left running behind a sheet is a far smaller problem than that.
    try {
      await _controller.stop().timeout(const Duration(seconds: 2));
    } catch (_) {}
    if (!mounted) return null;

    final name = await showHouseSheet<String>(
      context: context,
      builder: (_) => ProductNameSheet(
        initialName: initialName,
        suggestion: suggestion,
        brand: brand,
        attribution: attribution,
      ),
    );

    if (!mounted) return null;
    unawaited(_startCamera());

    final trimmed = name?.trim();
    return trimmed == null || trimmed.isEmpty ? null : trimmed;
  }

  /// Puts a whole line back the way it was found, however many scans and taps
  /// went into it.
  Future<void> _undo(_Scanned entry) async {
    // A debounced `+` still waiting to be sent would otherwise land after the
    // undo and put the stock straight back.
    _commitTimers[entry.item.id]?.cancel();
    _pendingQuantity.remove(entry.item.id);

    setState(() => entry.undone = true);
    try {
      // Only a line this session *created* is deleted. Everything else is
      // restored to the quantity it had, which is the only correct answer for a
      // jar that was already in the cupboard.
      if (entry.created) {
        await householdApi.deletePantryItem(entry.item.id).timeout(_scanDeadline);
        _byBarcode.remove(entry.item.barcode);
      } else {
        final updated = await householdApi
            .updatePantryItem(entry.item.id, quantity: entry.quantityBefore)
            .timeout(_scanDeadline);
        final barcode = updated.barcode;
        if (barcode != null) _byBarcode[barcode] = updated;
      }
      if (!mounted) return;
      _setStatus(
        _Status.done(
          _useUp
              ? 'Put ${entry.item.name} back'
              : 'Took ${entry.item.name} back out',
        ),
      );
    } catch (error) {
      if (!mounted) return;
      setState(() => entry.undone = false);
      _setStatus(
        _Status.failed(householdErrorText(error, 'Could not undo that.')),
      );
    }
  }

  /// What the screen hands back on the way out: **scans, not lines**.
  ///
  /// Four yoghurts on one line is four things put away, and the pantry behind
  /// this screen says so in a sentence. Counting lines instead would have
  /// folding the tally quietly change the number.
  int get _movedCount =>
      _scanned.where((s) => !s.undone).fold(0, (sum, s) => sum + s.count);

  @override
  Widget build(BuildContext context) {
    // The one screen in the app whose background is a camera rather than the
    // theme's surface, so the status-bar icons are forced light here instead of
    // following the app theme into being invisible.
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: Colors.black,
        body: _permissionDenied
            ? _CameraDenied(onOpenSettings: () => unawaited(openAppSettings()))
            : LayoutBuilder(
                builder: (context, constraints) {
                  final frame = _reticleRect(constraints.biggest);
                  return Stack(
                    fit: StackFit.expand,
                    children: [
                      if (_cameraReady)
                        MobileScanner(
                          controller: _controller,
                          onDetect: _onDetect,
                          onDetectError: _onDetectError,

                          // The camera can only focus where it is asked to, and
                          // a barcode on a curved jar under kitchen lighting is
                          // exactly the case where autofocus settles on the
                          // wrong plane. This costs nothing and rescues the
                          // scans that would otherwise just never resolve.
                          tapToFocus: true,

                          // What the frame draws is what the detector reads.
                          // Without this the reticle is decoration - detection
                          // is full-frame, and a bag with four packets in it
                          // hands back whichever code was luckiest rather than
                          // the one being held up.
                          //
                          // Deliberately larger than the drawn frame: the
                          // filter is *containment*, so a code overlapping the
                          // line would otherwise be thrown away, and a frame
                          // that punishes near-misses is worse than no frame.
                          scanWindow: _scanWindowFor(frame),
                          scanWindowUpdateThreshold: 8,
                          placeholderBuilder: (context) =>
                              const _CameraStarting(),
                          errorBuilder: (context, error) => _CameraUnavailable(
                            onRetry: () => unawaited(_startCamera()),
                          ),
                        )
                      else
                        const _CameraStarting(),
                      IgnorePointer(
                        child: _ScanReticle(rect: frame, phase: _status.phase),
                      ),
                      SafeArea(
                        child: Column(
                          children: [
                            _ScannerBar(
                              controller: _controller,
                              channelName: widget.channelName,
                              mode: widget.mode,
                              onClose: () =>
                                  Navigator.of(context).pop(_movedCount),
                            ),
                            Expanded(
                              child: Align(
                                alignment: Alignment.topCenter,
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                    top: AppSpacing.m,
                                  ),
                                  // Nothing up here is interactive, and the
                                  // camera underneath now takes a tap to
                                  // focus - so the hint must not eat one.
                                  child: IgnorePointer(
                                    child: _AimHint(
                                      visible:
                                          _status.phase == _Phase.idle &&
                                          _scanned.isEmpty,
                                      mode: widget.mode,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(
                                AppSpacing.m,
                                0,
                                AppSpacing.m,
                                AppSpacing.s,
                              ),
                              child: _StatusStrip(
                                status: _status,
                                slow: _slow,
                                onCancel: _cancelScan,
                                onRetry: _retryLast,
                                onDismiss: _dismissStatus,
                              ),
                            ),
                            _Tally(
                              entries: _scanned,
                              mode: widget.mode,
                              onUndo: _undo,
                              onRename: _rename,
                              onAdjust: _adjustEntry,
                              onDone: () =>
                                  Navigator.of(context).pop(_movedCount),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
      ),
    );
  }
}

/// Which of the codes in frame the person actually meant, or nothing.
///
/// Both halves of this matter in a kitchen, and both used to be left to luck.
///
/// A shopping bag puts three or four barcodes in frame at once - the packet
/// being held up, and whatever else is lying on the counter behind it. Picking
/// "the first one with a value" picked among those by list order. The one held
/// up to the lens is the one taking up the most of the frame, so that is the
/// one taken.
///
/// And a partly-read EAN comes back looking exactly like a real code: the right
/// length, all digits, one of them wrong. Accepting it puts a barcode that
/// belongs to nothing into the pantry, asks somebody to name it, and teaches
/// the house that name for good. The check digit these formats carry exists to
/// catch precisely that, so it is checked rather than assumed.
///
/// Extracted from the screen because getting the checksum subtly wrong would
/// reject every genuine scan while looking entirely reasonable, which is the
/// definition of something that needs a test.
String? bestBarcodeOf(List<Barcode> barcodes) {
  String? best;
  var bestArea = -1.0;

  for (final barcode in barcodes) {
    final raw = barcode.rawValue;
    if (raw == null || raw.isEmpty) continue;
    if (!isPlausibleBarcode(barcode.format, raw)) continue;

    final area = barcode.size.width * barcode.size.height;
    if (best == null || area > bestArea) {
      best = raw;
      bestArea = area;
    }
  }

  return best;
}

/// Whether a decoded string is worth acting on, given what format it claims to
/// be.
bool isPlausibleBarcode(BarcodeFormat format, String raw) {
  switch (format) {
    // The GTIN family, every member of which ends in a mod-10 check digit.
    case BarcodeFormat.ean13:
    case BarcodeFormat.ean8:
    case BarcodeFormat.upcA:
      return gtinChecksumHolds(raw);
    // UPC-E is a compressed GTIN whose check digit belongs to the expanded
    // form, so the digits are all there is to go on here.
    case BarcodeFormat.upcE:
      return raw.length >= 6 && _digitsOnly.hasMatch(raw);
    // Code 128 and ITF-14 carry nothing that can be relied on this side of the
    // symbology. A length floor is all that separates a code from a smear.
    default:
      return raw.trim().length >= 4;
  }
}

final _digitsOnly = RegExp(r'^\d+$');

/// Weights of 1 and 3 alternating from the right, check digit included, and the
/// sum divisible by ten. The same rule for EAN-8, EAN-13 and UPC-A.
bool gtinChecksumHolds(String raw) {
  if (raw.length < 8) return false;
  var sum = 0;
  for (var i = 0; i < raw.length; i++) {
    final digit = raw.codeUnitAt(raw.length - 1 - i) - 0x30;
    if (digit < 0 || digit > 9) return false;
    sum += i.isOdd ? digit * 3 : digit;
  }
  return sum % 10 == 0;
}

/// Top row: which way round this is, the torch, and the way out.
///
/// The direction is stated here rather than left to be inferred from the
/// buttons, because the two modes look identical through a lens and getting
/// them the wrong way round empties a cupboard somebody was trying to fill.
class _ScannerBar extends StatelessWidget {
  const _ScannerBar({
    required this.controller,
    required this.channelName,
    required this.mode,
    required this.onClose,
  });

  final MobileScannerController controller;
  final String channelName;
  final PantryScanMode mode;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
      child: Row(
        children: [
          IconButton(
            onPressed: onClose,
            iconSize: 26,
            color: Colors.white,
            tooltip: 'Stop scanning',
            icon: const Icon(Icons.close_rounded),
          ),
          Expanded(
            child: Text(
              mode.isStockUp
                  ? 'Filling $channelName'
                  : 'Using up from $channelName',
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.titleSmall?.copyWith(color: Colors.white),
            ),
          ),
          ValueListenableBuilder<MobileScannerState>(
            valueListenable: controller,
            builder: (context, state, _) => IconButton(
              iconSize: 26,
              color: Colors.white,
              tooltip: state.torchState == TorchState.on
                  ? 'Turn the light off'
                  : 'Turn the light on',
              icon: Icon(
                state.torchState == TorchState.on
                    ? Icons.flashlight_on_rounded
                    : Icons.flashlight_off_rounded,
              ),
              onPressed: state.torchState == TorchState.unavailable
                  ? null
                  : () => unawaited(controller.toggleTorch()),
            ),
          ),
        ],
      ),
    );
  }
}

/// The aiming frame, which also happens to be the fastest way to say what the
/// screen is doing.
///
/// It changes colour with the phase, and that is not decoration: the eyes are
/// already here, on the packet under the lens, and a person who has just heard
/// the haptic wants to know within one glance whether to move their hand. The
/// strip at the bottom carries the words; this carries the answer.
class _ScanReticle extends StatelessWidget {
  const _ScanReticle({required this.rect, required this.phase});

  final Rect rect;
  final _Phase phase;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final (color, width) = switch (phase) {
      _Phase.idle => (Colors.white.withValues(alpha: 0.75), 2.0),
      _Phase.working => (Colors.white, 3.0),
      _Phase.done => (scheme.primary, 3.0),
      _Phase.failed => (scheme.error, 3.0),
    };

    return Stack(
      children: [
        Positioned.fromRect(
          rect: rect,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadii.dialog),
              border: Border.all(color: color, width: width),
            ),
          ),
        ),
      ],
    );
  }
}

/// The one thing a first-time user needs and nobody else does, so it leaves as
/// soon as the first packet goes in.
class _AimHint extends StatelessWidget {
  const _AimHint({required this.visible, required this.mode});

  final bool visible;
  final PantryScanMode mode;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: visible ? 1 : 0,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.m,
          vertical: AppSpacing.s,
        ),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.45),
          borderRadius: BorderRadius.circular(AppRadii.composerPill),
        ),
        child: Text(
          mode.isStockUp
              ? 'Hold a barcode in the frame · tap to focus'
              : 'Scan what you are taking out · tap to focus',
          style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white),
        ),
      ),
    );
  }
}

/// The single answer to "what is happening", in words.
///
/// Always on screen and always the same height, because a strip that appears
/// and disappears moves the tally under somebody's thumb mid-tap, and because
/// "there is nothing here" is itself an answer worth being able to read at a
/// glance.
///
/// The four states are deliberately not equal. Idle is nearly invisible.
/// Success says what went in and gets out of the way after a couple of seconds,
/// because the tally below is the durable record. Working says *hold still* in
/// so many words, and if it lasts long enough to feel wrong it says that too
/// and offers a way out. Failure does not leave on its own and carries the way
/// to try again - a scanner that silently forgets a failure is a scanner that
/// quietly loses shopping.
class _StatusStrip extends StatelessWidget {
  const _StatusStrip({
    required this.status,
    required this.slow,
    required this.onCancel,
    required this.onRetry,
    required this.onDismiss,
  });

  final _Status status;

  /// Whether the wait has gone on long enough to owe an explanation.
  final bool slow;

  final VoidCallback onCancel;
  final VoidCallback onRetry;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final (background, foreground) = switch (status.phase) {
      _Phase.idle => (Colors.black.withValues(alpha: 0.35), Colors.white70),
      _Phase.working => (Colors.black.withValues(alpha: 0.72), Colors.white),
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

        // Actions sit under the message rather than beside it. A `Try again`
        // and a dismiss on the same line as the server's own error wording is
        // fine at normal text size and runs off the edge of a 390pt phone at
        // the largest accessibility step - which is the one population most
        // likely to be reading an error rather than skimming past it.
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
              Row(mainAxisAlignment: MainAxisAlignment.end, children: actions),
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
    _Phase.idle => Icon(
      Icons.qr_code_scanner_rounded,
      size: 18,
      color: foreground,
    ),
  };

  Widget _text(ThemeData theme, Color foreground) {
    final message = switch (status.phase) {
      _Phase.idle => 'Ready',
      _ => status.message ?? '',
    };

    // The second line only ever exists to keep somebody's hands still, or to
    // admit that this is taking longer than it should.
    final detail = switch (status.phase) {
      _Phase.working when slow =>
        'Still going. Your connection or the product catalogue is slow - '
            'nothing has been lost.',
      _Phase.working => 'Hold on - do not scan the next one yet.',
      _ => null,
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
                color: foreground.withValues(alpha: 0.75),
                height: 1.3,
              ),
            ),
          ),
      ],
    );
  }

  List<Widget> _actions(Color foreground) {
    // Nothing offered until waiting has actually become unreasonable: a Cancel
    // button on the 300ms path is a button nobody needs and everybody reads.
    if (status.phase == _Phase.working) {
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
        if (status.barcode != null)
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

/// What went in this session, and the way out.
///
/// It grows to a few rows and then scrolls, so the camera keeps most of the
/// screen: the tally is a receipt, not the task. "Done" sits in it rather than
/// in the app bar because this screen is used one-handed and the top corners of
/// a phone are the two places a thumb cannot reach.
class _Tally extends StatelessWidget {
  const _Tally({
    required this.entries,
    required this.mode,
    required this.onUndo,
    required this.onRename,
    required this.onAdjust,
    required this.onDone,
  });

  final List<_Scanned> entries;
  final PantryScanMode mode;
  final void Function(_Scanned) onUndo;
  final void Function(_Scanned) onRename;

  /// `+1` / `-1`, in whole scans.
  final void Function(_Scanned, int) onAdjust;

  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final live = entries.where((e) => !e.undone).toList();
    final moved = live.fold(0, (sum, entry) => sum + entry.count);

    // The credit for whatever the catalog named in this session, once, under
    // the lines it covers. Once rather than per row because it is the same
    // notice every time and a scanner is not the place for a stack of them; the
    // per-row badge is what says which lines it is about.
    final attribution = live
        .map((entry) => entry.catalog?.attribution)
        .whereType<String>()
        .where((text) => text.trim().isNotEmpty)
        .firstOrNull;

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppRadii.dialog),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.m,
        AppSpacing.m,
        AppSpacing.m,
        AppSpacing.m,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (live.isEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.m),
              child: Text(
                mode.isStockUp
                    ? 'Nothing in yet. Everything you scan lands here, and you '
                          'can add more of it or take it back out.'
                    : 'Nothing out yet. Scan what you are using and it lands '
                          'here, where you can take more or put it back.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  height: 1.4,
                ),
              ),
            )
          else ...[
            HouseSectionHeader(
              // Counted in things, not lines: four yoghurts folded onto one row
              // are still four things, and the header is the number somebody
              // checks their bag against.
              label: moved == 1
                  ? (mode.isStockUp ? '1 thing put away' : '1 thing used')
                  : (mode.isStockUp ? 'Put away' : 'Used up'),
              trailing: Text('$moved'),
            ),
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 196),
              child: ListView.builder(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                itemCount: live.length,
                itemBuilder: (context, index) => _TallyRow(
                  entry: live[index],
                  mode: mode,
                  onUndo: onUndo,
                  onRename: onRename,
                  onAdjust: onAdjust,
                ),
              ),
            ),
            if (attribution != null) ...[
              const SizedBox(height: AppSpacing.s),
              ProductSourceNote(attribution: attribution),
            ],
            const SizedBox(height: AppSpacing.s),
          ],
          HousePrimaryButton(
            label: live.isEmpty
                ? 'Done'
                : moved == 1
                ? 'Done · 1 thing'
                : 'Done · $moved things',
            icon: Icons.check_rounded,
            onPressed: onDone,
          ),
        ],
      ),
    );
  }
}

/// One line of the receipt: which product, how many of it this session moved,
/// where that leaves the cupboard, and the three things that can be done about
/// it.
///
/// The name is a button. That is the whole correction affordance, and it is on
/// every row rather than only on catalog-named ones: a typo somebody made in
/// the naming sheet thirty seconds ago is exactly as worth fixing as a wrong
/// suggestion, and two different ways to fix a name would be one too many.
///
/// The stepper is the other half of the point. A bag with six identical
/// yoghurts in it should not be six trips past the lens, each one waiting out
/// the repeat guard - it should be one scan and five taps, and the taps have to
/// move in the same units the camera does or the two disagree.
class _TallyRow extends StatelessWidget {
  const _TallyRow({
    required this.entry,
    required this.mode,
    required this.onUndo,
    required this.onRename,
    required this.onAdjust,
  });

  final _Scanned entry;
  final PantryScanMode mode;
  final void Function(_Scanned) onUndo;
  final void Function(_Scanned) onRename;
  final void Function(_Scanned, int) onAdjust;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurface.withValues(alpha: 0.6);
    final unit = entry.item.unit?.trim();
    final suggested = entry.catalog != null;
    final canRename = (entry.item.barcode ?? '').isNotEmpty;

    final stock =
        '${formatQuantity(entry.item.quantity)}'
        '${unit == null || unit.isEmpty ? '' : ' $unit'}';

    final name = Row(
      children: [
        Flexible(
          child: Text(
            entry.item.name,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodyMedium,
          ),
        ),
        if (suggested) ...[
          const SizedBox(width: 6),

          // Flexible, not fixed: at the largest text size the word "Suggested"
          // is wider than the slot a long product name leaves it, and a pill
          // that cannot shrink takes the whole row over the edge with it. The
          // pill ellipsises down to its icon, which still says what it means.
          const Flexible(child: SuggestedNameBadge()),
        ],
      ],
    );

    // Both numbers, because they answer different questions and people ask
    // both: "how many did I just do" is what the tally is for, "what is in
    // there now" is why they were counting.
    final detail = Text(
      mode.isStockUp ? '$stock in stock' : '$stock left',
      style: theme.textTheme.labelSmall?.copyWith(color: muted),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(
            entry.created
                ? Icons.add_circle_outline_rounded
                : mode.isStockUp
                ? Icons.arrow_upward_rounded
                : Icons.arrow_downward_rounded,
            size: 16,
            color: muted,
          ),
          const SizedBox(width: AppSpacing.s),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (canRename)
                  InkWell(
                    onTap: () => onRename(entry),
                    borderRadius: BorderRadius.circular(AppRadii.badge),
                    child: Semantics(
                      button: true,
                      label: suggested
                          ? '${entry.item.name}, suggested name, tap to change it'
                          : '${entry.item.name}, tap to change the name',
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: name,
                      ),
                    ),
                  )
                else
                  name,
                detail,
              ],
            ),
          ),
          _TallyStepper(
            count: entry.count,
            label: entry.item.name,
            mode: mode,
            // Below one scan there is nothing left to take off - that is what
            // undo is for, and it sits right beside this.
            onLess: entry.count <= 1 ? null : () => onAdjust(entry, -1),
            onMore: () => onAdjust(entry, 1),
          ),
          IconButton(
            onPressed: () => onUndo(entry),
            visualDensity: VisualDensity.compact,
            iconSize: 18,
            tooltip: mode.isStockUp
                ? 'Take ${entry.item.name} back out'
                : 'Put ${entry.item.name} back',
            icon: const Icon(Icons.undo_rounded),
          ),
        ],
      ),
    );
  }
}

/// How many scans' worth of one product this session has moved, and the two
/// ways to change it without finding the packet again.
///
/// Counted in scans rather than units on purpose. A pantry that has learned
/// "a pack of six" moves six per scan, and a stepper that moved one at a time
/// would mean `+` and the camera did different things - which is exactly how a
/// count stops being trusted.
class _TallyStepper extends StatelessWidget {
  const _TallyStepper({
    required this.count,
    required this.label,
    required this.mode,
    required this.onLess,
    required this.onMore,
  });

  final int count;
  final String label;
  final PantryScanMode mode;
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
          tooltip: mode.isStockUp ? 'One fewer $label' : 'Take one less $label',
          icon: const Icon(Icons.remove_circle_outline),
        ),
        ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 26),
          child: Semantics(
            label: mode.isStockUp
                ? '$count $label put away'
                : '$count $label used',
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
          tooltip: mode.isStockUp ? 'One more $label' : 'Take one more $label',
          icon: const Icon(Icons.add_circle_outline),
        ),
      ],
    );
  }
}

class _CameraDenied extends StatelessWidget {
  const _CameraDenied({required this.onOpenSettings});

  final VoidCallback onOpenSettings;

  @override
  Widget build(BuildContext context) {
    return _ScannerMessage(
      icon: Icons.no_photography_outlined,
      title: 'Camera access is off',
      body:
          'Scanning needs the camera. Turn it on in system settings and come '
          'back - you can always add things to the pantry by hand instead.',
      action: FilledButton(
        onPressed: onOpenSettings,
        child: const Text('Open settings'),
      ),
    );
  }
}

/// The gap between opening this screen and the preview appearing, which on a
/// cold camera is a second or more of otherwise unexplained black.
class _CameraStarting extends StatelessWidget {
  const _CameraStarting();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ColoredBox(
      color: Colors.black,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white70),
              ),
            ),
            const SizedBox(height: AppSpacing.m),
            Text(
              'Starting the camera…',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CameraUnavailable extends StatelessWidget {
  const _CameraUnavailable({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return _ScannerMessage(
      icon: Icons.videocam_off_outlined,
      title: 'Camera unavailable',
      body:
          'The camera could not be started. Close anything else using it and '
          'try again.',
      // Worth a button rather than a "come back later": the usual cause is
      // another app holding the camera, which is fixed by the time somebody has
      // read this sentence.
      action: FilledButton(
        onPressed: onRetry,
        child: const Text('Try again'),
      ),
    );
  }
}

class _ScannerMessage extends StatelessWidget {
  const _ScannerMessage({
    required this.icon,
    required this.title,
    required this.body,
    this.action,
  });

  final IconData icon;
  final String title;
  final String body;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      child: Stack(
        children: [
          Align(
            alignment: Alignment.topLeft,
            child: IconButton(
              onPressed: () => Navigator.of(context).pop(0),
              color: Colors.white,
              tooltip: 'Back',
              icon: const Icon(Icons.close_rounded),
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: 44, color: Colors.white70),
                  const SizedBox(height: AppSpacing.m),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    body,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white70,
                      height: 1.4,
                    ),
                  ),
                  if (action != null) ...[
                    const SizedBox(height: AppSpacing.l),
                    action!,
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
