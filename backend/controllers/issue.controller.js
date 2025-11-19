import {db} from "../config/db.js"
import  { sendSuccessResponse, sendErrorResponse } from "../utils/response.js";

export const getIssuesByProject = async (req, res) => {
    console.log("Get Issues by Project ID called");
    try {
        const projectId = req.query.idProject?.toString();

        if (!projectId) {
            return sendErrorResponse(res, 400, "INVALID_ID", "Thiếu idProject trong query");
        }

        const issuesSnap = await db.collection("issues")
            .where("projectId", "==", projectId)
            .get();

        console.log("Issues snapshot retrieved:", issuesSnap.size);

        const issues = [];
        
        issuesSnap.forEach(doc => {
            issues.push({
                id: doc.id,
                ...doc.data()
            });
        });

        console.log(`Found ${issues.length} issues for project ID ${projectId}`);
        console.log("ISSUES DATA:", issues);

        return sendSuccessResponse(res, 200, "Lấy danh sách issues thành công", issues);

    } catch (error) {
        console.error("ERROR getIssuesByProject:", error);
        return sendErrorResponse(res, 500, "INTERNAL_ERROR", error.message);
    }
};


export const createIssue = async (req, res) => {
  try {
    console.log("Create Issue called");
    const userId = req.user?.uid;
    console.log("User ID from token:", userId);
    console.log(req.body);

    const {
      projectId,
      title,
      summary,
      description = "",
      type = "task",
      priority = "Low",
      status = "todo",
      assigneeId = null,
      parentId = null,
      createdAt,
      updatedAt,
    } = req.body;

    if (!title) {
      return sendErrorResponse(res, 400, "MISSING_TITLE", "Title is required!");
    }

    const docRef = db.collection("issues").doc();
    const issueId = docRef.id;

    const newIssue = {
      id: issueId,
      projectId,
      title,
      summary,
      description,
      type,
      priority,
      status,
      assigneeId,
      reporterId: userId ?? "", 
      parentId,
      subTasks: [],
      createdAt: createdAt ? new Date(createdAt) : new Date(),
      updatedAt: updatedAt ? new Date(updatedAt) : new Date(),
    };

    console.log("New Issue Data:", newIssue);

    await docRef.set(newIssue);

    if (parentId) {
      const parentRef = db.collection("issues").doc(parentId);
      const parentSnap = await parentRef.get();

      if (!parentSnap.exists) {
        return sendErrorResponse(res, 404, "PARENT_NOT_FOUND", "Parent issue not found");
      }

      const parentData = parentSnap.data();
      await parentRef.update({
        subTasks: [...parentData.subTasks, issueId],
        updatedAt: new Date(),
      });
    }

    return sendSuccessResponse(res, 201, "Issue created successfully", { issue: newIssue });

  } catch (error) {
    console.error(error);
    return sendErrorResponse(res, 500, "INTERNAL_ERROR", error.message);
  }
};



export const getIssueById = async (req, res) => {
    try {
        const issueId = req.params.issueId;
        
        const issueRef = db.collection("issues").doc(issueId);
        const issueSnap = await issueRef.get();
        if (!issueSnap.exists) {
            return res.status(404).json({ message: "Issue not Found" });
        }
        const issue = issueSnap.data();
        return res.status(200).json({ issue });
        
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: "Error Internal Server !", error: error.message });
    }
};

export const getIssuesByAssignee = async (req, res) => {
    try {
        const assigneeId = req.params.assigneeId;
        
        const issuesSnap = await db.collection("issues")
            .where("assigneeId", "==", assigneeId)
            .get();
        const issues = [];
        
        issuesSnap.forEach(doc => {
            issues.push(doc.data());
        });
        return res.status(200).json({ issues });
        
    }
    catch (error) {
        console.error(error);
        res.status(500).json({ message: "Error Internal Server !", error: error.message });
    }
};


