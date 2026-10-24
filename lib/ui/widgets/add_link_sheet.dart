import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../data/models/link_model.dart';
import '../../data/repositories/song_repository.dart';
import '../../l10n/app_localizations.dart';
import '../../utils/link_utils.dart';

/// Shows a bottom sheet to attach a web link to [songId]. Resolves to true
/// if a link was saved.
Future<bool> showAddLinkSheet(BuildContext context, {required int songId}) async {
  final saved = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) => _AddLinkSheet(songId: songId),
  );
  return saved == true;
}

class _AddLinkSheet extends StatefulWidget {
  const _AddLinkSheet({required this.songId});

  final int songId;

  @override
  State<_AddLinkSheet> createState() => _AddLinkSheetState();
}

class _AddLinkSheetState extends State<_AddLinkSheet> {
  final _urlController = TextEditingController();
  final _labelController = TextEditingController();
  String? _error;
  bool _saving = false;

  @override
  void dispose() {
    _urlController.dispose();
    _labelController.dispose();
    super.dispose();
  }

  Future<void> _paste() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    final text = data?.text;
    if (text == null || text.trim().isEmpty || !mounted) return;
    final url = LinkUtils.parse(text);
    setState(() {
      _urlController.text = url ?? text.trim();
      _error = null;
      if (url != null && _labelController.text.isEmpty) {
        final suggested = LinkUtils.suggestTitle(text, url);
        if (suggested != null) _labelController.text = suggested;
      }
    });
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context)!;
    final url = LinkUtils.parse(_urlController.text);
    if (url == null) {
      setState(() => _error = l10n.linkInvalid);
      return;
    }

    setState(() => _saving = true);
    final repo = Provider.of<SongRepository>(context, listen: false);
    final label = _labelController.text.trim();
    final added = await repo.addLinkIfAbsent(
      SongLink(
        songId: widget.songId,
        url: url,
        title: label.isEmpty ? null : label,
        createdAt: DateTime.now(),
      ),
    );
    if (!mounted) return;
    if (added) {
      Navigator.of(context).pop(true);
    } else {
      setState(() {
        _saving = false;
        _error = l10n.linkAlreadyAdded;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        16,
        0,
        16,
        16 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l10n.addLink, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 16),
          TextField(
            controller: _urlController,
            keyboardType: TextInputType.url,
            autofocus: true,
            onChanged: (_) {
              if (_error != null) setState(() => _error = null);
            },
            decoration: InputDecoration(
              labelText: l10n.linkUrl,
              errorText: _error,
              border: const OutlineInputBorder(),
              suffixIcon: IconButton(
                tooltip: l10n.pasteLink,
                icon: const Icon(Icons.content_paste),
                onPressed: _paste,
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _labelController,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
              labelText: l10n.linkLabelOptional,
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _saving ? null : _save,
            child: Text(l10n.addLink),
          ),
        ],
      ),
    );
  }
}
