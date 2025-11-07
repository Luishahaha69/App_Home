import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Tienda Deportiva',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  final List<Map<String, String>> products = [
    {'name': 'Balón de fútbol', 'image': 'https://upload.wikimedia.org/wikipedia/commons/e/ec/Soccer_ball.svg'},
    {'name': 'Zapatillas deportivas', 'image': 'https://upload.wikimedia.org/wikipedia/commons/9/9e/Running_shoes.png'},
    {'name': 'Guantes de portero', 'image': 'https://upload.wikimedia.org/wikipedia/commons/d/d3/Goalkeeper_gloves.svg'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tienda Deportiva'),
      ),
      body: GridView.builder(
        padding: EdgeInsets.all(10),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
        ),
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];
          return Card(
            elevation: 3,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.network(product['image']!, height: 80),
                SizedBox(height: 10),
                Text(product['name']!, style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          );
        },
      ),
    );
  }
}


