import 'package:flutter/material.dart';
import 'dart:async';

void showPlayerDialog({
  required BuildContext context,
  required bool isDarkMode,
  required Function(int) onPlayersSelected,
}) {
  final TextEditingController _playerController = TextEditingController();

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(
          'Select Number of Players',
          style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
        ),
        backgroundColor: isDarkMode ? Colors.grey[900] : Colors.white,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _playerController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'Enter number of players',
                hintStyle: TextStyle(
                  color: isDarkMode ? Colors.grey : Colors.black,
                ),
                filled: true,
                fillColor: isDarkMode ? Colors.grey[800] : Colors.grey[300],
                border: OutlineInputBorder(),
              ),
              style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                final playerCount = int.tryParse(_playerController.text);
                if (playerCount != null && playerCount > 0) {
                  onPlayersSelected(playerCount);
                  Navigator.of(context).pop();
                } else {
                  // Show an error if invalid input
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Please enter a valid number of players.',
                        style: TextStyle(
                          color: isDarkMode ? Colors.white : Colors.black,
                        ),
                      ),
                      backgroundColor:
                          isDarkMode ? Colors.grey[800] : Colors.blue,
                    ),
                  );
                }
              },
              child: Text('Set Number of Players'),
            ),
          ],
        ),
      );
    },
  );
}

class RotatingTimer extends StatefulWidget {
  final int numberOfPlayers;

  const RotatingTimer({Key? key, required this.numberOfPlayers})
    : super(key: key);

  @override
  _RotatingTimerState createState() => _RotatingTimerState();
}

class _RotatingTimerState extends State<RotatingTimer> {
  int _currentPlayerIndex = 0;
  int _currentTime = 40;
  bool _isRunning = false;
  Timer? _timer;
  double _rotationAngle = 0.0;

  List<String> get players =>
      List.generate(widget.numberOfPlayers, (index) => 'Player ${index + 1}');

  void startTimer() {
    if (_isRunning) return;

    setState(() {
      _isRunning = true;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_currentTime > 0) {
        setState(() {
          _currentTime--;
        });
      } else {
        _rotateToNextPlayer();
      }
    });
  }

  void resetTimer() {
    _timer?.cancel();
    setState(() {
      _currentTime = 40;
      _isRunning = false;
    });
  }

  void _rotateToNextPlayer() {
    setState(() {
      _currentPlayerIndex = (_currentPlayerIndex + 1) % widget.numberOfPlayers;
      _rotationAngle += 90.0;
      if (_rotationAngle >= 360) {
        _rotationAngle = 0;
      }
      _currentTime = 40;
    });
  }

  Widget _buildRotatingTimer() {
    return Transform.rotate(
      angle: _rotationAngle * (3.14159 / 180),
      child: Container(
        padding: const EdgeInsets.all(20.0),
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.blueAccent,
        ),
        child: Center(
          child: Text(
            '$_currentTime',
            style: const TextStyle(fontSize: 48, color: Colors.white),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Rotating Timer'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: resetTimer),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              showPlayerDialog(
                context: context,
                isDarkMode: isDarkMode,
                onPlayersSelected: (selected) {
                  // Handle new player count
                  // You might want to use setState in the parent and recreate this widget
                },
              );
            },
          ),
        ],
      ),
      body: Center(
        child: GestureDetector(
          onTap: () {
            if (!_isRunning) {
              startTimer();
            } else {
              resetTimer();
            }
          },
          child: _buildRotatingTimer(),
        ),
      ),
    );
  }
}
