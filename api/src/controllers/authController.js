const User = require('../models/User');
const jwt = require('jsonwebtoken');
const bcrypt = require('bcryptjs');

// Hàm tạo Token JWT
const generateToken = (id) => {
  return jwt.sign({ id }, process.env.JWT_SECRET || 'secret_key', {
    expiresIn: '30d',
  });
};

// Đăng ký tài khoản
exports.register = async (req, res) => {
  try {
    const { fullName, email, password } = req.body;

    const userExists = await User.findOne({ email });
    if (userExists) {
      return res.status(400).json({ status: 'fail', message: 'Email này đã được đăng ký' });
    }

    const user = await User.create({
      fullName,
      email,
      password,
    });

    const token = generateToken(user._id);

    res.status(201).json({
      status: 'success',
      token,
      user: {
        _id: user._id,
        fullName: user.fullName,
        email: user.email,
      },
    });
  } catch (error) {
    res.status(400).json({ status: 'fail', message: error.message });
  }
};

// Đăng nhập
exports.login = async (req, res) => {
  try {
    const { email, password } = req.body;

    const user = await User.findOne({ email });
    if (!user || !user.password || !(await bcrypt.compare(password, user.password))) {
      return res.status(401).json({ status: 'fail', message: 'Email hoặc mật khẩu không đúng' });
    }

    const token = generateToken(user._id);

    res.status(200).json({
      status: 'success',
      token,
      user: {
        _id: user._id,
        fullName: user.fullName,
        email: user.email,
      },
    });
  } catch (error) {
    res.status(400).json({ status: 'fail', message: error.message });
  }
};

// Lấy thông tin tài khoản hiện tại
exports.getMe = async (req, res) => {
  try {
    const user = await User.findById(req.user._id).select('-password');
    if (!user) {
      return res.status(404).json({ status: 'fail', message: 'Không tìm thấy thông tin người dùng' });
    }
    res.status(200).json({ status: 'success', data: user });
  } catch (error) {
    res.status(500).json({ status: 'fail', message: error.message });
  }
};