const express = require('express');
const router = express.Router();
const {
  createTask,
  getTasks,
  getTaskById,
  updateTask,
  deleteTask,
  getTaskActivities,
  assignTask,
  shareTask,
  removeShareAccess,
  getTaskStatistics, // <--- Đã thêm hàm thống kê vào đây
} = require('../controllers/taskController');

// Import middleware auth
const authMiddleware = require('../middleware/authMiddleware');
const protect = authMiddleware.protect || authMiddleware;

// Áp dụng middleware kiểm tra Token xác thực JWT cho toàn bộ routes
if (typeof protect === 'function') {
  router.use(protect);
}

// 1. Route gốc: /api/tasks
router.route('/')
  .post(createTask) // B1: Tạo công việc mới
  .get(getTasks); // B2: Lấy danh sách công việc

// =========================================
// E: Route Thống kê (PHẢI ĐẶT TRƯỚC /:id)
// =========================================
router.get('/statistics', getTaskStatistics);

// 2. Route xử lý theo ID: /api/tasks/:id
router.route('/:id')
  .get(getTaskById) // B2: Xem chi tiết công việc
  .put(updateTask) // B3: Cập nhật công việc
  .delete(deleteTask);// B3: Xóa công việc

// 3. Route Lịch sử hoạt động: /api/tasks/:id/activities
router.get('/:id/activities', getTaskActivities);

// 4. Route Nhóm C - Giao công việc: /api/tasks/:id/assign
router.post('/:id/assign', assignTask);

// 5. Route Nhóm C - Chia sẻ công việc: /api/tasks/:id/share
router.post('/:id/share', shareTask);

// 6. Route Nhóm C - Thu hồi quyền chia sẻ: /api/tasks/:id/share/:userId
router.delete('/:id/share/:userId', removeShareAccess);

module.exports = router;