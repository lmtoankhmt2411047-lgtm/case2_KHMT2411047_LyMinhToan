const express = require('express');
const mongoose = require('mongoose');
const dotenv = require('dotenv');

// Nạp các biến môi trường từ file .env
dotenv.config();

const app = express();
app.use(express.json()); // Cho phép server đọc dữ liệu JSON

// Kết nối với MongoDB Atlas
mongoose.connect(process.env.MONGODB_URI)
    .then(() => console.log('>>> Kết nối MongoDB Atlas thành công!'))
    .catch((err) => console.error('>>> Lỗi kết nối cơ sở dữ liệu:', err));

// Tạo một API test cơ bản
app.get('/', (req, res) => {
    res.json({ message: 'Task Manager API đang hoạt động bình thường!' });
});

// Chạy server
const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
    console.log(`>>> Server đang chạy tại: http://localhost:${PORT}`);
});