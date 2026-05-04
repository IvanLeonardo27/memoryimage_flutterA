import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:orangsombong_memoryimage/main.dart';
import 'package:orangsombong_memoryimage/screen/login.dart';
import 'dart:async';
import 'dart:math';

class Game extends StatefulWidget {
  const Game({Key? key}) : super(key: key);

  @override
  _GameState createState() => _GameState();
}

class _GameState extends State<Game> {
  bool _isGameFinish = false;
  bool _isMemorizePhase = true;
  List<int> _urutanGambar = [];
  List<String> _correctImages = [];
  int _index = 0;
  double _opacity = 0.0;

  List<String> _pilihan = [];
  int _score = 0;
  bool _isAnswered = false;
  String? _selectedAnswer;

  Timer? _answerTimer;
  int _timeLeft = 30;

  late Timer _cycleTimer;

  @override
  void initState() {
    super.initState();
    randomUrutanDanJawaban();
    startCycle();
  }

  void randomUrutanDanJawaban() {
    List<int> angka = [1, 2, 3];
    List<String> listJawaban = [];
    angka.shuffle();

    for (int i = 0; i < angka.length; i++) {
      int subAngka = Random().nextInt(4) + 1;
      String jawaban = "assets/images/${angka[i]}_$subAngka.png";
      listJawaban.add(jawaban);
    }
    setState(() {
      _correctImages = List.from(listJawaban);
      _urutanGambar = List.from(angka);
    });
  }

  void startCycle() async {
    if (_isMemorizePhase) {
      _runCycle();
    }
  }

  void _runCycle() {
    setState(() => _opacity = 1.0);
    _cycleTimer = Timer(const Duration(seconds: 1), () {
      _cycleTimer = Timer(const Duration(seconds: 1), () {
        setState(() => _opacity = 0.0);
        _cycleTimer = Timer(const Duration(seconds: 1), () {
          if (_index == _urutanGambar.length - 1) {
            setState(() {
              _isMemorizePhase = false;
              _index = 0;
              _generatePilihan();
            });
            return;
          } else {
            setState(() {
              _index += 1;
            });
            _runCycle();
          }
        });
      });
    });
  }

  void _generatePilihan() {
    int objectNumber = _urutanGambar[_index];
    List<String> options = [
      "assets/images/${objectNumber}_1.png",
      "assets/images/${objectNumber}_2.png",
      "assets/images/${objectNumber}_3.png",
      "assets/images/${objectNumber}_4.png",
    ];
    options.shuffle();
    setState(() {
      _pilihan = options;
      _isAnswered = false;
      _selectedAnswer = null;
      _timeLeft = 30;
    });
    _startAnswerTimer();
  }

  void _startAnswerTimer() {
    _answerTimer?.cancel();
    _answerTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return; //cuman buat penanganan detail

      setState(() {
        if (_timeLeft > 0) {
          _timeLeft--;
        }
      });

      if (_timeLeft == 0) {
        _answerTimer?.cancel();
        _autoNextQuestion(isTimeout: true);
      }
    });
  }

  void _checkAnswer(String selectedImage) {
    String correctImage = _correctImages[_index];
    _answerTimer?.cancel();
    setState(() {
      _selectedAnswer = selectedImage;
      _isAnswered = true;
      if (selectedImage == correctImage) {
        _score += 1;
      }
    });
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        _autoNextQuestion(isTimeout: false);
      }
    });
  }

  void _autoNextQuestion({required bool isTimeout}) {
    if (_index < _urutanGambar.length - 1) {
      _index += 1;
      _generatePilihan();

    } else {
      _answerTimer?.cancel();
      _saveScore();
      setState(() {
        _isGameFinish = true;
      });
    }
  }

  void _saveScore() async {
    final prefs = await SharedPreferences.getInstance();

    for (var user in users) { //ini ambil dari login
      if (user["username"] == active_user && _score > int.parse(score_user)) {
        if (mounted) {
          setState(() {
            user["score"] = _score.toString(); 
            score_user = _score.toString();
          });
        }
        await prefs.setString("score", _score.toString());
        await prefs.setString("score", _score.toString());
        await saveUsers(); 
      }
    }
  }

  @override
  void dispose() {
    _cycleTimer.cancel();
    _answerTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/background_game.jpg"),
                fit: BoxFit.cover,
              ),
            ),
          ),

          SafeArea(
            child: _isGameFinish
                ? _finishUI()
                : (_isMemorizePhase ? _memorizeUI() : _guessingUI()),
          ),
        ],
      ),
    );
  }

  // 1. Tampilan Fase Mengingat (Program 1)
  Widget _memorizeUI() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.8),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              "MENGINGAT GAMBAR...",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B), 
                letterSpacing: 1.1,
              ),
            ),
          ),
          const SizedBox(height: 50),

          AnimatedOpacity(
            opacity: _opacity,
            duration: const Duration(milliseconds: 300),
            child: Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 25,
                    offset: const Offset(0, 10),
                  ),
                ],
                border: Border.all(color: Colors.white, width: 6),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset(
                  _correctImages[_index],
                  width: 220,
                  height: 220,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
          const SizedBox(height: 30),
          // Indikator Progress 
          Text(
            "${_index + 1} / ${_urutanGambar.length}",
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // 2. Tampilan Fase Menebak (Program 2)
  Widget _guessingUI() {
    return Column(
      children: [
        _buildGameHeader(),

        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 40,
            ), // Padding samping diperlebar agar grid mengecil
            child: Column(
              children: [
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.85),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    "Manakah gambar yang kamu lihat sebelumnya?",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                ),
                const SizedBox(height: 25),

                // GRID 2x2 
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  crossAxisSpacing: 40,
                  mainAxisSpacing: 40,
                  childAspectRatio: 1.1,
                  physics: const NeverScrollableScrollPhysics(),
                  children: List.generate(_pilihan.length, (index) {
                    String pilihan = _pilihan[index];
                    bool isCorrect = pilihan == _correctImages[_index];
                    bool isSelected = _selectedAnswer == pilihan;

                    Color borderColor = Colors.white;
                    if (_isAnswered) {
                      if (isCorrect) {
                        borderColor = Colors.greenAccent.shade700;
                      } else if (isSelected) {
                        borderColor = Colors.redAccent;
                      }
                    }

                    return GestureDetector(
                      onTap: _isAnswered ? null : () => _checkAnswer(pilihan),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        constraints: const BoxConstraints(
                          maxWidth: 120,
                          maxHeight: 120,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                          border: Border.all(
                            color: borderColor,
                            width:
                                _isAnswered && isCorrect ? 4 : 2,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.asset(pilihan, fit: BoxFit.contain),
                          ),
                        ),
                      ),
                    );
                  }),
                ),

                const SizedBox(height: 25),
                if (_isAnswered) _buildFeedbackCard(),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Helper: Header Game Modern
  Widget _buildGameHeader() {
    return Container(
      padding: const EdgeInsets.all(15),
      margin: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Progress
          _headerInfoChip(Icons.tag, "${_index + 1} / ${_urutanGambar.length}"),
          // Score
          _headerInfoChip(
            Icons.star,
            "Skor: $_score",
            color: Colors.amber.shade700,
          ),
          // Timer (Warna berubah saat kritis)
          _headerInfoChip(
            Icons.timer,
            "${_timeLeft}s",
            color: _timeLeft <= 5 ? Colors.red : Colors.blueGrey.shade700,
          ),
        ],
      ),
    );
  }

  Widget _headerInfoChip(
    IconData icon,
    String label, {
    Color color = const Color(0xFF1E293B),
  }) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 5),
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: color,
          ),
        ),
      ],
    );
  }

  // Helper: Kartu Feedback Jawaban
  Widget _buildFeedbackCard() {
    bool isCorrect = _selectedAnswer == _correctImages[_index];
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isCorrect ? Colors.green : Colors.red,
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isCorrect ? Icons.check_circle : Icons.cancel,
                color: isCorrect ? Colors.green : Colors.red,
                size: 30,
              ),
              const SizedBox(width: 10),
              Text(
                isCorrect ? "LUAR BIASA!" : "YAH, SALAH...",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: isCorrect ? Colors.green : Colors.red,
                ),
              ),
            ],
          ),
          if (!isCorrect) ...[
            const SizedBox(height: 15),
            const Text(
              "Jawaban yang benar adalah:",
              style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.green, width: 2),
              ),
              child: Image.asset(
                _correctImages[_index],
                width: 100,
                height: 100,
              ),
            ),
          ],
        ],
      ),
    );
  }

  // 3. Tampilan Layar Selesai
  Widget _finishUI() {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(30),
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.95),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 20)],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize:
              MainAxisSize.min, // Agar container mengikuti tinggi konten
          children: [
            const Icon(Icons.emoji_events, size: 100, color: Colors.amber),
            const SizedBox(height: 20),
            const Text(
              "Permainan Selesai!",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 15),
            Text(
              "Total Skor Kamu:",
              style: TextStyle(fontSize: 18, color: Colors.grey.shade700),
            ),
            Text(
              "$_score / ${_urutanGambar.length}",
              style: const TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.w900,
                color: Colors.amber,
              ),
            ),
            const SizedBox(height: 15),
            Text(
              getRank(_score),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: Colors.amber,
              ),
            ),
            const SizedBox(height: 40),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  foregroundColor: Colors.black87,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 5,
                ),
                onPressed: () {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => Game()),
                    (route) => false,
                  );
                },
                child: const Text(
                  "PLAY AGAIN",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 15),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  foregroundColor: Colors.black87,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 5,
                ),
                onPressed: () => Navigator.pushNamed(context, 'GameHighScore'),
                child: const Text(
                  "HIGH SCORES",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 15),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E293B),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 5,
                ),
                onPressed: () {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    'home',
                    (route) => false,
                  );
                },
                child: const Text(
                  "KEMBALI KE HOME",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String getRank(int score) {
    if (score == 0) return "Sfortunato Indovinatore (Unlucky Guesser)";
    if (score == 1) return "Neofita dell'Indovinello (Riddle Novice)";
    if (score == 2) return "Principiante dell'Indovinello (Riddle Beginner)";
    if (score == 3) return "Abile Indovinatore (Skillful Guesser)";
    if (score == 4) return "Esperto dell'Indovinello (Expert of Riddles)";
    return "Maestro dell'Indovinello (Master of Riddles)";
  }
}
