const express = require('express');
const { searchUser } = require('../controllers/user.controller');
const { authenticate } = require('../middleware/auth.middleware');

const router = express.Router();
router.get('/search', authenticate, searchUser);

module.exports = router;