import { db } from "../config/db.js";

/**
 * Thêm notification cho user
 * @param {string} userId - ID của user nhận thông báo
 * @param {object} notification - Object notification
 */
export const addNotification = async (userId, notification) => {
  const notifRef = db.collection('users').doc(userId).collection('notifications');
  await notifRef.add({
    ...notification,
    timestamp: new Date(),
    isRead: false,
    status: notification.status || 'pending',
  });
};


// // 1️⃣ API Add member to project
// export const addMember = async (req, res) => {
//   try {
//     const addedByUid = req.user?.uid;
//     const addedByName = req.user?.name || "Unknown";

//     if (!addedByUid) {
//       return res.status(401).json({ message: "Unauthorized" });
//     }

//     const { addedUserId, projectName } = req.body;
//     if (!addedUserId || !projectName) {
//       return res.status(400).json({ message: "Missing required fields" });
//     }

//     await addNotification(addedUserId, {
//       type: 'project_assigned',
//       fromUid: addedByUid,
//       fromName: addedByName,
//       content: `${addedByName} added you to project "${projectName}"`,
//       timestamp: new Date(),
//       isRead: false,
//       status: 'pending',
//     });

//     res.json({ success: true });
//   } catch (error) {
//     console.error(error);
//     res.status(500).json({ message: "Server error" });
//   }
// };

// // 2️⃣ API Comment for task
// export const commentTask = async (req, res) => {
//   try {
//     const commenterUid = req.user?.uid;
//     const commenterName = req.user?.name || "Unknown";

//     if (!commenterUid) {
//       return res.status(401).json({ message: "Unauthorized" });
//     }

//     const { taskOwnerId, taskTitle } = req.body;
//     if (!taskOwnerId || !taskTitle) {
//       return res.status(400).json({ message: "Missing required fields" });
//     }

//     await addNotification(taskOwnerId, {
//       type: 'comment',
//       fromUid: commenterUid,
//       fromName: commenterName,
//       content: `${commenterName} commented on your task "${taskTitle}"`,
//       timestamp: new Date(),
//       isRead: false,
//       status: 'pending',
//     });

//     res.json({ success: true });
//   } catch (error) {
//     console.error(error);
//     res.status(500).json({ message: "Server error" });
//   }
// };


// // 3️⃣ API Assign task to member
// export const assignTask = async (req, res) => {
//     try {
//       const assignedByUid = req.user?.uid;
//       const assignedByName = req.user?.name || "Unknown";
  
//       if (!assignedByUid) {
//         return res.status(401).json({ message: "Unauthorized" });
//       }
  
//       const { assignedUserId, taskTitle } = req.body;
//       if (!assignedUserId || !taskTitle) {
//         return res.status(400).json({ message: "Missing required fields" });
//       }
  
//       await addNotification(assignedUserId, {
//         type: 'task_assigned',
//         fromUid: assignedByUid,
//         fromName: assignedByName,
//         content: `${assignedByName} assigned you task "${taskTitle}"`,
//         timestamp: new Date(),
//         isRead: false,
//         status: 'pending',
//       });
  
//       res.json({ success: true });
//     } catch (error) {
//       console.error(error);
//       res.status(500).json({ message: "Server error" });
//     }
//   };
  
