/// Helpers for turning pasted or shared text into a storable web link.
class LinkUtils {
  LinkUtils._();

  static final RegExp _urlPattern = RegExp(
    r'https?://[^\s<>"]+',
    caseSensitive: false,
  );

  /// Characters that commonly trail a URL in prose ("see https://x.com/a.")
  /// but are almost never part of it.
  static const String _trailingPunctuation = '.,;:!?)]}\'"';

  /// Returns the first http(s) URL found in [text], or null. Shared posts
  /// usually arrive as "Check this out https://..." rather than a bare URL.
  static String? extractUrl(String? text) {
    if (text == null) return null;
    final match = _urlPattern.firstMatch(text);
    if (match == null) return null;
    var url = match.group(0)!;
    while (url.isNotEmpty && _trailingPunctuation.contains(url[url.length - 1])) {
      url = url.substring(0, url.length - 1);
    }
    return isValidUrl(url) ? url : null;
  }

  /// Turns whatever the user pasted or typed into a storable URL, or null.
  /// Accepts a bare URL, text containing one, or a scheme-less host such as
  /// "youtube.com/watch?v=x" (https is assumed).
  static String? parse(String? input) {
    final text = input?.trim() ?? '';
    if (text.isEmpty) return null;
    final found = extractUrl(text);
    if (found != null) return found;

    // Scheme-less host. Anything that already looks like another scheme
    // (mailto:, javascript:) or carries userinfo is rejected, not coerced.
    final looksLikeOtherScheme = RegExp(r'^[a-zA-Z][a-zA-Z0-9+.\-]*:').hasMatch(text);
    if (text.contains(RegExp(r'\s')) ||
        text.contains('@') ||
        looksLikeOtherScheme) {
      return null;
    }
    final candidate = 'https://$text';
    final uri = Uri.tryParse(candidate);
    if (uri != null && isValidUrl(candidate) && uri.host.contains('.')) {
      return candidate;
    }
    return null;
  }

  /// A short label for a shared post: the text around [url] ("Song name -
  /// YouTube https://...") with the URL removed. Null if nothing is left.
  static String? suggestTitle(String? text, String url) {
    if (text == null) return null;
    final rest = text.replaceFirst(url, ' ').replaceAll(RegExp(r'\s+'), ' ').trim();
    if (rest.isEmpty) return null;
    return rest.length > 80 ? '${rest.substring(0, 80).trimRight()}…' : rest;
  }

  /// True only for absolute http/https URLs with a host. Anything else
  /// (javascript:, file:, intent:) is rejected so a tap can never launch it.
  static bool isValidUrl(String? url) {
    if (url == null) return false;
    final uri = Uri.tryParse(url.trim());
    if (uri == null || !uri.hasAuthority || uri.host.isEmpty) return false;
    final scheme = uri.scheme.toLowerCase();
    return scheme == 'http' || scheme == 'https';
  }
}
