const Task = require('../models/Task');
const TaskShare = require('../models/TaskShare');
const TaskActivity = require('../models/TaskActivity');

// @desc    Tạo công việc mới (B1)
// @route   POST /api/tasks
// @access  Private
exports.createTask = async (req, res) => {
  try {
    const { title, description, startDate, dueDate, priority, status } = req.body;

    if (!title) {
      return res.status(400).json({ message: 'Tên công việc không được để trống' });
    }

    const newTask = new Task({
      title,
      description,
      startDate,
      dueDate,
      priority: priority || 'medium',
      status: status || 'todo',
      createdBy: req.user._id
    });

    const savedTask = await newTask.save();

    // Ghi nhật ký hoạt động
    await TaskActivity.create({
      taskId: savedTask._id,
      userId: req.user._id,
      action: 'Tạo công việc',
      details: { title: savedTask.title }
    });

    res.status(201).json({
      success: true,
      message: 'Tạo công việc thành công',
      data: savedTask
    });
  } catch (error) {
    res.status(500).json({ message: 'Lỗi server khi tạo công việc', error: error.message });
  }
};

// @desc    Lấy danh sách công việc của người dùng (B2)
// @route   GET /api/tasks
// @access  Private
exports.getTasks = async (req, res) => {
  try {
    const userId = req.user._id;

    // Lấy danh sách taskIds được chia sẻ
    const sharedRecords = await TaskShare.find({ userId }).select('taskId');
    const sharedTaskIds = sharedRecords.map(record => record.taskId);

    // Lấy danh sách công việc do user tạo, được giao, hoặc được chia sẻ
    const tasks = await Task.find({
      $or: [
        { createdBy: userId },
        { assigneeIds: userId },
        { _id: { $in: sharedTaskIds } }
      ]
    }).sort({ createdAt: -1 });

    res.json({ success: true, data: tasks });
  } catch (error) {
    res.status(500).json({ message: 'Lỗi khi lấy danh sách công việc', error: error.message });
  }
};

// @desc    Xem chi tiết 1 công việc (B2)
// @route   GET /api/tasks/:id
// @access  Private
exports.getTaskById = async (req, res) => {
  try {
    const task = await Task.findById(req.params.id)
      .populate('createdBy', 'fullName email')
      .populate('assigneeIds', 'fullName email');

    if (!task) {
      return res.status(404).json({ message: 'Không tìm thấy công việc' });
    }

    res.json({ success: true, data: task });
  } catch (error) {
    res.status(500).json({ message: 'Lỗi khi lấy chi tiết công việc', error: error.message });
  }
};

// @desc    Cập nhật thông tin/trạng thái công việc (B2)
// @route   PUT /api/tasks/:id
// @access  Private (Người tạo, Người được giao hoặc Người có quyền editor)
exports.updateTask = async (req, res) => {
  try {
    const task = await Task.findById(req.params.id);
    if (!task) {
      return res.status(404).json({ message: 'Không tìm thấy công việc' });
    }

    // Kiểm tra phân quyền chỉnh sửa
    const isOwner = task.createdBy.toString() === req.user._id.toString();
    const isAssignee = task.assigneeIds?.some(id => id.toString() === req.user._id.toString());
    const hasEditorShare = await TaskShare.exists({
      taskId: task._id,
      userId: req.user._id,
      permission: 'editor'
    });

    if (!isOwner && !isAssignee && !hasEditorShare) {
      return res.status(403).json({ message: 'Bạn không có quyền chỉnh sửa công việc này' });
    }

    const updatedTask = await Task.findByIdAndUpdate(
      req.params.id,
      { $set: req.body, updatedAt: Date.now() },
      { new: true }
    );

    // Ghi nhật ký hoạt động
    await TaskActivity.create({
      taskId: task._id,
      userId: req.user._id,
      action: 'Chỉnh sửa công việc',
      details: req.body
    });

    res.json({ success: true, message: 'Cập nhật công việc thành công', data: updatedTask });
  } catch (error) {
    res.status(500).json({ message: 'Lỗi khi cập nhật công việc', error: error.message });
  }
};

// @desc    Xóa công việc (B3)
// @route   DELETE /api/tasks/:id
// @access  Private (Chỉ duy nhất người tạo createdBy được xóa)
exports.deleteTask = async (req, res) => {
  try {
    const task = await Task.findById(req.params.id);
    if (!task) {
      return res.status(404).json({ message: 'Không tìm thấy công việc' });
    }

    // Chỉ cho phép chính người tạo công việc xóa
    if (task.createdBy.toString() !== req.user._id.toString()) {
      return res.status(403).json({ message: 'Chỉ người tạo mới có quyền xóa công việc này' });
    }

    await Task.findByIdAndDelete(req.params.id);
    await TaskShare.deleteMany({ taskId: req.params.id });

    res.json({ success: true, message: 'Xóa công việc thành công' });
  } catch (error) {
    res.status(500).json({ message: 'Lỗi khi xóa công việc', error: error.message });
  }
};