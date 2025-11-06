import express from 'express'
import { createProject } from "../controllers/project.controller.js";
import {getProjectByUserId} from "../controllers/project.controller.js"
const route  = express.Router();

//post 
route.post('/' , createProject);
route.get("/user", getProjectByUserId);
export default route;