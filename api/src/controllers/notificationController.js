const Notification = require('../models/Notification');

// Lấy danh sách thông báo của người dùng hiện tại
exports.getMyNotifications = async (req, res) => {
  try {
    const notifications = await Notification.find({ recipient: req.user._id })
      .populate('task', 'title status priority')
      .sort({ createdAt: -1 });

    res.status(200).json({ status: 'success', data: notifications });
  } catch (error) {
    res.status(500).json({ status: 'fail', message: error.message });
  }
};

// Đánh dấu thông báo đã đọc
exports.markAsRead = async (req, res) => {
  try {
    const notification = await Notification.findByIdAndUpdate(
      req.params.id,
      { isRead: true },
      { new: true }
    );
    res.status(200).json({ status: 'success', data: notification });
  } catch (error) {
    res.status(400).json({ status: 'fail', message: error.message });
  }
};