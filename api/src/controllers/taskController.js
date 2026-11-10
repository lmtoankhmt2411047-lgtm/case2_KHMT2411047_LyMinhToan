const Task = require('../models/Task');
const TaskActivity = require('../models/TaskActivity');
const User = require('../models/User');

// B1: Tạo công việc mới
exports.createTask = async (req, res) => {
  try {
    const { title, description, startDate, dueDate, priority, status } = req.body;

    const task = await Task.create({
      title,
      description,
      startDate,
      dueDate,
      priority: priority || 'medium',
      status: status || 'pending',
      creator: req.user._id,
      assignees: [{ user: req.user._id, isPrimary: true }],
    });

    if (TaskActivity) {
      await TaskActivity.create({
        taskId: task._id,
        userId: req.user._id,
        action: 'Tạo công việc mới',
      });
    }

    res.status(201).json({ status: 'success', data: task });
  } catch (error) {
    res.status(400).json({ status: 'fail', message: error.message });
  }
};

// B2: Lấy danh sách công việc
exports.getTasks = async (req, res) => {
  try {
    const tasks = await Task.find({
      $or: [
        { creator: req.user._id },
        { 'assignees.user': req.user._id },
        { 'sharedWith.user': req.user._id },
      ],
    })
      .populate('creator', 'fullName email')
      .populate('assignees.user', 'fullName email')
      .populate('sharedWith.user', 'fullName email')
      .sort({ createdAt: -1 });

    res.status(200).json({ status: 'success', data: tasks });
  } catch (error) {
    res.status(500).json({ status: 'fail', message: error.message });
  }
};

// B2: Xem chi tiết công việc theo ID
exports.getTaskById = async (req, res) => {
  try {
    const task = await Task.findById(req.params.id)
      .populate('creator', 'fullName email')
      .populate('assignees.user', 'fullName email')
      .populate('sharedWith.user', 'fullName email');

    if (!task) {
      return res.status(404).json({ status: 'fail', message: 'Không tìm thấy công việc' });
    }

    res.status(200).json({ status: 'success', data: task });
  } catch (error) {
    res.status(500).json({ status: 'fail', message: error.message });
  }
};

// B3: Cập nhật công việc
exports.updateTask = async (req, res) => {
  try {
    const task = await Task.findByIdAndUpdate(req.params.id, req.body, {
      new: true,
      runValidators: true,
    });

    if (!task) {
      return res.status(404).json({ status: 'fail', message: 'Không tìm thấy công việc' });
    }

    if (TaskActivity) {
      await TaskActivity.create({
        taskId: task._id,
        userId: req.user._id,
        action: 'Cập nhật thông tin công việc',
      });
    }

    res.status(200).json({ status: 'success', data: task });
  } catch (error) {
    res.status(400).json({ status: 'fail', message: error.message });
  }
};

// B3: Xóa công việc
exports.deleteTask = async (req, res) => {
  try {
    const task = await Task.findByIdAndDelete(req.params.id);

    if (!task) {
      return res.status(404).json({ status: 'fail', message: 'Không tìm thấy công việc' });
    }

    res.status(200).json({ status: 'success', message: 'Đã xóa công việc thành công' });
  } catch (error) {
    res.status(500).json({ status: 'fail', message: error.message });
  }
};

// B4 / E: Xem lịch sử hoạt động
exports.getTaskActivities = async (req, res) => {
  try {
    if (!TaskActivity) {
      return res.status(200).json({ status: 'success', data: [] });
    }

    const activities = await TaskActivity.find({ taskId: req.params.id })
      .populate('userId', 'fullName email')
      .sort({ createdAt: -1 });

    const formattedActivities = activities.map((act) => ({
      _id: act._id,
      taskId: act.taskId,
      userName: act.userId ? (act.userId.fullName || act.userId.email) : 'Người dùng',
      action: act.action,
      createdAt: act.createdAt,
    }));

    res.status(200).json({ status: 'success', data: formattedActivities });
  } catch (error) {
    res.status(500).json({ status: 'fail', message: error.message });
  }
};

// C1: Giao việc cho thành viên qua Email
exports.assignTask = async (req, res) => {
  try {
    const { email, isPrimary } = req.body;
    const targetUser = await User.findOne({ email });

    if (!targetUser) {
      return res.status(404).json({ status: 'fail', message: 'Không tìm thấy người dùng với email này' });
    }

    const task = await Task.findById(req.params.id);
    if (!task) {
      return res.status(404).json({ status: 'fail', message: 'Không tìm thấy công việc' });
    }

    const alreadyAssigned = task.assignees.some(
      (a) => a.user.toString() === targetUser._id.toString()
    );

    if (!alreadyAssigned) {
      task.assignees.push({ user: targetUser._id, isPrimary: isPrimary || false });
      await task.save();

      if (TaskActivity) {
        await TaskActivity.create({
          taskId: task._id,
          userId: req.user._id,
          action: `Giao việc cho ${targetUser.fullName || targetUser.email}`,
        });
      }
    }

    res.status(200).json({ status: 'success', data: task });
  } catch (error) {
    res.status(400).json({ status: 'fail', message: error.message });
  }
};

// C2: Chia sẻ công việc
exports.shareTask = async (req, res) => {
  try {
    const { email, role } = req.body;
    const targetUser = await User.findOne({ email });

    if (!targetUser) {
      return res.status(404).json({ status: 'fail', message: 'Không tìm thấy người dùng với email này' });
    }

    const task = await Task.findById(req.params.id);
    if (!task) {
      return res.status(404).json({ status: 'fail', message: 'Không tìm thấy công việc' });
    }

    const shareIndex = task.sharedWith.findIndex(
      (s) => s.user.toString() === targetUser._id.toString()
    );

    if (shareIndex > -1) {
      task.sharedWith[shareIndex].role = role || 'viewer';
    } else {
      task.sharedWith.push({ user: targetUser._id, role: role || 'viewer' });
    }

    await task.save();

    if (TaskActivity) {
      await TaskActivity.create({
        taskId: task._id,
        userId: req.user._id,
        action: `Chia sẻ công việc cho ${targetUser.fullName || targetUser.email} (Quyền: ${role})`,
      });
    }

    res.status(200).json({ status: 'success', data: task });
  } catch (error) {
    res.status(400).json({ status: 'fail', message: error.message });
  }
};

// C3: Thu hồi quyền chia sẻ
exports.removeShareAccess = async (req, res) => {
  try {
    const { id, userId } = req.params;

    const task = await Task.findById(id);
    if (!task) {
      return res.status(404).json({ status: 'fail', message: 'Không tìm thấy công việc' });
    }

    task.sharedWith = task.sharedWith.filter(
      (s) => s.user.toString() !== userId
    );

    await task.save();

    if (TaskActivity) {
      await TaskActivity.create({
        taskId: task._id,
        userId: req.user._id,
        action: 'Thu hồi quyền chia sẻ công việc',
      });
    }

    res.status(200).json({ status: 'success', message: 'Đã thu hồi quyền thành công' });
  } catch (error) {
    res.status(400).json({ status: 'fail', message: error.message });
  }
};

// E: API Thống kê công việc
exports.getTaskStatistics = async (req, res) => {
  try {
    const userId = req.user._id;
    const now = new Date();

    const tasks = await Task.find({
      $or: [
        { creator: userId },
        { 'assignees.user': userId },
        { 'sharedWith.user': userId },
      ],
    });

    let pending = 0, inProgress = 0, completed = 0;
    let managing = 0, assigned = 0;
    let overdue = 0, dueSoon = 0;

    tasks.forEach((task) => {
      const status = task.status.toLowerCase();
      if (status === 'pending' || status === 'chưa làm') pending++;
      else if (status === 'in_progress' || status === 'đang làm') inProgress++;
      else if (status === 'completed' || status === 'hoàn thành') completed++;

      if (task.creator.toString() === userId.toString()) managing++;

      const isAssigned = task.assignees.some((a) => a.user.toString() === userId.toString());
      if (isAssigned) assigned++;

      if ((status !== 'completed' && status !== 'hoàn thành') && task.dueDate) {
        const dueDate = new Date(task.dueDate);
        const daysDiff = (dueDate - now) / (1000 * 3600 * 24);

        if (daysDiff < 0) {
          overdue++;
        } else if (daysDiff >= 0 && daysDiff <= 3) {
          dueSoon++;
        }
      }
    });

    res.status(200).json({
      status: 'success',
      data: {
        statusStats: { pending, inProgress, completed, total: tasks.length },
        roleStats: { managing, assigned },
        deadlineStats: { overdue, dueSoon }
      }
    });

  } catch (error) {
    res.status(500).json({ status: 'fail', message: error.message });
  }
};