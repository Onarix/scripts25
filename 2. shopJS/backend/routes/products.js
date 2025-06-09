const express = require('express');
const router = express.Router();
const db = require('../db');

router.get('/', (req, res) => {
  const products = db.prepare('SELECT * FROM products').all();
  res.json(products);
});

router.post('/', (req, res) => {
  const { name, price, category_id } = req.body;
  const stmt = db.prepare('INSERT INTO products (name, price, category_id) VALUES (?, ?, ?)');
  const info = stmt.run(name, price, category_id);
  res.json({ id: info.lastInsertRowid });
});

module.exports = router;
