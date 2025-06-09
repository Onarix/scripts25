const express = require('express');
const router = express.Router();
const db = require('../db');

router.get('/', (req, res) => {
  const categories = db.prepare('SELECT * FROM categories').all();
  res.json(categories);
});

router.post('/', (req, res) => {
  const { name } = req.body;
  const stmt = db.prepare('INSERT INTO categories (name) VALUES (?)');
  const info = stmt.run(name);
  res.json({ id: info.lastInsertRowid });
});

module.exports = router;
