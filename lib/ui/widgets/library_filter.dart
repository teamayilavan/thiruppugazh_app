import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';

/// A Library list shorter than this needs no filter box; it appears once the
/// list has grown enough to be worth searching.
const int libraryFilterThreshold = 8;

/// Keeps the rows where any of [keys] contains [filter] (case-insensitive).
/// An empty [filter] keeps everything.
List<Map<String, dynamic>> filterLibraryRows(
  List<Map<String, dynamic>> rows,
  String filter,
  List<String> keys,
) {
  final f = filter.trim().toLowerCase();
  if (f.isEmpty) return rows;
  return [
    for (final row in rows)
      if (keys.any(
        (k) => ((row[k] as String?) ?? '').toLowerCase().contains(f),
      ))
        row,
  ];
}

/// A Library list with a filter box above it once it is long enough.
/// [total] is the number of rows before filtering, [nothingMatches] whether
/// the filter left none.
Widget libraryListFrame({
  required AppLocalizations l10n,
  required int total,
  required bool nothingMatches,
  required ValueChanged<String> onFilter,
  required Widget list,
}) {
  return Column(
    children: [
      if (total >= libraryFilterThreshold)
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
          child: TextField(
            onChanged: onFilter,
            decoration: InputDecoration(
              hintText: l10n.filterLibraryHint,
              prefixIcon: const Icon(Icons.search),
              isDense: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      Expanded(
        child: nothingMatches ? Center(child: Text(l10n.noResultsFound)) : list,
      ),
    ],
  );
}
