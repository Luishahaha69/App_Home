import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MyApp());
}

const backendBase = 'http://10.0.2.2:3000'; // Use 10.0.2.2 for Android emulator. For Codespaces adjust accordingly.

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sports Store',
      theme: ThemeData(
        primarySwatch: Colors.green,
        scaffoldBackgroundColor: Colors.white,
      ),
      home: LoginScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class LoginScreen extends StatefulWidget {
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController(text: 'user@example.com');
  final _passCtrl = TextEditingController(text: 'password');

  bool _loading = false;
  String? _error;

  Future<void> _login() async {
    setState(() { _loading = true; _error = null; });
    try {
      final res = await http.post(Uri.parse('\$backendBase/login'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'email': _emailCtrl.text, 'password': _passCtrl.text}));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', data['token']);
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomeScreen()));
      } else {
        setState(() { _error = 'Login failed (\${res.statusCode})'; });
      }
    } catch (e) {
      setState(() { _error = 'Error: \$e'; });
    } finally {
      setState(() { _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child:
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Spacer(),
              Text('Welcome back,', style: TextStyle(fontSize: 18)),
              SizedBox(height: 6),
              Text('Athlete', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
              SizedBox(height: 30),
              TextField(controller: _emailCtrl, decoration: InputDecoration(labelText: 'Email')),
              SizedBox(height: 12),
              TextField(controller: _passCtrl, decoration: InputDecoration(labelText: 'Password'), obscureText: true),
              SizedBox(height: 20),
              _error != null ? Text(_error!, style: TextStyle(color: Colors.red)) : SizedBox.shrink(),
              ElevatedButton(
                onPressed: _loading ? null : _login,
                child: _loading ? CircularProgressIndicator(color: Colors.white) : Text('Sign in'),
              ),
              Spacer(flex: 2),
              Text('Use this simple login to get a token from the backend.'),
            ],
          ),
        )
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List categories = [];
  List products = [];
  Map? promo;
  bool loading = true;
  String? token;

  @override
  void initState() {
    super.initState();
    _loadTokenAndFetch();
  }

  Future<void> _loadTokenAndFetch() async {
    final prefs = await SharedPreferences.getInstance();
    token = prefs.getString('token');
    if (token == null) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => LoginScreen()));
      return;
    }
    await fetchAll();
  }

  Future<void> fetchAll() async {
    setState(() { loading = true; });
    try {
      final headers = {'Authorization': 'Bearer \$token'};
      final cRes = await http.get(Uri.parse('\$backendBase/api/categories'), headers: headers);
      final pRes = await http.get(Uri.parse('\$backendBase/api/products'), headers: headers);
      final promoRes = await http.get(Uri.parse('\$backendBase/api/promotions'), headers: headers);

      if (cRes.statusCode == 401 || pRes.statusCode == 401) {
        // token expired or invalid
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('token');
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => LoginScreen()));
        return;
      }

      categories = cRes.statusCode == 200 ? jsonDecode(cRes.body) : [];
      products = pRes.statusCode == 200 ? jsonDecode(pRes.body) : [];
      final promos = promoRes.statusCode == 200 ? jsonDecode(promoRes.body) : [];
      promo = promos.isNotEmpty ? promos[0] : null;
    } catch (e) {
      print('Fetch error: \$e');
    } finally {
      setState(() { loading = false; });
    }
  }

  Widget buildCategoryChip(Map cat) {
    return Container(
      margin: EdgeInsets.only(right: 12),
      padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(cat['name']),
    );
  }

  Widget buildProductCard(Map prod) {
    return Container(
      width: 160,
      margin: EdgeInsets.only(right: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 110,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.grey[200],
              image: DecorationImage(
                image: NetworkImage(prod['image']),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SizedBox(height: 8),
          Text(prod['name'], style: TextStyle(fontWeight: FontWeight.bold)),
          Text('\$\${prod['price']}', style: TextStyle(color: Colors.grey[700])),
          SizedBox(height: 6),
          Row(
            children: [
              Expanded(child: ElevatedButton(onPressed: () {}, child: Text('Buy'))),
            ],
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: loading ? Center(child: CircularProgressIndicator()) : SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // top row: greeting + search
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Welcome back,', style: TextStyle(fontSize: 16)),
                    Text('Athlete', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  ]),
                  IconButton(onPressed: () {}, icon: Icon(Icons.search))
                ],
              ),
              SizedBox(height: 16),
              // promo banner
              if (promo != null)
                Container(
                  height: 120,
                  padding: EdgeInsets.all(14),
                  decoration: BoxDecoration(
                      color: Colors.green[100],
                      borderRadius: BorderRadius.circular(16),
                      image: promo!['image'] != null ? null : null
                  ),
                  child: Row(
                    children: [
                      Expanded(child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(promo!['title'], style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                          SizedBox(height: 8),
                          Text(promo!['subtitle'] ?? '', style: TextStyle(fontSize: 12)),
                          SizedBox(height: 8),
                          ElevatedButton(onPressed: () {}, child: Text('Shop now'))
                        ],
                      )),
                      SizedBox(width: 12),
                      Container(
                        width: 80,
                        height: 80,
                        child: Image.network(promo!['image'] ?? 'https://via.placeholder.com/80'),
                      )
                    ],
                  ),
                ),
              SizedBox(height: 18),
              // categories horizontal
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text('Categories', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                TextButton(onPressed: () {}, child: Text('See all'))
              ]),
              SizedBox(height: 8),
              Container(
                height: 44,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: categories.map<Widget>((c) => buildCategoryChip(c)).toList(),
                ),
              ),
              SizedBox(height: 18),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text('New arrivals', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                TextButton(onPressed: () {}, child: Text('See all'))
              ]),
              SizedBox(height: 12),
              Container(
                height: 220,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: products.map<Widget>((p) => buildProductCard(p)).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
