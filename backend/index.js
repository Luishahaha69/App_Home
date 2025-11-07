const express = require('express');
const cors = require('cors');
const app = express();

app.use(cors());
app.use(express.json());


app.get('/', (req, res) => {
  res.send('🏃‍♂️ Backend de deportes corriendo correctamente');
});


app.get('/api/categories', (req, res) => {
  res.json([
    { id: 1, name: 'Fútbol' },
    { id: 2, name: 'Ciclismo' },
    { id: 3, name: 'Tenis' },
    { id: 4, name: 'Natación' },
  ]);
});

app.get('/api/products', (req, res) => {
  res.json([
    {
      id: 1,
      name: 'Balón Adidas Pro',
      price: 35.99,
      image: 'https://images.unsplash.com/photo-1602872028886-96f53b29b6b7',
    },
    {
      id: 2,
      name: 'Guantes de Box Everlast',
      price: 42.50,
      image: 'https://images.unsplash.com/photo-1599058917212-d750089bc07d',
    },
    {
      id: 3,
      name: 'Raqueta Wilson Ultra',
      price: 79.99,
      image: 'https://images.unsplash.com/photo-1505751172876-fa1923c5c528',
    },
  ]);
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => console.log(`Servidor corriendo en puerto ${PORT}`));
