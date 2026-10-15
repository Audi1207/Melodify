import 'package:flutter/material.dart';
import '../models/song.dart';

// Widget tile untuk menampilkan satu baris lagu
// Digunakan di HomeScreen, SearchScreen, PlaylistDetailScreen
class SongTile extends StatelessWidget {
  final Song song;
  final VoidCallback onTap;
  final bool showMoreButton;
  final VoidCallback? onMorePressed;

  const SongTile({
    super.key,
    required this.song,
    required this.onTap,
    this.showMoreButton = false,
    this.onMorePressed,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: song.coverUrl != null
            ? Image.network(
                song.coverUrl!,
                width: 52,
                height: 52,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _defaultCover(),
              )
            : _defaultCover(),
      ),
      title: Text(
        song.title,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w500,
          fontSize: 14,
        ),
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        song.artistName,
        style: const TextStyle(color: Colors.grey, fontSize: 12),
        overflow: TextOverflow.ellipsis,
      ),
      trailing: showMoreButton
          ? IconButton(
              icon: const Icon(Icons.more_vert, color: Colors.grey),
              onPressed: onMorePressed,
            )
          : Text(
              song.formattedDuration,
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
      onTap: onTap,
    );
  }

  // Cover default jika gambar gagal dimuat
  Widget _defaultCover() {
    return Container(
      width: 52,
      height: 52,
      color: const Color(0xFF282828),
      child: const Icon(Icons.music_note, color: Colors.grey, size: 24),
    );
  }
}
