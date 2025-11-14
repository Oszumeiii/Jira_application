import { User } from "../models/user.js";
import  { sendSuccessResponse, sendErrorResponse } from "../utils/response.js";

export const searchUser = async (req, res) => {
  try {
    const q = req.query.q || "";

    const users = await User.searchByEmail(q);
    console.log("Search results:", users);
    console.log(`Number of users found: ${users.length}`);

    return sendSuccessResponse(res, 200, "Search completed successfully", {
      results: users.length,
      users,
    });
  } catch (err) {
    console.error(err);
    return sendErrorResponse(res, 500, err.message);
  }
};
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