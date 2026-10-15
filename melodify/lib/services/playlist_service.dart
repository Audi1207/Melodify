import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants.dart';
import '../models/playlist.dart';
import 'auth_service.dart';

// PlaylistService menangani semua request yang berkaitan dengan playlist
class PlaylistService {
  // Helper: header dengan token
  static Future<Map<String, String>> _authHeaders() async {
    final token = await AuthService.getToken();
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }

  // Ambil semua playlist milik user yang sedang login
  static Future<List<Playlist>> getMyPlaylists() async {
    try {
      final headers = await _authHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/playlists'),
        headers: headers,
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Playlist.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // Ambil detail playlist (termasuk daftar lagu)
  static Future<Playlist?> getPlaylistDetail(int playlistId) async {
    try {
      final headers = await _authHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/playlists/$playlistId'),
        headers: headers,
      );
      if (response.statusCode == 200) {
        return Playlist.fromJson(jsonDecode(response.body));
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Buat playlist baru
  static Future<Playlist?> createPlaylist(
      String name, String description) async {
    try {
      final headers = await _authHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/playlists'),
        headers: headers,
        body: jsonEncode({'name': name, 'description': description}),
      );
      if (response.statusCode == 201) {
        return Playlist.fromJson(jsonDecode(response.body));
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Update nama dan deskripsi playlist
  static Future<bool> updatePlaylist(
      int playlistId, String name, String description) async {
    try {
      final headers = await _authHeaders();
      final response = await http.put(
        Uri.parse('$baseUrl/playlists/$playlistId'),
        headers: headers,
        body: jsonEncode({'name': name, 'description': description}),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // Hapus playlist
  static Future<bool> deletePlaylist(int playlistId) async {
    try {
      final headers = await _authHeaders();
      final response = await http.delete(
        Uri.parse('$baseUrl/playlists/$playlistId'),
        headers: headers,
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // Tambah lagu ke playlist
  static Future<bool> addSongToPlaylist(int playlistId, int songId) async {
    try {
      final headers = await _authHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/playlists/$playlistId/songs'),
        headers: headers,
        body: jsonEncode({'song_id': songId}),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // Hapus lagu dari playlist
  static Future<bool> removeSongFromPlaylist(
      int playlistId, int songId) async {
    try {
      final headers = await _authHeaders();
      final response = await http.delete(
        Uri.parse('$baseUrl/playlists/$playlistId/songs/$songId'),
        headers: headers,
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
