import 'package:flutter_test/flutter_test.dart';
import 'package:thiruppugazh/utils/link_utils.dart';

void main() {
  group('isValidUrl', () {
    test('accepts http and https', () {
      expect(LinkUtils.isValidUrl('https://youtu.be/abc'), isTrue);
      expect(LinkUtils.isValidUrl('http://example.com/a?b=1'), isTrue);
    });

    test('rejects other schemes and junk', () {
      for (final bad in [
        'javascript:alert(1)',
        'file:///etc/passwd',
        'intent://scan/#Intent;end',
        'mailto:a@b.com',
        'ftp://example.com',
        'https://',
        'not a url',
        '',
        null,
      ]) {
        expect(LinkUtils.isValidUrl(bad), isFalse, reason: '$bad');
      }
    });
  });

  group('extractUrl', () {
    test('finds a URL inside shared text', () {
      expect(
        LinkUtils.extractUrl('Check this out https://youtu.be/abc123 so good'),
        'https://youtu.be/abc123',
      );
    });

    test('strips trailing sentence punctuation', () {
      expect(
        LinkUtils.extractUrl('see https://example.com/a.'),
        'https://example.com/a',
      );
      expect(
        LinkUtils.extractUrl('(https://example.com/a)'),
        'https://example.com/a',
      );
    });

    test('keeps query strings and fragments', () {
      expect(
        LinkUtils.extractUrl('https://www.youtube.com/watch?v=xyz&t=10s#c'),
        'https://www.youtube.com/watch?v=xyz&t=10s#c',
      );
    });

    test('returns null when there is no web link', () {
      expect(LinkUtils.extractUrl('just words'), isNull);
      expect(LinkUtils.extractUrl(null), isNull);
      expect(LinkUtils.extractUrl('javascript:alert(1)'), isNull);
    });
  });

  group('parse', () {
    test('passes a full URL through', () {
      expect(
        LinkUtils.parse('  https://example.com/x  '),
        'https://example.com/x',
      );
    });

    test('assumes https for a scheme-less host', () {
      expect(
        LinkUtils.parse('youtube.com/watch?v=1'),
        'https://youtube.com/watch?v=1',
      );
    });

    test('extracts from surrounding text', () {
      expect(
        LinkUtils.parse('Song - YouTube https://youtu.be/a'),
        'https://youtu.be/a',
      );
    });

    test('rejects other schemes, userinfo tricks, spaces and bare words', () {
      for (final bad in [
        'javascript:alert(1)',
        'mailto:x@y.com',
        'user@example.com',
        'localhost',
        'two words',
        '',
        '   ',
      ]) {
        expect(LinkUtils.parse(bad), isNull, reason: bad);
      }
      expect(LinkUtils.parse(null), isNull);
    });
  });

  group('suggestTitle', () {
    test('uses the text around the URL', () {
      const url = 'https://youtu.be/a';
      expect(
        LinkUtils.suggestTitle('Kandar Anubhuti - YouTube $url', url),
        'Kandar Anubhuti - YouTube',
      );
    });

    test('is null when the text is only the URL', () {
      const url = 'https://youtu.be/a';
      expect(LinkUtils.suggestTitle(url, url), isNull);
      expect(LinkUtils.suggestTitle(null, url), isNull);
    });

    test('truncates very long text', () {
      const url = 'https://youtu.be/a';
      final title = LinkUtils.suggestTitle('${'word ' * 60}$url', url)!;
      expect(title.length, lessThanOrEqualTo(81));
      expect(title.endsWith('…'), isTrue);
    });
  });
}
