import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Tienda Deportiva',
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade50,
      appBar: AppBar(
        title: const Text('Tienda Deportiva'),
        backgroundColor: Colors.blue,
      ),
      body: GridView.count(
        crossAxisCount: 2,
        padding: const EdgeInsets.all(16),
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        children: const [
          ProductCard(name: 'Balón de Fútbol', price: '\$120.000', image: 'https://cdn-icons-png.flaticon.com/512/833/833314.png'),
          ProductCard(name: 'Zapatillas Deportivas', price: '\$250.000', image: 'https://cdn-icons-png.flaticon.com/512/679/679922.png'),
          ProductCard(name: 'Guantes de Gimnasio', price: '\$80.000', image: 'https://cdn-icons-png.flaticon.com/512/684/684908.png'),
        ],
      ),
    );
  }
}

class ProductCard extends StatelessWidget {
  final String name;
  final String price;
  final String image;

  const ProductCard({super.key, required this.name, required this.price, required this.image});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.network(image, height: 80),
          const SizedBox(height: 8),
          Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(price, style: const TextStyle(color: Colors.blueAccent)),
        ],
      ),
    );
  }
}
