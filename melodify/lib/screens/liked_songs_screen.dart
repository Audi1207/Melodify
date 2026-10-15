import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/song.dart';
import '../providers/player_provider.dart';
import '../services/song_service.dart';
import '../widgets/song_tile.dart';
import '../widgets/mini_player.dart';

// Halaman Playlist "Lagu yang Disukai" (Liked Songs) khas Spotify
class LikedSongsScreen extends StatefulWidget {
  const LikedSongsScreen({super.key});

  @override
  State<LikedSongsScreen> createState() => _LikedSongsScreenState();
}

class _LikedSongsScreenState extends State<LikedSongsScreen> {
  List<Song> _songs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLikedSongs();
  }

  Future<void> _loadLikedSongs() async {
    final songs = await SongService.getLikedSongs();
    if (mounted) {
      setState(() {
        _songs = songs;
        _isLoading = false;
      });
      // Pastikan provider sinkron
      context.read<PlayerProvider>().loadLikedSongs();
    }
  }

  @override
  Widget build(BuildContext context) {
    final player = context.watch<PlayerProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              // Header dengan gradasi ungu khas Spotify Liked Songs
              SliverAppBar(
                expandedHeight: 240,
                pinned: true,
                backgroundColor: const Color(0xFF450af5),
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  title: const Text(
                    'Lagu yang Disukai',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  background: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color(0xFF450af5),
                          Color(0xFF1e0866),
                          Color(0xFF121212),
                        ],
                      ),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 30),
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF450af5), Color(0xFF8e8ee5)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.4),
                                  blurRadius: 15,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: const Icon(Icons.favorite,
                                color: Colors.white, size: 44),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            '${_songs.length} lagu favorit kamu',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.8),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Bar tombol Play Semua
              SliverToBoxAdapter(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${_songs.length} Lagu',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (_songs.isNotEmpty)
                        GestureDetector(
                          onTap: () {
                            player.playSong(_songs.first, songList: _songs);
                          },
                          child: Container(
                            width: 50,
                            height: 50,
                            decoration: const BoxDecoration(
                              color: Color(0xFF1DB954),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.play_arrow,
                              color: Colors.black,
                              size: 32,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              // Daftar Lagu Favorit
              if (_isLoading)
                const SliverFillRemaining(
                  child: Center(
                    child:
                        CircularProgressIndicator(color: Color(0xFF1DB954)),
                  ),
                )
              else if (_songs.isEmpty)
                SliverFillRemaining(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.favorite_border,
                              color: Colors.grey, size: 64),
                          const SizedBox(height: 16),
                          const Text(
                            'Belum ada lagu yang disukai',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Ketuk ikon hati pada lagu apa saja saat memutar lagu untuk menambahkannya ke sini.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: EdgeInsets.only(
                    bottom: player.currentSong != null ? 80 : 20,
                  ),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final song = _songs[index];
                        return SongTile(
                          song: song,
                          onTap: () {
                            player.playSong(song, songList: _songs);
                          },
                          showMoreButton: true,
                          onMorePressed: () async {
                            final liked = await player.toggleLike(song.id);
                            if (!liked && mounted) {
                              setState(() {
                                _songs.removeAt(index);
                              });
                            }
                          },
                        );
                      },
                      childCount: _songs.length,
                    ),
                  ),
                ),
            ],
          ),

          // Mini Player di bagian bawah jika ada lagu yang sedang diputar
          const Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: MiniPlayer(),
          ),
        ],
      ),
    );
  }
}
