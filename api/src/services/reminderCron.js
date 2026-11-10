const cron = require('node-cron');
const Task = require('../models/Task');
const { sendEmailAndNotify } = require('./emailService');

const initReminderCron = () => {
  // Tự động chạy kiểm tra vào lúc 08:00 sáng mỗi ngày
  cron.schedule('0 8 * * *', async () => {
    try {
      const now = new Date();
      const in24Hours = new Date(now.getTime() + 24 * 60 * 60 * 1000);

      const upcomingTasks = await Task.find({
        status: { $ne: 'completed' },
        dueDate: { $gte: now, $lte: in24Hours },
      }).populate('creator assignees.user');

      for (const task of upcomingTasks) {
        if (task.creator) {
          await sendEmailAndNotify({
            toUser: task.creator,
            subject: `[Nhắc việc 24h] Công việc sắp đến hạn: ${task.title}`,
            text: `Công việc "${task.title}" sẽ đến hạn hoàn thành trong 24h tới. Vui lòng kiểm tra và xử lý!`,
            task,
          });
        }
      }
    } catch (err) {
      console.error('Lỗi chạy Cron Job nhắc việc:', err.message);
    }
  });
};

module.exports = initReminderCron;