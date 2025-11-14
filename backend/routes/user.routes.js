<<<<<<< HEAD
const express = require('express');
const { searchUser } = require('../controllers/user.controller');
const { authenticate } = require('../middleware/auth.middleware');

const router = express.Router();
router.get('/search', authenticate, searchUser);

module.exports = router;
=======
import express from 'express';
// import { registerUser, loginUser, getUserProfile } from '../controllers/user.controller.js';
import { verifyToken } from '../middleware/authMiddleware.js';
import {searchUser} from "../controllers/user.controller.js"

const route = express.Router();

route.get('/search', verifyToken , searchUser);
export default route;
>>>>>>> 4b6dcdcccf044157c75080280e3e60b71f42eb90
