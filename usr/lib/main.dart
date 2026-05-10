import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';

void main() {
  runApp(const HyperCasualGamesApp());
}

class HyperCasualGamesApp extends StatelessWidget {
  const HyperCasualGamesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hyper-Casual Games',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.teal,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const MainMenuScreen(),
        '/reaction_tap': (context) => const ReactionTapGame(),
      },
    );
  }
}

class MainMenuScreen extends StatelessWidget {
  const MainMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hyper-Casual Games'),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.gamepad, size: 100, color: Colors.tealAccent),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushNamed(context, '/reaction_tap');
                },
                icon: const Icon(Icons.touch_app),
                label: const Text('Play Reaction Tap'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  textStyle: const TextStyle(fontSize: 20),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ReactionTapGame extends StatefulWidget {
  const ReactionTapGame({super.key});

  @override
  State<ReactionTapGame> createState() => _ReactionTapGameState();
}

class _ReactionTapGameState extends State<ReactionTapGame> {
  int _score = 0;
  bool _isPlaying = false;
  double _targetX = 0.5;
  double _targetY = 0.5;
  Timer? _timer;
  int _timeLeft = 30;

  final Random _random = Random();

  void _startGame() {
    setState(() {
      _score = 0;
      _isPlaying = true;
      _timeLeft = 30;
      _moveTarget();
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_timeLeft > 0) {
          _timeLeft--;
        } else {
          _endGame();
        }
      });
    });
  }

  void _endGame() {
    _timer?.cancel();
    setState(() {
      _isPlaying = false;
    });
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Game Over'),
        content: Text('Your score: $_score'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _startGame();
            },
            child: const Text('Play Again'),
          ),
        ],
      ),
    );
  }

  void _moveTarget() {
    setState(() {
      _targetX = _random.nextDouble() * 0.8 + 0.1;
      _targetY = _random.nextDouble() * 0.8 + 0.1;
    });
  }

  void _onTargetTapped() {
    if (!_isPlaying) return;
    setState(() {
      _score++;
      _moveTarget();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reaction Tap'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Time: $_timeLeft',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                Text(
                  'Score: $_score',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
          ),
          Expanded(
            child: !_isPlaying && _timeLeft == 30
                ? Center(
                    child: ElevatedButton(
                      onPressed: _startGame,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 24),
                        textStyle: const TextStyle(fontSize: 24),
                      ),
                      child: const Text('Start'),
                    ),
                  )
                : LayoutBuilder(
                    builder: (context, constraints) {
                      return Stack(
                        children: [
                          if (_isPlaying)
                            Positioned(
                              left: constraints.maxWidth * _targetX - 30,
                              top: constraints.maxHeight * _targetY - 30,
                              child: GestureDetector(
                                onTap: _onTargetTapped,
                                child: Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.primary,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                                        blurRadius: 10,
                                        spreadRadius: 2,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
