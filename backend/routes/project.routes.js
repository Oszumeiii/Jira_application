import express from 'express'
import { createProject } from "../controllers/project.controller.js";

const route  = express.Router();

//post 
route.post('/' , createProject);

export default route;