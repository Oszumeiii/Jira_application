// src/controllers/chat.controller.js
const { db } = require('../utils/firebase');
const admin = require('firebase-admin');

const createGroup = async (req, res) => {
  const { name, memberIds } = req.body;
  const currentUserId = req.user.uid;

  if (!name || !Array.isArray(memberIds) || memberIds.length === 0) {
    return res.status(400).json({ error: 'Invalid input' });
  }

  const members = [currentUserId, ...memberIds];

  try {
    const chatRef = await db.collection('chats').add({
      name,
      isGroup: true,
      members,
      admin: currentUserId,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      lastMessage: '',
    });

    // Tin nhắn hệ thống
    await chatRef.collection('messages').add({
      text: `${name} đã được tạo.`,
      from: currentUserId,
      time: admin.firestore.FieldValue.serverTimestamp(),
      system: true,
    });

    res.json({ chatId: chatRef.id, message: 'Group created' });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

const sendMessage = async (req, res) => {
  const { chatId } = req.params;
  const { text } = req.body;
  const from = req.user.uid;

  if (!text?.trim()) return res.status(400).json({ error: 'Text required' });

  try {
    const messageRef = await db.collection('chats').doc(chatId).collection('messages').add({
      text: text.trim(),
      from,
      time: admin.firestore.FieldValue.serverTimestamp(),
    });

    // Cập nhật lastMessage
    await db.collection('chats').doc(chatId).update({
      lastMessage: text.trim(),
      lastMessageTime: admin.firestore.FieldValue.serverTimestamp(),
    });

    res.json({ messageId: messageRef.id });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

const getMessages = async (req, res) => {
  const { chatId } = req.params;

  try {
    const snapshot = await db
      .collection('chats')
      .doc(chatId)
      .collection('messages')
      .orderBy('time', 'asc')
      .get();

    const messages = snapshot.docs.map(doc => ({
      id: doc.id,
      ...doc.data(),
    }));

    res.json(messages);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

module.exports = { createGroup, sendMessage, getMessages };