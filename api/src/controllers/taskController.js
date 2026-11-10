const Task = require('../models/Task');
const TaskShare = require('../models/TaskShare');
const TaskActivity = require('../models/TaskActivity');

// @desc    Tạo công việc mới
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

    // Lưu lịch sử hoạt động
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

// @desc    Cập nhật công việc
// @route   PUT /api/tasks/:id
// @access  Private (Người tạo, Người được giao hoặc Người có quyền editor)
exports.updateTask = async (req, res) => {
  try {
    const task = await Task.findById(req.params.id);
    if (!task) {
      return res.status(404).json({ message: 'Không tìm thấy công việc' });
    }

    // Kiểm tra quyền: Người tạo, người phụ trách, hoặc người được chia sẻ quyền editor
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

    // Lưu lịch sử hoạt động
    await TaskActivity.create({
      taskId: task._id,
      userId: req.user._id,
      action: 'Chỉnh sửa công việc',
      details: req.body
    });

    res.json({ message: 'Cập nhật thành công', task: updatedTask });
  } catch (error) {
    res.status(500).json({ message: 'Lỗi khi cập nhật công việc', error: error.message });
  }
};

// @desc    Xóa công việc
// @route   DELETE /api/tasks/:id
// @access  Private (Chỉ duy nhất người tạo công việc createdBy được xóa)
exports.deleteTask = async (req, res) => {
  try {
    const task = await Task.findById(req.params.id);
    if (!task) {
      return res.status(404).json({ message: 'Không tìm thấy công việc' });
    }

    // CHỈ người tạo (createdBy) mới được xóa công việc
    if (task.createdBy.toString() !== req.user._id.toString()) {
      return res.status(403).json({ message: 'Chỉ người tạo mới có quyền xóa công việc này' });
    }

    await Task.findByIdAndDelete(req.params.id);
    await TaskShare.deleteMany({ taskId: req.params.id }); // Xóa luôn các bản ghi chia sẻ liên quan

    res.json({ message: 'Xóa công việc thành công' });
  } catch (error) {
    res.status(500).json({ message: 'Lỗi khi xóa công việc', error: error.message });
  }
};