import express from 'express';
// import { registerUser, loginUser, getUserProfile } from '../controllers/user.controller.js';
import { verifyToken } from '../middleware/authMiddleware.js';
import {searchUser} from "../controllers/user.controller.js"

const route = express.Router();

route.get('/search', verifyToken , searchUser);
export default route;