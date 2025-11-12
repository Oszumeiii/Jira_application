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
    const { name, description, status, createdAt, updatedAt } = req.body;
    const ownerId = req.user?.uid;

    if (!ownerId) {
      return res.status(401).json({ status: "error", message: "Unauthorized" });
    }

    if (!name || !description) {
      return res.status(400).json({ status: "error", message: "Tên và mô tả là bắt buộc" });
    }

    const project = new Project({
      name,
      description,
      ownerId,
      status: status || "active",
      createdAt: createdAt ? new Date(createdAt) : new Date(),
      updatedAt: updatedAt ? new Date(updatedAt) : new Date(),
    });

     await project.save();
    console.log("Project đã được tạo:", project);

    return res.status(201).json({
      status: "success",
      message: "Tạo project thành công!",
      data: {
        id: project._id,
        name: project.name,
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
    return res.status(500).json({ status: "error", message: error.message });
  }
};