import express from 'express'
//import { createProject } from "../controllers/project.controller.js";
import {getProjectByUserId , createProject , removeProject , editProject} from "../controllers/project.controller.js"
import { getUserInProject } from '../controllers/project.controller.js';

import { verifyToken } from '../middleware/authMiddleware.js';

const route  = express.Router();

route.get("/", verifyToken , getProjectByUserId);
route.post('/', verifyToken , createProject);
route.delete("/", verifyToken, removeProject);
route.put("/", verifyToken, );


// get user in project
route.get("/:projectId/users", verifyToken, getUserInProject);

export default route;