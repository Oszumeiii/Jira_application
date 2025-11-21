import { Project } from "../models/project.js";
import {db} from "../config/db.js"

import  { sendSuccessResponse, sendErrorResponse } from "../utils/response.js";

export const getProjectByUserId = async (req, res) => {
  try {

    const userId = req.user.uid;
  
    const snapshot = await db.collection("projects")
      .where("ownerId", "==", userId)
      .get();

    if (snapshot.empty) {
      return sendErrorResponse(res, 404, "NotFound", "Không tìm thấy project nào cho user này");
    }

    const projects = snapshot.docs.map(doc => ({
      id: doc.id,
      ...doc.data(),
    }));

    return sendSuccessResponse(res, 200, "Lấy project thành công", projects);
  } catch (error) {
    console.error(" Lỗi khi lấy project:", error);
    return sendErrorResponse(res, 500, "InternalServerError", "Đã có lỗi xảy ra khi lấy project");
  }
};

export const createProject = async (req, res) => {
  try {
    const {
      name,
      priority , 
      description,
      status,
      projectType,
      sumary,
      createdAt,
      updatedAt,
      members,
    } = req.body;
    console.log(members);

    const ownerId = req.user?.uid;
    if (!ownerId) {
      return res
        .status(401)
        .json({ status: "error", message: "Unauthorized" });
    }

    if (!name) {
      return res
        .status(400)
        .json({ status: "error", message: "Tên và mô tả là bắt buộc" });
    }


    let project = new Project({
      name,
      priority ,
      description,
      projectType: projectType || "general",
      sumary: sumary || "",
      ownerId,
      members: members,
      status: status || "active",
      createdAt: createdAt ? new Date(createdAt) : new Date(),
      updatedAt: updatedAt ? new Date(updatedAt) : new Date(),
    });

    project = await project.save();
    console.log("Project đã được tạo:", project);

    return res.status(201).json({
      status: "success",
      message: "Tạo project thành công!",
      data: {
        id: project.id,
        name: project.name,
        priority : project.priority,
        projectType: project.projectType,
        sumary: project.sumary,
        description: project.description,
        ownerId: project.ownerId,
        members: project.members,
        status: project.status,
        createdAt: project.createdAt,
        updatedAt: project.updatedAt,
      },
    });
  } catch (error) {
    console.error("Lỗi khi tạo project:", error);
    return res
      .status(500)
      .json({ status: "error", message: error.message });
  }
};


// Remove 
export const removeProject = async (req, res) => {
  try {
    const idProject = req.body.id;
    const ownerId = req.user?.uid;

    if (!ownerId) {
      return sendErrorResponse(res, 401, "Unauthorized", "You must be logged in to delete a project");
    }

    if (!idProject) {
      return sendErrorResponse(res, 400, "BadRequest", "Missing project ID");
    }

    const projectRef = db.collection("projects").doc(idProject);
    const doc = await projectRef.get();

    if (!doc.exists) {
      return sendErrorResponse(res, 404, "NotFound", "Project not found");
    }

    const projectData = doc.data();
    if (projectData.ownerId !== ownerId) {
      return sendErrorResponse(res, 403, "Forbidden", "You are not authorized to delete this project");
    }

    await projectRef.delete();

    return sendSuccessResponse(res, 200, "Project deleted successfully", {
      id: idProject,
      name: projectData.name,
      description: projectData.description,
    });
  } catch (error) {
    console.error("Error while deleting project:", error);
    return sendErrorResponse(res, 500, "InternalServerError", "An unexpected error occurred while deleting the project");
  }
};

// Edit 
export const editProject = async (req, res) => {
  try {
    const { idProject, name, description, status } = req.body;
    const ownerId = req.user?.uid;

    if (!ownerId) {
      return sendErrorResponse(res, 401, "Unauthorized", "You must be logged in to update a project");
    }

    if (!idProject) {
      return sendErrorResponse(res, 400, "BadRequest", "Missing project ID");
    }

    const projectRef = db.collection("projects").doc(idProject);
    const doc = await projectRef.get();

    if (!doc.exists) {
      return sendErrorResponse(res, 404, "NotFound", "Project not found");
    }

  
    const projectData = doc.data();
    if (projectData.ownerId !== ownerId) {
      return sendErrorResponse(res, 403, "Forbidden", "You are not authorized to edit this project");
    }


    const updatedFields = {
      ...(name && { name }),
      ...(description && { description }),
      ...(status && { status }),
      updatedAt: new Date(),
    };

    await projectRef.update(updatedFields);

    return sendSuccessResponse(res, 200, "Project updated successfully", {
      id: idProject,
      ...projectData,
      ...updatedFields,
    });
  } catch (error) {
    console.error("Error while updating project:", error);
    return sendErrorResponse(res, 500, "InternalServerError", "An unexpected error occurred while updating the project");
  }
};


//get user in project
export const getUserInProject = async (req, res) => {
  try {
    const { projectId } = req.params;

    const projectDoc = await db.collection("projects").doc(projectId).get();
    if (!projectDoc.exists) {
      return res.status(404).json({ success: false, message: "Project not found" });
    }

    const projectData = projectDoc.data();
    const ownerId = projectData.ownerId;
    const memberIds = projectData.members || [];

    const allUserIds = [ownerId, ...memberIds.filter(id => id !== ownerId)];

    const userDocs = await Promise.all(
      allUserIds.map(uid => db.collection("users").doc(uid).get())
    );


    const users = userDocs
      .filter(doc => doc.exists)
      .map(doc => ({ id: doc.id, ...doc.data() }));

    return res.status(200).json({ success: true, users });

  } catch (err) {
    console.error(err);
    return res.status(500).json({ success: false, message: "Server error" });
  }
};

