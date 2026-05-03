import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:orangsombong_memoryimage/main.dart' as main;


class HighscoreScreen extends StatefulWidget {
  const HighscoreScreen({Key? key}) : super(key: key);

  @override
  State<HighscoreScreen> createState() => _HighscoreScreenState();
}

class _HighscoreScreenState extends State<HighscoreScreen> {
  List<Map<String, dynamic>> _topPlayers = [];

  @override
  void initState() {
    super.initState();
    _loadLeaderboard();
  }

  void _loadLeaderboard() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Ambil leaderboard dari SharedPreferences
    List<String> leaderboard = prefs.getStringList('leaderboard') ?? [];
    
    // Parse dan konversi ke list of maps
    List<Map<String, dynamic>> players = [];
    
    // Sort leaderboard berdasarkan score (descending), kemudian timestamp (ascending) untuk tie-breaking
    leaderboard.sort((a, b) {
      List<String> partsA = a.split(',');
      List<String> partsB = b.split(',');
      int scoreA = int.parse(partsA[1]);
      int scoreB = int.parse(partsB[1]);
      int scoreCompare = scoreB.compareTo(scoreA); // Score descending
      if (scoreCompare != 0) return scoreCompare;
      // Jika score sama, urutkan berdasarkan timestamp (lebih awal = rank lebih tinggi)
      int timestampA = partsA.length > 2 ? int.parse(partsA[2]) : 0;
      int timestampB = partsB.length > 2 ? int.parse(partsB[2]) : 0;
      return timestampA.compareTo(timestampB); // Timestamp ascending
    });
    
    // Ambil hanya top 3
    for (int i = 0; i < leaderboard.length && i < 3; i++) {
      List<String> parts = leaderboard[i].split(',');
      String username = parts[0];
      int score = int.parse(parts[1]);
      
      players.add({
        'rank': i + 1,
        'username': username,
        'score': score,
      });
    }
    
    setState(() {
      _topPlayers = players;
    });
  }

  Color _getRankColor(int rank) {
    switch (rank) {
      case 1:
        return Colors.amber;
      case 2:
        return Colors.grey.shade400;
      case 3:
        return Colors.orange.shade700;
      default:
        return Colors.white;
    }
  }

  IconData _getRankIcon(int rank) {
    switch (rank) {
      case 1:
        return Icons.looks_one;
      case 2:
        return Icons.looks_two;
      case 3:
        return Icons.looks_3;
      default:
        return Icons.star;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('High Score'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Trophy Icon
                const Icon(Icons.emoji_events, size: 100, color: Colors.amber),
                const SizedBox(height: 30),

                // Judul
                const Text(
                  'LEADERBOARD',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 60),

                // Tampilkan Top 3 Players
                if (_topPlayers.isEmpty)
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 30),
                    padding: const EdgeInsets.all(30),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: const Text(
                      'Belum ada data pemain',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white70,
                      ),
                    ),
                  )
                else
                  Column(
                    children: List.generate(_topPlayers.length, (index) {
                      Map<String, dynamic> player = _topPlayers[index];
                      int rank = player['rank'];
                      String username = player['username'];
                      int score = player['score'];
                      Color rankColor = _getRankColor(rank);
                      
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 30,
                          vertical: 12,
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: rankColor.withOpacity(0.15),
                            border: Border.all(color: rankColor, width: 2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              // Rank Icon
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: rankColor.withOpacity(0.3),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  _getRankIcon(rank),
                                  color: rankColor,
                                  size: 32,
                                ),
                              ),
                              const SizedBox(width: 20),
                              
                              // Username & Rank
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Rank $rank',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: rankColor.withOpacity(0.7),
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1,
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      username,
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              
                              // Score
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: rankColor.withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  score.toString(),
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w900,
                                    color: rankColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ),

                const SizedBox(height: 60),

                // Your Score Card
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 30),
                  padding: const EdgeInsets.all(25),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    border: Border.all(color: Colors.white38, width: 2),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'LOGGED IN AS',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white.withOpacity(0.7),
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        main.active_user,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.amber,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 60),

                // Button Kembali
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: SizedBox(
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
                          MaterialPageRoute(
                            builder: (context) => main.MyHomePage(title: 'Home'),
                          ),
                          (route) => false,
                        );
                      },
                      child: const Text(
                        'KEMBALI KE HOME',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}