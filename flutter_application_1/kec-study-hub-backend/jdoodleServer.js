// jdoodleServer.js
const express = require('express');
const axios = require('axios');
const cors = require('cors');

const app = express();
app.use(cors()); // Enable CORS for all routes
app.use(express.json());

app.post('/execute', async (req, res) => {
    try {
        const response = await axios.post('https://api.jdoodle.com/v1/execute', req.body);
        res.json(response.data);
    } catch (error) {
        res.status(500).json({ error: 'Failed to execute code' });
    }
});

const PORT = 2001;
app.listen(PORT, () => {
    console.log(`JDoodle Server running on http://localhost:${PORT}`);
});