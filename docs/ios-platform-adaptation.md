# iOS platform adaptation — 2026-08-16

Making the app stop reading as an Android app when it runs on iOS. This records what
phase 1 changed, the one place I deliberately did **not** use the framework's own
`.adaptive` constructor, and the ranked list of what is left.

> **Status:** phase 1 is done, analysed and tested. Not yet seen on a real iOS device —
> this repo is developed on Windows, so `test/platform_adaptation_test.dart` is the only
> thing on this machine that can render the Cupertino branch at all. Two specific spots
> still want a human eye on a Mac; see [Needs eyeballing](#needs-eyeballing-on-a-mac).

## The diagnosis

The app is a Material 3 app end to end: `MaterialApp.router` (`lib/app.dart:219`) with
`useMaterial3: true`, ~566 Dart files of `package:flutter/material.dart`, and — before this
pass — exactly one Cupertino reference in `lib/` (the localizations delegate) and zero
`defaultTargetPlatform` / `Theme.of(context).platform` branches in UI code.

Flutter only auto-adapts about four things on iOS, and the app already got all of them:
page transitions and the edge swipe-back (`appPage` delegates to
`Theme.of(context).pageTransitionsTheme`, `lib/core/routing/back_navigation.dart:119`),
bouncing scroll physics, and text-selection handles. **Navigation already felt right.**
Everything drawn *inside* the page was the giveaway: ripples, Material spinners, M3
switches, FABs, left-aligned nav titles, filled back arrows, snackbars, Material dialogs.

There is no global Material↔Cupertino toggle in Flutter, and `CupertinoApp` would mean
rebuilding every screen. The approach taken is per-widget adaptive constructors plus a
platform-aware theme — no new dependency, no screen rewrites.

## What phase 1 changed

172 call sites across 87 files, 2 of them new.

| Area | Change |
|---|---|
| Theme — `lib/core/theme/app_theme.dart` | `splashFactory` → `NoSplash` on iOS/macOS, `InkRipple` elsewhere |
| Theme — same file | `centerTitle` → **unset** on iOS (was hard-`false`), letting `AppBar` apply its own platform default |
| App bars | 6 with custom `Row`/`Column`/`TextField` titles pinned to `centerTitle: false`; the other ~70 now centre on iOS |
| `lib/core/widgets/app_back_button.dart` | `Icons.arrow_back_ios_new` on iOS, `Icons.arrow_back` elsewhere |
| Spinners | 87 sites: 56 bare → `CircularProgressIndicator.adaptive()`, 31 sized/tinted → new `AdaptiveProgressIndicator` |
| Selection controls | 51 → `.adaptive`: 42 `SwitchListTile`, 4 `RadioListTile<T>`, 3 `Switch`, 1 `Checkbox`, 1 `CheckboxListTile` |
| Pull-to-refresh | 34 `RefreshIndicator` → `.adaptive` across 23 files |

New files:

- `lib/core/widgets/adaptive_progress_indicator.dart`
- `test/platform_adaptation_test.dart`

The 6 app bars pinned to `centerTitle: false`: `thread_view.dart`, `wiki_home_screen.dart`,
`message_search_screen.dart`, `guild_voice_screen.dart`, `voice_fullscreen_view.dart`,
`household_channel_base.dart`. Each carries a one-line comment pointing back at `AppTheme`.

### Zero sites were blocked

All six selection-control `.adaptive` constructors accept a strict superset of their default
constructor's parameters in Flutter 3.44.8 (the extras are `applyCupertinoTheme` on
Switch/SwitchListTile and `useCupertinoCheckmarkStyle` on Radio/RadioListTile), and no call
site in `lib/` passes a Material-only styling argument. Every `RefreshIndicator` passed only
`onRefresh:` and `child:`. Nothing had to be skipped for compatibility.

## The one deviation: don't use `CircularProgressIndicator.adaptive` for sized spinners

This is the part worth remembering, because the framework constructor looks like the obvious
answer and is quietly wrong for most of this codebase.

On iOS, `CircularProgressIndicator.adaptive`:

- renders `CupertinoActivityIndicator` at **its own fixed 20×20**, ignoring the box it is in;
- reads **`backgroundColor`** as the tick colour, and silently drops `color`, `valueColor`
  and `strokeWidth`.

(Source: `_buildCupertinoIndicator` in the SDK's `material/progress_indicator.dart`.)

Most spinners here are 16–18px inside a `SizedBox` with `strokeWidth: 2` and a colour, so a
blanket swap would have overflowed the box **and** reverted the `onPrimary` tint inside filled
buttons — on iOS only, where nobody on a Windows machine would have seen it.

`AdaptiveProgressIndicator` drives `CupertinoActivityIndicator`'s own `radius`/`color`
instead, so size and tint survive both platforms. `ButtonProgressIndicator` now delegates to
it. **Use `AdaptiveProgressIndicator` for anything sized or tinted; plain
`CircularProgressIndicator.adaptive()` is fine only for a bare, unstyled, full-area spinner.**

It is indeterminate-only by design. `lib/` currently has zero determinate spinners (no call
site passes `value:`), and a determinate progress ring has no iOS idiom worth swapping to.
The 4 `LinearProgressIndicator` sites were left alone for the same reason
(`wiki_page_view_screen.dart:333`, `onboarding_wizard_screen.dart:157`,
`chores_channel_screen.dart:953`, `create_guild_screen.dart:90`).

## Deliberately not done

- **`ThemeData.adaptations`** — Flutter ships no concrete `Adaptation` subclasses; it is only
  a hook for writing your own. It buys nothing for free. Skipped.
- **`flutter_platform_widgets`** — a genuine global toggle, but a heavy dependency across 566
  files that would fight the hand-mapped Alpine token theme. Rejected.
- **The font.** Inter via `google_fonts` rather than SF Pro is brand parity with Alpine and
  worth keeping; Discord, Slack and Spotify all ship non-native type on iOS.
- **Page transitions.** Already correct — leave `appPage` alone.

## Verification

- `flutter analyze` — **0 errors**, and **zero issues in any of the 87 changed files**. The
  114 remaining infos + 2 warnings are pre-existing, in files this pass never touched.
- `flutter test` — **1337 passing**.
- `flutter test test/platform_adaptation_test.dart` — 7 cases covering both platform branches
  of the theme, the back-button icon, and the spinner's size/tint on each platform.
- Formatting: 3 files this pass unformatted were re-formatted. 7 other changed files were
  *already* unformatted at HEAD and were left that way to keep the diff clean.

### Two traps found while writing the tests

- `testWidgets` asserts the foundation debug vars are unset at the end of the **test body**,
  which is earlier than any `tearDown` runs. `debugDefaultTargetPlatformOverride = null` has
  to be the last statement in each body; the `tearDown` is only a safety net.
- Building the theme reaches `GoogleFonts.interTextTheme()`, which needs a binding — so even
  a test that pumps nothing must be `testWidgets`, not `test`.

### One non-issue, checked

`NoSplash` does **not** leave iOS rows without press feedback. It suppresses the travelling
splash only; `InkHighlight` (the pressed dim) is a separate code path and still draws —
`InkResponse` resolves it from `highlightColor` at `material/ink_well.dart:1038`, independent
of `splashFactory`. No `AdaptivePressable` wrapper is needed.

## Needs eyeballing on a Mac

Nothing here is known to be wrong — these are just the places where the Cupertino control's
intrinsic metrics differ enough from the M3 one that layout should be confirmed.

1. `lib/features/household/presentation/screens/ledger_channel_screen.dart:1752` — bare
   `Checkbox.adaptive` in a tight `Row` with an `Expanded` label and a 96px `TextField`.
2. `lib/features/guilds/presentation/screens/guild_settings/onboarding_settings_tab.dart:401`
   — `Switch.adaptive` as a `ListTile.trailing`; the Cupertino pill is wider than the M3 switch.
3. A general pass over the ~70 app bars that now centre their title on iOS.

## Next up, ranked

### 1. `PopupMenuButton` + `Icons.more_vert` — best feel-per-hour left

11 `PopupMenuButton` (27 `PopupMenuItem`) and 8 `Icons.more_vert`, largely the same sites:
`events_screen.dart`, `forum_channel_screen.dart`, `guild_detail_screen.dart`,
`household/.../{chores,decisions,ledger,list,meals,pantry}_channel_screen.dart`,
`user_profile_screen.dart`, `wiki_page_view_screen.dart`.

iOS expects a `CupertinoActionSheet` from the bottom (or a long-press `CupertinoContextMenu`),
and a horizontal ellipsis. Plan: one shared `showAdaptiveMenu(context, items)` helper (~80
lines, same shape as `AdaptiveProgressIndicator`), then a mechanical rewrite per site;
`more_vert` → `more_horiz` is an 8-line find/replace.

**Fold in:** ~10 of the 32 `showModalBottomSheet` sites are pure action lists that belong in
the same helper — `guild_detail_screen.dart:190,467`, `guild_members_screen.dart:136`,
`forum_channel_screen.dart:464`, `thread_view.dart:373,1197`, `conversation_actions_sheet.dart`,
`app_shell.dart:82`, `wiki_block_editor.dart:571`.

### 2. Date/time pickers

10 `showDatePicker`, 3 `showTimePicker`, 1 `showDateRangePicker` across 11 files
(`events_screen.dart`, `bills_view.dart`, `chores_`/`decisions_`/`ledger_`/`maintenance_`
(×2)/`pantry_channel_screen.dart`, `house_settings_tab.dart`, `register_screen.dart`,
`away_board.dart`). The Material calendar grid and analog clock dial are unmistakable, and
Flutter ships no adaptive constructor. Needs one helper wrapping `CupertinoDatePicker` in a
bottom sheet (~120 lines), then a one-line swap per site. High impact, contained effort.

### 3. `FloatingActionButton`

12 sites / 12 files (`home_screen.dart`, `events_screen.dart`, `forum_channel_screen.dart`,
`guild_detail_screen.dart`, three `guild_settings` tabs, `chores_`/`decisions_`/
`ledger_channel_screen.dart`, two wiki screens; 3 are `.extended`). There is no FAB idiom on
iOS — the primary create action belongs in the nav bar trailing slot. Highest perceived
impact of anything remaining, and the highest effort: each site needs a layout decision, not
a substitution.

### 4. Cheap tail

- **`TabBar` / `SegmentedButton`** — 4 tab bars (`inbox_screen.dart:84`,
  `guild_settings_screen.dart:117`, `chores_channel_screen.dart:320`,
  `ledger_channel_screen.dart:448`) and 3 segmented buttons
  (`onboarding_prompt_editor_screen.dart`, `chores_`, `ledger_`). iOS uses
  `CupertinoSlidingSegmentedControl`. Inbox is high-traffic, so that one tab bar carries most
  of the value; the `SegmentedButton` trio is nearly free.
- **`Tooltip`** — 7 sites (`pantry_channel_screen.dart:487`, `pantry_vision_screen.dart:1464`,
  `home_status_board.dart:210`, `reaction_picker_sheet.dart:203`, `encrypted_badge.dart:29`,
  `markdown_toolbar.dart:380`, `wiki_rich_toolbar.dart:180`). Long-press tooltips are not an
  iOS idiom — replace with `Semantics(label:)` or a visible caption. Cheapest item here.
- **Bottom-sheet consistency** — of 32 sheets, only 6 pass `showDragHandle: true`. A grabber
  + corner-radius pass is cheap, and `household_widgets.dart:1085` is already a shared helper,
  so a chunk of it is one-file work.

### 5. Bigger, lower priority

- **`DropdownButtonFormField`** — 21 sites / 15 files (no bare `DropdownButton`). Medium-high
  effort because of form validation / `onSaved` integration; medium impact, mostly in settings
  screens users visit rarely.
- **Haptics** — only 4 `HapticFeedback` sites today, two being the `houseHaptic()` helpers in
  `household_widgets.dart:1068`. iOS feel leans hard on `selectionClick` for segment/toggle
  changes and `impact` for destructive confirms. Scattered medium effort, subtle but real.
- **Icon set** — 778 `Icons.*`, 0 `CupertinoIcons`. A wholesale swap is not worth it; the ~20
  highest-traffic chrome glyphs (close ×31, add, search, share) carry most of the weight.
  Schedule last.
- **Snackbars (~271 refs / 61 files) and `AlertDialog` (59 / 36 files).** iOS has no bottom-toast
  idiom at all. Snackbars need a `showAppSnack(context, …)` helper — one does not exist today,
  which is why this was cut from phase 1. Dialogs are a more mechanical
  `showAdaptiveDialog` + `AlertDialog.adaptive` migration.

## Confirmed non-issues — don't spend time here

- No `Drawer`, `BottomNavigationBar`, `NavigationBar`, `NavigationRail`, `showMenu`,
  `showSearch`, `SearchBar`, `ExpansionTile`, `DataTable`, `Slider`, `MaterialBanner` or
  `showAboutDialog` anywhere in `lib/`.
- The left server rail (`app_shell.dart:372`) is custom and is product identity, not an
  Android tell.
- Page transitions: 29 `MaterialPageRoute` / 1 `PageRouteBuilder`, and `AppTheme` sets no
  `pageTransitionsTheme`, so iOS already gets `CupertinoPageTransitionsBuilder` plus the edge
  swipe-back gesture.
- `Card` (115 sites) is already flattened by `cardTheme` elevation 0; `InputDecoration` (125)
  is centralised in `inputDecorationTheme`. Both are theme-level if ever needed.
- `_QuantityStepper`/`_TallyStepper`/`_CountStepper` are custom widgets, not Material `Stepper`.
- Only 1 `Dismissible` (`pantry_channel_screen.dart:814`) — swipe-action parity is not worth a pass.

## Unrelated, but in the tree

The working tree carries an uncommitted `sensors_plus: ^7.0.0` addition in `pubspec.yaml` /
`pubspec.lock` — the tilt-rotation dependency for the full-screen video viewer. It predates
this pass and was left alone, but it will ride along in any commit made from here.
