import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../data/models/song_model.dart';
import '../../l10n/app_localizations.dart';

/// The "look this song up" buttons on the song page. Every one goes through
/// [_launchWhitelisted]: https only, a fixed list of hosts, and a
/// confirmation naming the site before anything opens.

Future<void> searchOnYouTube(BuildContext context, Song song) {
  final l10n = AppLocalizations.of(context)!;
  final songTitle = Uri.encodeComponent(song.title);
  return _launchWhitelisted(
    context,
    url: Uri.parse(
      'https://www.youtube.com/results?search_query=திருப்புகழ்%20$songTitle',
    ),
    hosts: const ['youtube.com', 'www.youtube.com'],
    siteName: 'YouTube',
    failure: l10n.couldNotLaunchYouTube(song.title),
  );
}

Future<void> searchOnGoogle(BuildContext context, Song song) {
  final l10n = AppLocalizations.of(context)!;
  final songTitle = Uri.encodeComponent(song.title);
  return _launchWhitelisted(
    context,
    url: Uri.parse('https://www.google.com/search?q=திருப்புகழ்%20$songTitle'),
    hosts: const ['google.com', 'www.google.com'],
    siteName: 'Google',
    failure: l10n.couldNotLaunchGoogle(song.title),
  );
}

Future<void> openOnKaumaram(BuildContext context, Song song) {
  final l10n = AppLocalizations.of(context)!;
  final kaumaramId = song.kaumaramId.padLeft(4, '0');
  return _launchWhitelisted(
    context,
    url: Uri.parse('https://kaumaram.com/thiru/nnt${kaumaramId}_u.html'),
    hosts: const ['kaumaram.com', 'www.kaumaram.com'],
    siteName: 'Kaumaram',
    failure: l10n.couldNotLaunchUrl,
  );
}

Future<void> openOnMayuragiri(BuildContext context, Song song) {
  final l10n = AppLocalizations.of(context)!;
  return _launchWhitelisted(
    context,
    url: Uri.parse('https://mayuragiri.com/thiruppugal${song.kaumaramId}'),
    hosts: const ['mayuragiri.com', 'www.mayuragiri.com'],
    siteName: 'Mayuragiri',
    failure: l10n.couldNotLaunchMayuragiri,
  );
}

/// Whether [url] is https on one of [allowedHosts].
@visibleForTesting
bool isAllowedWebUrl(Uri url, List<String> allowedHosts) =>
    url.scheme == 'https' && allowedHosts.contains(url.host);

/// Opens [url] in the browser, but only if it is https on one of [hosts],
/// and only after the user confirms, naming [siteName].
Future<void> _launchWhitelisted(
  BuildContext context, {
  required Uri url,
  required List<String> hosts,
  required String siteName,
  required String failure,
}) async {
  final messenger = ScaffoldMessenger.of(context);
  final invalid = AppLocalizations.of(context)!.invalidUrl;

  if (!isAllowedWebUrl(url, hosts)) {
    messenger.showSnackBar(SnackBar(content: Text(invalid)));
    return;
  }

  final confirmed = await _confirmOpen(context, siteName);
  if (confirmed == true && !await launchUrl(url)) {
    messenger.showSnackBar(SnackBar(content: Text(failure)));
  }
}

Future<bool?> _confirmOpen(BuildContext context, String siteName) {
  final l10n = AppLocalizations.of(context)!;
  return showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(l10n.openExternalLink),
      content: Text(l10n.openExternalLinkConfirmation(siteName)),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: () => Navigator.of(dialogContext).pop(true),
          child: Text(l10n.open),
        ),
      ],
    ),
  );
}
