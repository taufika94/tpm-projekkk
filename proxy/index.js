require('dotenv').config(); // Load environment variables from .env file
const express = require('express');
const cors = require('cors');
const axios = require('axios');
const bcrypt = require('bcryptjs'); // For password hashing
const jwt = require('jsonwebtoken'); // For JWT token

const fs = require('fs').promises; // For async file operations (to store users)
const USERS_FILE = 'users.json'; // File to store user data

console.log('Checkpoint 1: Setelah require modules'); // CHECKPOINT 1

const app = express();
app.use(cors());
app.use(express.json()); // Enable JSON body parsing for POST requests

console.log('Checkpoint 2: Setelah inisialisasi Express dan CORS'); // CHECKPOINT 2


const JWT_SECRET = process.env.JWT_SECRET;
if (!JWT_SECRET) {
    console.error('FATAL ERROR: JWT_SECRET is not defined in .env file.');
    process.exit(1); // Exit if secret is missing
}

// --- User Management Functions (using a simple JSON file) ---
async function readUsers() {
    try {
        const data = await fs.readFile(USERS_FILE, 'utf8');
        return JSON.parse(data);
    } catch (error) {
        if (error.code === 'ENOENT') { // File not found
            await fs.writeFile(USERS_FILE, JSON.stringify([])); // Create empty file
            return [];
        }
        console.error('Error reading users file:', error);
        return []; // Return empty array on other errors
    }
}

async function writeUsers(users) {
    await fs.writeFile(USERS_FILE, JSON.stringify(users, null, 2)); // Pretty print JSON
}

// --- Authentication Middleware ---
const authenticateToken = (req, res, next) => {
    const authHeader = req.headers['authorization'];
    const token = authHeader && authHeader.split(' ')[1]; // Bearer TOKEN

    if (token == null) {
        return res.sendStatus(401); // No token
    }

    jwt.verify(token, JWT_SECRET, (err, user) => {
        if (err) {
            console.error('JWT verification error:', err);
            return res.sendStatus(403); // Invalid token
        }
        req.user = user;
        next();
    });
};


// Register Endpoint
app.post('/api/register', async (req, res) => {
    const { username, password } = req.body;

    if (!username || !password) {
        return res.status(400).json({ message: 'Username and password are required.' });
    }

    const users = await readUsers();
    if (users.find(u => u.username === username)) {
        return res.status(409).json({ message: 'Username already exists.' });
    }

    try {
        const hashedPassword = await bcrypt.hash(password, 10); // Hash password with salt rounds = 10
        const newUser = { username, password: hashedPassword };
        users.push(newUser);
        await writeUsers(users);
        res.status(201).json({ message: 'User registered successfully.' });
    } catch (err) {
        console.error('Registration error:', err);
        res.status(500).json({ error: err.message });
    }
});

// Login Endpoint
app.post('/api/login', async (req, res) => {
    const { username, password } = req.body;

    if (!username || !password) {
        return res.status(400).json({ message: 'Username and password are required.' });
    }

    const users = await readUsers();
    const user = users.find(u => u.username === username);

    if (!user) {
        return res.status(401).json({ message: 'Invalid credentials.' });
    }

    try {
        const isMatch = await bcrypt.compare(password, user.password);
        if (!isMatch) {
            return res.status(401).json({ message: 'Invalid credentials.' });
        }

        // Generate JWT token
        const token = jwt.sign({ username: user.username }, JWT_SECRET, { expiresIn: '1h' }); // Token valid for 1 hour
        res.json({ message: 'Login successful.', token });

    } catch (err) {
        console.error('Login error:', err);
        res.status(500).json({ error: err.message });
    }
});

// Endpoint untuk mendapatkan semua entri KBBI
app.get('/api/kbbi', async (req, res) => {
  console.log('Request received for /api/kbbi'); // Ini akan muncul kalau endpoint diakses
  try {
    res.json({ message: "Endpoint untuk mendapatkan semua entri KBBI belum diimplementasikan." });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Endpoint untuk mencari entri KBBI berdasarkan kata kunci (PATH PARAMETER)
app.get('/api/kbbi/search/:query', async (req, res) => {
  console.log(`Request received for /api/kbbi/search/${req.params.query}`); // Ini akan muncul kalau endpoint diakses
  try {
    const { query } = req.params;
    console.log(`Searching for path parameter: ${query}`);
    const result = await axios.get(`https://x-labs.my.id/api/kbbi/search/${encodeURIComponent(query)}`);
    res.json(result.data);
  } catch (err) {
    console.error('Error fetching from external API (path param):', err.message);
    res.status(500).json({ error: err.message });
  }
});

// Endpoint untuk mencari entri KBBI dengan query string (QUERY PARAMETER)
app.get('/api/kbbi-query', async (req, res) => {
  console.log(`Request received for /api/kbbi-query with search: ${req.query.search}`); // Ini akan muncul kalau endpoint diakses
  const searchQuery = req.query.search;
  if (searchQuery) {
    try {
      console.log(`Searching for query parameter: ${searchQuery}`);
      const result = await axios.get(`https://x-labs.my.id/api/kbbi/search/${encodeURIComponent(searchQuery)}`);
      res.json(result.data);
    } catch (err) {
      console.error('Error fetching from external API (query param):', err.message);
      res.status(500).json({ error: err.message });
    }
  } else {
    res.status(400).json({ error: "Query parameter 'search' is required." });
  }
});

console.log('Checkpoint 3: Setelah semua route didefinisikan'); // CHECKPOINT 3

// Menjalankan server pada port 3000
const PORT = process.env.PORT || 3001; // Use port from environment variable or default to 3000
app.listen(PORT, () => {
    console.log(`Proxy server running at http://localhost:${PORT}`);
});

console.log('Checkpoint 5: Setelah app.listen call (ini jarang terlihat)'); // CHECKPOINT 5 (ini jarang terlihat)