import 'package:flutter/material.dart';

import '../../data/models/category_model.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/app_theme.dart';
import '../widgets/adaptive_layout.dart';
import 'categories_screen.dart';
import 'highlights_notes_screen.dart';
import 'search_screen.dart';
import 'settings_screen.dart';
import 'song_list_screen.dart';

/// One card on the Discover page: what a feature is and, where there is a
/// screen for it, how to open it. Features with no screen of their own (the
/// home-screen widget, sharing a link into the app) carry a how-to line only.
class DiscoverFeature {
  const DiscoverFeature({
    required this.id,
    required this.icon,
    required this.title,
    required this.description,
    this.destination,
    this.largeScreenOnly = false,
  });

  final String id;
  final IconData icon;
  final String Function(AppLocalizations l10n) title;
  final String Function(AppLocalizations l10n) description;

  /// The screen "Try it" opens. Null when there is nothing to open.
  final WidgetBuilder? destination;

  /// Only listed on tablets and other large windows.
  final bool largeScreenOnly;
}

/// Every feature the page can show, in display order. Each one is a real,
/// shipped feature; add a card here when a release adds one.
List<DiscoverFeature> discoverFeatures() => [
  DiscoverFeature(
    id: 'chanting',
    icon: Icons.self_improvement,
    title: (l) => l.discoverChantingTitle,
    description: (l) => l.discoverChantingBody,
  ),
  DiscoverFeature(
    id: 'continue',
    icon: Icons.play_circle_outline,
    title: (l) => l.discoverContinueTitle,
    description: (l) => l.discoverContinueBody,
  ),
  DiscoverFeature(
    id: 'favorites',
    icon: Icons.favorite_border,
    title: (l) => l.discoverFavoritesTitle,
    description: (l) => l.discoverFavoritesBody,
    // Favorites is the built-in category with id 1.
    destination: (context) => SongListScreen(
      category: Category(id: 1, name: AppLocalizations.of(context)!.favorites),
    ),
  ),
  DiscoverFeature(
    id: 'categories',
    icon: Icons.category_outlined,
    title: (l) => l.discoverCategoriesTitle,
    description: (l) => l.discoverCategoriesBody,
    destination: (_) => const CategoriesScreen(),
  ),
  DiscoverFeature(
    id: 'library',
    icon: Icons.library_books_outlined,
    title: (l) => l.discoverLibraryTitle,
    description: (l) => l.discoverLibraryBody,
    destination: (_) => const HighlightsNotesScreen(),
  ),
  DiscoverFeature(
    id: 'links',
    icon: Icons.link,
    title: (l) => l.discoverLinksTitle,
    description: (l) => l.discoverLinksBody,
  ),
  DiscoverFeature(
    id: 'share',
    icon: Icons.ios_share,
    title: (l) => l.discoverShareTitle,
    description: (l) => l.discoverShareBody,
  ),
  DiscoverFeature(
    id: 'widget',
    icon: Icons.widgets_outlined,
    title: (l) => l.discoverWidgetTitle,
    description: (l) => l.discoverWidgetBody,
  ),
  DiscoverFeature(
    id: 'reminder',
    icon: Icons.notifications_outlined,
    title: (l) => l.discoverReminderTitle,
    description: (l) => l.discoverReminderBody,
    destination: (_) => const SettingsScreen(),
  ),
  DiscoverFeature(
    id: 'search',
    icon: Icons.search,
    title: (l) => l.discoverSearchTitle,
    description: (l) => l.discoverSearchBody,
    destination: (_) => const SearchScreen(),
  ),
  DiscoverFeature(
    id: 'keepAwake',
    icon: Icons.stay_current_portrait_outlined,
    title: (l) => l.discoverKeepAwakeTitle,
    description: (l) => l.discoverKeepAwakeBody,
    destination: (_) => const SettingsScreen(),
  ),
  DiscoverFeature(
    id: 'language',
    icon: Icons.translate_outlined,
    title: (l) => l.discoverLanguageTitle,
    description: (l) => l.discoverLanguageBody,
    destination: (_) => const SettingsScreen(),
  ),
  DiscoverFeature(
    id: 'backup',
    icon: Icons.storage_outlined,
    title: (l) => l.discoverBackupTitle,
    description: (l) => l.discoverBackupBody,
    destination: (_) => const SettingsScreen(),
  ),
  DiscoverFeature(
    id: 'tablet',
    icon: Icons.tablet_mac_outlined,
    title: (l) => l.discoverTabletTitle,
    description: (l) => l.discoverTabletBody,
    largeScreenOnly: true,
  ),
];

/// A quiet page of short feature cards. Nothing here changes user data, and
/// "Try it" only opens an existing screen on top of this one.
class DiscoverScreen extends StatelessWidget {
  const DiscoverScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final large = Breakpoints.isLargeScreen(context);
    final features = [
      for (final f in discoverFeatures())
        if (large || !f.largeScreenOnly) f,
    ];

    return Scaffold(
      appBar: AppBar(title: Text(l10n.discoverTitle)),
      body: ContentWidth(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          children: [
            Text(
              l10n.discoverIntro,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            for (final feature in features)
              _FeatureCard(feature: feature, l10n: l10n),
          ],
        ),
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({required this.feature, required this.l10n});

  final DiscoverFeature feature;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColorExtension>()!;
    final onCard = Theme.of(context).colorScheme.onSurface;
    final destination = feature.destination;
    final title = feature.title(l10n);
    final body = feature.description(l10n);

    return Card(
      color: colors.card,
      margin: const EdgeInsets.only(top: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ExcludeSemantics(
              child: Icon(feature.icon, color: onCard, size: 26),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: onCard,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    body,
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: onCard),
                  ),
                  if (destination != null)
                    Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: Semantics(
                        label: '${l10n.discoverTryIt}: $title',
                        excludeSemantics: true,
                        button: true,
                        child: TextButton(
                          style: TextButton.styleFrom(
                            minimumSize: const Size(48, 48),
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                          ),
                          onPressed: () => Navigator.of(
                            context,
                          ).push(MaterialPageRoute(builder: destination)),
                          child: Text(l10n.discoverTryIt),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
