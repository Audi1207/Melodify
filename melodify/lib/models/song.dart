// Model data untuk Song (Lagu)
class Song {
  final int id;
  final String title;
  final String artistName;
  final int artistId;
  final String? albumTitle;
  final int? albumId;
  final int duration; // dalam detik
  final String? audioUrl;
  final String? coverUrl;
  final int playCount;

  Song({
    required this.id,
    required this.title,
    required this.artistName,
    required this.artistId,
    this.albumTitle,
    this.albumId,
    required this.duration,
    this.audioUrl,
    this.coverUrl,
    required this.playCount,
  });

  // Helper untuk membersihkan dan meng-encode URL (misal ada spasi atau karakter khusus)
  static String? _sanitizeUrl(dynamic url) {
    if (url == null) return null;
    final str = url.toString().trim();
    if (str.isEmpty) return null;
    return Uri.encodeFull(str);
  }

  // Konversi dari JSON ke objek Song
  factory Song.fromJson(Map<String, dynamic> json) {
    return Song(
      id: json['id'],
      title: json['title'] ?? '',
      artistName: json['artist_name'] ?? 'Unknown Artist',
      artistId: json['artist_id'] ?? 0,
      albumTitle: json['album_title'],
      albumId: json['album_id'],
      duration: json['duration'] ?? 0,
      audioUrl: _sanitizeUrl(json['audio_url']),
      coverUrl: _sanitizeUrl(json['cover_url']),
      playCount: json['play_count'] ?? 0,
    );
  }

  // Format durasi dari detik ke mm:ss
  String get formattedDuration {
    final minutes = duration ~/ 60;
    final seconds = duration % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}
