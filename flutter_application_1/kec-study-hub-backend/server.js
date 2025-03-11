const express = require('express');
const dotenv = require('dotenv');
const cors = require('cors');
const mongoose = require('mongoose');
const multer = require('multer');
const path = require('path');
const Filter = require('bad-words');
const { GoogleGenerativeAI } = require('@google/generative-ai');

// Load environment variables
dotenv.config();

// MongoDB Connection
mongoose.connect(process.env.MONGO_URI || 'mongodb+srv://mmuralikarthick123:murali555@clusterkechub.u7r0o.mongodb.net/kec-study-hub?retryWrites=true&w=majority&appName=Clusterkechub', {
  useNewUrlParser: true,
  useUnifiedTopology: true,
})
  .then(() => console.log('Connected to MongoDB (KEC Study Hub)'))
  .catch(err => console.log('MongoDB connection error:', err));

// Initialize Express app
const app = express();

// Middleware
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Serve static files
app.use('/uploads', express.static(path.join(__dirname, 'uploads')));
app.use(express.static('public')); // For chatbot HTML and static files

// Multer setup for file uploads
const storage = multer.diskStorage({
  destination: './uploads/',
  filename: (req, file, cb) => {
    cb(null, `${Date.now()}-${file.originalname}`);
  },
});
const upload = multer({ storage });

// Message Schema for Discussion Forum
const messageSchema = new mongoose.Schema({
  sender: String,
  content: String,
  timestamp: { type: Date, default: Date.now },
  isGlobal: Boolean,
});

const Message = mongoose.model('Message', messageSchema);

// Initialize the profanity filter
const filter = new Filter();

// Google Generative AI Setup
const API_KEY = process.env.GOOGLE_AI_API_KEY || 'YOUR_API_KEY_HERE'; // Replace with your actual API key
const genAI = new GoogleGenerativeAI(API_KEY);

// Routes for KEC Study Hub
app.use('/api/users', require('./routes/userRoutes'));
app.use('/api/resources', upload.single('file'), require('./routes/resourceRoutes'));
app.use('/study-materials', require('./routes/studyMaterialRoutes'));
app.use('/forum-posts', require('./routes/forumPostRoutes'));
app.use('/report-material', require('./routes/reportRoutes'));
app.use('/user-materials', require('./routes/userMaterialRoutes'));
app.use('/reports', require('./routes/reportRoutes'));
app.use('/exam-dates', require('./routes/examDateRoutes'));

// Routes for Discussion Forum
app.get('/api/messages/global', async (req, res) => {
  try {
    const messages = await Message.find({ isGlobal: true }).sort({ timestamp: -1 });
    res.json(messages);
  } catch (error) {
    res.status(500).json({ message: 'Error fetching global messages', error });
  }
});

app.get('/api/messages/department/:department', async (req, res) => {
  const { department } = req.params;
  try {
    const messages = await Message.find({ 
      isGlobal: false, 
      sender: { $regex: department, $options: 'i' } 
    }).sort({ timestamp: -1 });
    res.json(messages);
  } catch (error) {
    res.status(500).json({ message: 'Error fetching department messages', error });
  }
});

app.post('/api/messages', async (req, res) => {
  let { sender, content, isGlobal } = req.body;

  // Apply profanity filter
  if (filter.isProfane(content)) {
    return res.status(400).json({ 
      message: 'Failed to send message. Content contains inappropriate language.' 
    });
  }

  try {
    const message = new Message({ sender, content, isGlobal });
    await message.save();
    res.json(message);
  } catch (error) {
    res.status(500).json({ message: 'Error saving message', error });
  }
});

// Chatbot Endpoint
app.post('/chat', async (req, res) => {
  const userMessage = req.body.message;
  if (userMessage) {
    try {
      const model = genAI.getGenerativeModel({ model: "gemini-1.5-flash" });
      const result = await model.generateContent([userMessage]);
      const reply = result.response.text();
      res.json({ reply });
    } catch (error) {
      console.error("Error:", error);
      res.status(500).json({ error: "An error occurred while processing your request." });
    }
  } else {
    res.status(400).json({ error: "No message provided." });
  }
});

// Serve the chatbot HTML file (if needed)
app.get('/c', (req, res) => {
  res.sendFile(path.join(__dirname, 'public', 'chatbot.html'));
});

// Root endpoint
app.get('/', (req, res) => {
  res.send('KEC Study Hub and Discussion Forum API is running...');
});

// Error handling middleware
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).json({ message: 'Something went wrong!', error: err.message });
});

// Start the server
const PORT = process.env.PORT || 5000;
app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});