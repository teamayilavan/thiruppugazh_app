import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thiruppugazh/constants/app_constants.dart';
import 'package:thiruppugazh/providers/reading_state_provider.dart';

Future<ReadingStateProvider> _make([Map<String, Object> initial = const {}]) async {
  SharedPreferences.setMockInitialValues(initial);
  final provider = ReadingStateProvider();
  await provider.ready;
  return provider;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('starts with nothing to continue', () async {
    final p = await _make();
    expect(p.lastSongId, isNull);
    expect(p.recentSongIds, isEmpty);
    expect(p.lastMode, ResumeMode.read);
    expect(p.lastChantIndex, isNull);
  });

  test('recordOpened keeps the most recent first, without duplicates', () async {
    final p = await _make();
    await p.recordOpened(1);
    await p.recordOpened(2);
    await p.recordOpened(1);
    expect(p.recentSongIds, [1, 2]);
    expect(p.lastSongId, 1);
  });

  test('the recent list is capped', () async {
    final p = await _make();
    for (var i = 1; i <= ReadingStateProvider.maxRecent + 5; i++) {
      await p.recordOpened(i);
    }
    expect(p.recentSongIds, hasLength(ReadingStateProvider.maxRecent));
    expect(p.lastSongId, ReadingStateProvider.maxRecent + 5);
  });

  test('chanting position is remembered and switches the mode', () async {
    final p = await _make();
    await p.recordOpened(7);
    await p.recordChantPosition(7, 3);
    expect(p.lastMode, ResumeMode.chant);
    expect(p.lastChantIndex, 3);
    expect(p.chantIndexFor(7), 3);
  });

  test('reopening the page without chanting goes back to read mode', () async {
    final p = await _make();
    await p.recordChantPosition(7, 3);
    await p.recordOpened(7);
    expect(p.lastMode, ResumeMode.read);
  });

  test('clearing the position stops offering chanting', () async {
    final p = await _make();
    await p.recordChantPosition(7, 3);
    await p.clearChantPosition(7);
    expect(p.lastChantIndex, isNull);
    expect(p.lastMode, ResumeMode.read);
  });

  test('positions are dropped for songs that fall out of the recent list', () async {
    final p = await _make();
    await p.recordChantPosition(1, 2);
    for (var i = 2; i <= ReadingStateProvider.maxRecent + 1; i++) {
      await p.recordOpened(i);
    }
    expect(p.chantIndexFor(1), isNull);
  });

  test('state survives a restart', () async {
    final first = await _make();
    await first.recordOpened(4);
    await first.recordChantPosition(9, 5);

    // Same stored preferences, brand new provider.
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(AppConstants.readingStatePrefsKey)!;
    final second = await _make({AppConstants.readingStatePrefsKey: stored});

    expect(second.lastSongId, 9);
    expect(second.recentSongIds, [9, 4]);
    expect(second.lastMode, ResumeMode.chant);
    expect(second.lastChantIndex, 5);
  });

  test('a corrupt stored value is ignored, not fatal', () async {
    final p = await _make({AppConstants.readingStatePrefsKey: '{not json'});
    expect(p.lastSongId, isNull);
    await p.recordOpened(3);
    expect(p.lastSongId, 3);
  });

  test('junk entries in stored data are filtered out', () async {
    final p = await _make({
      AppConstants.readingStatePrefsKey: jsonEncode({
        'recent': [5, 'x', null, 6],
        'mode': 'chant',
        'chant': {'5': 2, 'bad': 1, '6': -3, '99': 4},
      }),
    });
    expect(p.recentSongIds, [5, 6]);
    expect(p.chantIndexFor(5), 2);
    expect(p.chantIndexFor(6), isNull); // negative index rejected
    expect(p.chantIndexFor(99), isNull); // not in the recent list
  });
}
