const express = require('express');
const { getStudyMaterials, uploadStudyMaterial, searchStudyMaterials } = require('../controllers/studyMaterialController');
const authMiddleware = require('../middleware/authMiddleware');
const multer = require('multer');

const storage = multer.diskStorage({
  destination: './uploads/',
  filename: (req, file, cb) => {
    cb(null, `${Date.now()}-${file.originalname}`);
  },
});
const upload = multer({ storage });

const router = express.Router();

router.get('/', authMiddleware, getStudyMaterials);
router.post('/', authMiddleware, upload.single('file'), uploadStudyMaterial);
router.get('/search', authMiddleware, searchStudyMaterials);

module.exports = router;