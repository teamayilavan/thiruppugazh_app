import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../constants/app_constants.dart';
import '../../data/models/song_model.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/lyrics_font_size_provider.dart';
import '../../providers/lyrics_language_provider.dart';
import '../../providers/reading_state_provider.dart';
import '../../services/screen_awake_service.dart';
import '../../utils/verses.dart';

/// A distraction-free view for chanting: one verse at a time in large text,
/// the screen kept awake, moved through by hand (swipe or buttons) or
/// advanced automatically at a pace the user sets.
class ChantingScreen extends StatefulWidget {
  const ChantingScreen({super.key, required this.song, this.initialIndex = 0});

  final Song song;

  /// Which verse to start on (used by "Continue").
  final int initialIndex;

  /// Seconds per verse the user can choose from in auto mode.
  static const List<int> paceOptions = [10, 15, 20, 30, 45, 60];
  static const int defaultPaceSeconds = 20;

  @override
  State<ChantingScreen> createState() => _ChantingScreenState();
}

class _ChantingScreenState extends State<ChantingScreen>
    with WidgetsBindingObserver {
  late final PageController _pageController;
  late int _index;
  Timer? _timer;

  bool _auto = false;
  bool _playing = false;
  bool _finished = false;
  bool _showTune = true;
  int _paceSeconds = ChantingScreen.defaultPaceSeconds;

  /// Verse count for the language currently shown; refreshed every build so
  /// timers and buttons never use a stale length.
  int _verseCount = 0;

  /// Lyric lines are drawn this much larger than in the normal reader.
  static const double _chantScale = 1.3;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _index = widget.initialIndex < 0 ? 0 : widget.initialIndex;
    _pageController = PageController(initialPage: _index);
    ScreenAwakeService.setKeepAwake(true);
    _loadPrefs();
    WidgetsBinding.instance.addPostFrameCallback((_) => _recordPosition());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    _pageController.dispose();
    ScreenAwakeService.setKeepAwake(false);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Don't advance verses while the app is out of sight.
    if (state == AppLifecycleState.paused && _playing) _setPlaying(false);
  }

  Future<void> _loadPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (!mounted) return;
      final pace = prefs.getInt(AppConstants.chantPaceSecondsPrefsKey);
      setState(() {
        _auto = prefs.getBool(AppConstants.chantAutoPrefsKey) ?? false;
        _showTune = prefs.getBool(AppConstants.chantShowTunePrefsKey) ?? true;
        if (pace != null && ChantingScreen.paceOptions.contains(pace)) {
          _paceSeconds = pace;
        }
      });
    } catch (_) {
      // Preferences are a convenience; defaults are fine.
    }
  }

  Future<void> _savePref(String key, Object value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (value is bool) {
        await prefs.setBool(key, value);
      } else if (value is int) {
        await prefs.setInt(key, value);
      }
    } catch (_) {}
  }

  void _recordPosition() {
    if (!mounted) return;
    final state = context.read<ReadingStateProvider>();
    final songId = widget.song.id;
    if (_verseCount > 0 && _index >= _verseCount - 1) {
      // Reached the last verse: the song is done, so don't offer to resume
      // mid-song next time.
      state.recordOpened(songId);
      state.clearChantPosition(songId);
    } else {
      state.recordChantPosition(songId, _index);
    }
  }

  void _scheduleAdvance() {
    _timer?.cancel();
    if (!_auto || !_playing) return;
    _timer = Timer(Duration(seconds: _paceSeconds), _advance);
  }

  void _advance() {
    if (!mounted) return;
    if (_index >= _verseCount - 1) {
      setState(() {
        _playing = false;
        _finished = true;
      });
      return;
    }
    _goTo(_index + 1);
  }

  void _goTo(int index) {
    if (index < 0 || index >= _verseCount) return;
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
    );
  }

  void _onPageChanged(int index) {
    setState(() {
      _index = index;
      _finished = false;
    });
    _recordPosition();
    // Any move, by hand or by timer, restarts the countdown.
    _scheduleAdvance();
  }

  void _setPlaying(bool playing) {
    setState(() {
      _playing = playing;
      if (playing) _finished = false;
    });
    _scheduleAdvance();
  }

  void _setAuto(bool auto) {
    setState(() => _auto = auto);
    _savePref(AppConstants.chantAutoPrefsKey, auto);
    // Choosing Auto means "go": start counting straight away.
    _setPlaying(auto);
  }

  void _setPace(int seconds) {
    setState(() => _paceSeconds = seconds);
    _savePref(AppConstants.chantPaceSecondsPrefsKey, seconds);
    _scheduleAdvance();
  }

  void _toggleTune() {
    setState(() => _showTune = !_showTune);
    _savePref(AppConstants.chantShowTunePrefsKey, _showTune);
  }

  void _startAgain() {
    setState(() => _finished = false);
    _pageController.jumpToPage(0);
    _onPageChanged(0);
    if (_auto) _setPlaying(true);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final fontProvider = context.watch<LyricsFontSizeProvider>();
    final useEnglish =
        context.watch<LyricsLanguageProvider>().lyricsLanguage ==
            LyricsLanguage.english &&
        widget.song.hasEnglishContent;

    final song = widget.song;
    final title = useEnglish ? (song.englishTitle ?? song.title) : song.title;
    final lines = useEnglish ? song.englishLyricsList : song.lyricsList;
    final tuneLines = useEnglish ? song.englishTuneList : song.tuneList;
    final verses = splitIntoVerses(lines, tuneLines.length);
    _verseCount = verses.length;
    if (verses.isNotEmpty && _index >= verses.length) {
      // A saved position past the end (the song data changed, or the other
      // language has fewer verses): land on the last verse instead.
      _index = verses.length - 1;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _pageController.hasClients) {
          _pageController.jumpToPage(_index);
        }
      });
    }

    final fontSize = fontProvider.fontSize * _chantScale;
    final atLast = _index >= _verseCount - 1;

    return Scaffold(
      appBar: AppBar(
        title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
        actions: [
          if (tuneLines.isNotEmpty)
            IconButton(
              tooltip: l10n.chantShowTune,
              isSelected: _showTune,
              icon: const Icon(Icons.music_note_outlined),
              selectedIcon: const Icon(Icons.music_note),
              onPressed: _toggleTune,
            ),
          IconButton(
            tooltip: l10n.decreaseLyricsFontSize,
            icon: const Icon(Icons.text_decrease),
            onPressed: fontProvider.canDecrease ? fontProvider.decrease : null,
          ),
          IconButton(
            tooltip: l10n.increaseLyricsFontSize,
            icon: const Icon(Icons.text_increase),
            onPressed: fontProvider.canIncrease ? fontProvider.increase : null,
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(3),
          child: LinearProgressIndicator(
            value: _verseCount == 0 ? 0 : (_index + 1) / _verseCount,
            minHeight: 3,
          ),
        ),
      ),
      body: verses.isEmpty
          ? Center(child: Text(l10n.noResultsFound))
          : Column(
              children: [
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: verses.length,
                    onPageChanged: _onPageChanged,
                    itemBuilder: (context, i) => _VersePage(
                      lines: verses[i],
                      tuneLines: _showTune ? tuneLines : const [],
                      fontSize: fontSize,
                    ),
                  ),
                ),
                _buildControls(l10n, theme, atLast),
              ],
            ),
    );
  }

  Widget _buildControls(AppLocalizations l10n, ThemeData theme, bool atLast) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SegmentedButton<bool>(
              showSelectedIcon: false,
              segments: [
                ButtonSegment(value: false, label: Text(l10n.chantManual)),
                ButtonSegment(value: true, label: Text(l10n.chantAuto)),
              ],
              selected: {_auto},
              onSelectionChanged: (s) => _setAuto(s.first),
            ),
            if (_auto) ...[
              const SizedBox(height: 8),
              Text(l10n.chantPace, style: theme.textTheme.labelMedium),
              const SizedBox(height: 4),
              Wrap(
                spacing: 8,
                children: [
                  for (final seconds in ChantingScreen.paceOptions)
                    ChoiceChip(
                      label: Text(l10n.chantSeconds(seconds)),
                      selected: _paceSeconds == seconds,
                      onSelected: (_) => _setPace(seconds),
                    ),
                ],
              ),
            ],
            const SizedBox(height: 8),
            Row(
              children: [
                IconButton.filledTonal(
                  tooltip: l10n.chantPrevious,
                  iconSize: 32,
                  icon: const Icon(Icons.chevron_left),
                  onPressed: _index > 0 ? () => _goTo(_index - 1) : null,
                ),
                Expanded(child: _buildCenter(l10n, theme)),
                IconButton.filledTonal(
                  tooltip: l10n.chantNext,
                  iconSize: 32,
                  icon: const Icon(Icons.chevron_right),
                  onPressed: atLast ? null : () => _goTo(_index + 1),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCenter(AppLocalizations l10n, ThemeData theme) {
    if (_finished) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(l10n.chantFinished, style: theme.textTheme.titleMedium),
          TextButton.icon(
            onPressed: _startAgain,
            icon: const Icon(Icons.replay),
            label: Text(l10n.chantStartAgain),
          ),
        ],
      );
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          l10n.chantProgress(_index + 1, _verseCount),
          style: theme.textTheme.titleMedium,
        ),
        if (_auto)
          IconButton(
            tooltip: _playing ? l10n.chantPause : l10n.chantPlay,
            iconSize: 40,
            icon: Icon(
              _playing ? Icons.pause_circle_filled : Icons.play_circle_filled,
            ),
            onPressed: () => _setPlaying(!_playing),
          ),
      ],
    );
  }
}

class _VersePage extends StatelessWidget {
  const _VersePage({
    required this.lines,
    required this.tuneLines,
    required this.fontSize,
  });

  final List<String> lines;
  final List<String> tuneLines;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final tune in tuneLines)
              Text(
                tune,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontSize: fontSize * 0.6,
                  height: 1.5,
                ),
              ),
            if (tuneLines.isNotEmpty) const SizedBox(height: 20),
            for (final line in lines)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Text(
                  line,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontSize: fontSize,
                    height: 1.6,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
