import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart';

// Data User
final List<Map<String, String>> users = [
  {"username": "admin"},
  {"username": "budi"},
  {"username": "andi"},
];

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Login',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: Login(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<StatefulWidget> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  String username = "";

  bool checkLogin(String u) {
    for (var user in users) {
      if (user["username"] == u.trim()) {
        return true;
      }
    }
    return false;
  }

  void doLogin() async {
    if (username.isEmpty) {
      showMsg("Isi username mu");
      return;
    }

    bool success = checkLogin(username);

    if (success) {
      final prefs = await SharedPreferences.getInstance();

      await prefs.setString("username", username.trim());
      active_user = username.trim();

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const MyApp()),
        (route) => false,
      );
    } else {
      showMsg("Username salah");
    }
  }

  void showMsg(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login'), centerTitle: true),
      body: Center(
        child: Container(
          height: 300,
          width: 400,
          padding: const EdgeInsets.all(20),
          margin: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(width: 1),
            color: Colors.white,
            boxShadow: const [BoxShadow(blurRadius: 5)],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                decoration: const InputDecoration(labelText: "Username"),
                onChanged: (v) => username = v,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 45,
                child: ElevatedButton(
                  onPressed: doLogin,
                  child: const Text("Login"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
