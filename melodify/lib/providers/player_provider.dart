import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../models/song.dart';
import '../services/song_service.dart';

// PlayerProvider mengelola state audio player global
// Dengan ChangeNotifier, semua widget yang listen akan update otomatis
class PlayerProvider extends ChangeNotifier {
  final AudioPlayer _audioPlayer = AudioPlayer();

  Song? _currentSong;           // Lagu yang sedang diputar
  List<Song> _queue = [];       // Antrian lagu
  int _currentIndex = -1;       // Index lagu aktif di queue
  bool _isPlaying = false;      // Status play/pause
  Duration _position = Duration.zero;     // Posisi saat ini
  Duration _duration = Duration.zero;     // Durasi total lagu
  bool _isShuffle = false;      // Mode acak lagu
  bool _isRepeat = false;       // Mode repeat
  bool _isLoading = false;      // Loading saat pertama stream
  double _volume = 0.7;         // Volume audio (0.0 - 1.0)
  final Set<int> _likedSongIds = {}; // ID lagu yang disukai

  // Getter (baca saja dari luar)
  Song? get currentSong => _currentSong;
  List<Song> get queue => _queue;
  bool get isPlaying => _isPlaying;
  bool get isLoading => _isLoading;
  Duration get position => _position;
  Duration get duration => _duration;
  bool get isShuffle => _isShuffle;
  bool get isRepeat => _isRepeat;
  double get volume => _volume;

  bool isLiked(int songId) => _likedSongIds.contains(songId);

  PlayerProvider() {
    _initPlayer();
    loadLikedSongs();
  }

  void _initPlayer() {
    try {
      _audioPlayer.setVolume(_volume);
    } catch (_) {}

    // Listener untuk update posisi
    _audioPlayer.onPositionChanged.listen((pos) {
      _position = pos;
      notifyListeners();
    });

    // Listener untuk durasi lagu
    _audioPlayer.onDurationChanged.listen((dur) {
      _duration = dur;
      notifyListeners();
    });

    // Listener ketika lagu selesai → ulang jika repeat, atau lanjut next
    _audioPlayer.onPlayerComplete.listen((_) {
      if (_isRepeat && _currentSong != null) {
        seekTo(Duration.zero);
        _audioPlayer.resume();
      } else {
        next();
      }
    });

    // Listener status player
    _audioPlayer.onPlayerStateChanged.listen((state) {
      _isPlaying = state == PlayerState.playing;
      notifyListeners();
    });
  }

  // Load lagu favorit dari backend
  Future<void> loadLikedSongs() async {
    try {
      final liked = await SongService.getLikedSongs();
      _likedSongIds.clear();
      for (final s in liked) {
        _likedSongIds.add(s.id);
      }
      notifyListeners();
    } catch (_) {}
  }

  // Toggle suka lagu
  Future<bool> toggleLike(int songId) async {
    final result = await SongService.toggleLike(songId);
    if (result['success'] == true) {
      if (result['liked'] == true) {
        _likedSongIds.add(songId);
      } else {
        _likedSongIds.remove(songId);
      }
      notifyListeners();
      return result['liked'] == true;
    }
    return isLiked(songId);
  }

  // Putar lagu tertentu dan atur queue
  Future<void> playSong(Song song, {List<Song>? songList}) async {
    if (songList != null) {
      _queue = List.from(songList);
      _currentIndex = _queue.indexWhere((s) => s.id == song.id);
      if (_currentIndex == -1) {
        _queue.insert(0, song);
        _currentIndex = 0;
      }
    } else if (_queue.isEmpty) {
      _queue = [song];
      _currentIndex = 0;
    }

    _currentSong = song;
    _position = Duration.zero;
    _duration = Duration(seconds: song.duration);
    _isLoading = true;
    _isPlaying = false;
    notifyListeners();

    // Increment play count di server (non-blocking)
    SongService.incrementPlayCount(song.id);

    // Putar audio dari URL dengan proteksi error
    if (song.audioUrl != null && song.audioUrl!.isNotEmpty) {
      try {
        await _audioPlayer.stop();
        await _audioPlayer.play(UrlSource(song.audioUrl!));
      } catch (e) {
        debugPrint('Error memutar audio: $e');
      } finally {
        _isLoading = false;
        notifyListeners();
      }
    } else {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Play / Pause toggle
  Future<void> togglePlay() async {
    try {
      if (_isPlaying) {
        _isPlaying = false;
        notifyListeners();
        await _audioPlayer.pause();
      } else {
        if (_currentSong != null) {
          _isPlaying = true;
          notifyListeners();
          if (_position == Duration.zero && _currentSong!.audioUrl != null) {
            await _audioPlayer.play(UrlSource(_currentSong!.audioUrl!));
          } else {
            await _audioPlayer.resume();
          }
        }
      }
    } catch (e) {
      debugPrint('Error toggle play: $e');
    }
    notifyListeners();
  }

  // Lagu berikutnya
  Future<void> next() async {
    if (_queue.isEmpty) return;

    if (_isShuffle && _queue.length > 1) {
      final random = math.Random();
      int newIndex;
      do {
        newIndex = random.nextInt(_queue.length);
      } while (newIndex == _currentIndex);
      _currentIndex = newIndex;
    } else {
      _currentIndex = (_currentIndex + 1) % _queue.length;
    }

    await playSong(_queue[_currentIndex]);
  }

  // Lagu sebelumnya
  Future<void> previous() async {
    if (_queue.isEmpty) return;

    if (_position.inSeconds > 3) {
      // Jika sudah berjalan lebih dari 3 detik, restart lagu sekarang
      await seekTo(Duration.zero);
      return;
    }

    _currentIndex = (_currentIndex - 1 + _queue.length) % _queue.length;
    await playSong(_queue[_currentIndex]);
  }

  // Seek ke posisi tertentu
  Future<void> seekTo(Duration position) async {
    try {
      _position = position;
      notifyListeners();
      await _audioPlayer.seek(position);
    } catch (e) {
      debugPrint('Error seek: $e');
    }
  }

  // Toggle Shuffle
  void toggleShuffle() {
    _isShuffle = !_isShuffle;
    notifyListeners();
  }

  // Toggle Repeat
  void toggleRepeat() {
    _isRepeat = !_isRepeat;
    notifyListeners();
  }

  // Atur Volume
  void setVolume(double val) {
    _volume = val.clamp(0.0, 1.0);
    try {
      _audioPlayer.setVolume(_volume);
    } catch (_) {}
    notifyListeners();
  }

  // Tambah lagu ke antrian
  void addToQueue(Song song) {
    if (!_queue.any((s) => s.id == song.id)) {
      _queue.add(song);
      notifyListeners();
    }
  }

  // Hapus lagu dari antrian
  void removeFromQueue(int index) {
    if (index < _queue.length) {
      _queue.removeAt(index);
      notifyListeners();
    }
  }

  // Geser dan atur ulang urutan antrean lagu secara mulus
  void reorderQueue(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final Song item = _queue.removeAt(oldIndex);
    _queue.insert(newIndex, item);
    if (_currentSong != null) {
      _currentIndex = _queue.indexWhere((s) => s.id == _currentSong!.id);
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
}
