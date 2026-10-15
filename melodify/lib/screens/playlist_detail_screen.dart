import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/player_provider.dart';
import '../models/playlist.dart';
import '../services/playlist_service.dart';
import '../services/song_service.dart';
import '../widgets/song_tile.dart';
import 'player_screen.dart';

// Halaman detail playlist — menampilkan lagu-lagu dalam playlist
class PlaylistDetailScreen extends StatefulWidget {
  final int playlistId;

  const PlaylistDetailScreen({super.key, required this.playlistId});

  @override
  State<PlaylistDetailScreen> createState() => _PlaylistDetailScreenState();
}

class _PlaylistDetailScreenState extends State<PlaylistDetailScreen> {
  Playlist? _playlist;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPlaylist();
  }

  Future<void> _loadPlaylist() async {
    final playlist = await PlaylistService.getPlaylistDetail(widget.playlistId);
    if (mounted) {
      setState(() {
        _playlist = playlist;
        _isLoading = false;
      });
    }
  }

  // Dialog untuk tambah lagu ke playlist
  Future<void> _showAddSongDialog() async {
    final allSongs = await SongService.getAllSongs();
    // Filter lagu yang belum ada di playlist
    final existingIds =
        _playlist?.songs.map((s) => s.id).toSet() ?? <int>{};
    final availableSongs =
        allSongs.where((s) => !existingIds.contains(s.id)).toList();

    if (!mounted) return;

    await showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF282828),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Tambah lagu ke playlist',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: availableSongs.isEmpty
                ? const Center(
                    child: Text('Semua lagu sudah ada di playlist',
                        style: TextStyle(color: Colors.grey)),
                  )
                : ListView.builder(
                    itemCount: availableSongs.length,
                    itemBuilder: (_, index) {
                      final song = availableSongs[index];
                      return ListTile(
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: song.coverUrl != null
                              ? Image.network(song.coverUrl!,
                                  width: 44,
                                  height: 44,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                    width: 44,
                                    height: 44,
                                    color: const Color(0xFF333333),
                                    child: const Icon(Icons.music_note,
                                        color: Colors.grey),
                                  ))
                              : Container(
                                  width: 44,
                                  height: 44,
                                  color: const Color(0xFF333333),
                                  child: const Icon(Icons.music_note,
                                      color: Colors.grey),
                                ),
                        ),
                        title: Text(song.title,
                            style: const TextStyle(color: Colors.white)),
                        subtitle: Text(song.artistName,
                            style: const TextStyle(color: Colors.grey)),
                        onTap: () async {
                          final ok = await PlaylistService.addSongToPlaylist(
                            widget.playlistId,
                            song.id,
                          );
                          if (ok && mounted) {
                            Navigator.pop(ctx);
                            _loadPlaylist();
                          }
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF1DB954)))
          : _playlist == null
              ? const Center(
                  child: Text('Playlist tidak ditemukan',
                      style: TextStyle(color: Colors.white)))
              : CustomScrollView(
                  slivers: [
                    // Header dengan gradient
                    SliverAppBar(
                      expandedHeight: 240,
                      backgroundColor: const Color(0xFF1a1a2e),
                      flexibleSpace: FlexibleSpaceBar(
                        background: Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Color(0xFF1DB954),
                                Color(0xFF121212),
                              ],
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const SizedBox(height: 60),
                              Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF282828),
                                  borderRadius: BorderRadius.circular(8),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.5),
                                      blurRadius: 20,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: const Icon(Icons.queue_music,
                                    color: Color(0xFF1DB954), size: 60),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                _playlist!.name,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Info dan tombol play
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (_playlist!.description?.isNotEmpty == true)
                              Text(
                                _playlist!.description!,
                                style: const TextStyle(
                                    color: Colors.grey, fontSize: 13),
                              ),
                            const SizedBox(height: 12),
                            Text(
                              '${_playlist!.songs.length} lagu',
                              style: const TextStyle(
                                  color: Colors.grey, fontSize: 13),
                            ),
                            const SizedBox(height: 16),

                            // Tombol Play dan tambah lagu
                            Row(
                              children: [
                                // Tombol Play Semua
                                if (_playlist!.songs.isNotEmpty)
                                  GestureDetector(
                                    onTap: () {
                                      context
                                          .read<PlayerProvider>()
                                          .playSong(
                                            _playlist!.songs.first,
                                            songList: _playlist!.songs,
                                          );
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (_) =>
                                                const PlayerScreen()),
                                      );
                                    },
                                    child: Container(
                                      width: 56,
                                      height: 56,
                                      decoration: const BoxDecoration(
                                        color: Color(0xFF1DB954),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(Icons.play_arrow,
                                          color: Colors.black, size: 32),
                                    ),
                                  ),
                                const SizedBox(width: 16),
                                // Tombol tambah lagu
                                IconButton(
                                  onPressed: _showAddSongDialog,
                                  icon: const Icon(Icons.add_circle_outline,
                                      color: Color(0xFF1DB954), size: 32),
                                  tooltip: 'Tambah lagu',
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Daftar lagu di playlist
                    _playlist!.songs.isEmpty
                        ? const SliverToBoxAdapter(
                            child: Padding(
                              padding: EdgeInsets.all(32),
                              child: Center(
                                child: Text(
                                  'Belum ada lagu di playlist ini.\nTekan + untuk menambahkan lagu.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: Colors.grey, fontSize: 14),
                                ),
                              ),
                            ),
                          )
                        : SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                final song = _playlist!.songs[index];
                                return SongTile(
                                  song: song,
                                  showMoreButton: true,
                                  onMorePressed: () async {
                                    final confirm = await showDialog<bool>(
                                      context: context,
                                      builder: (ctx) => AlertDialog(
                                        backgroundColor:
                                            const Color(0xFF282828),
                                        title: const Text('Hapus dari playlist',
                                            style: TextStyle(
                                                color: Colors.white)),
                                        content: Text(
                                          'Hapus "${song.title}" dari playlist ini?',
                                          style: const TextStyle(
                                              color: Colors.grey),
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(ctx, false),
                                            child: const Text('Batal',
                                                style: TextStyle(
                                                    color: Colors.grey)),
                                          ),
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(ctx, true),
                                            child: const Text('Hapus',
                                                style: TextStyle(
                                                    color: Colors.red)),
                                          ),
                                        ],
                                      ),
                                    );

                                    if (confirm == true) {
                                      await PlaylistService
                                          .removeSongFromPlaylist(
                                        widget.playlistId,
                                        song.id,
                                      );
                                      _loadPlaylist();
                                    }
                                  },
                                  onTap: () {
                                    context
                                        .read<PlayerProvider>()
                                        .playSong(song,
                                            songList: _playlist!.songs);
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (_) => const PlayerScreen()),
                                    );
                                  },
                                );
                              },
                              childCount: _playlist!.songs.length,
                            ),
                          ),

                    const SliverToBoxAdapter(child: SizedBox(height: 80)),
                  ],
                ),
    );
  }
}
