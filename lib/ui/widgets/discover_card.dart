import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../providers/discover_provider.dart';
import '../../theme/app_theme.dart';
import '../screens/discover_screen.dart';

/// A quiet pointer from Home to the Discover page. It opens nothing by
/// itself, and once the user closes it (or opens Discover from it) it stays
/// gone. Hidden until the saved choice has been read, so it never flashes up
/// for someone who already closed it.
class DiscoverCard extends StatelessWidget {
  const DiscoverCard({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DiscoverProvider>();
    if (!provider.loaded || provider.cardDismissed) {
      return const SizedBox.shrink();
    }

    final l10n = AppLocalizations.of(context)!;
    final colors = Theme.of(context).extension<AppColorExtension>()!;
    final onCard = Theme.of(context).colorScheme.onSurface;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Card(
        color: colors.card,
        clipBehavior: Clip.antiAlias,
        child: Row(
          children: [
            Expanded(
              child: Semantics(
                button: true,
                label: '${l10n.discoverCardTitle}. ${l10n.discoverCardBody}',
                excludeSemantics: true,
                child: InkWell(
                  onTap: () {
                    provider.dismissCard();
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const DiscoverScreen()),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 0, 16),
                    child: Row(
                      children: [
                        Icon(Icons.explore_outlined, color: onCard, size: 26),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.discoverCardTitle,
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(
                                      color: onCard,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                l10n.discoverCardBody,
                                style: Theme.of(
                                  context,
                                ).textTheme.bodySmall?.copyWith(color: onCard),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            IconButton(
              icon: Icon(Icons.close, color: onCard),
              tooltip: l10n.discoverCardDismiss,
              onPressed: provider.dismissCard,
            ),
          ],
        ),
      ),
    );
  }
}
