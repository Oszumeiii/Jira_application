// controllers/comment.controller.js
import { db } from "../config/db.js";
import { sendSuccessResponse, sendErrorResponse } from "../utils/response.js";




/**
 * @swagger
 * /comments/{idTask}:
 *   get:
 *     summary: Lấy danh sách comment của một task
 *     description: Trả về tất cả comment thuộc issue (task) theo idTask.
 *     tags:
 *       - Comment
 *     security:
 *       - BearerAuth: []
 *     parameters:
 *       - in: path
 *         name: idTask
 *         required: true
 *         schema:
 *           type: string
 *         description: ID của task (issue)
 *     responses:
 *       200:
 *         description: Lấy comment thành công
 *         content:
 *           application/json:
 *             schema:
 *               type: array
 *               items:
 *                 $ref: "#/components/schemas/Comment"
 *       404:
 *         description: Không tìm thấy task
 *       500:
 *         description: Lỗi server
 */


export const getCommentByTask = async (req, res) => {
    console.log('called getCommentByTask');
    const { idTask } = req.params;
    try {
      const snapshot = await db
        .collection("issues")
        .doc(idTask)
        .collection("comments")
        .orderBy("createdAt", "desc")
        .get();
  
      const comments = snapshot.docs.map(doc => ({ id: doc.id, ...doc.data() }));
      return sendSuccessResponse(res, 200, "Comments fetched successfully", comments);
    } catch (error) {
      return sendErrorResponse(res, 500, error.message, "Failed to fetch comments");
    }
  };
  
  


  /**
 * @swagger
 * /comments/{idTask}:
 *   post:
 *     summary: Tạo comment mới trong task
 *     description: User cần gửi nội dung comment trong body. Tự động lấy user từ Firebase Token.
 *     tags:
 *       - Comment
 *     security:
 *       - BearerAuth: []
 *     parameters:
 *       - in: path
 *         name: idTask
 *         required: true
 *         schema:
 *           type: string
 *         description: ID của task (issue)
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - content
 *             properties:
 *               content:
 *                 type: string
 *                 example: "This feature should be improved."
 *     responses:
 *       200:
 *         description: Tạo comment thành công
 *         content:
 *           application/json:
 *             schema:
 *               $ref: "#/components/schemas/Comment"
 *       400:
 *         description: Thiếu nội dung comment
 *       500:
 *         description: Lỗi server
 */

  export const createComment = async (req, res) => {
    console.log('called createComment');
    const { idTask } = req.params;
    const { content } = req.body;

    console.log("REQ.USER = ", req.user);
    const { uid : userId, username, email } = req.user;
    try {
      const newComment = {
        userId,
        content,
        username: username || null,
        email: email || null,
        createdAt: new Date(),
      };
  
    
      const docRef = await db
        .collection("issues")
        .doc(idTask)
        .collection("comments")
        .add(newComment);
  
      return sendSuccessResponse(res, 200, "Comment created successfully", { id: docRef.id, ...newComment });
    } catch (error) {
      return sendErrorResponse(res, 500, error.message, "Failed to create comment");
    }
  };
  
  


  /**
 * @swagger
 * /comments/{idTask}/{idComment}:
 *   delete:
 *     summary: Xóa comment khỏi task
 *     description: Xóa comment theo id của task và id của comment.
 *     tags:
 *       - Comment
 *     security:
 *       - BearerAuth: []
 *     parameters:
 *       - in: path
 *         name: idTask
 *         required: true
 *         schema:
 *           type: string
 *         description: ID của task
 *       - in: path
 *         name: idComment
 *         required: true
 *         schema:
 *           type: string
 *         description: ID của comment
 *     responses:
 *       200:
 *         description: Xóa comment thành công
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 id:
 *                   type: string
 *                   example: "cmt123"
 *       404:
 *         description: Không tìm thấy comment
 *       500:
 *         description: Lỗi server
 */
  export const removeComment = async (req, res) => {
    console.log('called removeComment');
    const { idTask, idComment } = req.params;
  
    try {
      const docRef = db
        .collection("issues")
        .doc(idTask)
        .collection("comments")
        .doc(idComment);
  
      const doc = await docRef.get();
      if (!doc.exists) {
        return sendErrorResponse(res, 404, null, "Comment not found");
      }
  
      await docRef.delete();
      return sendSuccessResponse(res, 200, "Comment deleted successfully", { id: idComment });
    } catch (error) {
      console.log(error);
      return sendErrorResponse(res, 500, error.message, "Failed to delete comment");
    }
  };
  
  