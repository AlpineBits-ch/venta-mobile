/// Rung 3 of the resolution ladder: letting a model choose between catalog rows
/// the server already returned, without ever letting it produce a code.
///
/// See `docs/pantry-vision.md` §1, "Rung 3: the model picks, but it can only
/// pick". Two things look similar there and are not. *Generating* a barcode -
/// inventing thirteen digits - is forbidden forever, and is why
/// `pantry_vision_models.dart` has no barcode field anywhere in it. *Choosing*
/// among rows our own catalog search returned is a bounded classification over
/// real data, which models are good at.
///
/// **The model returns an index into a list we gave it. It never returns a
/// barcode.** That is not a convention it is trusted to follow, it is the only
/// thing [catalogMatchJsonSchema] permits: `choice` is an integer or null, and
/// there is no string field anywhere for a code to arrive in. The client looks
/// up `candidates[choice]` and takes *that row's* barcode. An index that is out
/// of range, duplicated, contradicted or missing is an **abstention** - not an
/// error, not a crash, and above all not a different product. Everything in
/// [parseCatalogMatchResponse] exists to hold that line.
///
/// Nothing here writes anything. A match arrives at the review sheet pre-filled
/// and badged as a suggestion; an abstention arrives as "pick one" with the
/// picker a tap away. A person still confirms, exactly as they do for a row the
/// model matched confidently, because a good match does not buy an exemption
/// from the review rule.
///
/// ## Why one call for the whole plan
///
/// The matcher is handed every unresolved item at once rather than being called
/// per item. It is cheaper (one system prompt and one schema, not twelve), it is
/// faster at a cupboard where somebody is waiting, and cross-item context
/// genuinely helps: a photo holding one oat milk and one cow's milk disambiguates
/// both when they are seen together and neither when they are seen apart.
///
/// The cost of batching is prompt growth, and it is real: twenty items with
/// twenty-five candidates each would be five hundred candidate lines, of the
/// order of ten thousand tokens, on a call that is optional. Two things keep it
/// bounded. [maxCatalogCandidates] caps how many rows any one item may offer -
/// catalog search returns results in relevance order and the right answer is
/// essentially never at rank twenty, while a longer list makes indistinguishable
/// rows *more* likely and pushes the honest answer toward abstention anyway. And
/// items with nothing to choose between are left out of the prompt entirely:
/// they abstain for free, without being paid for.
library;

import '../../features/household/data/models/pantry_dto.dart';
import '../locale/app_language.dart';
import 'ai_provider.dart';
import 'pantry_vision_models.dart';

/// The most catalog rows one item may put in front of the model.
///
/// The cap is applied in [CatalogMatchCandidates]' constructor rather than when
/// the prompt is built, and that placement is load-bearing: the numbered list
/// the model sees and the list the client subscripts must be the *same* list.
/// Truncating at prompt time would leave the parser indexing a longer list than
/// the one that was shown, so index 7 would resolve to a row the model never
/// saw - which is the wrong-product failure this file exists to prevent,
/// reintroduced by an optimisation.
const int maxCatalogCandidates = 8;

/// One unresolved proposal and the real catalog rows our search returned for it.
///
/// The candidates come from `GET pantry/catalog/search`, so every one of them is
/// a product that exists with a code we did not invent. The proposal is kept
/// whole - name, brand, size, unit - because brand and pack size are most of
/// what tells two nearly identical rows apart, and a matcher handed only a name
/// is being asked a harder question than the one we can actually ask.
class CatalogMatchCandidates {
  CatalogMatchCandidates({
    required this.proposal,
    required List<ProductCatalogMatchDto> candidates,
    int limit = maxCatalogCandidates,
  }) : candidates = List.unmodifiable(
         candidates.take(limit < 0 ? 0 : limit),
       );

  final PantryVisionItem proposal;

  /// Capped at [maxCatalogCandidates] and never mutated afterwards. Positions in
  /// this list are the only vocabulary the model has for saying which row it
  /// means, so the list must not change between the request and the answer.
  final List<ProductCatalogMatchDto> candidates;

  /// Whether there is anything to choose between. An item with no candidates is
  /// rung 4 already - it is not sent, and it is not paid for.
  bool get hasCandidates => candidates.isNotEmpty;
}

/// What the matcher decided about one item, in a form the review sheet can
/// render without indexing anything itself.
///
/// The caller never sees the model's number. It gets a row or it gets null, and
/// null is a perfectly ordinary answer that means "pick one" rather than
/// "something went wrong" - which is why there is no error variant here at all:
/// a failed call and a deliberate abstention are the same thing to the person
/// reviewing, and collapsing them keeps the review sheet from growing a state
/// nobody can act on.
class CatalogMatchChoice {
  const CatalogMatchChoice({
    required this.item,
    required this.match,
    this.confidence = VisionConfidence.low,
    this.reason,
  });

  /// An item nobody chose for. Confidence is deliberately not carried over from
  /// the model here: a "high confidence" abstention is a contradiction, and the
  /// first thing anybody would do with such a value is sort a list by it.
  factory CatalogMatchChoice.abstain(
    CatalogMatchCandidates item, {
    String? reason,
  }) => CatalogMatchChoice(item: item, match: null, reason: reason);

  /// Every item abstained.
  ///
  /// This is the whole-batch degradation path, and it is a named constructor
  /// rather than something the caller assembles because it is reached often: no
  /// key configured, rate limited, offline, the model refused. Losing a shelf's
  /// worth of proposals because an *optional* second call was throttled would be
  /// absurd - the plan is still perfectly usable with a picker on every row.
  static List<CatalogMatchChoice> abstainAll(
    Iterable<CatalogMatchCandidates> items,
  ) => [for (final item in items) CatalogMatchChoice.abstain(item)];

  final CatalogMatchCandidates item;

  /// The chosen catalog row, or null for an abstention. Always an element of
  /// [CatalogMatchCandidates.candidates] - it is looked up here, never parsed
  /// out of the model's answer.
  final ProductCatalogMatchDto? match;

  /// How sure the model says it is. Advisory, exactly as it is for a vision row:
  /// it orders the review list and marks what is worth a second look. It never
  /// gates a write, because a person does that.
  final VisionConfidence confidence;

  /// One short clause explaining the pick or the abstention ("four own-brand
  /// cartons, none distinguishable"). Shown on the review row; never acted on.
  final String? reason;

  bool get isMatch => match != null;

  PantryVisionItem get proposal => item.proposal;

  /// The code behind the chosen row, if it has one.
  ///
  /// A catalog row without a barcode is still a useful match - it carries a
  /// better name and a pack size - so a null here is not a failed match, and the
  /// caller checks this rather than assuming a match implies a code.
  String? get barcode => match?.barcode;
}

/// The JSON Schema the matcher holds every provider to.
///
/// **There is no barcode field and no free-form product field.** `choice` is an
/// integer or null and nothing else: there is nowhere for thirteen digits to
/// land, and a model that wanted to hand back a code would have to violate the
/// schema to do it. That is the difference between a rule and a guarantee.
///
/// Shaped like [pantryVisionJsonSchema] deliberately - flat, everything in
/// `required`, `additionalProperties: false` throughout, no `minimum`/`maximum`
/// constraints some providers silently drop. Two of the three need the strictness
/// for structured output to be enforced at all, and range validation happens in
/// [parseCatalogMatchResponse] instead, where a bad value costs one row rather
/// than the whole answer.
const Map<String, Object?> catalogMatchJsonSchema = {
  'type': 'object',
  'properties': {
    'matches': {
      'type': 'array',
      'items': {
        'type': 'object',
        'properties': {
          'item': {
            'type': 'integer',
            'description':
                'The number of the item this answer is about, exactly as it was '
                'given in the list. One answer per item.',
          },
          'choice': {
            'type': ['integer', 'null'],
            'description':
                'The number of the candidate that is the same product, taken '
                'from the numbered list under that item. Null if you cannot '
                'tell which one it is - null is a good answer and costs '
                'nothing. Never write a barcode or a product code here.',
          },
          'confidence': {
            'type': 'string',
            'enum': ['high', 'medium', 'low'],
            'description':
                'How sure you are that this candidate is the same product as '
                'the item.',
          },
          'reason': {
            'type': ['string', 'null'],
            'description':
                'One short clause on why you chose this one, or why you could '
                'not choose. Null when there is nothing to say.',
          },
        },
        'required': ['item', 'choice', 'confidence', 'reason'],
        'additionalProperties': false,
      },
    },
  },
  'required': ['matches'],
  'additionalProperties': false,
};

/// The instruction sent with every match request, in the language both sides of
/// the comparison are written in.
///
/// Three things in it are load-bearing. It never mentions codes as something to
/// produce, only as something that exists behind the numbers. It says plainly
/// that a different pack size is still the same product but a different product
/// from the same brand is not - the two mistakes a size-matching heuristic makes
/// in opposite directions. And it makes abstaining *cheap*: a model that treats
/// null as a failure will pick the first plausible row every time, which is a
/// fuzzy match promoted to a fact in somebody else's cupboard.
///
/// ## Why the language has to be said out loud here too
///
/// Both halves of this prompt already arrive in [language]: the catalog rows
/// because the search carried `Accept-Language`, and the proposals because
/// [pantryVisionSystemPrompt] asked for the words printed on the packet. Saying
/// so is what stops the fourth rule above from eating the whole change. A
/// matcher that has not been told will read `Hafer Drink` beside `Oat drink` as
/// two products described in two languages - which is exactly the shape of "same
/// brand, different variety" - and answer null, correctly by its own lights and
/// wrongly for every row. Abstaining is meant to be cheap, so an argument for
/// abstaining that applies to *every* item is the most expensive thing that can
/// get into this prompt.
///
/// It is a floor, not a licence: the rule says language is never by itself a
/// reason to abstain, and leaves every other reason exactly where it was.
String catalogMatchSystemPrompt(AppLanguage language) {
  final name = language.promptName;
  return '''
You are matching products somebody photographed in a kitchen against rows from a
product catalog. For each item you are given what was read off the packet, then a
numbered list of catalog products it might be. Say which numbered candidate is
the same product, or say you cannot tell.

Rules:
- Answer with the candidate's number. Numbers are the only way to name a
  candidate; there is nothing else to write and no code to produce.
- Everything below is in $name. The items were read off the $name text on the
  packets and the candidates came out of the catalog in $name, so wording that
  differs between an item and a candidate is two people describing one product,
  not evidence of two products. A candidate written in another language is the
  same row wearing a different label. Never answer null because of the language
  something is written in - abstain over what the product is, never over which
  words it is spelled with. Write your reason in $name too.
- Answer for every item you are given, exactly once, including the ones you
  cannot decide.
- A different pack size of the right product is still the right product. The
  size printed on the shelf is a suggestion, not an identity: a 1 l carton and a
  500 ml carton of the same drink are the same product, and you should match
  them.
- A different product from the same brand is not the right product. Same brand,
  same packaging style and a different flavour, variety or contents is a
  different thing - penne is not fusilli, and semi-skimmed is not whole.
- Answer null whenever you cannot tell which one it is. Four indistinguishable
  own-brand cartons is exactly the case for null; so is a candidate list where
  nothing is clearly the item. Abstaining is the right answer, not a failure.
- Weigh that honestly. A wrong product goes into a shared household cupboard,
  under a code somebody else will scan and trust, and it outlives the person who
  caused it. One extra tap does not. When it is close, answer null.
- Set confidence honestly, and use "low" freely. It costs nothing.
''';
}

/// Renders the batch as the numbered lists the model answers about.
///
/// **No barcodes go into this string.** They are not decision-relevant - nobody,
/// model or person, picks a product by its check digit - they cost tokens on
/// every row, and their absence is one more reason a code cannot come back out:
/// a model that never saw one has nothing to copy.
///
/// Items with no candidates are skipped, but the numbering is the caller's list
/// index throughout rather than a running counter, so a skipped item does not
/// shift every answer after it by one.
String buildCatalogMatchPrompt(List<CatalogMatchCandidates> items) {
  final buffer = StringBuffer();
  for (var i = 0; i < items.length; i++) {
    final item = items[i];
    if (!item.hasCandidates) continue;

    if (buffer.isNotEmpty) buffer.writeln();
    buffer.writeln('Item $i: ${_describeProposal(item.proposal)}');
    buffer.writeln('Candidates:');
    for (var c = 0; c < item.candidates.length; c++) {
      buffer.writeln('  $c. ${_describeCandidate(item.candidates[c])}');
    }
  }
  return buffer.toString().trimRight();
}

/// Turns the model's answer into one decision per input item.
///
/// **Total by construction.** It never throws and it never returns a list of a
/// different length to [items]: every path that is not a clean, in-range,
/// uncontested index ends at an abstention. That is what lets the caller render
/// the review sheet from this without a try/catch and without a null check on
/// the list itself.
///
/// The rules, each of which is a way a model has actually been seen to answer:
///
/// - **Out of range abstains.** `choice: 12` against nine candidates is not
///   clamped to eight and is not an error. Clamping would hand somebody a
///   product the model did not choose, which is exactly the failure the index
///   design prevents everywhere else.
/// - **Anything that is not a JSON number abstains.** A string is never coerced
///   into an index, even when it parses - coercion is precisely how thirteen
///   digits become a subscript. A negative number abstains for the same reason
///   an out-of-range one does.
/// - **Contradictions abstain.** Two entries for the same item that name the
///   same candidate are a harmless duplicate and the first is taken; two that
///   name *different* candidates are the model disagreeing with itself, and
///   picking either one is a coin toss over which product goes into a shared
///   cupboard. The item abstains instead. An entry that resolves to null counts
///   as a distinct answer for this test, so "row 3, and also no idea" abstains
///   too.
/// - **An omitted item abstains**, as does an item that was never sent because
///   it had no candidates.
List<CatalogMatchChoice> parseCatalogMatchResponse(
  Map<String, Object?> json,
  List<CatalogMatchCandidates> items,
) {
  final claims = <int, _Claim>{};
  final contradicted = <int>{};

  final raw = json['matches'];
  if (raw is List) {
    for (final entry in raw) {
      if (entry is! Map) continue;

      // Which item this is about. Anything that is not a plain in-range index
      // is dropped rather than guessed at: an answer we cannot attribute is an
      // answer, applied to the wrong row, in the worst case.
      final index = _asIndex(entry['item']);
      if (index == null || index < 0 || index >= items.length) continue;

      final item = items[index];
      final choice = _asIndex(entry['choice']);
      // The range check is the safety property, not a tidying step. Everything
      // a model could put here that is not a position in the list it was shown -
      // a barcode, a count, a hallucinated rank - lands outside it.
      final resolved =
          (choice != null && choice >= 0 && choice < item.candidates.length)
          ? choice
          : null;

      final existing = claims[index];
      if (existing != null) {
        if (existing.choice != resolved) contradicted.add(index);
        continue;
      }

      claims[index] = _Claim(
        choice: resolved,
        confidence: VisionConfidence.parse(entry['confidence']),
        reason: _text(entry['reason']),
      );
    }
  }

  return [
    for (var i = 0; i < items.length; i++)
      _choiceFor(items[i], contradicted.contains(i) ? null : claims[i]),
  ];
}

CatalogMatchChoice _choiceFor(CatalogMatchCandidates item, _Claim? claim) {
  final choice = claim?.choice;
  if (claim == null || choice == null) {
    return CatalogMatchChoice.abstain(item, reason: claim?.reason);
  }
  return CatalogMatchChoice(
    item: item,
    match: item.candidates[choice],
    confidence: claim.confidence,
    reason: claim.reason,
  );
}

/// One answer, before it is looked up. [choice] is already range-checked, so a
/// null here means "abstained" and nothing else.
class _Claim {
  const _Claim({
    required this.choice,
    required this.confidence,
    required this.reason,
  });

  final int? choice;
  final VisionConfidence confidence;
  final String? reason;
}

/// Only a JSON number is an index.
///
/// A string is refused even when `int.tryParse` would take it, which is the
/// point: the one thing a model might put where a number belongs is a product
/// code, and a parser willing to read digits out of a string is a parser willing
/// to turn one into a subscript. A float is accepted only when it is whole, since
/// several JSON encoders round-trip 3 as 3.0 and refusing that would abstain on
/// correct answers for no gain.
int? _asIndex(Object? raw) {
  if (raw is int) return raw;
  if (raw is num) {
    final rounded = raw.round();
    return rounded == raw ? rounded : null;
  }
  return null;
}

String? _text(Object? raw) {
  final value = raw?.toString().trim();
  return value == null || value.isEmpty ? null : value;
}

/// The proposal as one line: what a person reading the shelf said it was.
String _describeProposal(PantryVisionItem proposal) {
  final parts = <String>[proposal.name];
  final brand = proposal.brand?.trim();
  if (brand != null && brand.isNotEmpty) parts.add(brand);
  final size = _joinSize(proposal.size, proposal.unit);
  if (size != null) parts.add(size);
  return parts.join(' - ');
}

/// One candidate row, with the four fields that actually separate two of them:
/// the name, the brand, the pack size, and which database it came from. No code,
/// no id, no url - see [buildCatalogMatchPrompt].
String _describeCandidate(ProductCatalogMatchDto candidate) {
  final parts = <String>[candidate.name.trim()];
  final brand = candidate.brand?.trim();
  if (brand != null && brand.isNotEmpty) parts.add(brand);
  final size = _joinSize(_formatQuantity(candidate.quantity), candidate.quantityUnit);
  if (size != null) parts.add(size);
  final source = candidate.sourceName.trim();
  if (source.isNotEmpty) parts.add(source);
  return parts.join(' - ');
}

String? _joinSize(String? size, String? unit) {
  final s = size?.trim();
  final u = unit?.trim();
  final hasSize = s != null && s.isNotEmpty;
  final hasUnit = u != null && u.isNotEmpty;
  if (hasSize && hasUnit) return '$s $u';
  if (hasSize) return s;
  return null;
}

/// "380", not "380.0". The pack size is read aloud from a packet, and a trailing
/// `.0` on every row is a token per row spent making the list look machine-made.
String? _formatQuantity(double? quantity) {
  if (quantity == null) return null;
  return quantity == quantity.roundToDouble()
      ? quantity.toStringAsFixed(0)
      : quantity.toString();
}

/// The adapter surface this needs on top of [VisionAdapter]: send a prompt with
/// *some* forced schema, and hand back the JSON object the model produced.
///
/// [VisionAdapter] hardcodes the pantry-vision schema on the way out and
/// `PantryVisionResult` on the way in, which is right for the call it was written
/// for and unusable for a second one. Rather than widen that contract - and
/// with it every implementation and every fixture test - the two extra members
/// live here, on the caller that needs them. All three adapters implement this,
/// their existing `buildBody`/`parseResponse` are now expressed in terms of it,
/// and so there is still exactly one copy of each provider's envelope handling.
abstract interface class JsonSchemaAdapter implements VisionAdapter {
  /// The request body for a call whose answer must satisfy [schema]. A request
  /// carrying no images is a text-only call; all three providers accept one.
  Map<String, Object?> buildJsonBody(
    VisionRequest request,
    Map<String, Object?> schema,
  );

  /// Pulls the model's JSON object out of the provider's envelope.
  ///
  /// Throws [AiFailure] for anything that is the provider's fault - a refusal, a
  /// truncated answer, an envelope without a payload - and never a raw
  /// `FormatException` or `TypeError`, exactly as [VisionAdapter.parseResponse]
  /// promises.
  Map<String, Object?> extractJson(Map<String, Object?> body);
}
