# Thiruppugazh Design System — Penpot (self-hosted)

Built 2026-09-25. Supersedes the earlier Figma attempt (`docs/figma-design-system-status.md`),
which was abandoned after hitting Figma's Starter-plan MCP rate limit (20 calls/month).
Penpot is self-hosted locally via Docker in WSL2, with no such limits, so this build is complete.

## Access

- Web app: **http://localhost:9001** (Penpot account created 2026-09-25)
- File: **Thiruppugazh** (already open/connected in the user's browser via the Penpot MCP plugin)
- Runtime: Docker Compose stack in WSL2 Ubuntu-22.04, project dir `/opt/penpot` (compose file downloaded from `penpot/penpot` main branch), containers: frontend, backend, exporter, admin-console, mcp, postgres, valkey, mailcatcher.
- **Do not stop/reboot without checking**: WSL2's default idle timeouts (`instanceIdleTimeout` 15s, `vmIdleTimeout` 60s) would silently kill the whole stack a minute after the last `wsl.exe` command. Fixed via `C:\Users\mvino\.wslconfig`:
  ```
  [wsl2]
  vmIdleTimeout=-1
  [general]
  instanceIdleTimeout=-1
  ```
  If Penpot ever becomes unreachable at localhost:9001 again, check this file first, then `wsl -d Ubuntu-22.04 -u root -- bash -c "cd /opt/penpot && docker compose -p penpot -f docker-compose.yaml up -d"`.
- Claude Code MCP registration: `claude mcp add --transport http penpot "http://localhost:9001/mcp/stream?userToken=<token>"` (already done, stored in this project's local `.claude.json`). The token came from the file's MCP connect flow inside Penpot's UI.

## What's built

**Foundations page** — Cover, color swatch documentation (Light/Dark side-by-side), a 15-style Material 3 type specimen (Roboto), spacing/radius scale bars.

**Design tokens** (`penpot.library.local.tokens`, 72 tokens across 5 sets — all active):
- `primitives` (17): raw hex values from the app's `AppColorExtension`/`AppColors` (light/dark green palette)
- `colors` (28): semantic tokens, named `color.light.<role>` / `color.dark.<role>` (e.g. `color.light.bg.canvas`, `color.dark.text.high`, `color.light.nav.icon-selected`). **Not real Figma-style modes** — Penpot's theme/mode system works, but two frames can't show two different resolved values simultaneously from one active theme, so light/dark are separate token names instead, letting screens show both side by side.
- `spacing` (6): `spacing.xs`…`spacing.2xl` (4/8/16/24/32/48)
- `radius` (6): `radius.none`…`radius.full` (0/4/8/12/16/999)
- `typography` (15): Material 3 type scale, Roboto. **Gotcha**: `lineHeight` on a typography token is a **unitless ratio** (like CSS `line-height: 1.5`), not absolute px — using absolute px values (as Material 3 specs list them) inflates text height by ~30-50x. Always convert: `ratio = lineHeightPx / fontSizePx`.

**Components page** (23 library components, organized in labeled wrapper boards, not separate pages):
Button (Filled/Outlined/Text), Chip (Selected/Unselected), NavigationBar (Light/Dark, 5 destinations: Songs/Temples/Categories/Library/More), AppBar, ListRow (Song, Temple-WithProgress), Card (Onboarding-Option, Arupadai-Panel), PracticeStatsSection, DailyPracticeCard, FAB-Stack, SwitchListTile, CheckboxListTile, SearchField, AlertDialog, BottomSheet (doubles as MilestoneSheet), NotificationIntroSheet, AddToCategoryDialog, ErrorDisplayWidget.

**Screens page** (24 frames = 12 screens × light/dark): Home (includes the nav-shell chrome — MainWrapper wasn't built as a separate screen since it's always visible behind Home), Onboarding, SongDetail, Categories, Search, TempleSongs, Temples, Arupadai, MandalamComplete, HighlightsNotes ("Library" tab), Settings ("More" tab), PrivacyPolicy. All populated with real content from the app (actual Tamil song titles, the 6 Arupadai Veedu temples, real nav structure) pulled from a codebase research pass.

## Key technical gotchas hit during the build (for future sessions)

1. **Font exact-match required**: `penpot.fonts.findByName('Roboto')` can match `'Roboto Mono'` instead of plain `'Roboto'`. Always use `penpot.fonts.all.find(f => f.name === 'Roboto')` for an exact match.
2. **Tamil needs a different font**: Roboto has no Tamil glyphs (renders blank). Use `Noto Sans Tamil` for any string matching `/[\u0B80-\u0BFF]/`; Roboto for everything else. This logic is baked into the reusable `storage.makeText`/`storage.styleText` helpers used throughout the build (see below).
3. **Typography token `lineHeight` is a ratio, not px** (see above).
4. **Applying a typography token resets `growType` to `'fixed'`** — always re-set `text.growType = 'auto-width'` (or `'auto-height'`) immediately after `token.applyToShapes([text], ['typography'])`.
5. **`flexAlignItems`/`justifyContent` use `'start'|'end'`, not `'flex-start'|'flex-end'`.**
6. **`text.characters` cannot be set to an empty string** — remove the text node instead if you want to clear a label.
7. **A new child's `layoutChild` is `null` until it's actually appended to an auto-layout parent** — append first, then set `layoutChild.horizontalSizing`/`verticalSizing`.
8. **Component names containing `/` are silently truncated to their last path segment** by Penpot's `.name` getter (e.g. `'Card/Arupadai-Panel'` reads back as `'Arupadai-Panel'`). A component/instance's on-canvas display name can also come back as `'Card / Card / Arupadai-Panel'` (double, space-separated) — don't rely on instance names for identifying "which one is which"; use returned IDs instead.
9. **Failed `execute_code` calls do NOT roll back prior mutations in the same script** — `createBoard`/`createRectangle`/`createText` auto-append to the current page root immediately as each line runs, so a script that throws partway through leaves partial boards/orphan shapes behind. Always sanity-check `penpot.root.children` after a failure and clean up before retrying. (By contrast, `component.instance()` returns a detached shape that only persists once explicitly `appendChild`-ed somewhere — no orphan risk there.)
10. **Dark-mode generation shortcut**: build the screen once in light, `shape.clone()` it, then walk descendants (`penpotUtils.analyzeDescendants`) reapplying each bound `color.light.*` token's `color.dark.*` counterpart to the same property. This is the `storage.convertToDark(rootShape)` helper used for every screen's dark variant — much faster than rebuilding twice.

## Reusable helpers (defined in the MCP session's `storage` object — re-declare if resuming in a new session)

`storage.fonts` (exact Roboto/Noto Sans Tamil font refs), `storage.makeText(chars, size, weight, colorTokenName)`, `storage.makeBoard(name, x, y)`, `storage.applyColorFill`, `storage.applyTypographyToken`, `storage.instanceOf(componentName)` / `storage.getComponent` (handles the `/`-truncation alias map — see `storage.componentAlias`), `storage.convertToDark(rootShape)`, `storage.songRowFor(ordinal, title, place)`.

## Not yet done / possible follow-ups

- No Code Connect / dev-mode annotations.
- Icons are emoji placeholders, not a real icon font/component set (no Material Symbols font was loaded).
- No accessibility contrast audit was run.
- `MainWrapper` (the bottom-nav shell) isn't a standalone frame — it's implicit in every screen via the pinned `NavigationBar` instance.
