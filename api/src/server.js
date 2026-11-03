const express = require('express');
const mongoose = require('mongoose');
const dotenv = require('dotenv');
const authRoutes = require('./routes/authRoutes');

dotenv.config();

const app = express();
app.use(express.json());

// Routes API
app.use('/api/auth', authRoutes);

// Kết nối MongoDB Atlas
mongoose.connect(process.env.MONGODB_URI)
    .then(() => console.log('>>> Kết nối MongoDB Atlas thành công!'))
    .catch((err) => console.error('>>> Lỗi kết nối cơ sở dữ liệu:', err));

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
    console.log(`>>> Server đang chạy tại: http://localhost:${PORT}`);
});