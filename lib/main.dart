import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screen/login.dart';
import 'screen/highscore.dart';
import 'screen/game.dart';

String active_user = "";

Future<String> checkUser() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString("username") ?? '';
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  final String? username = prefs.getString('username');

  if (username == null) {
    active_user = "";
    runApp(const MemoryBirdApp(initialScreen: LoginScreen()));
  } else {
    active_user = username;
    runApp(const MemoryBirdApp(initialScreen: MyHomePage(title: 'Home')));
  }
}

class MemoryBirdApp extends StatelessWidget {
  final Widget initialScreen;

  const MemoryBirdApp({super.key, required this.initialScreen});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mind Master Memory',
      debugShowCheckedModeBanner: false,
      
      // DESIGN SYSTEM: Menggunakan tema modern & clean
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1E293B),
          primary: const Color(0xFF1E293B),
          secondary: Colors.amber,
          surface: Colors.white,
        ),
        
        // Custom Text Theme
        textTheme: const TextTheme(
          displayLarge: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
          bodyMedium: TextStyle(color: Color(0xFF334155)),
        ),
        
        // Global Styling untuk AppBar
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
          titleTextStyle: TextStyle(
            color: Color(0xFF0F172A), 
            fontSize: 20, 
            fontWeight: FontWeight.bold
          ),
        ),
        
        // Modern Button Theme
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          ),
        ),
      ),
      
      home: initialScreen,
      routes: {
        'PlayGame': (context) => Game(),
        'GameHighScore': (context) => HighscoreScreen(),
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  void doLogout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('username');
    active_user = "";

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Menggunakan Stack untuk background image yang memenuhi layar
      body: Stack(
        children: [
          // 1. Background Image Layer
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/background_main.jpg"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          
          // 2. Overlay Layer (Sedikit transparansi agar UI terbaca)
          Container(color: Colors.white.withOpacity(0.1)),

          // 3. Content Layer
          Column(
            children: [
              AppBar(
                title: const Text('Memory Image Game'),
                backgroundColor: Colors.transparent,
                elevation: 0,
              ),
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    child: Container(
                      margin: const EdgeInsets.all(24),
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        color: Colors.white.withOpacity(0.9), // Glassmorphism soft
                        boxShadow: [
                          BoxShadow(
                            blurRadius: 20,
                            color: Colors.black.withOpacity(0.1),
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Welcome Avatar & Text
                          const CircleAvatar(
                            radius: 35,
                            backgroundColor: Colors.amber,
                            child: Icon(Icons.person, size: 40, color: Colors.white),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            "Welcome back,",
                            style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                          ),
                          Text(
                            active_user,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                          const SizedBox(height: 40),
                          
                          // PLAY Button
                          SizedBox(
                            width: double.infinity,
                            height: 60,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.amber,
                                foregroundColor: Colors.black87,
                                elevation: 5,
                                shadowColor: Colors.amber.withOpacity(0.4),
                              ),
                              onPressed: () {
                                Navigator.pushNamed(context, 'PlayGame');
                              },
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.play_arrow_rounded, size: 30),
                                  SizedBox(width: 8),
                                  Text('PLAY GAME', style: TextStyle(letterSpacing: 1.2)),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          
                          // HIGHSCORE Button
                          SizedBox(
                            width: double.infinity,
                            height: 60,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF1E293B),
                                foregroundColor: Colors.white,
                              ),
                              onPressed: () {
                                Navigator.pushNamed(context, 'GameHighScore');
                              },
                              child: const Text('HIGHSCORE'),
                            ),
                          ),
                          const SizedBox(height: 16),
                          
                          // LOGOUT Button (Text Button Style untuk variasi UX)
                          TextButton.icon(
                            style: TextButton.styleFrom(foregroundColor: Colors.red.shade400),
                            onPressed: doLogout,
                            icon: const Icon(Icons.logout),
                            label: const Text('Logout Account', style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}