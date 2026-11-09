const jwt = require('jsonwebtoken');

const authMiddleware = (req, res, next) => {
    // Lấy token từ header
    const token = req.header('Authorization');

    if (!token) {
        return res.status(401).json({ message: 'Không có token, từ chối truy cập!' });
    }

    try {
        // Xác thực token
        const decoded = jwt.verify(token.replace('Bearer ', ''), process.env.JWT_SECRET);
        req.user = decoded;
        next();
    } catch (error) {
        res.status(401).json({ message: 'Token không hợp lệ hoặc đã hết hạn!' });
    }
};

module.exports = authMiddleware;