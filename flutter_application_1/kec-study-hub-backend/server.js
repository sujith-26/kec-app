const express = require('express');
const dotenv = require('dotenv');
const cors = require('cors');
const connectDB = require('./config/db');
const multer = require('multer');
const path = require('path');

dotenv.config();
connectDB();

const app = express();
app.use(cors());
app.use(express.json());

// Multer setup for file uploads
const storage = multer.diskStorage({
  destination: './uploads/',
  filename: (req, file, cb) => {
    cb(null, `${Date.now()}-${file.originalname}`);
  },
});
const upload = multer({ storage });

// Serve uploaded files statically
app.use('/uploads', express.static(path.join(__dirname, 'uploads')));

// Routes
app.use('/api/users', require('./routes/userRoutes')); // Existing user routes
app.use('/api/resources', upload.single('file'), require('./routes/resourceRoutes'));
app.use('/study-materials', require('./routes/studyMaterialRoutes'));
app.use('/forum-posts', require('./routes/forumPostRoutes'));
app.use('/report-material', require('./routes/reportRoutes'));
app.use('/user-materials', require('./routes/userMaterialRoutes'));
app.use('/reports', require('./routes/reportRoutes'));

// Root endpoint
app.get('/', (req, res) => {
  res.send('KEC Study Hub API is running...');
});

const PORT = process.env.PORT || 5000;
app.listen(PORT, () => console.log(`Server running on port ${PORT}`));