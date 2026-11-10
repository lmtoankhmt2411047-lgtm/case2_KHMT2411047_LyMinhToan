const nodemailer = require('nodemailer');
const EmailLog = require('../models/EmailLog');
const Notification = require('../models/Notification');

// Khởi tạo Transporter chuẩn Nodemailer
const transporter = nodemailer.createTransport({
  service: 'gmail',
  auth: {
    user: process.env.EMAIL_USER,
    pass: process.env.EMAIL_PASS,
  },
});

// Hàm dùng chung: Tạo Notification trong App + Gửi Email + Lưu Log lịch sử
const sendEmailAndNotify = async ({ toUser, subject, text, task }) => {
  try {
    // 1. Tạo thông báo trong ứng dụng (In-App)
    if (toUser && toUser._id) {
      await Notification.create({
        recipient: toUser._id,
        title: subject,
        message: text,
        task: task ? task._id : null,
      });
    }

    // 2. Gửi Email và ghi lịch sử (Log)
    if (toUser && toUser.email) {
      const mailOptions = {
        from: process.env.EMAIL_USER || 'no-reply@taskmanager.com',
        to: toUser.email,
        subject,
        text,
      };

      if (process.env.EMAIL_USER && process.env.EMAIL_PASS) {
        await transporter.sendMail(mailOptions);
      }

      await EmailLog.create({
        to: toUser.email,
        subject,
        content: text,
        status: 'success',
      });
    }
  } catch (err) {
    if (toUser && toUser.email) {
      await EmailLog.create({
        to: toUser.email,
        subject,
        content: text,
        status: 'failed',
        error: err.message,
      });
    }
  }
};

module.exports = { sendEmailAndNotify };