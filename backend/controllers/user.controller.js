// src/controllers/user.controller.js
const { db } = require('../utils/firebase');

const searchUser = async (req, res) => {
  const { email } = req.query;
  const currentUserId = req.user.uid;

  if (!email || email.length < 3) {
    return res.status(400).json({ error: 'Email must be at least 3 characters' });
  }

  try {
    const snapshot = await db
      .collection('users')
      .where('email', '>=', email)
      .where('email', '<=', email + '\uf8ff')
      .limit(10)
      .get();

    const users = snapshot.docs
      .map(doc => ({ uid: doc.id, ...doc.data() }))
      .filter(u => u.uid !== currentUserId);

    res.json(users);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

module.exports = { searchUser };