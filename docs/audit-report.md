# Codebase Audit Report — Thiruppugazh Flutter App

**Date**: 2026-04-18  
**Scope**: Security · Performance · Code Maintenance  
**Method**: Static analysis — no code was changed

---

## Summary

| Category | Total | High | Medium | Low |
|----------|-------|------|--------|-----|
| Security | 9 | 3 | 4 | 2 |
| Performance | 8 | 3 | 3 | 2 |
| Maintenance | 12 | 0 | 6 | 6 |
| **Total** | **29** | **6** | **13** | **10** |

No critical (data-loss or RCE) issues were found. The app has a good overall structure and clean separation of concerns, but has recurring patterns around async handling, performance, and data safety that are worth addressing.

---

## Security

### SEC-1 · Backup files exported as plaintext — `lib/services/backup_service.dart:54–58`
**Severity**: High

User notes, highlights, and categories are written to disk as unencrypted JSON:

```dart
final file = File('${directory.path}/$fileName');
await file.writeAsString(jsonString);  // No encryption
```

Any app with file access (or a malicious process) can read this file. User notes may contain personal or devotional information. Consider encrypting the backup with a device-derived key before writing.

---

### SEC-2 · Backup import trusts file structure implicitly — `lib/services/backup_service.dart:91–103`
**Severity**: Medium

Import validates that top-level keys exist, but doesn't validate the types, bounds, or contents of nested values:

```dart
if (!importMap.containsKey('favorites') || !importMap.containsKey('categories')) {
  throw Exception('Invalid backup file format');
}
// No further validation — array elements are used without type checks
```

A crafted JSON file with unexpected types or deeply nested values can cause runtime errors or consume excessive memory.

---

### SEC-3 · Deep link song ID not validated — `lib/ui/screens/main_wrapper.dart:72–78`
**Severity**: Medium

The path segment is extracted and used without verifying it's a valid integer:

```dart
if (uri.pathSegments.length > 1) songIdString = uri.pathSegments[1];
// songIdString is later used in a db query with no format check
```

A malformed link (e.g. `thiruppugazh://song/../../etc`) could cause unhandled exceptions.

---

### SEC-4 · Async constructors can silently fail — `lib/providers/theme_provider.dart:10`, `lib/providers/language_provider.dart:25`
**Severity**: High

Both providers call async setup methods from constructors without awaiting:

```dart
ThemeProvider() {
  _loadThemeMode();  // fire-and-forget
}
```

If SharedPreferences throws, the exception is silently swallowed. The app renders before preferences are loaded, causing a brief flash of wrong theme/language.

---

### SEC-5 · `void` return type on async methods — `lib/providers/theme_provider.dart:14,33`
**Severity**: High

Methods declared `void async` instead of `Future<void> async` make it impossible for callers to await them or catch errors:

```dart
void _loadThemeMode() async { ... }   // should be Future<void>
void setThemeMode(ThemeMode mode) async { ... }  // should be Future<void>
```

---

### SEC-6 · Search query sanitisation is misleading — `lib/data/database/database_helper.dart:447–465`
**Severity**: Low

`_sanitizeSearchQuery()` strips quotes, but the app already uses parameterised queries (`whereArgs`), which is the correct SQL-injection defence. The character stripping:
- Gives false confidence
- Can break legitimate Tamil search terms that happen to contain these characters

The sanitisation should be removed and the parameterised query approach documented as the sole defence.

---

### SEC-7 · No client-side validation on category names — `lib/data/repositories/song_repository.dart:109`
**Severity**: Medium

`AppConstants.categoryMaxNameLength` is defined but not enforced before the database insert. An oversized name reaches the database layer rather than being caught at the UI boundary.

---

### SEC-8 · Hardcoded domain in multiple locations — `lib/ui/screens/song_detail_screen.dart:271`
**Severity**: Low

```dart
final deepLink = 'https://thiruppugazh.ayilavan.org/song/${song.id}';
```

The domain appears in at least two places in the UI layer. If the domain changes, it must be updated manually everywhere. Should be a single constant.

---

### SEC-9 · iOS deep links configured but Android `assetlinks.json` not confirmed
**Severity**: Medium

`ios/Runner/Info.plist` enables Flutter deep linking and the app uses `thiruppugazh.ayilavan.org` for App Links. Android App Links require a verified `/.well-known/assetlinks.json` file hosted on the domain. If this file is absent or misconfigured, Android will open links in the browser rather than the app, and any domain could theoretically claim the scheme.

---

## Performance

### PERF-1 · N+1 database queries in Highlights screen — `lib/ui/screens/highlights_notes_screen.dart:91–95`
**Severity**: High

For each highlighted song, a separate `FutureBuilder` calls `getSongById()`:

```dart
return FutureBuilder<Song?>(
  future: repo.getSongById(songId),  // one query per song group
```

With 20 highlighted songs this becomes 20 sequential database queries. The songs should be fetched in a single `WHERE id IN (...)` query.

---

### PERF-2 · `getAllHighlights()` FutureBuilder re-runs on every repository change — `lib/ui/screens/highlights_notes_screen.dart:61–63`
**Severity**: High

```dart
return Consumer<SongRepository>(
  builder: (context, repo, _) => FutureBuilder<List<Highlight>>(
    future: repo.getAllHighlights(),  // new Future created on every notifyListeners()
```

Every time any song's favourite status changes, all highlights reload — even if the highlights themselves are unchanged. The result should be cached or the screen should listen only to highlight changes.

---

### PERF-3 · Duplicate pagination triggers — `lib/ui/screens/home_screen.dart:72–76`, `136–142`
**Severity**: High

`loadMoreSongs()` is triggered in two independent places:

```dart
// Trigger 1 — NotificationListener at line 72
if (scrollInfo.metrics.pixels >= scrollInfo.metrics.maxScrollExtent - 2500) {
  provider.loadMoreSongs();
}

// Trigger 2 — itemBuilder prefetch at line 136–142
if (provider.hasMore && !provider.isLoading && index >= provider.songs.length - 30) {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    provider.loadMoreSongs();
  });
}
```

Both fire for the same scroll event, resulting in duplicate database queries and potential race conditions.

---

### PERF-4 · Hero image loaded synchronously at full size — `lib/ui/screens/home_screen.dart:93–98`
**Severity**: Low

```dart
Image.asset(
  'assets/images/hero.png',
  width: double.infinity,
  height: 350,
  fit: BoxFit.cover,
)
```

No explicit caching or lazy loading. If `hero.png` is large (>500 KB) it will block the raster thread on first load.

---

### PERF-5 · All notes and highlights loaded at once for export — `lib/services/backup_service.dart:22–26`
**Severity**: Medium

```dart
final notes = await _dbHelper.getAllNotes();
final highlights = await _dbHelper.getAllHighlights();
```

For a power user with thousands of records this loads everything into memory simultaneously. Streaming or batching would be safer.

---

### PERF-6 · Search hard-limited to 50 results with no pagination — `lib/data/database/database_helper.dart:420`
**Severity**: Medium

```sql
LIMIT 50
```

Results beyond 50 are silently discarded. There is no pagination UI for search. Users searching for common Tamil words will not see all results without a visible indication that results are truncated.

---

### PERF-7 · Redundant ScrollController alongside NotificationListener — `lib/ui/screens/home_screen.dart:16,72,87`
**Severity**: Low

A `ScrollController` is created and attached, but scroll events for pagination are handled by `NotificationListener`. Both are active, creating duplicate listeners on the same scroll axis.

---

### PERF-8 · Missing database indexes on frequently filtered columns
**Severity**: Medium

The schema creates the `songs` table and adds category/favorites tables, but no explicit indexes are visible on columns used in common queries:
- `favorites.song_id`
- `song_categories.song_id` / `song_categories.category_id`
- `highlights.song_id`

Without indexes, filtering on these columns performs a full table scan on every query.

---

## Code Maintenance

### MAINT-1 · `Song` model is annotated `@immutable` but has a mutable field — `lib/data/models/song_model.dart:22`
**Severity**: Medium

```dart
@immutable
class Song {
  // ...
  List<int> categoryIds;  // mutable List — violates the @immutable contract
```

This breaks assumptions made by `ChangeNotifier` and identity comparisons. The field should be `final List<int>`.

---

### MAINT-2 · `FutureBuilderWithError` widget is dead code — `lib/ui/widgets/error_display_widget.dart:59–112`
**Severity**: Low

The widget is defined but never used anywhere in the app. Additionally, its retry callback calls `setStateFn()` which is a non-functional placeholder:

```dart
onRetry: () {
  setStateFn();  // does nothing
}
```

Either implement the retry logic and use the widget, or delete it.

---

### MAINT-3 · Raw exception objects surfaced to users — `lib/ui/screens/song_list_screen.dart:50`
**Severity**: Medium

```dart
return Center(child: Text('Error: ${snapshot.error}'));
```

This shows a Dart stack-trace–style error string to the user. All user-facing errors should use localised, human-readable messages.

---

### MAINT-4 · Incomplete Tamil variation search — `lib/data/database/database_helper.dart:429`
**Severity**: Low

`_getTamilVariations()` only handles one character swap (ன ↔ ந) and has a comment:

```dart
// We could add more here (ra/Ra, la/La/zha) if needed later
```

This is an unresolved TODO. Either complete the implementation or remove the comment.

---

### MAINT-5 · SharedPreferences key defined inline, not centralised — `lib/providers/theme_provider.dart:6`
**Severity**: Low

```dart
final String _key = "themeMode";
```

Similar inline keys likely exist in other providers. Keys should be centralised in `AppConstants` to prevent silent mismatches if a key is renamed.

---

### MAINT-6 · Unclear database migration strategy — `lib/data/database/database_helper.dart:67–79`
**Severity**: Medium

Comments indicate the migration path is not fully resolved:

```dart
// Since we are consolidating to v1, we assume a "reset" or "ensure" approach.
```

A future version bump without a clear migration will silently lose user data (favourites, categories, notes). The migration strategy should be documented and tested.

---

### MAINT-7 · Silent failure when database asset copy fails — `lib/data/database/database_helper.dart:37–54`
**Severity**: Medium

```dart
} catch (e) {
  AppLogger.error("Error copying database", error: e);
  // Fallback: Let openDatabase create an empty one
}
```

The app continues with an empty database if the bundled asset cannot be copied. The user sees no songs but no error. This should at minimum surface an error screen.

---

### MAINT-8 · Duplicate deep-link domain in UI layer — `lib/ui/screens/song_detail_screen.dart:271`
**Severity**: Low

Same issue as SEC-8 from a maintainability perspective: the domain string is duplicated across the codebase rather than referenced from a single constant.

---

### MAINT-9 · Inconsistent async return types across the codebase
**Severity**: Medium

Some async methods return `Future<void>`, others return `void` (fire-and-forget), with no apparent deliberate design. This makes it difficult to reason about which methods are safe to call without awaiting. A project-wide convention should be established and enforced via the linter.

---

### MAINT-10 · No feedback when duplicate category is silently ignored — `lib/data/repositories/song_repository.dart`
**Severity**: Low

The insert uses `ConflictAlgorithm.ignore`, which means creating a category with an existing name silently does nothing. The user gets no toast, snackbar, or dialog to indicate the name is already taken.

---

### MAINT-11 · Linter rules not strict enough — `analysis_options.yaml`
**Severity**: Low

The project uses default Flutter lints. Enabling additional rules would have caught several issues in this report:

```yaml
linter:
  rules:
    - always_declare_return_types    # catches async void
    - prefer_final_fields             # catches mutable fields in immutable classes
    - use_setters_to_change_properties
    - avoid_void_async               # explicitly flags void async
```

---

### MAINT-12 · Search and filter logic tightly coupled in `SearchScreen` — `lib/ui/screens/search_screen.dart:112–118`
**Severity**: Medium

`SearchFilterOptions` callback directly invokes `_performSearch()`. Filter state and search state are intertwined in the same widget, making it difficult to test filter changes in isolation or reuse either component.

---

## Dependency Notes

Run `flutter pub outdated` to check for available updates. Pay particular attention to:

| Package | Reason to keep current |
|---------|------------------------|
| `sqflite` | SQLite binding — security fixes |
| `file_picker` | File access — permissions model changes |
| `url_launcher` | URL handling — scheme validation |
| `shared_preferences` | Local storage — platform security model |

---

## Positive Findings

- Android manifest requests no dangerous permissions — correct for this app's functionality.
- SQL injection is correctly defended via parameterised queries (`whereArgs`).
- `AppLogger` is used consistently throughout the codebase.
- The app is well-structured with clear separation between data, service, and UI layers.
- Localisation (ARB files) is in place for both English and Tamil.
- Deep-link scheme is correctly scoped to the app's own domain.
