const StudyMaterial = require('../models/StudyMaterial');

const getStudyMaterials = async (req, res) => {
  try {
    const { department, year } = req.query;
    const query = {};
    if (department && department !== 'All') query.department = department;
    if (year) query.year = year;

    const materials = await StudyMaterial.find(query);
    res.json(materials);
  } catch (error) {
    console.error('Error fetching study materials:', error.message);
    res.status(500).json({ message: 'Server error', error: error.message });
  }
};

const uploadStudyMaterial = async (req, res) => {
  const { subjectName, courseCode, materialType, semester, description, department, year, deviceId } = req.body;
  const file = req.file;

  if (!subjectName || !courseCode || !materialType || !semester || !department || !year || !deviceId || !file) {
    return res.status(400).json({ message: 'All fields and file are required' });
  }

  try {
    const fileUrl = `http://localhost:5000/uploads/${file.filename}`;
    const material = await StudyMaterial.create({
      subjectName,
      courseCode,
      materialType,
      semester,
      description: description || '',
      department,
      year,
      fileUrl,
      uploadedBy: deviceId,
    });

    res.status(201).json(material);
  } catch (error) {
    console.error('Error uploading study material:', error.message);
    res.status(500).json({ message: 'Server error', error: error.message });
  }
};

const searchStudyMaterials = async (req, res) => {
  const { query } = req.query;
  if (!query) {
    return res.status(400).json({ message: 'Search query is required' });
  }

  try {
    const materials = await StudyMaterial.find({
      $or: [
        { subjectName: { $regex: query, $options: 'i' } },
        { courseCode: { $regex: query, $options: 'i' } },
        { description: { $regex: query, $options: 'i' } },
      ],
    });
    res.json(materials);
  } catch (error) {
    console.error('Error searching study materials:', error.message);
    res.status(500).json({ message: 'Server error', error: error.message });
  }
};

module.exports = { getStudyMaterials, uploadStudyMaterial, searchStudyMaterials };