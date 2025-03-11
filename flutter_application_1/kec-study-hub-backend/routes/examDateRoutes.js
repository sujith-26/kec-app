const express = require('express');
const router = express.Router();
const ExamDate = require('../models/examDate');
const multer = require('multer');
const csv = require('csv-parser');
const fs = require('fs');
const auth = require('../middleware/auth');

// Multer configuration for file uploads
const storage = multer.diskStorage({
  destination: './uploads/',
  filename: (req, file, cb) => {
    cb(null, `${Date.now()}-${file.originalname}`);
  },
});
const upload = multer({ storage });

// Upload exam dates from CSV
router.post('/upload', auth, upload.single('csvFile'), async (req, res) => {
  if (!req.file) {
    return res.status(400).json({ message: 'No file uploaded' });
  }

  console.log('req.user:', req.user); // Debug: Check user object

  const examDates = [];
  fs.createReadStream(req.file.path)
    .pipe(csv())
    .on('data', (row) => {
      const examDate = {
        name: row.name?.trim(),
        date: new Date(row.date),
        uploadedBy: req.user.id, // Changed from req.user.email to req.user.id
      };
      if (examDate.name && !isNaN(examDate.date.getTime())) {
        examDates.push(examDate);
      }
    })
    .on('end', async () => {
      try {
        if (examDates.length === 0) {
          fs.unlinkSync(req.file.path);
          return res.status(400).json({ message: 'No valid exam dates found in CSV' });
        }

        await ExamDate.insertMany(examDates);
        fs.unlinkSync(req.file.path);
        res.status(201).json({ message: 'Exam dates uploaded successfully', count: examDates.length });
      } catch (error) {
        fs.unlinkSync(req.file.path);
        res.status(500).json({ message: 'Error uploading exam dates', error: error.message });
      }
    })
    .on('error', (error) => {
      fs.unlinkSync(req.file.path);
      res.status(500).json({ message: 'Error parsing CSV', error: error.message });
    });
});

// Get all exam dates
router.get('/', auth, async (req, res) => {
  try {
    const examDates = await ExamDate.find().sort({ date: 1 });
    res.status(200).json(examDates);
  } catch (error) {
    res.status(500).json({ message: 'Error fetching exam dates', error: error.message });
  }
});

module.exports = router;