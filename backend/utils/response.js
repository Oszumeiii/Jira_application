/**
 * Tạo template phản hồi JSON
 * @param {Object} res - Đối tượng response từ Express
 * @param {number} statusCode - Mã trạng thái HTTP (ví dụ: 200, 400, 500)
 * @param {string} message - Thông báo đi kèm phản hồi
 * @param {any} data - Dữ liệu trả về (đối tượng, mảng, chuỗi, số, ...)
 * @return {Object} - Đối tượng JSON theo cấu trúc chuẩn
 */
export const sendSuccessResponse = (res, statusCode, message, data = []) => {
    return res.status(statusCode).json({
      statusCode: statusCode,
      message: message,
      data: data,
    });
  };
  
  /**
   * Tạo template phản hồi JSON
   * @param {Object} res - Đối tượng response của Express
   * @param {number} statusCode - Mã trạng thái HTTP (ví dụ: 200, 400, 500)
   * @param {string} error - Mã lỗi
   * @param {string} message - Thông báo lỗi
   * @returns {Object} - Đối tượng JSON theo cấu trúc chuẩn
   */
  
  export const sendErrorResponse = (res, statusCode, error, message) => {
    return res.status(statusCode).json({
      statusCode: statusCode,
      error: error,
      message: message,
    });
  };
  
