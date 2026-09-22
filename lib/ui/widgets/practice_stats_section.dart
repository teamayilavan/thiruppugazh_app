import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../constants/app_constants.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/practice_provider.dart';
import '../../providers/practice_settings_provider.dart';
import '../../theme/app_theme.dart';

/// Two stat tiles -- days practiced on the left, songs read on the right --
/// with a small caption underneath naming the corpus size. Sits below
/// [DailyPracticeCard] on the home screen.
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

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _StatTile(
                  value: practice.totalDays,
                  label: l10n.daysPracticedLabel,
                  colors: colors,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatTile(
                  value: practice.completedCount,
                  label: l10n.songsReadLabel,
                  colors: colors,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            l10n.totalSongsCaption(AppConstants.corpusSize),
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: colors.textMuted),
          ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final int value;
  final String label;
  final AppColorExtension colors;

  const _StatTile({
    required this.value,
    required this.label,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: colors.container,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 12.0),
        child: Column(
          children: [
            Text(
              '$value',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: colors.textHigh,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: colors.textMuted),
            ),
          ],
        ),
      ),
    );
  }
}
