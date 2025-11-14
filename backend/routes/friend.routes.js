const express = require('express');
const { sendFriendRequest, acceptFriendRequest, getFriends } = require('../controllers/friend.controller');
const { authenticate } = require('../middleware/auth.middleware');

const router = express.Router();
router.post('/request', authenticate, sendFriendRequest);
router.post('/accept', authenticate, acceptFriendRequest);
router.get('/', authenticate, getFriends);

module.exports = router;