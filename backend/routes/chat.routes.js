const express = require('express');
const { createGroup, sendMessage, getMessages } = require('../controllers/chat.controller');
const { authenticate } = require('../middleware/auth.middleware');

const router = express.Router();
router.post('/group', authenticate, createGroup);
router.post('/:chatId/messages', authenticate, sendMessage);
router.get('/:chatId/messages', authenticate, getMessages);

module.exports = router;