# Pantry vision — filling and emptying a cupboard from a photograph

Bring-your-own-key AI that reads a photo of a shelf and proposes what to put
in, or take out of, a pantry channel.

**Status:** planned. Phases 1–3 are client-only and need no backend work.
Meals are explicitly out of scope (see the last section).

---

## What "local" means

Nothing goes through venta's backend. The app holds the user's own API key in
the device keychain and talks **straight to the provider**. No photo, no key,
and no derived text ever reaches `api.venta.gg`.

This is not on-device inference. A photo of somebody's kitchen leaves the
device and goes to OpenAI, Google, or Anthropic — whichever the user
configured, with whichever key they pay for. That is a real disclosure and it
gets an explicit consent moment (§5), not a line in a settings page nobody
reads.

The distinction matters because this app has an E2EE story. Messages are
end-to-end encrypted; a shelf photo sent to a model provider is not, and must
never be described as if it were.

---

## 1. The constraint everything else follows from

**The model is never asked for a barcode.**

An EAN is thirteen digits that are, in practice, never legible in a photograph
of a shelf. Every model in scope will produce a confident, plausible, wrong one
if the schema gives it somewhere to put one. So the schema has no barcode
field at all — not an optional one, not a nullable one. There is nothing to
hallucinate into.

What the model is asked for is what a person could read off the same photo:
a name, maybe a brand, maybe a pack size, and how many of them are visible.

### Resolving a name to something the pantry can hold

A proposed item resolves down a ladder, best first:

| # | Match against | Result |
|---|---|---|
| 1 | This house's learned barcodes (`getLearnedBarcodes(q:)`) | A real barcode → `scanPantryItem` gives the house's own name *and* its learned default quantity for free |
| 2 | The pantry's existing items, by name | Reconcile against that row — no new row, no duplicate |
| 3 | The product catalog (`GET pantry/catalog/search?q=`) | **Candidates, offered — never applied.** See below. |
| 4 | Nothing | `createPantryItem(name:, quantity:)`, no barcode |

Rung 1 is why this compounds: a photo-seeded item that somebody later scans
picks up its barcode through the existing teach flow, and every future photo of
it lands on rung 1 instead of rung 4.

### Rung 3: the model picks, but it can only pick

Two things look similar here and are not:

- **Generating a barcode** — inventing thirteen digits. Forbidden, forever, and
  the reason the response schema has no barcode field.
- **Choosing among candidates the server returned** — a bounded classification
  over real rows from our own catalog. That is a task models are genuinely good
  at, and refusing to use one for it would be superstition rather than caution.

So rung 3 searches the catalog for each unresolved item, then makes a **second
model call** that sees the proposal beside its candidates and picks the best
one, or abstains.

**The matcher returns an index, never a code.** It is handed a numbered list and
answers with a number; the client looks up `candidates[i]` and takes *its*
barcode. Hallucinating a code is not something the model is trusted not to do —
it is something the wire format makes impossible. An out-of-range index is
treated as an abstention.

**Abstaining is cheap and is encouraged.** "Oat milk" against four
indistinguishable own-brand cartons should come back null. A wrong barcode in a
shared pantry outlives the person who caused it; one extra tap does not.

Either way the row is still **reviewable and badged**. A confident match arrives
pre-filled and marked as a suggestion; an abstention arrives as "pick one" with
the picker one tap away and the search pre-filled. Nothing is written until
somebody confirms the plan — that rule does not bend for a good match.

### Consequences of the catalog contract

- **Attribution is not optional.** ODbL obliges crediting the database wherever
  one of its names is shown. `ProductSourceNote` already exists for this;
  candidate lists and picker sheets both need it, and `sourceName` varies per
  row (Open Food Facts / Beauty / Products / Pet Food) so it cannot be
  hardcoded.
- **`quantity`/`quantityUnit` is the pack size, not a stock count** — "250 ml"
  on the packet, not 250 of them. It is a suggestion for the unit field and is
  never filled in silently. This independently confirms the decision already
  made in the plan layer not to write the model's `unit` on create.
- **Coverage is uneven and honestly documented**: groceries and cosmetics good,
  cleaning products thin, Swiss retailer own-brands (M-Budget, Prix Garantie,
  Denner) largely absent. An empty search means "not in our catalog", never
  "no such product" — rung 4 stays load-bearing and the copy must not imply
  otherwise.
- **Search is local to our catalog.** There is no live third-party lookup
  behind it; only the *scan* path reaches the live source, by barcode.
- Minimum 3 characters, debounce ≥300ms, `countIsLowerBound` renders as `500+`.

---

## 2. Safety rules

These are not polish. Each one exists because its absence is how the feature
gets switched off.

**Review before write, always.** The model proposes; a person confirms. Writing
thirty rows into a *shared household* pantry on a guess is not a feature.

**Absence is never evidence.** A photo is one shelf, not an inventory. Items
the photo did not show are never touched and never zeroed. Only rows the user
confirms are written.

**Counts are proposals.** Models are unreliable on stacked and occluded goods.
The prompt says to count the front row only and to report `unreadable` — how
many things are visible but not identifiable. That number is the honest signal
that the photo missed something, and it is shown to the user. Every count lands
on the same `− N +` stepper the barcode scanner uses.

**Proposals are badged as offers.** Same treatment as catalog-suggested names:
`SuggestedNameBadge`, and the name is a button that opens the correction sheet.
This app already holds the line that "a suggestion is never forced on anybody";
an AI proposal is exactly that and gets no special authority.

**Photos are never persisted.** Not attached to a pantry item, not cached, not
uploaded anywhere but the provider. They exist in memory for one request.

---

## 3. The pipeline

```
capture (1..n photos)
   → downscale + encode
   → provider request (forced JSON schema)
   → PantryVisionResult { items[], unreadable }
   → merge across photos (dedupe by normalised name)
   → resolve each item down the ladder (§1)
   → reconcile against current stock  →  PantryVisionPlan
   → REVIEW SHEET  (edit counts, fix names, drop rows)
   → apply (scan / create / update, one call per row)
```

`resolve` and `reconcile` are pure functions over data — no I/O, no widgets.
They are the part that can silently double somebody's stock, so they are the
part that gets tested hardest.

### Reconciliation

For each resolved item, the plan records an **action** and the resulting
quantity, both shown in review:

| Situation | Default action | Shown as |
|---|---|---|
| Not in the pantry | `create` | "Add — 2" |
| In the pantry, stocking up | `set` | "Milk → 3 (was 1)" |
| In the pantry, using up | `set` (decrement) | "Milk → 1 (was 3)" |

`set` rather than `add` for existing rows because a photo is a stocktake, not a
delivery note — photographing a shelf twice must not double it. The review row
can flip an individual line to `add` where that is what the user meant.

---

## 4. Provider layer

One request shape, one response schema, three thin adapters. Each adapter is a
pair of pure functions — build a request body, parse a response body — so both
halves are fixture-testable without a network.

| | Endpoint | Auth | Structured output |
|---|---|---|---|
| Claude | `POST /v1/messages` | `x-api-key` + `anthropic-version: 2023-06-01` | `output_config.format` → `json_schema` |
| OpenAI | `POST /v1/chat/completions` | `Authorization: Bearer` | `response_format` → `json_schema`, `strict: true` |
| Gemini | `POST …/models/{model}:generateContent` | `x-goog-api-key` | `generationConfig.responseSchema` + `responseMimeType` |

All three accept inline base64 images and can be forced to emit schema-valid
JSON, which is why the shared surface is small.

**Model IDs are user-editable per provider**, with a sensible default. Model
names churn; a hardcoded one rots, and BYOK users often have specific access.

Claude defaults to `claude-opus-5` ($5/$25 per MTok). Note that thinking is on
by default on that model and `max_tokens` caps thinking *plus* output — so the
adapter sends generous headroom and `output_config.effort: "low"`, or responses
truncate mid-object. Cheaper picks the user can select: `claude-sonnet-5`,
`claude-haiku-4-5`.

> The OpenAI and Gemini request shapes above are from working knowledge and
> **must be checked against their current docs during implementation** — model
> IDs especially. The Claude shape is verified against current reference.

### The schema

```jsonc
{
  "items": [
    {
      "name":       "Oat milk",        // required
      "brand":      "Oatly",           // nullable
      "size":       "1",               // nullable, numeric string
      "unit":       "l",               // nullable
      "count":      3,                 // integer ≥ 1, front row only
      "confidence": "high|medium|low",
      "note":       "partly hidden"    // nullable, one short clause
    }
  ],
  "unreadable": 2                      // visible but not identifiable
}
```

No barcode field. No free-form top-level text. `additionalProperties: false`
throughout, because two of the three providers need it for strict mode.

### Cost and latency

A 1568px-long-edge photo is roughly 1.6k image tokens; the system prompt and
schema add ~0.6k; output is ~0.4k. On `claude-opus-5` that is about **$0.02 a
photo**, about $0.004 on Haiku. Cost is dominated by the image, so the
resolution knob is the cost knob: 1568px default, 2576px "small print" mode for
shelves with fiddly labels.

Latency is 5–15s per photo. The capture screen needs the discipline the barcode
scanner just got: a bounded wait, a real cancel, and failures that do not fade.

---

## 5. Keys, consent, and privacy

**Storage.** `SecureStorageService` (the existing device keychain wrapper), one
entry per provider. Never written to the backend, never into a channel, never
into a message, never logged.

**Per user, not per guild.** My key must not silently pay for my flatmate's
photographs. The configuration is a device/account setting; it is not shared
with the household and is not visible to it.

**Consent.** One explicit sheet before the first photo ever leaves the device,
naming the provider it will be sent to and stating plainly that the photo is
not covered by the app's end-to-end encryption. Recorded once per provider.
A persistent line in the capture UI names the provider on every use, so nobody
forgets which third party is looking at their kitchen.

**Failure modes are distinct and named.** No key configured routes to settings;
a rejected key says the key was rejected (not "something went wrong"); a rate
limit says so; a schema-invalid response gets exactly one repair retry and then
fails visibly.

---

## 6. Phases

### Phase 1 — the layer, and finding out whether this works at all

`lib/core/ai/`: the contract, the key store, image preparation, three adapters,
fixture tests. Plus an AI settings page (provider, key, model, the consent
record) and a deliberately ugly harness screen that takes a photo and dumps the
parsed JSON on screen.

The harness is the point. The only question phase 1 answers is *can these
models actually read a real cupboard* — side-on labels, things behind things,
kitchen lighting. If the answer is no, that is a day spent, not a month. I do
not know the answer and neither does anyone else until it is pointed at a real
shelf.

### Phase 2 — stock up

Capture → propose → resolve → reconcile → review → apply, in the stock-up
direction. Entry point from the pantry channel's action bar.

### Phase 3 — use up

The same pipeline inverted, reusing `PantryScanMode`. Photograph what is going
in the bin. This is the half that gets used daily, for the same reason the
scan-out mode does.

---

## 7. Not in scope: meals

The direction this is heading is meal suggestions from what the house actually
has, and that needs backend work — so it is not planned here and nothing is
built toward it ahead of time.

Worth stating what these three phases leave behind for it anyway: a pantry that
reflects reality without manual labour is the actual prerequisite for "what can
we make", more so than the meal feature itself. And propose → review → apply is
the same shape a meal suggestion would need. Nothing is foreclosed; nothing is
pre-built.
