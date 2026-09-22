import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../constants/app_constants.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/practice_provider.dart';
import '../../providers/practice_settings_provider.dart';
import '../../theme/app_theme.dart';

/// Two stats -- days practiced on the left, songs read on the right --
/// separated by a thin vertical divider, with a small caption underneath
/// naming the corpus size. Flat, no card chrome: bounded by a Divider
/// above and below to match the rest of the home screen's list style.
/// Sits below [DailyPracticeCard] on the home screen.
///
/// Returns [SizedBox.shrink] whenever the practice layer is off --
/// standing rule 7.
class PracticeStatsSection extends StatelessWidget {
  const PracticeStatsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final enabled = context.watch<PracticeSettingsProvider>().enabled;
    if (!enabled) return const SizedBox.shrink();

    final l10n = AppLocalizations.of(context)!;
    final colors = Theme.of(context).extension<AppColorExtension>()!;
    final practice = context.watch<PracticeProvider>();

    return Column(
      children: [
        const Divider(height: 1),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: IntrinsicHeight(
            child: Row(
              children: [
                Expanded(
                  child: _StatTile(
                    icon: Icons.calendar_today_outlined,
                    value: practice.totalDays,
                    label: l10n.daysPracticedLabel,
                    colors: colors,
                  ),
                ),
                VerticalDivider(width: 1, color: colors.card),
                Expanded(
                  child: _StatTile(
                    icon: Icons.menu_book_outlined,
                    value: practice.completedCount,
                    label: l10n.songsReadLabel,
                    colors: colors,
                  ),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: Text(
            l10n.totalSongsCaption(AppConstants.corpusSize),
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: colors.textMuted),
          ),
        ),
        const Divider(height: 1),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  final IconData icon;
  final int value;
  final String label;
  final AppColorExtension colors;

  const _StatTile({
    required this.icon,
    required this.value,
    required this.label,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: colors.textHigh, size: 26),
        const SizedBox(height: 6),
        Text(
          '$value',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: colors.textHigh,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          textAlign: TextAlign.center,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: colors.textMuted),
        ),
      ],
    );
  }
}
