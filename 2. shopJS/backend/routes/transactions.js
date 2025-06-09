const express = require('express');
const router = express.Router();
const db = require('../db');

router.post('/', (req, res) => {
  const { user_id, total } = req.body;
  const timestamp = new Date().toISOString();

  const stmt = db.prepare('INSERT INTO transactions (user_id, total, timestamp) VALUES (?, ?, ?)');
  const info = stmt.run(user_id, total, timestamp);

  res.json({ success: true, id: info.lastInsertRowid });
});

module.exports = router;
