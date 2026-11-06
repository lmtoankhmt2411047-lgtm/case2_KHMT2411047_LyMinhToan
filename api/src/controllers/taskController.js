exports.createTask = async (req, res) => {
  try {
    const { title, description, startDate, dueDate, priority, status } = req.body;
    const newTask = new Task({
      title, description, startDate, dueDate,
      priority: priority || 'medium',
      status: status || 'todo',
      createdBy: req.user._id
    });
    await newTask.save();
    res.status(201).json({ message: 'Tạo công việc thành công', task: newTask });
  } catch (error) {
    res.status(500).json({ message: 'Lỗi khi tạo công việc', error: error.message });
  }
};
exports.updateTask = async (req, res) => {
  try {
    const updatedTask = await Task.findByIdAndUpdate(
      req.params.id,
      { $set: req.body, updatedAt: Date.now() },
      { new: true }
    );
    res.json({ message: 'Cập nhật thành công', task: updatedTask });
  } catch (error) {
    res.status(500).json({ message: 'Lỗi khi cập nhật công việc', error: error.message });
  }
};
exports.deleteTask = async (req, res) => {
  try {
    await Task.findByIdAndDelete(req.params.id);
    res.json({ message: 'Xóa công việc thành công' });
  } catch (error) {
    res.status(500).json({ message: 'Lỗi khi xóa công việc', error: error.message });
  }
};