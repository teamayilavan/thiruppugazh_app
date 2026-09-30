# Figma Design System — Status (paused 2026-09-25)

Figma file: https://www.figma.com/design/PoAarFZ7Gr4olc9X1NMaF5/Thiruppugazh
Figma account: Ayilavan (teamayilavan@gmail.com), team "teamayilavan's team", plan tier **Starter**, seat **View**.

## Why it's paused

The Figma MCP server enforces a hard **20 tool-calls/month** cap on the Starter plan — this applies to *both* View and Dev/Full seats (per Figma's own `rate-limits-access.md`: the Starter column spans both seat rows at "Up to 20/month"). We hit this cap partway through building the foundations page. To resume with meaningful throughput, the Figma **seat/plan needs upgrading to Professional or higher** (Professional Dev/Full seat = 200 calls/day, 15/min) — otherwise each session can only make a handful of calls before erroring out again.

The Starter plan also caps **files at 3 pages total** (`createPage()` throws past 3) — already designed around, see below.

## What's done (persisted in the actual Figma file, not dependent on this doc)

**Phase 1 — Foundations (complete):**
- 4 variable collections: `Primitives` (17 raw colors), `Color` (28 semantic variables), `Spacing` (6), `Radius` (6)
- Because Starter also has no multi-mode variable support (`addMode()` throws "Limited to 1 modes only"), light/dark live as **separate named variables** instead of Figma modes: `color/light/bg/canvas` vs `color/dark/bg/canvas`, etc. (not `color/bg/canvas` with a Light/Dark mode switch)
- All variables scoped explicitly, code syntax set (Android: `AppColors.xxx`, Web: `var(--...)`)
- 15 Material 3 type-scale text styles (font: Roboto Regular/Medium) + 2 elevation effect styles (`elevation/level-1-card`, `elevation/level-3-sheet-dialog`)

**Phase 2 — File structure (partial):**
- 3-page skeleton: `Foundations` / `Components` / `Screens` (page IDs: `0:1` / `4:82` / `4:83`). Each page uses **Sections** (unlimited, unlike pages) to organize content instead of one-page-per-component/screen.
- Foundations page has: a Cover section, a Color-swatches section (light+dark columns), a Type-specimen section, a Spacing/Radius bars section.

## Known bug to fix on resume

**Tamil text renders blank in Roboto.** The Figma renderer's "Roboto" has no Tamil glyph coverage — any text containing Tamil characters (Unicode range U+0B80–U+0BFF) renders as an invisible/1×1 glyph run when set in Roboto. Fix: use font family **"Noto Sans Tamil"** (confirmed available, styles: Regular/Medium/Bold/SemiBold/etc., renders Latin fine too) for any string containing Tamil characters, and keep Roboto only for pure-Latin/UI text.

- Already fixed: the cover title node (was node `5:4` in that session).
- Still broken as of pause: ~10 Tamil-containing sample lines in the Type Scale specimen section (node `6:91` subtree) still use Roboto.
- **Action for next session:** before building anything else, sweep every page with `findAllWithCriteria({types:['TEXT']})`, regex-test `characters` against `/[஀-௿]/`, and swap font family to `Noto Sans Tamil` (matching weight) wherever it matches. Bake a Tamil-aware font-picker into the reusable text-creation helper used for all future component/screen text, since nearly every screen shows real Tamil song/temple titles.

## Remaining work (not started)

**Phase 3 — Components** (on the `Components` page, one Section per component/family):
NavigationBar (5 destinations: Songs/Temples/Categories/Library/More), AppBar, SongListItem (ordinal+title+place row, divider-bounded flat style — no Card chrome), TempleRow (with/without progress-bar variant), Card (2 variants: onboarding-option-picker, Arupadai grid panel), FilledButton/OutlinedButton/TextButton, FilterChip, SearchField, SwitchListTile, CheckboxListTile, AlertDialog shell, BottomSheet shell, stacked-FAB pair, StatTile, circular ProgressRing, LinearProgress bar, ErrorDisplayWidget state.

**Phase 4 — Screens** (on the `Screens` page, one Section per screen, light+dark frames side by side):
Onboarding, Home, MainWrapper (nav shell), SongList, SongDetail, Categories, Search, TempleSongs, Temples, Arupadai, MandalamComplete, HighlightsNotes ("Library"), Settings ("More"), PrivacyPolicy — plus 3 overlay frames: AddToCategoryDialog, MilestoneSheet, NotificationIntroSheet.

**Phase 5 — Integration/QA:** accessibility contrast check, naming audit, unresolved-hardcoded-fill audit, final visual review.

## Real content to use when building screens (from codebase research)

- **App title**: "திருப்புகழ்" (Thiruppugazh). Onboarding heritage line: "Arunagirinathar composed over 16,000 hymns. 1,334 survived. You are one of the people keeping them read."
- **Bottom nav (5, in order)**: Songs (music_note) / Temples (temple_hindu) / Categories (category) / Library (library_books) / More (more_horiz)
- **6 Arupadai Veedu temples** (Tamil / romanized / song count): திருப்பரங்குன்றம்/thirupparangkundRam (14), திருச்செந்தூர்/thiruchchendhUr (84), பழநி/pazhani (98), சுவாமிமலை/SwAmimalai (40), திருத்தணிகை/thiruththaNigai (64), பழமுதிர்ச்சோலை/pazhamudhirchOlai (16)
- **Sample real song titles** (from திருப்பரங்குன்றம்): அருக்கு மங்கையர், உனைத் தினம், கருவடைந்து, கறுக்கும் அஞ்சன, கனகந்திரள்கின்ற
- **Only "Favorites" category ships by default** (heart icon); others are user-created
- Full per-screen layout breakdown (widgets top-to-bottom, states, real copy) was captured in a research pass on 2026-09-25 — re-run the same research (read `lib/ui/screens/*.dart` + `lib/ui/widgets/*.dart` + `lib/constants/arupadai.dart` + `assets/*.json`/`thiruppugazh.db`) if this doc's summary isn't enough detail when resuming.

## To resume

Tell Claude: "Resume the Thiruppugazh Figma design system — see `docs/figma-design-system-status.md`." Upgrade the Figma seat/plan first if more than a handful of MCP calls will be needed in the session.
