# Backend (Node.js + Express)

This simple backend provides protected endpoints for categories, products and promotions.

Install:
1. cd backend
2. npm install

Run:
1. node index.js
2. POST /login with JSON { "email": "user@example.com", "password": "password" } to get a token.
3. Use header Authorization: Bearer <token> to access /api/categories, /api/products, /api/promotions
