import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants.dart';
import '../models/song.dart';
import 'auth_service.dart';

// SongService menangani semua request yang berkaitan dengan lagu
class SongService {
  // Ambil semua lagu (tidak perlu login)
  static Future<List<Song>> getAllSongs() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/songs'));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Song.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // Cari lagu berdasarkan keyword
  static Future<List<Song>> searchSongs(String keyword) async {
    try {
      final response =
          await http.get(Uri.parse('$baseUrl/songs/search?q=$keyword'));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Song.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // Increment play count saat lagu diputar
  static Future<void> incrementPlayCount(int songId) async {
    try {
      await http.post(Uri.parse('$baseUrl/songs/$songId/play'));
    } catch (_) {}
  }

  // Like / unlike sebuah lagu (butuh token)
  static Future<Map<String, dynamic>> toggleLike(int songId) async {
    try {
      final token = await AuthService.getToken();
      final response = await http.post(
        Uri.parse('$baseUrl/songs/$songId/like'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      final data = jsonDecode(response.body);
      return {'success': true, 'liked': data['liked']};
    } catch (e) {
      return {'success': false};
    }
  }

  // Ambil semua lagu yang di-like user
  static Future<List<Song>> getLikedSongs() async {
    try {
      final token = await AuthService.getToken();
      final response = await http.get(
        Uri.parse('$baseUrl/songs/liked/all'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Song.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }
}
