const express = require('express');
const router = express.Router();
const authController = require('../controllers/authController');
const { protect } = require('../middleware/authMiddleware');

// Đăng ký
if (typeof authController.register === 'function') {
  router.post('/register', authController.register);
}

// Đăng nhập
if (typeof authController.login === 'function') {
  router.post('/login', authController.login);
}

// Lấy thông tin cá nhân
if (typeof authController.getMe === 'function') {
  router.get('/me', protect, authController.getMe);
}

module.exports = router;