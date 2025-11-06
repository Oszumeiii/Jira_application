import { Project } from "../models/project.js";
import {db} from "../config/db.js"

import  { sendSuccessResponse, sendErrorResponse } from "../utils/response.js";

export const getProjectByUserId = async (req, res) => {
  try {
    const userId = req.query.userId;
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



export const createProject = async (req , res) =>{
    try {
        const { name, description, ownerId, members } = req.body;
        if (!name || !ownerId) {
            return res.status(400).json({ error: "Thiếu tên project hoặc ownerId" });
        }
        const project = new Project({
        name,
        description,
        ownerId,
        members,
        });

        await project.save();

        return res.status(201).json({
        message: "Tạo project thành công!",
        project: {
            id: project.id,
            name: project.name,
            description: project.description,
            ownerId: project.ownerId,
            members: project.members,
            status: project.status,
            createdAt: project.createdAt,
        },
        });
    }catch (error) {
    console.error("Lỗi khi tạo project:", error);
    return res.status(500).json({ error: "Lỗi server" });
  }
}