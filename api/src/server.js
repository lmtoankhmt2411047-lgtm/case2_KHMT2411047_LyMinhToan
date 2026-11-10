const express = require('express');
const mongoose = require('mongoose');
const dotenv = require('dotenv');

dotenv.config();

const app = express();
app.use(express.json());

// Routes
const authRoutes = require('./routes/authRoutes');
const taskRoutes = require('./routes/taskRoutes');
const notificationRoutes = require('./routes/notificationRoutes');
const initReminderCron = require('./services/reminderCron');

app.use('/api/auth', authRoutes);
app.use('/api/tasks', taskRoutes);
app.use('/api/notifications', notificationRoutes);

// Khởi chạy tiến trình nhắc việc 24h
initReminderCron();

const PORT = process.env.PORT || 3000;
const MONGO_URI = process.env.MONGO_URI || 'mongodb://localhost:27017/taskmanager';

mongoose
  .connect(MONGO_URI)
  .then(() => {
    console.log('>>> Kết nối MongoDB Atlas thành công!');
    app.listen(PORT, () => {
      console.log(`>>> Server Phần D đang chạy tại: http://localhost:${PORT}`);
    });
  })
  .catch((err) => console.error('Lỗi kết nối MongoDB:', err));