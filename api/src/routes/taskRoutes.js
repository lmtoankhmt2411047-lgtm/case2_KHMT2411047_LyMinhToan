const express = require('express');
const router = express.Router();
const {
  createTask,
  getTasks,
  getTaskById,
  updateTask,
  deleteTask
} = require('../controllers/taskController');
const { protect } = require('../middleware/authMiddleware');

// Áp dụng middleware kiểm tra Token xác thực cho toàn bộ routes
router.use(protect);

// Route xử lý tại đường dẫn gốc /api/tasks
router.route('/')
  .post(createTask)   // B1: Tạo công việc
  .get(getTasks);     // B2: Lấy danh sách công việc

// Route xử lý theo ID công việc /api/tasks/:id
router.route('/:id')
  .get(getTaskById)   // B2: Xem chi tiết công việc
  .put(updateTask)    // B2: Cập nhật công việc
  .delete(deleteTask);// B3: Xóa công việc

module.exports = router;