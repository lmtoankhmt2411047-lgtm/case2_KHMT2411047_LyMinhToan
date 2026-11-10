const mongoose = require('mongoose');

const taskSchema = new mongoose.Schema(
  {
    title: {
      type: String,
      required: [true, 'Vui lòng nhập tên công việc'],
      trim: true,
    },
    description: {
      type: String,
      default: '',
    },
    startDate: {
      type: Date,
    },
    dueDate: {
      type: Date,
    },
    priority: {
      type: String,
      enum: ['low', 'medium', 'high', 'thấp', 'trung bình', 'cao'],
      default: 'medium',
    },
    status: {
      type: String,
      enum: ['pending', 'in_progress', 'completed', 'chưa làm', 'đang làm', 'hoàn thành'],
      default: 'pending',
    },
    creator: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: true,
    },
    assignees: [
      {
        user: {
          type: mongoose.Schema.Types.ObjectId,
          ref: 'User',
        },
        isPrimary: {
          type: Boolean,
          default: false,
        },
      },
    ],
    sharedWith: [
      {
        user: {
          type: mongoose.Schema.Types.ObjectId,
          ref: 'User',
        },
        role: {
          type: String,
          enum: ['viewer', 'editor'],
          default: 'viewer',
        },
      },
    ],
  },
  {
    timestamps: true,
  }
);

module.exports = mongoose.model('Task', taskSchema);