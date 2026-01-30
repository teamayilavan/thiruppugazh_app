class Category {
  final int? id;
  final String name;
  
  /// The number of songs associated with this category.
  /// This value is calculated in a database query, not stored in the table.
  final int songCount;

  Category({
    this.id,
    required this.name,
    this.songCount = 0,
  });

  /// Converts a Category object into a Map for database insertion.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
    };
  }

  /// Creates a Category object from a Map, typically from a database query.
  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'],
      name: map['name'] ?? 'Unnamed',
      // Reads the calculated song count from the query result.
      songCount: map['song_count'] ?? 0,
    );
  }
}