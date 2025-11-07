const express = require('express');
const cors = require('cors');
const bodyParser = require('body-parser');
const jwt = require('jsonwebtoken');

const app = express();
app.use(cors());
app.use(bodyParser.json());

const JWT_SECRET = 'replace_this_with_a_strong_secret';
const PORT = process.env.PORT || 3000;

// demo users (in real applications use a DB)
const users = [{ id: 1, email: 'user@example.com', password: 'password', name: 'Athlete' }];

// sample data
const categories = [
  { id: 1, name: 'Running' },
  { id: 2, name: 'Football' },
  { id: 3, name: 'Gym' },
  { id: 4, name: 'Yoga' },
  { id: 5, name: 'Cycling' }
];

const products = [
  { id: 1, name: 'Running Shoes', price: 79.99, image: 'https://via.placeholder.com/300x200?text=Running+Shoes' },
  { id: 2, name: 'Soccer Ball', price: 29.99, image: 'https://via.placeholder.com/300x200?text=Soccer+Ball' },
  { id: 3, name: 'Gym Gloves', price: 19.50, image: 'https://via.placeholder.com/300x200?text=Gym+Gloves' },
  { id: 4, name: 'Water Bottle', price: 9.99, image: 'https://via.placeholder.com/300x200?text=Bottle' }
];

const promotions = [
  { id: 1, title: 'Summer Training Gear', subtitle: 'Up to 20% off selected items', image: 'https://via.placeholder.com/120x120?text=Promo' }
];

function authenticateToken(req, res, next) {
  const auth = req.headers['authorization'];
  if (!auth) return res.status(401).json({ error: 'No token' });
  const parts = auth.split(' ');
  if (parts.length !== 2) return res.status(401).json({ error: 'Malformed token' });
  const token = parts[1];
  jwt.verify(token, JWT_SECRET, (err, user) => {
    if (err) return res.status(401).json({ error: 'Invalid token' });
    req.user = user;
    next();
  });
}

app.post('/login', (req, res) => {
  const { email, password } = req.body;
  const user = users.find(u => u.email === email && u.password === password);
  if (!user) return res.status(401).json({ error: 'Invalid credentials' });
  const token = jwt.sign({ id: user.id, email: user.email, name: user.name }, JWT_SECRET, { expiresIn: '1h' });
  res.json({ token });
});

app.get('/api/categories', authenticateToken, (req, res) => {
  res.json(categories);
});

app.get('/api/products', authenticateToken, (req, res) => {
  res.json(products);
});

app.get('/api/promotions', authenticateToken, (req, res) => {
  res.json(promotions);
});

app.listen(PORT, () => {
  console.log('Server running on port', PORT);
  console.log('Use POST /login with {"email":"user@example.com","password":"password"} to obtain a token.');
});
