import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:orangsombong_memoryimage/main.dart';
import 'dart:async';
import 'dart:math';

String user = active_user;

class Game extends StatefulWidget {
  const Game({Key? key}) : super(key: key);

  @override
  _GameState createState() => _GameState();
}

class _GameState extends State<Game> {
  int _countdownKuis = 30; // 1 detik fade-in, 1 dtk stay, 1 dtk fade-out
  bool _isGameFinish = false;
  bool _isMemorizePhase = true;
  List<int> _urutanGambar = [];
  List<String> _correctImages = [];
  int _index = 0;
  double _opacity = 0.0;

  late Timer _cycleTimer;
  late Timer _kuisTimer;


  void initState() {
    super.initState();
    randomUrutanDanJawaban();
    startCycle();
    startTimer();
  }

  void randomUrutanDanJawaban() {
    List<int> angka = [1,2,3,4,5,6,7]; //karena gambar soalnya pake angka, jadi biar gampang buat urutin nanti
    List<String> listJawaban = []; // karena nama file gambarnya "1_1.png . . . 1_4.png . . . 7_4.png"
    angka.shuffle();

    for (int i = 0; i < angka.length; i++) {
      int subAngka = Random().nextInt(4)+1; // karena ada 4 opsi
      String jawaban = "assets/images/${angka[i]}_$subAngka.png";
      listJawaban.add(jawaban);
    }
    setState(() {
      _correctImages = List.from(listJawaban);
      _urutanGambar = List.from(angka);
    });
  }

  startTimer(){
    int hitung = _countdownKuis; 

    _kuisTimer = Timer.periodic(Duration(milliseconds: 1000), (timer) {
      setState(() {

        hitung--;
        
        if (hitung == 0){
          _index += 1; //ganti lanjut tebak gambar selanjutnya
          hitung = _countdownKuis;
        }
      });

    });
  }

  void startCycle() async {
    if (_isMemorizePhase) {
      _runCycle();
    }
  }

  void _runCycle() {
    // 1. fade in
    setState(() => _opacity = 1.0);

    _cycleTimer = Timer(const Duration(seconds: 1), () {
      // 2. stay (1 detik full opacity)
      _cycleTimer = Timer(const Duration(seconds: 1), () {
       
        // 3. fade out
        setState(() => _opacity = 0.0);

        _cycleTimer = Timer(const Duration(seconds: 1), () {
          // 4. cek dan ganti gambar
          if(_index == _urutanGambar.length - 1){
            setState(() {
              _isMemorizePhase = false;
              _index = 0;
            });
            return;
          }
          else {
            setState(() {
              _index += 1;
            });

            // ulang lagi
            _runCycle();
          }
        });
      });
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isMemorizePhase
          ? Center(
              child: AnimatedOpacity(
                opacity: _opacity,
                duration: const Duration(milliseconds: 300),
                child: Image.asset(
                  _correctImages[_index],
                  width: 200,
                ),
              ),
            )
          : const Center(
              child: Text("Phase Tebak Gambar"),
            )
        ,
    );
  }

  @override
  void dispose() {
    _cycleTimer.cancel();
    _kuisTimer.cancel();
    super.dispose();
  }
}
