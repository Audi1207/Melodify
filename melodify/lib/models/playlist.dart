import 'song.dart';

// Model data untuk Playlist
class Playlist {
  final int id;
  final int userId;
  final String name;
  final String? description;
  final String? coverUrl;
  final bool isPublic;
  final List<Song> songs;

  Playlist({
    required this.id,
    required this.userId,
    required this.name,
    this.description,
    this.coverUrl,
    required this.isPublic,
    this.songs = const [],
  });

  factory Playlist.fromJson(Map<String, dynamic> json) {
    final songsList = json['songs'] as List<dynamic>?;
    return Playlist(
      id: json['id'],
      userId: json['user_id'],
      name: json['name'] ?? '',
      description: json['description'],
      coverUrl: (json['cover_url'] != null && json['cover_url'].toString().trim().isNotEmpty)
          ? Uri.encodeFull(json['cover_url'].toString().trim())
          : null,
      isPublic: json['is_public'] ?? false,
      songs: songsList != null
          ? songsList.map((s) => Song.fromJson(s)).toList()
          : [],
    );
  }
}
