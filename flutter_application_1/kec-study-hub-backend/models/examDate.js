const mongoose = require('mongoose');

const examDateSchema = new mongoose.Schema({
  name: { type: String, required: true },
  date: { type: Date, required: true },
  uploadedBy: { type: String, required: true }, // Works with user _id as a string
  uploadedAt: { type: Date, default: Date.now },
});

module.exports = mongoose.model('ExamDate', examDateSchema);