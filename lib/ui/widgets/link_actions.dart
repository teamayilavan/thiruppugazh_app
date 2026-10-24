import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../l10n/app_localizations.dart';
import '../../utils/link_utils.dart';

/// Asks the user to confirm leaving the app for [url], naming the site it
/// goes to -- the same prompt the app shows before any other external link.
Future<bool> confirmOpenLink(BuildContext context, String url) async {
  final l10n = AppLocalizations.of(context)!;
  final host = Uri.tryParse(url)?.host ?? url;
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(l10n.openExternalLink),
      content: Text(l10n.openExternalLinkConfirmation(host)),
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
  return confirmed == true;
}

/// Opens a user-saved link in the browser or the app that handles it, after
/// the user confirms. The URL is re-validated here as well, so even a row
/// that reached the database some other way can never launch a non-http(s)
/// scheme.
Future<void> openSavedLink(BuildContext context, String url) async {
  final messenger = ScaffoldMessenger.of(context);
  final failure = AppLocalizations.of(context)!.linkCouldNotOpen;

  if (!LinkUtils.isValidUrl(url)) {
    messenger.showSnackBar(SnackBar(content: Text(failure)));
    return;
  }
  if (!await confirmOpenLink(context, url)) return;

  var opened = false;
  try {
    opened = await launchUrl(
      Uri.parse(url),
      mode: LaunchMode.externalApplication,
    );
  } catch (_) {
    opened = false;
  }
  if (!opened) {
    messenger.showSnackBar(SnackBar(content: Text(failure)));
  }
}

/// Asks the user to confirm removing a link. Resolves to true if confirmed.
Future<bool> confirmDeleteLink(BuildContext context) async {
  final l10n = AppLocalizations.of(context)!;
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(l10n.deleteLink),
      content: Text(l10n.deleteLinkConfirmation),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(l10n.cancel),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(
            l10n.delete,
            style: const TextStyle(color: Colors.red),
          ),
        ),
      ],
    ),
  );
  return confirmed == true;
}
