const mongoose = require('mongoose');

const emailLogSchema = new mongoose.Schema(
  {
    to: { type: String, required: true },
    subject: { type: String, required: true },
    content: { type: String, required: true },
    status: { type: String, enum: ['success', 'failed'], required: true },
    error: { type: String, default: null },
  },
  { timestamps: true }
);

module.exports = mongoose.model('EmailLog', emailLogSchema);