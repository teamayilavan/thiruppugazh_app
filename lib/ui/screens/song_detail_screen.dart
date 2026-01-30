import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../data/models/song_model.dart';
import '../../data/repositories/song_repository.dart';
import '../widgets/add_to_category_dialog.dart';
import '../../../constants/app_strings.dart';

class SongDetailScreen extends StatefulWidget {
  final Song song;
  const SongDetailScreen({super.key, required this.song});

  @override
  State<SongDetailScreen> createState() => _SongDetailScreenState();
}

class _SongDetailScreenState extends State<SongDetailScreen> {
  bool _isFavorite = false;
  bool _isFavoriteLoading = false;

  @override
  void initState() {
    super.initState();
    final repo = Provider.of<SongRepository>(context, listen: false);
    _loadCategoryInfo(repo);
  }

  void _loadCategoryInfo(SongRepository repo) async {
    final categoryIds = await repo.getCategoryIdsForSong(widget.song.id);
    if (mounted) {
      setState(() {
        widget.song.categoryIds = categoryIds;
        _isFavorite = widget.song.isFavorite;
      });
    }
  }

  void _toggleFavorite() async {
    if (_isFavoriteLoading) return;

    final repo = Provider.of<SongRepository>(context, listen: false);
    final messenger = ScaffoldMessenger.of(context);
    final wasFavorite = _isFavorite || widget.song.categoryIds.contains(1);

    setState(() {
      _isFavoriteLoading = true;
    });

    try {
      await repo.toggleFavorite(widget.song.id, !wasFavorite);

      if (!mounted) return;

      setState(() {
        _isFavorite = !wasFavorite;
        _isFavoriteLoading = false;
      });

      messenger.showSnackBar(
        SnackBar(
          content: Text(
            'Song ${widget.song.title} ${wasFavorite ? 'removed from Favorites' : 'added to Favorites'}',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isFavoriteLoading = false;
      });
      messenger.showSnackBar(
        SnackBar(
          content: Text('Error updating favorite: $e'),
        ),
      );
    }
  }



  void _shareSongText() {
    final song = widget.song;

    final textToShare =
        '''
      தலைப்பு: 
      ${song.title} 
 
      திருத்தலம்:
      ${song.place}
 
      சந்தம்: 
      ${song.tune}
 
      பாடல்:
      ${song.lyrics}
      ''';

    SharePlus.instance.share(
      ShareParams(title: 'பாடல்: ${song.title}', text: textToShare),
    );
  }

  void _shareSongLink() {
    final song = widget.song;
    // Custom scheme URI that MainWrapper detects
    final deepLink = 'thiruppugazh://song/${song.id}';
    // Fallback Play Store URL (using standard ID format, replace if actual ID differs)
    final playStoreUrl = 'https://play.google.com/store/apps/details?id=com.example.thiruppugazh';

    final textToShare = 
        'Check out "${song.title}" on the Thiruppugazh App!\n\n'
        'Tap to open in app:\n$deepLink\n\n'
        'Get the app here:\n$playStoreUrl';

    SharePlus.instance.share(
      ShareParams(title: 'Check out ${song.title}', text: textToShare),
    );
  }

  void _launchYouTubeSearch() async {
    final messenger = ScaffoldMessenger.of(context);

    final songTitle = Uri.encodeComponent(widget.song.title);
    final url = Uri.parse(
      'https://www.youtube.com/results?search_query=திருப்புகழ்%20$songTitle',
    );

    if (!_isValidUrl(url, ['youtube.com', 'www.youtube.com'])) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Invalid URL')),
      );
      return;
    }

    final confirmed = await _showUrlConfirmationDialog(context, 'YouTube');
    if (confirmed == true) {
      if (!await launchUrl(url)) {
        messenger.showSnackBar(
          SnackBar(
            content: Text('Could not launch YouTube for ${widget.song.title}'),
          ),
        );
      }
    }
  }

  void _launchCustomUrl() async {
    final messenger = ScaffoldMessenger.of(context);

    final kaumaramId = widget.song.kaumaramId.padLeft(4, '0');
    final url = Uri.parse(
      'https://kaumaram.com/thiru/nnt${kaumaramId}_u.html',
    );

    if (!_isValidUrl(url, ['kaumaram.com', 'www.kaumaram.com'])) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Invalid URL')),
      );
      return;
    }

    final confirmed = await _showUrlConfirmationDialog(context, 'Kaumaram');
    if (confirmed == true) {
      if (!await launchUrl(url)) {
        messenger.showSnackBar(
          const SnackBar(content: Text('Could not launch the custom URL')),
        );
      }
    }
  }

  /// Validates URL against whitelist of trusted domains.
  bool _isValidUrl(Uri url, List<String> allowedDomains) {
    if (url.scheme != 'https') {
      return false;
    }
    
    if (!allowedDomains.contains(url.host)) {
      return false;
    }
    
    return true;
  }

  /// Shows a confirmation dialog before launching external URLs.
  Future<bool?> _showUrlConfirmationDialog(BuildContext context, String domain) {
    return showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Open External Link'),
          content: Text('You are about to visit $domain. Continue?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Open'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 32),
                Text(
                  widget.song.title,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                _buildInfoCard(context),
                const SizedBox(height: 32),
              ],
            ),
          ),
          
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('பாடல்', style: TextStyle(fontSize: 16)),
                  const SizedBox(height: 8),
                  const Divider(height: 16),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
          
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            sliver: SliverList.separated(
              itemCount: widget.song.lyricsList.length,
              itemBuilder: (context, index) {
                final paragraph = widget.song.lyricsList[index];
                if (paragraph.trim().isEmpty) return const SizedBox.shrink();
                
                return SelectableText(
                  paragraph,
                  style: const TextStyle(fontSize: 16, height: 1.2),
                );
              },
              separatorBuilder: (context, index) {
                // Calculate separator based on tuneList length to group lines into stanzas
                final tuneLength = widget.song.tuneList.length;
                
                // Avoid division by zero, default to simple list if no tune structure
                if (tuneLength == 0) return const SizedBox(height: 8);

                // Check if the current line (index+1) completes a stanza
                if ((index + 1) % tuneLength == 0) {
                  return const SizedBox(height: 32); // Paragraph break
                } else {
                  return const SizedBox(height: 4); // Line break (tightly spaced)
                }
              },
            ),
          ),
          
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 32.0),
               child: _buildMeaningsCard(
                'பொருள்',
                widget.song.words,
                widget.song.meanings,
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.description),
                          label: const Text('Share Lyrics'),
                          onPressed: _shareSongText,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.share),
                          label: const Text('Share'),
                          onPressed: _shareSongLink,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.play_circle_outline),
                    label: const Text('Search on YouTube'),
                    onPressed: _launchYouTubeSearch,
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.link),
                    label: const Text('Open Kaumaram Page'),
                    onPressed: _launchCustomUrl,
                  ),
                  const SizedBox(height: 48),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Semantics(
            button: true,
            label: _isFavorite ? 'Remove from favorites' : 'Add to favorites',
            hint: _isFavoriteLoading ? 'Loading' : 'Tap to toggle favorite status',
            child: FloatingActionButton(
              heroTag: 'fab_favorite',
              onPressed: _isFavoriteLoading ? null : _toggleFavorite,
              child: _isFavoriteLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Icon((_isFavorite || widget.song.categoryIds.contains(1)) ? Icons.favorite : Icons.favorite_border),
            ),
          ),
          const SizedBox(height: 16),
          Semantics(
            button: true,
            label: 'Add to categories',
            hint: 'Tap to add song to categories',
            child: FloatingActionButton(
              heroTag: 'fab_add_category',
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AddToCategoryDialog(
                    song: widget.song,
                    onUpdate: () {
                      setState(() {
                         _isFavorite = widget.song.categoryIds.contains(1);
                      });
                    },
                  ),
                );
              },
              child: const Icon(Icons.playlist_add),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("திருத்தலம்", style: TextStyle(fontSize: 16)),
          const SizedBox(height: 8),
          Text(
            widget.song.place,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 24),
          Text("சந்தம்", style: TextStyle(fontSize: 16)),
          Text(widget.song.tune, style: TextStyle(fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildMeaningsCard(
    String title,
    List<String> words,
    List<String> meanings,
  ) {
    // Assert that both lists have the same length.
    // This helps catch errors during development.
    assert(
      words.length == meanings.length,
      'The words and meanings lists must have the same length.',
    );

    if (words.isEmpty || meanings.isEmpty) return const SizedBox.shrink();

    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Divider(height: 16),
          const SizedBox(height: 16),
          ...List.generate(meanings.length, (index) {
            final word = index < words.length ? words[index] : '';
            final meaning = meanings[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (word.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4.0),
                      child: SelectableText(
                        word,
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                  SelectableText(
                    meaning,
                    style: const TextStyle(fontSize: 16, height: 1.5),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
