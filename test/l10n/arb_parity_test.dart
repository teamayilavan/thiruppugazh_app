import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

Set<String> _messageKeys(String path) {
  final map = jsonDecode(File(path).readAsStringSync()) as Map<String, dynamic>;
  return map.keys.where((k) => !k.startsWith('@')).toSet();
}

void main() {
  test('app_en.arb and app_ta.arb define the same messages', () {
    final en = _messageKeys('lib/l10n/app_en.arb');
    final ta = _messageKeys('lib/l10n/app_ta.arb');

    expect(en.difference(ta), isEmpty, reason: 'missing from app_ta.arb');
    expect(ta.difference(en), isEmpty, reason: 'missing from app_en.arb');
  });
}
