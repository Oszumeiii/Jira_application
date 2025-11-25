// src/controllers/friend.controller.js
const { db } = require('../utils/firebase');

const sendFriendRequest = async (req, res) => {
  const { targetUid } = req.body;
  const currentUserId = req.user.uid;

  if (!targetUid) return res.status(400).json({ error: 'targetUid is required' });

  try {
    const batch = db.batch();

    // Thêm vào danh sách pending của người nhận
    const pendingRef = db
      .collection('users')
      .doc(targetUid)
      .collection('friendRequests')
      .doc(currentUserId);
    batch.set(pendingRef, {
      from: currentUserId,
      status: 'pending',
      createdAt: new Date(),
    });

    // Ghi log
    await batch.commit();
    res.json({ message: 'Friend request sent' });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

const acceptFriendRequest = async (req, res) => {
  const { requesterUid } = req.body;
  const currentUserId = req.user.uid;

  try {
    const batch = db.batch();

    // Xóa request
    const requestRef = db
      .collection('users')
      .doc(currentUserId)
      .collection('friendRequests')
      .doc(requesterUid);
    batch.delete(requestRef);

    // Thêm vào danh sách bạn bè
    const userRef = db.collection('users').doc(currentUserId);
    const friendRef = db.collection('users').doc(requesterUid);

    batch.update(userRef, {
      friends: admin.firestore.FieldValue.arrayUnion(requesterUid),
    });
    batch.update(friendRef, {
      friends: admin.firestore.FieldValue.arrayUnion(currentUserId),
    });

    await batch.commit();
    res.json({ message: 'Friend accepted' });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

const getFriends = async (req, res) => {
  const currentUserId = req.user.uid;

  try {
    const userDoc = await db.collection('users').doc(currentUserId).get();
    const friendIds = userDoc.data()?.friends || [];

    const friends = await Promise.all(
      friendIds.map(async (id) => {
        const doc = await db.collection('users').doc(id).get();
        return { uid: id, ...doc.data() };
      })
    );

    res.json(friends);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

module.exports = { sendFriendRequest, acceptFriendRequest, getFriends };