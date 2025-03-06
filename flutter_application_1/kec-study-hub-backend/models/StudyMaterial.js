const mongoose = require('mongoose');

const studyMaterialSchema = new mongoose.Schema({
  subjectName: { type: String, required: true },
  courseCode: { type: String, required: true },
  materialType: { type: String, required: true },
  semester: { type: String, required: true },
  description: { type: String, default: '' },
  department: { type: String, required: true },
  year: { type: String, required: true },
  fileUrl: { type: String, required: true },
  uploadedBy: { type: String, required: true },
  uploadedAt: { type: Date, default: Date.now },
  reportCount: { type: Number, default: 0 },
});

module.exports = mongoose.model('StudyMaterial', studyMaterialSchema);