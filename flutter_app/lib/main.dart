import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

const backendBase = 'http://musical-space-couscous-7v46w6xw95gqhrvgx-3000.app.github.dev';


class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sports Store',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.grey[50],
      ),
      home: const LoginScreen(),
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailCtrl = TextEditingController(text: 'user@example.com');
  final passCtrl = TextEditingController(text: 'password');
  bool loading = false;
  String? error;

  Future<void> _login() async {
    setState(() {
      loading = true;
      error = null;
    });
    try {
      final res = await http.post(
        Uri.parse('$backendBase/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': emailCtrl.text.trim(), 'password': passCtrl.text.trim()}),
      );
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final token = data['token'];
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token);
        if (!mounted) return;
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomeScreen(token: token)));
      } else {
        setState(() {
          error = 'Credenciales incorrectas (${res.statusCode})';
        });
      }
    } catch (e) {
      setState(() {
        error = 'Error de conexión';
      });
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24),
          child: Column(
            children: [
              const SizedBox(height: 8),
              const Icon(Icons.sports_soccer, size: 84, color: Colors.blue),
              const SizedBox(height: 12),
              const Text('Sports Store', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
              const SizedBox(height: 28),
              TextField(controller: emailCtrl, decoration: const InputDecoration(labelText: 'Correo electrónico')),
              const SizedBox(height: 12),
              TextField(controller: passCtrl, decoration: const InputDecoration(labelText: 'Contraseña'), obscureText: true),
              const SizedBox(height: 18),
              if (error != null) Text(error!, style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 6),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: loading ? null : _login,
                  style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                  child: loading ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text('Iniciar sesión'),
                ),
              ),
              const Spacer(),
              const Text('Usa user@example.com / password para probar'),
            ],
          ),
        ),
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  final String token;
  const HomeScreen({super.key, required this.token});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List categories = [];
  List products = [];
  Map? promo;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchAll();
  }

  Future<void> fetchAll() async {
    setState(() => loading = true);
    try {
      final headers = {'Authorization': 'Bearer ${widget.token}'};
      final cRes = await http.get(Uri.parse('$backendBase/api/categories'), headers: headers);
      final pRes = await http.get(Uri.parse('$backendBase/api/products'), headers: headers);
      final promoRes = await http.get(Uri.parse('$backendBase/api/promotions'), headers: headers);
      if (cRes.statusCode == 401 || pRes.statusCode == 401) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('token');
        if (!mounted) return;
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
        return;
      }
      categories = cRes.statusCode == 200 ? jsonDecode(cRes.body) : [];
      products = pRes.statusCode == 200 ? jsonDecode(pRes.body) : [];
      final promos = promoRes.statusCode == 200 ? jsonDecode(promoRes.body) : [];
      promo = promos.isNotEmpty ? promos[0] : null;
    } catch (e) {
      // ignore network errors silently in UI; show empty lists
    } finally {
      setState(() => loading = false);
    }
  }

  Widget categoryChip(Map cat) {
    return Container(
      margin: const EdgeInsets.only(right: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(20)),
      child: Text(cat['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.w600)),
    );
  }

  Widget productCard(Map p) {
    final image = p['image'] ?? 'https://via.placeholder.com/300x200?text=Product';
    return Container(
      width: 170,
      margin: const EdgeInsets.only(right: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 110,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: Colors.grey[200]),
            clipBehavior: Clip.hardEdge,
            child: Image.network(image, fit: BoxFit.cover, width: double.infinity, errorBuilder: (_, __, ___) => const Icon(Icons.broken_image)),
          ),
          const SizedBox(height: 8),
          Text(p['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text('\$${p['price']}', style: TextStyle(color: Colors.grey[800])),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(onPressed: () {}, child: const Text('Comprar')),
          )
        ],
      ),
    );
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    if (!mounted) return;
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inicio'),
        backgroundColor: Colors.blue,
        actions: [IconButton(onPressed: () => fetchAll(), icon: const Icon(Icons.refresh)), IconButton(onPressed: logout, icon: const Icon(Icons.logout))],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('¡Hola, atleta!', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  if (promo != null)
                    Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      elevation: 2,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        child: Row(children: [
                          Expanded(
                              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(promo!['title'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            const SizedBox(height: 6),
                            Text(promo!['subtitle'] ?? '', style: const TextStyle(fontSize: 13)),
                            const SizedBox(height: 8),
                            ElevatedButton(onPressed: () {}, child: const Text('Ver promoción'))
                          ])),
                          const SizedBox(width: 12),
                          SizedBox(width: 80, height: 80, child: Image.network(promo!['image'] ?? 'https://via.placeholder.com/80', fit: BoxFit.cover))
                        ]),
                      ),
                    ),
                  const SizedBox(height: 16),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    const Text('Categorías', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    TextButton(onPressed: () {}, child: const Text('Ver todas'))
                  ]),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 44,
                    child: ListView(scrollDirection: Axis.horizontal, children: categories.map<Widget>((c) => categoryChip(c)).toList()),
                  ),
                  const SizedBox(height: 18),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    const Text('Productos destacados', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    TextButton(onPressed: () {}, child: const Text('Ver todos'))
                  ]),
                  const SizedBox(height: 12),
                  SizedBox(height: 220, child: ListView(scrollDirection: Axis.horizontal, children: products.map<Widget>((p) => productCard(p)).toList())),
                ]),
              ),
            ),
    );
  }
}
