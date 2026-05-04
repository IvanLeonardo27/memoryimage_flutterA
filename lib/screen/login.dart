import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart';
import 'dart:convert' ;

// Data User, perlu diubah jadi shared pref
final List<Map<String, String>> users = [
  {"username": "admin", "score":"1"},
  {"username": "budi", "score":"1"},
  {"username": "andi", "score":"1"},
];

// Muat users dari SharedPreferences saat app start
Future<void> loadUsers() async {
  final prefs = await SharedPreferences.getInstance();
  final saved = prefs.getStringList('users');
  if (saved != null) {
    users.clear();
    for (String item in saved) {
      users.add(Map<String, String>.from(jsonDecode(item)));
    }
  }
}

// Simpan users ke SharedPreferences
Future<void> saveUsers() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setStringList('users', users.map((u) => jsonEncode(u)).toList());
}

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Login();
  }
}

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<StatefulWidget> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  String username = "";

  Map<String, String> getOrCreateUser(String u) {
  for (var user in users) {
    if (user["username"] == u.trim()) {
      return user; 
    }
  }

  final newUser = {
    "username": u.trim(),
    "score": "0",
  };

  users.add(newUser);
  return newUser;
}

  void doLogin() async {
    if (username.isEmpty) {
      showMsg("Isi username mu");
      return;
    }

    final userData = getOrCreateUser(username);

      final prefs = await SharedPreferences.getInstance();

      String uname = userData["username"]!;
      String uscore = userData["score"]!;

      await prefs.setString("username", uname);
      await prefs.setString("score", uscore);
      await saveUsers(); 

      active_user = uname;
      score_user = uscore;

      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const MyHomePage()),
          (route) => false,
        );
      }
    // if (userData != null) {
    // } else {
    //   showMsg("Username salah");
    // }
  }

  void showMsg(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
            // colors: [Colors.white, Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo/Icon dengan efek shadow
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.auto_awesome, size: 80, color: Colors.amber),
              ),
              const SizedBox(height: 24),
              const Text(
                "Memory Master",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 40),
              // Input Field Glassmorphism
              TextField(
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: "Enter your username",
                  hintStyle: const TextStyle(color: Colors.white54),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.05),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  prefixIcon: const Icon(Icons.person_outline, color: Colors.amber),
                ),
                onChanged: (v) => username = v,
              ),
              const SizedBox(height: 24),
              // Main Button
              ElevatedButton(
                onPressed: doLogin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  foregroundColor: Colors.black87,
                  minimumSize: const Size(double.infinity, 55),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: const Text("LOGIN", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
