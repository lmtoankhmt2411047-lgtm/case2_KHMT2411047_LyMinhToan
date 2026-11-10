const jwt = require('jsonwebtoken');

exports.protect = async (req, res, next) => {
  let token;

  if (
    req.headers.authorization &&
    req.headers.authorization.startsWith('Bearer')
  ) {
    token = req.headers.authorization.split(' ')[1];
  }

  if (!token) {
    return res.status(401).json({
      status: 'fail',
      message: 'Bạn chưa đăng nhập! Vui lòng đăng nhập để truy cập.',
    });
  }

  try {
    const decoded = jwt.verify(token, process.env.JWT_SECRET || 'secret_key');
    req.user = { _id: decoded.id || decoded._id };
    next();
  } catch (error) {
    return res.status(401).json({
      status: 'fail',
      message: 'Token không hợp lệ hoặc đã hết hạn!',
    });
  }
};