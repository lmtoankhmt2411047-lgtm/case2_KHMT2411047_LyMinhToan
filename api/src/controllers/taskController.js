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