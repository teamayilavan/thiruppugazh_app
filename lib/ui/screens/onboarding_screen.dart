import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/models/song_model.dart';
import '../../data/repositories/song_repository.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/practice_settings_provider.dart';
import '../../services/daily_selection_service.dart';
import '../../theme/app_theme.dart';

/// The v1.5 sankalpam onboarding screen (T1.9). Shown once, from
/// MainWrapper, while `PracticeSettingsProvider.onboardingComplete` is
/// false. One screen with one in-place state transition (picker ->
/// value-first reveal) -- no carousel, no multi-step flow, no
/// notification permission ask (that's T2.2, gated to day 3).
///
/// The chosen sankalpam and first-run date are only persisted on the
/// final "continue" tap, not the moment an option is picked -- that's
/// what lets the reveal step show first without MainWrapper (which
/// watches `onboardingComplete`) swapping this screen away instantly.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  Sankalpam? _selected;
  Song? _verseSong;
  bool _loadingVerse = false;

  void _choose(Sankalpam value) {
    setState(() {
      _selected = value;
      _loadingVerse = true;
    });
    _loadVerse();
  }

  /// Same date-seeded pick as DailyPracticeCard's "today's grace" --
  /// deliver value before any ask, and the verse shown here matches what
  /// the home screen will show once onboarding finishes.
  Future<void> _loadVerse() async {
    final repo = Provider.of<SongRepository>(context, listen: false);
    try {
      final allIds = await repo.getAllSongIds();
      if (allIds.isEmpty) {
        if (mounted) setState(() => _loadingVerse = false);
        return;
      }
      final sortedIds = [...allIds]..sort();
      final index = verseSongIdForDate(DateTime.now(), sortedIds.length);
      final song = await repo.getSongById(sortedIds[index]);
      if (!mounted) return;
      setState(() {
        _verseSong = song;
        _loadingVerse = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loadingVerse = false);
    }
  }

  Future<void> _finish() async {
    final selected = _selected;
    if (selected == null) return;
    final settings = Provider.of<PracticeSettingsProvider>(
      context,
      listen: false,
    );
    await settings.setSankalpam(selected);
    await settings.markFirstRunIfUnset();
    // No navigation call here: MainWrapper watches onboardingComplete
    // and swaps away from this screen on its own once it flips true.
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = Theme.of(context).extension<AppColorExtension>()!;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: _selected == null
              ? _buildPicker(context, l10n, colors)
              : _buildReveal(context, l10n, colors),
        ),
      ),
    );
  }

  Widget _buildPicker(
    BuildContext context,
    AppLocalizations l10n,
    AppColorExtension colors,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          l10n.onboardingTitle,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: colors.textHigh,
          ),
        ),
        const SizedBox(height: 32),
        _optionCard(
          context,
          colors,
          l10n.sankalpamDailyPractice,
          () => _choose(Sankalpam.dailyPractice),
        ),
        const SizedBox(height: 12),
        _optionCard(
          context,
          colors,
          l10n.sankalpamMeanings,
          () => _choose(Sankalpam.meanings),
        ),
        const SizedBox(height: 12),
        _optionCard(
          context,
          colors,
          l10n.sankalpamTemples,
          () => _choose(Sankalpam.temples),
        ),
        const SizedBox(height: 12),
        _optionCard(
          context,
          colors,
          l10n.sankalpamJustLooking,
          () => _choose(Sankalpam.justLooking),
        ),
      ],
    );
  }

  Widget _optionCard(
    BuildContext context,
    AppColorExtension colors,
    String label,
    VoidCallback onTap,
  ) {
    return Card(
      color: colors.container,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Text(
            label,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: colors.textHigh,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReveal(
    BuildContext context,
    AppLocalizations l10n,
    AppColorExtension colors,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Frame the corpus as heritage, never as a backlog.
        Text(
          l10n.onboardingHeritageLine,
          style: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(color: colors.textMuted, height: 1.5),
        ),
        const SizedBox(height: 24),
        if (_loadingVerse)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 24.0),
            child: Center(child: CircularProgressIndicator()),
          )
        else if (_verseSong != null)
          _buildVersePreview(context, colors),
        const Spacer(),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: _finish,
            child: Text(l10n.onboardingContinue),
          ),
        ),
      ],
    );
  }

  Widget _buildVersePreview(BuildContext context, AppColorExtension colors) {
    final song = _verseSong!;
    final count = song.words.length < song.meanings.length
        ? song.words.length
        : song.meanings.length;
    if (count == 0) return const SizedBox.shrink();

    final index = verseIndexForDate(DateTime.now(), count);

    return Card(
      color: colors.container,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              song.words[index],
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: colors.textHigh,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              song.meanings[index],
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: colors.textMuted),
            ),
          ],
        ),
      ),
    );
  }
}
