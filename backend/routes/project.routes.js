import express from 'express'
//import { createProject } from "../controllers/project.controller.js";
import {getProjectByUserId , createProject} from "../controllers/project.controller.js"
import { verifyToken } from '../middleware/authMiddleware.js';


const route  = express.Router();

//post 
//route.post('/' ,verifyToken , createProject);
route.get("/", verifyToken , getProjectByUserId);
route.post('/', verifyToken , createProject);
export default route;