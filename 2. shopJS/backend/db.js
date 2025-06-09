const Database = require('better-sqlite3');
const db = new Database('shop.db');

db.exec(`
  CREATE TABLE IF NOT EXISTS categories (
    id INTEGER PRIMARY KEY,
    name TEXT NOT NULL
  );

  CREATE TABLE IF NOT EXISTS products (
    id INTEGER PRIMARY KEY,
    name TEXT NOT NULL,
    price REAL NOT NULL,
    category_id INTEGER,
    FOREIGN KEY(category_id) REFERENCES categories(id)
  );

  CREATE TABLE IF NOT EXISTS transactions (
  id INTEGER PRIMARY KEY,
  user_id TEXT NOT NULL,
  total REAL NOT NULL,
  timestamp TEXT NOT NULL
);
`);

module.exports = db;
