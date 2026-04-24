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

  checkUser().then((username) async {
    if (username == '') {
      runApp(LoginScreen());
    } else {
      active_user = username;
      runApp(const MyApp());
    }
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Home',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Home'),

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

    await prefs.clear(); 

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Memory Image Game'), centerTitle: true,),
      body:Center(
        child: Container(
          height: 300,
          margin: EdgeInsets.all(20),
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            border: Border.all(width: 1),
            color: Colors.white,
            boxShadow: [BoxShadow(blurRadius: 5)],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding( //! btn play
                padding: EdgeInsets.all(10),
                child: Container(
                  height: 50,
                  width: 300,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, 'PlayGame');
                    },
                    child: Text('PLAY', style: TextStyle(fontSize: 25)),
                  ),
                ),
              ),
              Padding( //! btn highscore
                padding: EdgeInsets.all(10),
                child: Container(
                  height: 50,
                  width: 300,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, 'GameHighScore');
                    },
                    child: Text('HIGHSCORE', style: TextStyle(fontSize: 25)),
                  ),
                ),
              ),
              Padding( //! btn logout
                padding: EdgeInsets.all(10),
                child: Container(
                  height: 50,
                  width: 300,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: ElevatedButton(
                    onPressed: () {
                      doLogout();
                    },
                    child: Text('LOGOUT', style: TextStyle(fontSize: 25)),
                  ),
                ),
              ),
            ],
          ),
        )
      ),
    );
  }

}
