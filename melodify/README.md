# 🎵 Melodify — Spotify Clone

Aplikasi streaming musik mobile berbasis Flutter yang mereplikasi tampilan dan fitur utama Spotify.

**Dibuat untuk:** UTS Pemrograman Aplikasi Bergerak — Sistem Informasi 2026/2027

---

## 👥 Anggota Kelompok

| No | Nama | NIM |
|----|------|-----|
| 1  | [Nama Anggota 1] | [NIM] |
| 2  | [Nama Anggota 2] | [NIM] |
| 3  | [Nama Anggota 3] | [NIM] |

---

## 📱 Tentang Aplikasi

| | |
|---|---|
| **Aplikasi Asli** | Spotify |
| **Nama Plesetkan** | Melodify |
| **Versi** | 1.0.0 |

---

## 🛠️ Tech Stack

| Layer | Teknologi |
|-------|-----------|
| Frontend | Flutter (Dart) |
| Backend API | Node.js + Express |
| Database | PostgreSQL |
| Auth | JWT (JSON Web Token) |
| State Management | Provider |

---

## 📂 Struktur Proyek

```
Spotify/
├── melodify/               # Flutter frontend
│   └── lib/
│       ├── main.dart
│       ├── constants.dart
│       ├── models/         # Song, Playlist, User
│       ├── services/       # API calls
│       ├── providers/      # State management
│       ├── screens/        # Halaman UI
│       └── widgets/        # Komponen reusable
└── melodify-backend/       # Node.js backend
    ├── index.js            # Entry point
    ├── db.js               # Koneksi database
    ├── database.sql        # Schema + seed data
    ├── routes/             # Auth, Songs, Playlists, Artists
    └── middleware/         # JWT auth middleware
```

---

## ✨ Fitur Utama

- 🔐 **Register & Login** — autentikasi dengan JWT
- 🏠 **Home Screen** — sapaan, lagu populer, recently played
- 🔍 **Search** — cari lagu berdasarkan judul / artis
- 📚 **Library** — kelola playlist pribadi
- ▶️ **Music Player** — kontrol play/pause, next, previous, seek, queue
- 🎵 **Mini Player** — player kecil persisten di bottom bar
- ❤️ **Like Lagu** — tandai lagu favorit
- 📋 **Playlist** — buat, edit, hapus playlist, tambah/hapus lagu

---

## 🚀 Cara Menjalankan Proyek

### 1. Setup Database (PostgreSQL)

```bash
# Buka psql dan jalankan script database
psql -U postgres -f melodify-backend/database.sql
```

### 2. Setup & Jalankan Backend

```bash
cd melodify-backend

# Salin file konfigurasi
cp .env.example .env
# Edit .env sesuai konfigurasi database kamu

# Install dependencies
npm install

# Jalankan server
npm start
# Server berjalan di http://localhost:3000
```

### 3. Jalankan Flutter App

```bash
cd melodify

# Install dependencies
flutter pub get

# Jalankan di emulator/device
flutter run
```

> **Catatan:** Jika menggunakan device fisik, ubah `baseUrl` di `lib/constants.dart` menjadi IP komputer kamu, contoh: `http://192.168.1.5:3000/api`

---

## 🌐 API Endpoints

| Method | Endpoint | Keterangan | Auth |
|--------|----------|------------|------|
| POST | `/api/auth/register` | Daftar akun baru | ❌ |
| POST | `/api/auth/login` | Login | ❌ |
| GET | `/api/songs` | Semua lagu | ❌ |
| GET | `/api/songs/search?q=` | Cari lagu | ❌ |
| POST | `/api/songs/:id/play` | Increment play count | ❌ |
| POST | `/api/songs/:id/like` | Like / unlike lagu | ✅ |
| GET | `/api/songs/liked/all` | Lagu favorit user | ✅ |
| GET | `/api/playlists` | Playlist milik user | ✅ |
| POST | `/api/playlists` | Buat playlist baru | ✅ |
| GET | `/api/playlists/:id` | Detail playlist | ✅ |
| PUT | `/api/playlists/:id` | Edit playlist | ✅ |
| DELETE | `/api/playlists/:id` | Hapus playlist | ✅ |
| POST | `/api/playlists/:id/songs` | Tambah lagu ke playlist | ✅ |
| DELETE | `/api/playlists/:id/songs/:songId` | Hapus lagu dari playlist | ✅ |
| GET | `/api/artists` | Semua artis | ❌ |
| GET | `/api/artists/:id` | Detail artis | ❌ |

---

## 🎬 Video Presentasi

[Link YouTube — Coming Soon]

---

## 📄 Pembagian Tugas

| Nama | Tugas |
|------|-------|
| [Anggota 1] | Flutter UI (Home, Player, Search) |
| [Anggota 2] | Backend API (Auth, Songs) |
| [Anggota 3] | Backend API (Playlists) + Database |
