import express from 'express'
import { verifyToken } from '../middleware/authMiddleware.js';
import {createIssue , getIssuesByProject , getIssuesByAssignee } from "../controllers/issue.controller.js";
import {assignUserToIssue , updateIssue  , deleteIssue } from  "../controllers/issue.controller.js";
import {
    removeComment
} from "../controllers/comment.controller.js";


const route = express.Router();

route.post("/", verifyToken, createIssue);
route.get("/", verifyToken, getIssuesByProject);
route.get("/assignee", verifyToken, getIssuesByAssignee);

route.put("/:issueId", verifyToken, updateIssue);
route.put("/:issueId/assign", verifyToken, assignUserToIssue);
route.delete("/:issueId", verifyToken, deleteIssue);



route.delete('/:idTask/comments/:idComment', verifyToken, removeComment);

export default route;