import { Project } from "../models/project.js";
import {db} from "../config/db.js"

import  { sendSuccessResponse, sendErrorResponse } from "../utils/response.js";
import { addNotification } from "./notify.controller.js";
/**
 * @swagger
 * /projects/by-user:
 *   get:
 *     summary: Lấy tất cả project mà user sở hữu hoặc là thành viên
 *     tags: [Project]
 *     security:
 *       - BearerAuth: []
 *     responses:
 *       200:
 *         description: Lấy danh sách project thành công
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 status:
 *                   type: string
 *                 message:
 *                   type: string
 *                 data:
 *                   type: array
 *                   items:
 *                     $ref: '#/components/schemas/Project'
 *       404:
 *         description: Không tìm thấy project
 *       500:
 *         description: Lỗi server
 */


export const getProjectByUserId = async (req, res) => {
  try {
    const userId = req.user.uid;

    const snapshot = await db.collection("projects")
      .where("members", "array-contains", userId)
      .get();

    const projects = snapshot.docs.map(doc => ({
      id: doc.id,
      ...doc.data(),
    }));

    return sendSuccessResponse(res, 200, "Lấy project thành công", projects);

  } catch (error) {
    console.error("Lỗi khi lấy project:", error);
    return sendErrorResponse(res, 500, "InternalServerError", "Đã có lỗi xảy ra khi lấy project");
  }
};




/**
 * @swagger
 * /projects:
 *   post:
 *     summary: Tạo mới project
 *     tags: [Project]
 *     security:
 *       - BearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required: [name, ownerId]
 *             properties:
 *               name:
 *                 type: string
 *               priority:
 *                 type: string
 *                 enum: [Low, Medium, High]
 *               projectType:
 *                 type: string
 *               sumary:
 *                 type: string
 *               description:
 *                 type: string
 *               ownerId:
 *                 type: string
 *               members:
 *                 type: array
 *                 items:
 *                   type: string
 *     responses:
 *       201:
 *         description: Tạo project thành công
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Project'
 *       400:
 *         description: Dữ liệu không hợp lệ
 *       500:
 *         description: Lỗi server
 */



export const createProject = async (req, res) => {
  try {
    const {
      name,
      priority, 
      description,
      status,
      projectType,
      sumary,
      createdAt,
      updatedAt,
      members = [],
    } = req.body;

    const ownerId = req.user?.uid;
    console.log(req.user);
    if (!ownerId) {
      return res.status(401).json({
        status: "error",
        message: "Unauthorized",
      });
    }

    if (!name) {
      return res.status(400).json({
        status: "error",
        message: "Tên và mô tả là bắt buộc",
      });
    }

    const uniqueMembers = Array.from(new Set([ownerId, ...members]));

    let project = new Project({
      name,
      priority,
      description,
      projectType: projectType || "general",
      sumary: sumary || "",
      ownerId,
      members: uniqueMembers,
      status: status || "active",
      createdAt: createdAt ? new Date(createdAt) : new Date(),
      updatedAt: updatedAt ? new Date(updatedAt) : new Date(),
    });

    project = await project.save();

    // thêm thông báo 
    const userDoc = await db.collection('users').doc(ownerId).get();
    const ownerName = userDoc.exists ? userDoc.data().userName : 'Owner';
    
    const addedMembers = uniqueMembers.filter(uid => uid !== ownerId);
    
    await Promise.all(
      addedMembers.map(memberId =>
        addNotification(memberId, {
          type: 'project_assigned',
          fromUid: ownerId,
          fromName: ownerName,
          content: `${ownerName} added you to project "${project.name}"`,
          timestamp: new Date(),
          isRead: false,
          status: 'pending',
        })
      )
    );
    


    return res.status(201).json({
      status: "success",
      message: "Tạo project thành công!",
      data: {
        id: project.id,
        name: project.name,
        priority: project.priority,
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
    return res.status(500).json({
      status: "error",
      message: error.message,
    });
  }
};





/**
 * @swagger
 * /projects/{id}:
 *   delete:
 *     summary: Xóa project
 *     tags: [Project]
 *     security:
 *       - BearerAuth: []
 *     parameters:
 *       - name: id
 *         in: path
 *         required: true
 *         schema:
 *           type: string
 *     responses:
 *       200:
 *         description: Xóa thành công
 *       404:
 *         description: Không tìm thấy project
 *       500:
 *         description: Lỗi server
 */


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

    const issuesSnapshot = await db.collection("issues")
      .where("projectId", "==", idProject)
      .get();

    const batch = db.batch();
    issuesSnapshot.docs.forEach(issueDoc => {
      batch.delete(issueDoc.ref);
    });

    batch.delete(projectRef);

    await batch.commit();

    return sendSuccessResponse(res, 200, "Project and related issues deleted successfully", {
      id: idProject,
      name: projectData.name,
      description: projectData.description,
    });
  } catch (error) {
    console.error("Error while deleting project:", error);
    return sendErrorResponse(res, 500, "InternalServerError", "An unexpected error occurred while deleting the project");
  }
};







/**
 * @swagger
 * /projects/{id}:
 *   put:
 *     summary: Cập nhật project
 *     tags: [Project]
 *     security:
 *       - BearerAuth: []
 *     parameters:
 *       - name: id
 *         in: path
 *         required: true
 *         schema:
 *           type: string
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               name:
 *                 type: string
 *               priority:
 *                 type: string
 *               projectType:
 *                 type: string
 *               sumary:
 *                 type: string
 *               description:
 *                 type: string
 *               members:
 *                 type: array
 *                 items:
 *                   type: string
 *               status:
 *                 type: string
 *     responses:
 *       200:
 *         description: Cập nhật thành công
 *       404:
 *         description: Không tìm thấy project
 *       500:
 *         description: Lỗi server
 */

// Edit 
export const editProject = async (req, res) => {
  try {
    const { id, name, description, status, members } = req.body;
    const ownerId = req.user?.uid;

    if (!ownerId) {
      return sendErrorResponse(res, 401, "Unauthorized", "You must be logged in to update a project");
    }
    if (!id) {
      return sendErrorResponse(res, 400, "BadRequest", "Missing project ID");
    }

    const projectRef = db.collection("projects").doc(id);
    const doc = await projectRef.get();

    if (!doc.exists) {
      return sendErrorResponse(res, 404, "NotFound", "Project not found");
    }

    const projectData = doc.data();

    // if (projectData.ownerId !== ownerId) {
    //   return sendErrorResponse(res, 403, "Forbidden", "You are not authorized to edit this project");
    // }

    const updatedFields = {};
    if (name !== undefined && name.trim() !== "") updatedFields.name = name;
    if (description !== undefined && description.trim() !== "") updatedFields.description = description;
    if (status !== undefined && status.trim() !== "") updatedFields.status = status;
    if (Array.isArray(members)) updatedFields.members = members; // <-- cập nhật members
    updatedFields.updatedAt = new Date();

    await projectRef.update(updatedFields);

    const updatedDoc = await projectRef.get();
    const updatedData = updatedDoc.data();

    return sendSuccessResponse(res, 200, "Project updated successfully", {
      id: updatedDoc.id,
      ...updatedData,
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

