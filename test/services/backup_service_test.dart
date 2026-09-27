import 'package:flutter_test/flutter_test.dart';
import 'package:thiruppugazh/data/models/highlight_model.dart';
import 'package:thiruppugazh/data/models/note_model.dart';
import 'package:thiruppugazh/services/backup_service.dart';

void main() {
  group('validateBackupVersion', () {
    test('accepts version 1', () {
      expect(validateBackupVersion({'version': 1, 'favorites': [], 'categories': []}), 1);
    });

    test('rejects a missing version', () {
      expect(
        () => validateBackupVersion({'favorites': [], 'categories': []}),
        throwsA(isA<FormatException>()),
      );
    });

    test('rejects an unsupported version', () {
      expect(
        () => validateBackupVersion({'version': 2, 'favorites': [], 'categories': []}),
        throwsA(isA<FormatException>()),
      );
    });
  });

  group('_songIdsPresentIn (via filterExistingIds)', () {
    test('splits requested IDs into present and missing', () {
      final present = filterExistingIds([1, 2, 3, 99], {1, 2, 3});
      expect(present, [1, 2, 3]);
    });

    test('returns an empty list when none exist', () {
      expect(filterExistingIds([5, 6], {1, 2, 3}), isEmpty);
    });
  });

  group('withoutRowId', () {
    test('drops id so a note gets a fresh local id, keeping song_id for the merge', () {
      final backupRow = Note(
        id: 1,
        songId: 42,
        content: 'hello',
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 2),
      ).toMap();

      final stripped = withoutRowId(backupRow);
      expect(stripped.containsKey('id'), false);

      final note = Note.fromMap(stripped);
      expect(note.id, isNull);
      expect(note.songId, 42);
      expect(note.content, 'hello');
      expect(note.createdAt, DateTime(2026, 1, 1));
      expect(note.updatedAt, DateTime(2026, 1, 2));
    });

    test('drops id from a highlight, keeping everything else', () {
      final backupRow = Highlight(
        id: 3,
        songId: 7,
        verseIndex: 2,
        textContent: 'verse',
        createdAt: DateTime(2026, 1, 1),
      ).toMap();

      final hl = Highlight.fromMap(withoutRowId(backupRow));
      expect(hl.id, isNull);
      expect(hl.songId, 7);
      expect(hl.verseIndex, 2);
      expect(hl.textContent, 'verse');
    });

    test('accepts a loosely-typed decoded JSON map and does not mutate it', () {
      final Map<dynamic, dynamic> decoded = {'id': 5, 'song_id': 9};
      final stripped = withoutRowId(decoded);
      expect(stripped, {'song_id': 9});
      expect(decoded, {'id': 5, 'song_id': 9});
    });
  });
}
