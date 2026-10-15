import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/player_provider.dart';
import '../screens/player_screen.dart';

// MiniPlayer muncul di bagian bawah layar ketika ada lagu yang diputar
// Mirip dengan mini player di Spotify
class MiniPlayer extends StatelessWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    final player = context.watch<PlayerProvider>();
    final song = player.currentSong;

    // Jika tidak ada lagu yang diputar, sembunyikan widget ini
    if (song == null) return const SizedBox.shrink();

    return GestureDetector(
      onTap: () {
        // Navigasi ke halaman player penuh
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const PlayerScreen()),
        );
      },
      child: Container(
        height: 64,
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFF282828),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const SizedBox(width: 8),

            // Cover lagu kecil
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: song.coverUrl != null
                  ? Image.network(
                      song.coverUrl!,
                      width: 48,
                      height: 48,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _defaultCover(),
                    )
                  : _defaultCover(),
            ),
            const SizedBox(width: 12),

            // Info lagu
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    song.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    song.artistName,
                    style: const TextStyle(color: Colors.grey, fontSize: 11),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // Tombol previous
            IconButton(
              icon: const Icon(Icons.skip_previous, color: Colors.white),
              onPressed: () => player.previous(),
            ),

            // Tombol Play / Pause
            IconButton(
              icon: player.isLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Icon(
                      player.isPlaying ? Icons.pause : Icons.play_arrow,
                      color: Colors.white,
                      size: 28,
                    ),
              onPressed: () => player.togglePlay(),
            ),

            // Tombol next
            IconButton(
              icon: const Icon(Icons.skip_next, color: Colors.white),
              onPressed: () => player.next(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _defaultCover() {
    return Container(
      width: 48,
      height: 48,
      color: const Color(0xFF333333),
      child: const Icon(Icons.music_note, color: Colors.grey, size: 22),
    );
  }
}
