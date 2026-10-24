/// A web link a user has attached to a song (a video, a discourse, a post).
class SongLink {
  final int? id;
  final int songId;
  final String url;
  final String? title;
  final DateTime createdAt;

  SongLink({
    this.id,
    required this.songId,
    required this.url,
    this.title,
    required this.createdAt,
  });

  /// What to show in a list: the user's label, else the domain, else the URL.
  String get displayTitle {
    final label = title?.trim();
    if (label != null && label.isNotEmpty) return label;
    final host = Uri.tryParse(url)?.host ?? '';
    return host.isNotEmpty ? host : url;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'song_id': songId,
      'url': url,
      'title': title,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory SongLink.fromMap(Map<String, dynamic> map) {
    return SongLink(
      id: map['id'],
      songId: map['song_id'],
      url: map['url'],
      title: map['title'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }
}
