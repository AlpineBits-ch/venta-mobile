/// What a model is allowed to say about a photograph of a shelf, and what the
/// app is allowed to believe about it.
///
/// See `docs/pantry-vision.md` for the whole design. The one rule worth
/// repeating here, because it is the rule the whole feature rests on:
///
/// **There is no barcode field, anywhere in this file, on purpose.**
///
/// An EAN is thirteen digits that are in practice never legible in a photo of
/// a cupboard. Every model in scope will produce a confident, plausible, wrong
/// one if the schema gives it somewhere to put one - and a wrong barcode does
/// not fail loudly. It writes a product that does not exist into a shared
/// pantry, asks somebody to name it, and teaches the house that name for good.
/// So the schema has no barcode field: not an optional one, not a nullable
/// one. There is nothing to hallucinate into.
///
/// Names are resolved to real products afterwards, on the device, against
/// things this house already knows - see the resolution ladder in the doc.
library;

import '../locale/app_language.dart';

/// How sure the model says it is. Advisory only: it orders the review list and
/// marks the rows worth a second look. It never gates a write - a person does
/// that.
enum VisionConfidence {
  high,
  medium,
  low;

  static VisionConfidence parse(Object? raw) => switch (raw) {
    'high' => VisionConfidence.high,
    'low' => VisionConfidence.low,
    // Anything unrecognised is treated as the middle. A model that invents a
    // fourth level should not take a row off the list.
    _ => VisionConfidence.medium,
  };
}

/// One product the model claims to see, in the words a person could read off
/// the same photo.
class PantryVisionItem {
  const PantryVisionItem({
    required this.name,
    required this.count,
    this.brand,
    this.size,
    this.unit,
    this.confidence = VisionConfidence.medium,
    this.note,
  });

  /// What it is. The only required field beyond the count, and the key the
  /// resolution ladder matches on.
  final String name;

  /// How many are visible **in the front row**. The prompt is explicit that
  /// this is a count of what can be seen, not an estimate of what is behind
  /// it: models are unreliable on stacked and occluded goods, and a confident
  /// guess about the back of a shelf is worse than an honest small number that
  /// somebody corrects with a stepper.
  final int count;

  final String? brand;

  /// Pack size as printed, as a numeric string ("1", "500"). Kept apart from
  /// [unit] so the two can be recombined or dropped independently.
  final String? size;

  /// The unit that goes with [size] - "l", "g", "ml".
  final String? unit;

  final VisionConfidence confidence;

  /// One short clause about why this row is uncertain ("partly hidden",
  /// "label at an angle"). Shown on the review row; never acted on.
  final String? note;

  /// The name with the brand attached, for a review row that has space.
  String get displayName {
    final b = brand?.trim();
    if (b == null || b.isEmpty || name.toLowerCase().contains(b.toLowerCase())) {
      return name;
    }
    return '$name · $b';
  }

  /// The form both the resolution ladder and the de-duplicator compare on.
  ///
  /// Deliberately blunt: case-folded, punctuation-stripped, whitespace
  /// collapsed. It is matching "Oat Milk" against "oat milk", not doing
  /// linguistics - anything cleverer would start silently merging products
  /// that are genuinely different.
  String get matchKey => normaliseProductName(name);

  PantryVisionItem copyWith({String? name, int? count}) => PantryVisionItem(
    name: name ?? this.name,
    count: count ?? this.count,
    brand: brand,
    size: size,
    unit: unit,
    confidence: confidence,
    note: note,
  );

  /// Tolerant by design. A response that satisfies the schema still arrives
  /// from a third party over a network: a missing name or a zero count is a
  /// row to drop, not an exception to throw, because one bad row must not cost
  /// the user the other eleven.
  static PantryVisionItem? tryParse(Object? raw) {
    if (raw is! Map) return null;
    final name = (raw['name'] as Object?)?.toString().trim();
    if (name == null || name.isEmpty) return null;

    final count = switch (raw['count']) {
      final int n => n,
      final num n => n.round(),
      final String s => int.tryParse(s.trim()) ?? 1,
      _ => 1,
    };
    if (count < 1) return null;

    String? text(Object? value) {
      final s = value?.toString().trim();
      return s == null || s.isEmpty ? null : s;
    }

    return PantryVisionItem(
      name: name,
      // A model that reports fifty of something has misread a display shelf.
      // Clamped rather than dropped: the row is probably real, the number is
      // not, and the stepper is right there.
      count: count.clamp(1, 99),
      brand: text(raw['brand']),
      size: text(raw['size']),
      unit: text(raw['unit']),
      confidence: VisionConfidence.parse(raw['confidence']),
      note: text(raw['note']),
    );
  }
}

/// Everything one photograph produced.
class PantryVisionResult {
  const PantryVisionResult({required this.items, this.unreadable = 0});

  final List<PantryVisionItem> items;

  /// Things the model can see but cannot identify.
  ///
  /// This is the honest half of the answer and it is shown to the user. A
  /// model that silently returns eight of the eleven things on a shelf looks
  /// exactly like a model that got all of them; a model that says "and three
  /// more I could not read" is one somebody can actually check.
  final int unreadable;

  bool get isEmpty => items.isEmpty;

  static PantryVisionResult parse(Map<String, Object?> json) {
    final rawItems = json['items'];
    final items = <PantryVisionItem>[];
    if (rawItems is List) {
      for (final entry in rawItems) {
        final item = PantryVisionItem.tryParse(entry);
        if (item != null) items.add(item);
      }
    }

    final unreadable = switch (json['unreadable']) {
      final int n => n,
      final num n => n.round(),
      final String s => int.tryParse(s.trim()) ?? 0,
      _ => 0,
    };

    return PantryVisionResult(
      items: items,
      unreadable: unreadable < 0 ? 0 : unreadable,
    );
  }

  /// Folds several photos of the same cupboard into one list.
  ///
  /// Counts **add** across photos, because two photos of one shelf are two
  /// views of different parts of it - the alternative (taking the maximum)
  /// silently loses the second half of a wide cupboard. Overlapping photos
  /// therefore over-count, which is exactly what the review step is for and is
  /// the safer direction to be wrong in: a number somebody lowers beats stock
  /// that was never recorded.
  static PantryVisionResult merge(Iterable<PantryVisionResult> results) {
    final byKey = <String, PantryVisionItem>{};
    var unreadable = 0;

    for (final result in results) {
      unreadable += result.unreadable;
      for (final item in result.items) {
        final existing = byKey[item.matchKey];
        byKey[item.matchKey] = existing == null
            ? item
            : existing.copyWith(count: existing.count + item.count);
      }
    }

    return PantryVisionResult(
      items: byKey.values.toList(),
      unreadable: unreadable,
    );
  }
}

/// Deleted rather than spaced, unlike the rest of the punctuation. An
/// apostrophe joins a word to itself - "Grandma's jam" is one word plus a
/// possessive, not two - so spacing it gives `grandma s jam`, which matches
/// neither `grandmas jam` nor anything else a person would type. The rest of
/// the punctuation genuinely separates words and becomes a space.
final _apostrophes = RegExp(r"['‘’ʼ`]");

/// Letters and digits in **any** alphabet, not just the ASCII ones.
///
/// This was `[^\w\s]` and looked unicode-aware because it carries
/// `unicode: true`. It is not: Dart follows ECMAScript, where `\w` means
/// `[A-Za-z0-9_]` no matter which flags are set, and the flag only changes how
/// the pattern is *parsed*. So every accented letter counted as punctuation and
/// was replaced by a space - `Müsli` normalised to `m sli`, `Caffè` to `caff`.
///
/// That was survivable while the model answered in English and broke the moment
/// it started answering in the language on the packet, which is the whole point
/// of the language-aware prompt below. Two ways, both silent: `Müsli` and
/// `Mösli` collapsed onto the same key and merged into one row, and a pantry
/// item somebody typed as `Caffe` no longer matched the `Caffè` read off the
/// shelf, so the ladder created a duplicate.
///
/// `\p{L}\p{N}` is the same rule the old one was meant to express. It is
/// deliberately **not** transliteration: `ü` stays `ü` and does not become `ue`
/// or `u`, because folding accents away merges products that genuinely differ.
final _punctuation = RegExp(r'[^\p{L}\p{N}_\s]', unicode: true);
final _whitespace = RegExp(r'\s+');

/// The single comparison form for product names, shared by the merger and the
/// resolution ladder so the two can never disagree about whether two rows are
/// the same product.
String normaliseProductName(String raw) => raw
    .toLowerCase()
    .replaceAll(_apostrophes, '')
    .replaceAll(_punctuation, ' ')
    .replaceAll(_whitespace, ' ')
    .trim();

/// The JSON Schema every provider is held to.
///
/// `additionalProperties: false` throughout because two of the three providers
/// require it for strict mode, and because a model that invents a field is a
/// model about to invent a barcode.
///
/// Deliberately flat and small: no nesting beyond one array of objects, no
/// enums the providers disagree about, no constraints (`minimum`, `maxLength`)
/// that some of them silently drop. Everything that could be validated here
/// and is not is validated in [PantryVisionItem.tryParse] instead, where a bad
/// value costs one row rather than the whole response.
const Map<String, Object?> pantryVisionJsonSchema = {
  'type': 'object',
  'properties': {
    'items': {
      'type': 'array',
      'items': {
        'type': 'object',
        'properties': {
          'name': {
            'type': 'string',
            'description':
                'What the product is, in plain words, as a person reading the '
                'label would say it. No barcode, no product code.',
          },
          'brand': {
            'type': ['string', 'null'],
            'description': 'The brand if it is legible, otherwise null.',
          },
          'size': {
            'type': ['string', 'null'],
            'description':
                'Pack size as printed, digits only, e.g. "1" or "500". Null if '
                'not legible.',
          },
          'unit': {
            'type': ['string', 'null'],
            'description': 'The unit for size, e.g. "l", "ml", "g". Null if '
                'not legible.',
          },
          'count': {
            'type': 'integer',
            'description':
                'How many of this product are visible in the front row. Count '
                'only what you can actually see; do not estimate what is '
                'behind them.',
          },
          'confidence': {
            'type': 'string',
            'enum': ['high', 'medium', 'low'],
            'description':
                'How sure you are this is the product named, given how legible '
                'the label is.',
          },
          'note': {
            'type': ['string', 'null'],
            'description':
                'One short clause on why this row is uncertain, e.g. "partly '
                'hidden". Null when there is nothing to say.',
          },
        },
        'required': ['name', 'brand', 'size', 'unit', 'count', 'confidence', 'note'],
        'additionalProperties': false,
      },
    },
    'unreadable': {
      'type': 'integer',
      'description':
          'How many separate items are visible but cannot be identified well '
          'enough to name. Report this honestly - it tells the person what the '
          'photo missed.',
    },
  },
  'required': ['items', 'unreadable'],
  'additionalProperties': false,
};

/// The instruction sent with every photograph, in the language the person using
/// the app reads.
///
/// Written to be pasted into whichever field each provider calls the system
/// prompt. Three things in it are load-bearing and must not be softened:
/// no barcodes, count only the front row, and report what you could not read.
///
/// ## Why this takes a language instead of naming one
///
/// The names that come out of here are matched against a product catalog the
/// server has already answered in the same language - see the doc comment on
/// [AppLanguage], which is where the two halves of that agreement are written
/// down. English names against German candidates match nothing, so every rung
/// of the resolution ladder above "create it fresh" quietly stops finding
/// anything, and the person also reads a name their packet does not carry.
///
/// ## Why it asks the model to *read* the language rather than translate into it
///
/// Swiss packaging carries German, French and Italian on the same box, so the
/// words we want are already printed in the photograph. Asking for them is more
/// of the perception task the model is doing anyway; asking for a translation
/// is a second, different task stacked on top of one it has not finished. The
/// difference shows up in the answer: reading gives `Rüebli`, `Zopf` and
/// `Cervelat` - what the packet says and what the Swiss catalog was indexed
/// under - where translating "carrots" gives `Karotten`, which is correct
/// German and matches nothing on either shelf.
///
/// The fallback matters as much as the rule. Not every packet carries every
/// language, and a model told only "read the German" will faithfully transcribe
/// the Italian it can see. So it is told to fall back to the ordinary name in
/// the chosen language, which is the one case where translating is the right
/// answer.
String pantryVisionSystemPrompt(AppLanguage language) {
  final name = language.promptName;
  return '''
You are reading a photograph of a household food cupboard, fridge shelf, or
freezer compartment, and listing what is in it so somebody can check the list
against the real shelf.

Rules:
- Name each product the way a person reading the label would say it. Prefer the
  common name over marketing copy: "Oat milk", not "Barista Edition Oat Drink".
- Answer in $name. Swiss packaging usually carries two or three languages on the
  same box, so read the $name off the packet rather than the language you happen
  to find easiest - the $name words are already printed there, and they are the
  ones the person checking this list against the shelf is reading. Do not
  translate a name you read in another language into $name if the packet also
  carries the $name one. Where a packet carries no $name at all, use the ordinary
  $name name for that product rather than transcribing a language nobody asked
  for. Anything else you write in words - a note about why a row is uncertain -
  is in $name as well, because the same person reads it.
- A brand is whatever is printed on the packet, in whatever language it is
  printed in. Brands are not translated.
- Never output a barcode, EAN, or product code. You cannot read one from a
  photograph and a wrong one is worse than none.
- Count only what you can actually see in the front row. Do not estimate what
  is stacked behind or underneath something else.
- If several different products are visible, list them separately. If several
  identical packets are visible, list them once with a count.
- Set confidence honestly. "low" is the right answer for a label at an angle or
  in shadow, and it costs nothing.
- Count everything you can see but cannot name into `unreadable`. This is how
  the person knows what the photo missed - an undercount here is worse than
  admitting you could not read something.
- Ignore anything that is not a food or household product: crockery, appliances,
  hands, packaging that is clearly empty or discarded.
''';
}
