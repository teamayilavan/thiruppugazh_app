import 'package:flutter_test/flutter_test.dart';
import 'package:thiruppugazh/ui/widgets/song_web_links.dart';

void main() {
  const hosts = ['youtube.com', 'www.youtube.com'];

  test('allows https on a listed host', () {
    expect(isAllowedWebUrl(Uri.parse('https://www.youtube.com/results?q=x'), hosts), isTrue);
  });

  test('rejects http, other hosts and look-alike hosts', () {
    expect(isAllowedWebUrl(Uri.parse('http://www.youtube.com/'), hosts), isFalse);
    expect(isAllowedWebUrl(Uri.parse('https://evil.com/'), hosts), isFalse);
    expect(isAllowedWebUrl(Uri.parse('https://youtube.com.evil.com/'), hosts), isFalse);
    expect(isAllowedWebUrl(Uri.parse('javascript:alert(1)'), hosts), isFalse);
  });
}
