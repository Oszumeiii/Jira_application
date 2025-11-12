import express from 'express'
//import { createProject } from "../controllers/project.controller.js";
import {getProjectByUserId} from "../controllers/project.controller.js"
import { verifyToken } from '../middleware/authMiddleware.js';


const route  = express.Router();

//post 
//route.post('/' ,verifyToken , createProject);
route.get("/", verifyToken , getProjectByUserId);
export default route;