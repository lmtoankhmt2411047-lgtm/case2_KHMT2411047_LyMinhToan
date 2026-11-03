const User = require('../models/User');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');

// 1. Đăng ký tài khoản
exports.register = async (req, res) => {
    try {
        const { fullName, email, password } = req.body;

        if (!fullName || !email || !password) {
            return res.status(400).json({ message: 'Vui lòng điền đầy đủ thông tin!' });
        }

        const existingUser = await User.findOne({ email });
        if (existingUser) {
            return res.status(400).json({ message: 'Email này đã được sử dụng!' });
        }

        const salt = await bcrypt.genSalt(10);
        const passwordHash = await bcrypt.hash(password, salt);

        const newUser = new User({ fullName, email, passwordHash });
        await newUser.save();

        res.status(201).json({ message: 'Đăng ký tài khoản thành công!' });
    } catch (error) {
        res.status(500).json({ message: 'Lỗi server:', error: error.message });
    }
};

// 2. Đăng nhập
exports.login = async (req, res) => {
    try {
        const { email, password } = req.body;

        const user = await User.findOne({ email });
        if (!user) {
            return res.status(400).json({ message: 'Email hoặc mật khẩu không chính xác!' });
        }

        const isMatch = await bcrypt.compare(password, user.passwordHash);
        if (!isMatch) {
            return res.status(400).json({ message: 'Email hoặc mật khẩu không chính xác!' });
        }

        const token = jwt.sign(
            { userId: user._id, email: user.email },
            process.env.JWT_SECRET || 'secret_key_task_manager',
            { expiresIn: '7d' }
        );

        res.json({
            message: 'Đăng nhập thành công!',
            token,
            user: {
                id: user._id,
                fullName: user.fullName,
                email: user.email
            }
        });
    } catch (error) {
        res.status(500).json({ message: 'Lỗi server:', error: error.message });
    }
};

// 3. Lấy thông tin tài khoản hiện tại
exports.getMe = async (req, res) => {
    try {
        const user = await User.findById(req.user.userId).select('-passwordHash');
        res.json(user);
    } catch (error) {
        res.status(500).json({ message: 'Lỗi server:', error: error.message });
    }
};