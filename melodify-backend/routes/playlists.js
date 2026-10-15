const express = require('express');
const pool = require('../db');
const authMiddleware = require('../middleware/auth');

const router = express.Router();

// =====================
// GET /api/playlists  (protected)
// Ambil semua playlist milik user yang login
// =====================
router.get('/', authMiddleware, async (req, res) => {
  const userId = req.user.id;
  try {
    const result = await pool.query(
      'SELECT * FROM playlists WHERE user_id = $1 ORDER BY created_at DESC',
      [userId]
    );
    res.json(result.rows);
  } catch (err) {
    console.error('Error get playlists:', err.message);
    res.status(500).json({ message: 'Server error' });
  }
});

// =====================
// POST /api/playlists  (protected)
// Buat playlist baru
// =====================
router.post('/', authMiddleware, async (req, res) => {
  const userId = req.user.id;
  const { name, description } = req.body;

  if (!name) {
    return res.status(400).json({ message: 'Nama playlist wajib diisi' });
  }

  try {
    const result = await pool.query(
      'INSERT INTO playlists (user_id, name, description) VALUES ($1, $2, $3) RETURNING *',
      [userId, name, description || '']
    );
    res.status(201).json(result.rows[0]);
  } catch (err) {
    console.error('Error create playlist:', err.message);
    res.status(500).json({ message: 'Server error' });
  }
});

// =====================
// GET /api/playlists/:id  (protected)
// Detail playlist + daftar lagu di dalamnya
// =====================
router.get('/:id', authMiddleware, async (req, res) => {
  const userId = req.user.id;
  const playlistId = req.params.id;

  try {
    // Ambil info playlist
    const playlistResult = await pool.query(
      'SELECT * FROM playlists WHERE id = $1 AND user_id = $2',
      [playlistId, userId]
    );

    if (playlistResult.rows.length === 0) {
      return res.status(404).json({ message: 'Playlist tidak ditemukan' });
    }

    const playlist = playlistResult.rows[0];

    // Ambil lagu-lagu di playlist
    const songsResult = await pool.query(`
      SELECT s.id, s.title, s.duration, s.audio_url, s.cover_url,
             a.name AS artist_name, a.id AS artist_id,
             ps.added_at
      FROM playlist_songs ps
      JOIN songs s ON ps.song_id = s.id
      LEFT JOIN artists a ON s.artist_id = a.id
      WHERE ps.playlist_id = $1
      ORDER BY ps.added_at ASC
    `, [playlistId]);

    const host = req.get('host');
    const protocol = req.protocol;
    playlist.songs = songsResult.rows.map((song) => ({
      ...song,
      audio_url: `${protocol}://${host}/api/songs/${song.id}/stream`,
    }));
    res.json(playlist);
  } catch (err) {
    console.error('Error get playlist detail:', err.message);
    res.status(500).json({ message: 'Server error' });
  }
});

// =====================
// PUT /api/playlists/:id  (protected)
// Update nama / deskripsi playlist
// =====================
router.put('/:id', authMiddleware, async (req, res) => {
  const userId = req.user.id;
  const { name, description } = req.body;

  try {
    const result = await pool.query(
      'UPDATE playlists SET name = $1, description = $2 WHERE id = $3 AND user_id = $4 RETURNING *',
      [name, description, req.params.id, userId]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ message: 'Playlist tidak ditemukan' });
    }

    res.json(result.rows[0]);
  } catch (err) {
    console.error('Error update playlist:', err.message);
    res.status(500).json({ message: 'Server error' });
  }
});

// =====================
// DELETE /api/playlists/:id  (protected)
// Hapus playlist
// =====================
router.delete('/:id', authMiddleware, async (req, res) => {
  const userId = req.user.id;

  try {
    const result = await pool.query(
      'DELETE FROM playlists WHERE id = $1 AND user_id = $2 RETURNING id',
      [req.params.id, userId]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ message: 'Playlist tidak ditemukan' });
    }

    res.json({ message: 'Playlist berhasil dihapus' });
  } catch (err) {
    console.error('Error delete playlist:', err.message);
    res.status(500).json({ message: 'Server error' });
  }
});

// =====================
// POST /api/playlists/:id/songs  (protected)
// Tambah lagu ke playlist
// =====================
router.post('/:id/songs', authMiddleware, async (req, res) => {
  const userId = req.user.id;
  const playlistId = req.params.id;
  const { song_id } = req.body;

  try {
    // Pastikan playlist milik user
    const playlist = await pool.query(
      'SELECT id FROM playlists WHERE id = $1 AND user_id = $2',
      [playlistId, userId]
    );
    if (playlist.rows.length === 0) {
      return res.status(404).json({ message: 'Playlist tidak ditemukan' });
    }

    await pool.query(
      'INSERT INTO playlist_songs (playlist_id, song_id) VALUES ($1, $2) ON CONFLICT DO NOTHING',
      [playlistId, song_id]
    );

    res.json({ message: 'Lagu berhasil ditambahkan ke playlist' });
  } catch (err) {
    console.error('Error add song to playlist:', err.message);
    res.status(500).json({ message: 'Server error' });
  }
});

// =====================
// DELETE /api/playlists/:id/songs/:songId  (protected)
// Hapus lagu dari playlist
// =====================
router.delete('/:id/songs/:songId', authMiddleware, async (req, res) => {
  const userId = req.user.id;
  const { id: playlistId, songId } = req.params;

  try {
    // Pastikan playlist milik user
    const playlist = await pool.query(
      'SELECT id FROM playlists WHERE id = $1 AND user_id = $2',
      [playlistId, userId]
    );
    if (playlist.rows.length === 0) {
      return res.status(404).json({ message: 'Playlist tidak ditemukan' });
    }

    await pool.query(
      'DELETE FROM playlist_songs WHERE playlist_id = $1 AND song_id = $2',
      [playlistId, songId]
    );

    res.json({ message: 'Lagu berhasil dihapus dari playlist' });
  } catch (err) {
    console.error('Error remove song from playlist:', err.message);
    res.status(500).json({ message: 'Server error' });
  }
});

module.exports = router;
