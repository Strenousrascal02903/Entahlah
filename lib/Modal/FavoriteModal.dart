class FavoriteTrack {
  final String id;
  final String title;
  final String artist;
  final String thumbnailUrl;

  FavoriteTrack({
    required this.id,
    required this.title,
    required this.artist,
    required this.thumbnailUrl,
  });

  // Convert a FavoriteTrack into a Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'artist': artist,
      'thumbnailUrl': thumbnailUrl,
    };
  }

  // Convert a Map into a FavoriteTrack
  factory FavoriteTrack.fromMap(Map<String, dynamic> map) {
    return FavoriteTrack(
      id: map['id'],
      title: map['title'],
      artist: map['artist'],
      thumbnailUrl: map['thumbnailUrl'],
    );
  }
}
