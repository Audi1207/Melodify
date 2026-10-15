import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/player_provider.dart';
import '../models/song.dart';
import '../services/song_service.dart';
import '../widgets/song_tile.dart';
import 'player_screen.dart';

// Halaman Search — mirip Spotify search
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();
  List<Song> _results = [];
  bool _isSearching = false;
  bool _hasSearched = false;

  // Cari lagu saat keyword berubah
  Future<void> _search(String keyword) async {
    if (keyword.trim().isEmpty) {
      setState(() {
        _results = [];
        _hasSearched = false;
      });
      return;
    }

    setState(() => _isSearching = true);

    final songs = await SongService.searchSongs(keyword.trim());

    if (mounted) {
      setState(() {
        _results = songs;
        _isSearching = false;
        _hasSearched = true;
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                'Search',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),

            // Search bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: _searchController,
                onChanged: _search,
                decoration: InputDecoration(
                  hintText: 'Artis, lagu, atau album',
                  hintStyle: const TextStyle(color: Colors.grey),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  prefixIcon:
                      const Icon(Icons.search, color: Colors.black54),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, color: Colors.black54),
                          onPressed: () {
                            _searchController.clear();
                            _search('');
                          },
                        )
                      : null,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                ),
                style: const TextStyle(color: Colors.black, fontSize: 15),
              ),
            ),
            const SizedBox(height: 16),

            // Hasil pencarian
            Expanded(
              child: _isSearching
                  ? const Center(
                      child:
                          CircularProgressIndicator(color: Color(0xFF1DB954)),
                    )
                  : _hasSearched && _results.isEmpty
                      ? const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.search_off,
                                  color: Colors.grey, size: 60),
                              SizedBox(height: 16),
                              Text(
                                'Tidak ada hasil ditemukan',
                                style:
                                    TextStyle(color: Colors.grey, fontSize: 16),
                              ),
                            ],
                          ),
                        )
                      : !_hasSearched
                          ? _buildBrowseCategories()
                          : ListView.builder(
                              itemCount: _results.length,
                              itemBuilder: (context, index) {
                                final song = _results[index];
                                return SongTile(
                                  song: song,
                                  onTap: () {
                                    context
                                        .read<PlayerProvider>()
                                        .playSong(song, songList: _results);
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (_) => const PlayerScreen()),
                                    );
                                  },
                                );
                              },
                            ),
            ),
          ],
        ),
      ),
    );
  }

  // Tampilkan kategori genre (simulasi, tidak ada data nyata di backend)
  Widget _buildBrowseCategories() {
    final categories = [
      {'name': 'Pop', 'color': 0xFF1DB954},
      {'name': 'Rock', 'color': 0xFFE91429},
      {'name': 'Hip-Hop', 'color': 0xFF8D67AB},
      {'name': 'Jazz', 'color': 0xFF006450},
      {'name': 'R&B', 'color': 0xFFE8115B},
      {'name': 'Electronic', 'color': 0xFF0D73EC},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: Text(
            'Jelajahi semua',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: categories.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.8,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemBuilder: (context, index) {
              final cat = categories[index];
              return Container(
                decoration: BoxDecoration(
                  color: Color(cat['color'] as int),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Text(
                    cat['name'] as String,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
