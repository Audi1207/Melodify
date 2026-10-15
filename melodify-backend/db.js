const { Pool } = require('pg');
require('dotenv').config();

// Mendukung koneksi via DATABASE_URL (Cloud PostgreSQL seperti Neon/Supabase)
// atau kredensial terpisah (host, user, password, database)
const poolConfig = process.env.DATABASE_URL
  ? {
      connectionString: process.env.DATABASE_URL,
      ssl: { rejectUnauthorized: false }, // Wajib untuk cloud database
    }
  : {
      host: process.env.DB_HOST || 'localhost',
      port: process.env.DB_PORT || 5432,
      database: process.env.DB_NAME || 'melodify_db',
      user: process.env.DB_USER || 'postgres',
      password: process.env.DB_PASSWORD || 'password123',
      ssl: process.env.DB_SSL === 'true' ? { rejectUnauthorized: false } : false,
    };

const pool = new Pool(poolConfig);

pool.connect((err) => {
  if (err) {
    console.error('❌ Gagal koneksi ke database:', err.message);
  } else {
    console.log('✅ Berhasil terhubung ke PostgreSQL!');
  }
});

module.exports = pool;
