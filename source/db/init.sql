CREATE TABLE IF NOT EXISTS users (
  username TEXT NOT NULL UNIQUE,
  pwd_hash TEXT NOT NULL,
  bio TEXT,
  website TEXT,
  created_at INTEGER NOT NULL DEFAULT (strftime('%s', 'now'))
);

CREATE TABLE IF NOT EXISTS courses (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  by_user TEXT NOT NULL,
  price INT,
  title TEXT NOT NULL,
  subtitle TEXT NOT NULL,
  content TEXT NOT NULL,
  type TEXT NOT NULL,
  created_at INTEGER NOT NULL DEFAULT (strftime('%s', 'now'))
);

PRAGMA foreign_keys = ON;
