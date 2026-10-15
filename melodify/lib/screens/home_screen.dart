import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/player_provider.dart';
import '../models/song.dart';
import '../services/song_service.dart';
import '../widgets/song_tile.dart';
import 'player_screen.dart';
import 'profile_screen.dart';

// Halaman Home — tampilan utama seperti Spotify
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Song> _songs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSongs();
  }

  // Ambil semua lagu dari backend
  Future<void> _loadSongs() async {
    final songs = await SongService.getAllSongs();
    if (mounted) {
      setState(() {
        _songs = songs;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.user;

    // Sapa user berdasarkan jam
    final hour = DateTime.now().hour;
    String greeting = 'Selamat malam';
    if (hour < 12) {
      greeting = 'Selamat pagi';
    } else if (hour < 17) {
      greeting = 'Selamat siang';
    } else if (hour < 20) {
      greeting = 'Selamat sore';
    }

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadSongs,
          color: const Color(0xFF1DB954),
          child: CustomScrollView(
            slivers: [
              // App bar dengan greeting dan avatar
              SliverToBoxAdapter(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        greeting,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const ProfileScreen()),
                          );
                        },
                        child: CircleAvatar(
                          backgroundColor: const Color(0xFF1DB954),
                          radius: 18,
                          child: Text(
                            user?.name.isNotEmpty == true
                                ? user!.name[0].toUpperCase()
                                : 'M',
                            style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Grid shortcut (Recently played - simulasi)
              if (_songs.isNotEmpty)
                SliverToBoxAdapter(
                  child: _buildRecentGrid(),
                ),

              // Section "Popular Songs"
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(16, 24, 16, 12),
                  child: Text(
                    'Lagu Populer',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              // Daftar lagu
              _isLoading
                  ? const SliverToBoxAdapter(
                      child: Center(
                        child: Padding(
                          padding: EdgeInsets.all(32),
                          child: CircularProgressIndicator(
                              color: Color(0xFF1DB954)),
                        ),
                      ),
                    )
                  : SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final song = _songs[index];
                          return SongTile(
                            song: song,
                            onTap: () {
                              context
                                  .read<PlayerProvider>()
                                  .playSong(song, songList: _songs);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const PlayerScreen()),
                              );
                            },
                          );
                        },
                        childCount: _songs.length,
                      ),
                    ),

              // Space di bawah untuk mini player
              const SliverToBoxAdapter(child: SizedBox(height: 80)),
            ],
          ),
        ),
      ),
    );
  }

  // Grid "recently played" dari 6 lagu pertama
  Widget _buildRecentGrid() {
    final recentSongs = _songs.take(6).toList();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: recentSongs.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 4,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemBuilder: (context, index) {
          final song = recentSongs[index];
          return GestureDetector(
            onTap: () {
              context
                  .read<PlayerProvider>()
                  .playSong(song, songList: _songs);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PlayerScreen()),
              );
            },
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF282828),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                children: [
                  // Cover kecil
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(6),
                      bottomLeft: Radius.circular(6),
                    ),
                    child: song.coverUrl != null
                        ? Image.network(
                            song.coverUrl!,
                            width: 52,
                            height: 52,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              width: 52,
                              height: 52,
                              color: const Color(0xFF333333),
                              child: const Icon(Icons.music_note,
                                  color: Colors.grey, size: 20),
                            ),
                          )
                        : Container(
                            width: 52,
                            height: 52,
                            color: const Color(0xFF333333),
                            child: const Icon(Icons.music_note,
                                color: Colors.grey, size: 20),
                          ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      song.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
