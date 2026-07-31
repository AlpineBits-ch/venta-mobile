# QA findings — 2026-07-31

Exploratory pass over the running app. Bug descriptions only — no proposed fixes.

> **Status (2026-07-31, same day):** every A/B/C finding below is fixed. Root causes and
> what changed are recorded in **Resolutions** at the bottom; Q1/Q2 are answered there but
> not acted on (one is server data, one is a product call). `flutter analyze` is unchanged
> from the baseline below, `flutter test` is 22/22, and A1 · A2a · A2b · B1 · B2 · B3 ·
> C1 · C4 · C5 · C6 · C8 were re-verified on `emulator-5554` against the live backend.

**Environment**
- Device: `emulator-5554`, Pixel 6 / Android 15 (API 35), 1080×2400 @ 420dpi
- Device timezone: `Europe/Berlin` (UTC+2, CEST)
- Build: `main` @ `98db295`, debug, live backend `api.venta.gg`
- Account: `dominic`

**Baseline** — `flutter analyze` clean (90 `info` lints, 0 errors/warnings), `flutter test`
12/12 green. Everything below came from driving the app; almost none of it is visible to
static analysis.

The full `flutter run` log for the session (1130 lines, ~35 min of use across messaging,
household modules, guild settings, profile and settings) contained **exactly one** Dart
exception — **B4** below. No crashes, no failed frames beyond emulator-normal jank, and the
session ended with a clean `Lost connection to device`, not a fault. Worth stating plainly:
the app is stable under this kind of poking; the findings here are correctness and polish, not
robustness.

Severity is my read, not a mandate: **A** = wrong information or a promise the app can't keep,
**B** = visibly inconsistent/unfinished, **C** = polish.

---

## A1 — Pinned Messages shows the pin time in UTC, two hours behind the clock

**What happens:** the timestamp on a pinned-message row is the raw UTC time, not local.

**Repro**
1. Open any DM. Long-press a message → **Pin**.
2. Tap the pin icon in the app bar.
3. Compare the row's timestamp to the device clock.

**Evidence** — reproduced twice, both exactly UTC (device is UTC+2):

| Pinned at (device clock) | Row shows |
|---|---|
| 09:09 | 7:09 AM |
| 09:33 | 7:33 AM |

**Expected:** 9:09 AM / 9:33 AM.

**Notes for whoever picks this up:** message `createdAt` in the thread renders *correctly*,
and it goes through the same `.toLocal()` logic (`thread_view.dart:1610` vs
`core/format/date_time_format.dart`). So the two fields are not arriving in the same shape —
this looks like a data problem, not a formatting one. Worth auditing every other `DateTime`
the API returns against a known wall-clock, because I only had one field I could check this
way. Fields I could *not* verify (no known-good reference value): chore due dates, ledger
expense dates, event times, audit-log times.

**Where it shows up:** `lib/features/messaging/presentation/widgets/pinned_messages_screen.dart`

---

## A2 — Notification settings claim notifications are on while Android is blocking them

Two separate problems on one screen (Settings → Notifications).

**A2a — the master switch doesn't visibly govern its children.**
`Notifications enabled` was **off**, while `Direct messages`, `Mentions` and `Sounds` were all
**on** and rendered at full opacity, indistinguishable from interactive. The screen reads as
"DMs will notify you" and "the master is off" at the same time.

**A2b — the app never asks for the OS permission, and doesn't notice it's missing.**
Toggling `Notifications enabled` on produces no runtime permission prompt. The actual OS state
on this device:

```
$ adb shell dumpsys package gg.venta.mobile
android.permission.POST_NOTIFICATIONS: granted=false,
    flags=[ USER_SET|USER_FIXED|USER_SENSITIVE_WHEN_GRANTED|USER_SENSITIVE_WHEN_DENIED ]
```

`USER_FIXED` means the user denied it permanently — Android will not show the prompt again,
and nothing can be delivered. The settings screen shows no warning, no "blocked in system
settings" state, and no way to reach the system settings page.

**Expected:** the user can't end up with every switch on and silence, with nothing on screen
explaining why.

**Repro:** Settings → Notifications; toggle the master switch; observe children. Then check
the permission with the `adb` command above.

---

## B1 — Friends list shows letter placeholders instead of profile pictures

**What happens:** every row on the Friends screen shows a grey disc with a single letter.

**Repro:** Home → Friends. Compare to the DM list on the screen you just came from — `max` and
`randy` show their real avatars there and letter discs here. Same users, same session, two
different renderings, one screen apart.

Friend rows also carry no presence dot, unlike the DM list and the message rows.

**Where it shows up:** `lib/features/friends/presentation/screens/friends_screen.dart:210` —
the row builds a bare `CircleAvatar` with a `Text` initial rather than the shared avatar widget
used everywhere else.

**Note:** this is the same class of bug `98db295` fixed elsewhere ("never branch on
`avatarUrl` being null; use `AvatarImage`"). The friends screen appears to have been missed by
that sweep — worth grepping for other `CircleAvatar` call sites at the same time (see **B2**).

---

## B2 — Server Settings ▸ Members rows have no avatar

**What happens:** the member row is a naked line of text with no leading avatar.

**Repro:** any guild → gear → **Members**.

**Where it shows up:**
`lib/features/guilds/presentation/screens/guild_settings/members_settings_tab.dart:125` — the
`ListTile` has no `leading`.

**Not a bug:** the missing kick button on the household guild I tested is intentional — that
guild has no Moderation module, and the code says so explicitly.

---

## B3 — "New chore" sheet draws underneath the status bar

**What happens:** the sheet's content starts at y=0 with no top inset, so the title `New chore`
collides with the system clock. Scrolling makes it worse — the `Clean the bathroom` field ends
up behind the status-bar icons.

**Repro:** household guild → `#chores` → **+** (FAB).

Screenshots: `newchore.png`, `chorescroll.png` (session scratchpad).

---

## B4 — Viewing a profile with no banner throws a framework exception

**What happens:** opening another user's profile logs a red
`EXCEPTION CAUGHT BY IMAGE RESOURCE SERVICE` for every profile that has no banner uploaded.
Nothing is visibly broken — the banner falls back to a flat accent-coloured block — but the
console gets a full framework error + stack trace each time.

**Evidence** (from the `flutter run` log for this session):

```
══╡ EXCEPTION CAUGHT BY IMAGE RESOURCE SERVICE ╞═══════════════
The following NetworkImageLoadException was thrown resolving an image codec:
HTTP request failed, statusCode: 404,
https://api.venta.gg/api/v1/social/profiles/prfl_3HEDIFE80NSGWZZQCUHWKJZODWJ/banner
```

**Repro:** Home → tap a DM → tap a message row's empty space (or any avatar) to open the
author's profile, for a user with no banner. Watch the run log.

**Where it shows up:** three banner call sites all branch on `profile.bannerUrl != null`:
- `profile/presentation/screens/user_profile_screen.dart:247` — raw `NetworkImage`
- `profile/presentation/screens/self_profile_screen.dart:261` — `CachedNetworkImageProvider`
- `profile/presentation/screens/edit_profile_screen.dart:243` — `CachedNetworkImageProvider`

Two things are notable for whoever picks this up. The three siblings disagree about which
image provider to use, and only the raw-`NetworkImage` one surfaces the error. And per the
project's own note on `avatarUrl`, these URLs are **always non-null** and 404 when no image was
uploaded — so `bannerUrl != null` is a test that never fails and the `: null` fallback branch
is dead code at all three sites.

**Same root pattern as B1/B2** — the "never branch on the image URL being null" lesson from
`98db295` was applied to avatars but not to banners or the friends/members lists. Probably
worth one sweep rather than four separate fixes.

---

## C-list (polish)

- **C1 — the same quantity is formatted two different ways.** `#groceries` renders the pantry's
  restock entry as `5.0 Tab`; `#pantry` renders the same value as `5`. The list item's quantity
  is a server-supplied string while the pantry formats a `double` locally, so the two household
  screens disagree about one number on screen at the same time.
- **C2 — "Split equally, 1 ways."** Ledger expense card, plural agreement. (A one-way split
  arguably shouldn't say "split" at all.)
- **C3 — some emoji render as tofu boxes.** In the `max` DM, the 08:55 message shows two
  `.notdef` hex boxes below the 😂😂😂. Looks like a missing emoji fallback for the app font.
  I didn't capture the raw message bytes, so the exact codepoints are unknown.
- **C4 — search results and pinned rows look tappable but aren't.** Both are read-only lists by
  design (there's no scroll-to-message infrastructure yet), but they're styled as ordinary
  tappable list rows with no affordance saying otherwise, so they read as broken.
- **C5 — household guilds are called "servers" in their own settings.** "Server Settings",
  "Server name", "Delete server", while the rest of the household UI consistently says "the
  house" / "the flat".
- **C6 — settings search leaks a non-matching row.** Searching `notif` shows `Notifications`
  under **RESULTS** — and `Log Out` underneath it, which doesn't match the query.
- **C7 — the DM skeleton promises a subtitle that never arrives.** `SkeletonListTile` renders
  two lines per row while the loaded row only ever has one; there's no last-message preview.
  (`home_screen.dart:126` notes the DTO carries no such field — so the skeleton is what's
  wrong, not the row.)
- **C8 — inconsistent composer focus rings.** The `#groceries` "Add an item" field shows the
  global themed focus border; the message composer deliberately suppresses it.

---

## Needs someone with more context than I had

- **Q1 — two identical `dakura` entries in the DM list.** Same name, same avatar colour, no
  last-message preview to tell them apart, so they're indistinguishable in the UI. Either two
  accounts share a display name, or duplicate 1:1 conversations exist server-side.
  `ConversationRepository.findDirectMessageWith` returns the *first* 2-member match, so
  "Message this user" from a profile opens an arbitrary one of the two. Needs someone who can
  check the user ids / conversation ids on the backend.
- **Q2 — restocking doesn't clear the shopping-list entry.** Raising `Tabs` from 5 → 7 (above
  its `low at 5` threshold) moved it to IN STOCK in `#pantry`, but the auto-added `Tabs` entry
  stayed in `#groceries` under RESTOCK. The "Clear done" dialog copy ("Anything the pantry put
  here can come back next time it runs low") implies entries are meant to leave the list when
  *ticked*, not when restocked — so this may well be intended. Product call.

---

## Retracted — do not chase these

I reported both of these to the user mid-session and they are **wrong**. Recording them so
nobody re-investigates.

- ~~"Tapping message text does nothing; links can't be opened."~~ **False.** Tapping the
  invite link opens the in-app *Server Invite* dialog (Join Server / Dismiss) correctly. My
  taps were landing next to the link, not on it — my screenshot-to-device coordinate
  conversion was off by enough to miss a text row.
- ~~"The composer's touch area covers the last message, making it unactionable."~~ **False.**
  Long-pressing the last message opens the action sheet normally. Same coordinate error. The
  composer pill actually spans y=2190–2316 (device px), measured by pixel-probing the
  screenshot; my taps at 2178 and below were landing in the gap above it.

**Method note for the next person:** eyeballing coordinates off a downscaled screenshot is not
reliable for this app — Flutter exposes no accessibility tree to `uiautomator`, so there's no
element inspector. Pixel-probing the PNG for the target row's y-extent before tapping is what
made the difference; every finding above was re-verified that way or doesn't depend on a tap
landing precisely.

---

## Covered and working

DM list load · pin/unpin conversation (device-local, reorders correctly) · conversation action
sheet · send message · markdown rendering (bold/italic/autolink) · message grouping and the
7-minute header rule · long-press action sheet with correct own-vs-other actions · edit/delete
message with confirmation · pin/unpin message · pinned-messages list · message search with
match highlighting · invite links opening in-app · user profile screen · image attachments ·
household lists (add / tick / clear-done with confirmation) · pantry stepper and low-stock
bucketing · pantry→groceries restock hand-off · ledger · decisions (vote registers) ·
household presence sheet · guild settings overview · settings search · chores board/rota/
fairness tabs.

## State left behind

Everything I created was reverted: test message deleted, message unpinned, conversation
unpinned, pantry quantity and grocery list restored, notifications master toggle returned to
its original **off**. One exception — I voted "Yes" on the `Repaint the hallway` decision in
the household guild and there's no un-vote affordance I could find.

*(Fix pass, same day: one message in a `dakura` DM was pinned to re-verify A1 and unpinned
again. Nothing else was created or left behind.)*

---

# Resolutions — 2026-07-31

## A1 — pinned time in UTC · **fixed, verified live**

Not a formatting bug and not confined to `pinnedAt`. The backend is inconsistent about
time-zone designators: some fields arrive as `…T07:09:12.481Z`, others as bare
`…T07:09:12.481`. `DateTime.parse` reads a designator-less string as **local**, so the
`.toLocal()` every formatter calls is a no-op and the raw UTC wall-clock reaches the screen —
two hours behind on a UTC+2 device. `createdAt` looked fine only because it happens to carry
its `Z`.

Fixed at the seam rather than the call site, which also covers the audit the report asked for:
`core/format/api_date_time.dart` reads a designator-less timestamp as UTC, and every DTO
carrying a `DateTime` routes through it via `@ApiDateTimeConverter()` on its factory
constructor (23 model files, ~45 fields — chore due dates, ledger dates, event times and
audit-log times included). The four hand-written parses outside the generated code
(`message_repository`, `voice_repository`, `identity_api`, `guild_self_permissions`) were
converted too.

`guild_self_permissions` was a second live bug from the same cause: a guest role grant's
`expiresAt` was compared against `now` two hours out, so a lapsed grant kept granting — or a
live one stopped — for two hours around the boundary.

Covered by `test/api_date_time_test.dart`. Verified on device: pinned at 10:09, row reads
`10:09 AM`.

## A2 — notification settings · **fixed, verified live**

- **A2a**: the three child switches are now disabled while the master is off, with a footnote
  saying so. They were fully interactive and full-opacity under a dead master.
- **A2b**: the screen reads `Permission.notification` on open and on every resume, and shows a
  warning banner above the preferences when the OS is blocking. Toggling the master on now
  requests the OS permission.

  One trap worth recording: `permission_handler` cannot see Android's `USER_FIXED` flag. A
  twice-denied permission reports plain `denied` — same as never-asked — and
  `isPermanentlyDenied` stays `false`, so the obvious implementation offers an "Allow
  notifications" button that can be pressed forever with no dialog and no change. That is
  exactly what the first attempt did on this device. The signal is *asking and getting nothing
  back*: a request that returns without a grant flips the banner to the
  "Android won't ask again — open system settings" state.

## B1 — friends list placeholders · **fixed, verified live**

`friends_screen.dart` built a bare `CircleAvatar` with a `Text` initial. Now `UserAvatar`, the
same widget the DM list uses. The friend picker in `new_conversation_dialog.dart` had the
identical bug and was fixed with it — it was the only other user-avatar `CircleAvatar` left
(the remaining call sites are icons, unread badges and role colour swatches).

On the presence dot: the DM list *also* had none, despite `UserAvatar`'s own doc naming DM
lists as the case presence is for — it simply wasn't opting in. Both opt in now. Nothing
renders for the offline users on this account because `StatusDot` deliberately draws nothing
for `offline`/`hidden`.

## B2 — member rows have no avatar · **fixed, verified live**

`leading: UserAvatar(...)` on the `ListTile`. The fallback initial comes from
`member.profile?.userName`, not the nickname — a guild-local nickname would otherwise put a
different letter on the disc here than everywhere else.

## B3 — sheet under the status bar · **fixed, verified live**

`showModalBottomSheet` strips top padding from the `MediaQuery` it hands the builder, so
`HouseSheet`'s own `SafeArea` had nothing to work with once `isScrollControlled` let the sheet
grow to full height. `useSafeArea: true` on `showHouseSheet` fixes every household editor at
once; the four other tall editor sheets outside the household feature (event editor, forum
create-post, tag picker, welcome-screen channel picker) had the same latent bug and got the
same flag.

## C-list

- **C1 — `5.0 Tab` vs `5`** · *fixed, verified live.* The list item's quantity is free text the
  server writes during the restock hand-off; the pantry formats a `double` locally. A leading
  number in a list quantity is now respelled with the pantry's own `formatQuantity`, and only a
  leading number — "a bunch of the small ones" is untouched. `formatQuantity` moved to
  `household_widgets.dart` so both screens share one spelling. Covered by tests.
- **C2 — "Split equally, 1 ways"** · *fixed.* A one-share equal split now reads **Not split**,
  since it isn't one.
- **C3 — tofu emoji** · *mitigated, not confirmed.* `GoogleFonts.interTextTheme()` hands
  Flutter an Inter family with **no** `fontFamilyFallback`, so every emoji relies on the
  engine's implicit walk of the platform font chain. The chain is now named explicitly (Noto
  Color Emoji / Apple Color Emoji / Segoe UI Emoji). **This cannot be confirmed against the
  original report**: the codepoints weren't captured, and if they're genuinely absent from the
  device's emoji font there is nothing to fall back *to* and only bundling a font would fix it.
  If it recurs, capture the raw message bytes first.
- **C4 — read-only rows look tappable** · *fixed, verified live.* Both lists now carry a
  `ReadOnlyNotice` caption saying they're read-only and why. Scroll-to-message is still not
  built — this makes the limitation visible rather than pretending it away.
- **C5 — households called "servers"** · *fixed, verified live.* `GuildKind.noun` already
  existed and was simply unused here. The settings title, name field, delete button/dialog,
  template copy, the module-kind dialog and the module-off view all read it now:
  "House Settings" / "House name" / "Delete house".
- **C6 — search leaks Log Out** · *fixed, verified live.* Log Out isn't an `_Entry` (it acts in
  place rather than pushing a page), which is exactly how it escaped the filter. It now matches
  the query like everything else, and still appears for "log out"/"sign out".
- **C7 — skeleton promises a subtitle** · *fixed.* `SkeletonListTile`'s second line is now
  opt-in. All four current call sites (DMs, channels, members, list items) stand in for
  single-line rows, so none pass it.
- **C8 — inconsistent composer focus rings** · *fixed, verified live.* The list composer set
  `border` but not `focusedBorder`, so the theme's form focus ring won on focus. It now
  suppresses it the way the message composer does.

## Q1 / Q2 — answered, not acted on

- **Q1 — two `dakura` rows.** Confirmed a server-side data question, not a client bug. The
  discs are the same colour, and `AvatarPalette.colorForUserId` keys off the user id — so both
  rows are the *same user* with two distinct 1:1 conversations, rather than two accounts
  sharing a display name. `findDirectMessageWith` returning the first match is a symptom;
  making it "smarter" would only pick a different arbitrary one. Needs the duplicate
  conversation resolved on the backend. **Left alone deliberately** — client-side deduping
  would hide a conversation that may hold messages.
- **Q2 — restock doesn't clear the grocery entry.** Product call, unchanged. The dialog copy
  quoted in the report describes the intended behaviour (entries leave when *ticked*, not when
  the pantry level recovers), so this is working as written until someone decides otherwise.
