import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../l10n/app_localizations.dart';
import '../../utils/link_utils.dart';

/// Opens a user-saved link in the browser or the app that handles it.
/// The URL is re-validated here as well, so even a row that reached the
/// database some other way can never launch a non-http(s) scheme.
Future<void> openSavedLink(BuildContext context, String url) async {
  final messenger = ScaffoldMessenger.of(context);
  final message = AppLocalizations.of(context)!.linkCouldNotOpen;

  var opened = false;
  if (LinkUtils.isValidUrl(url)) {
    try {
      opened = await launchUrl(
        Uri.parse(url),
        mode: LaunchMode.externalApplication,
      );
    } catch (_) {
      opened = false;
    }
  }
  if (!opened) {
    messenger.showSnackBar(SnackBar(content: Text(message)));
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
