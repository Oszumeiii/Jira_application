import { User } from "../models/user.js";
import  { sendSuccessResponse, sendErrorResponse } from "../utils/response.js";

export const searchUser = async (req, res) => {
  try {
    const q = req.query.q || "";

    const users = await User.searchByEmail(q);
    console.log("Search results:", users);
    console.log(`Number of users found: ${users.length}`);

    return sendSuccessResponse(res, 200, "Search completed successfully", {
      results: users.length,
      users,
    });
  } catch (err) {
    console.error(err);
    return sendErrorResponse(res, 500, err.message);
  }
};