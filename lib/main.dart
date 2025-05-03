import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rummitimer/player_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool isDarkMode = true; // Default to dark mode

  @override
  void initState() {
    super.initState();
    _loadThemePreference(); // Load the saved theme preference
  }

  // Load the theme preference from SharedPreferences
  Future<void> _loadThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isDarkMode =
          prefs.getBool('isDarkMode') ?? true; // Default to true if not set
    });
  }

  // Save the theme preference to SharedPreferences
  Future<void> _saveThemePreference(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', value);
  }

  void toggleTheme(bool value) {
    setState(() {
      isDarkMode = value; // Update the theme mode
    });
    _saveThemePreference(value); // Save the preference
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme;

    if (isDarkMode) {
      theme = ThemeData(
        scaffoldBackgroundColor: Colors.black, // Dark mode background
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black, // Match the app background
          titleTextStyle: TextStyle(color: Colors.white, fontSize: 20),
        ),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: Colors.white), // White text
        ),
      );
    } else {
      theme = ThemeData(
        scaffoldBackgroundColor: Colors.white, // Light mode background
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFe70104), // Light mode AppBar color
          titleTextStyle: TextStyle(color: Colors.white, fontSize: 20),
        ),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: Colors.black), // Black text
        ),
      );
    }

    return MaterialApp(
      title: 'Rummikub Timer',
      theme: theme,
      home: MyHomePage(
        title: 'Rummikub Timer',
        isDarkMode: isDarkMode,
        onThemeChanged: toggleTheme,
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final String title;
  final bool isDarkMode;
  final Function(bool) onThemeChanged;

  const MyHomePage({
    super.key,
    required this.title,
    required this.isDarkMode,
    required this.onThemeChanged,
  });

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool _isRunning = false;
  int timerDuration = 40; // Default timer duration
  int currentTime = 40; // Current time for the countdown
  Timer? _timer;
  int numberOfPlayers = 2; // Variable to store the number of players
  final PlayerRotationHandler _rotationHandler = PlayerRotationHandler();

  void startTimer() {
    if (_isRunning) return; // Prevent multiple timers from starting

    setState(() {
      _isRunning = true;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (currentTime > 0) {
        setState(() {
          currentTime--;
        });
      } else {
        timer.cancel();
        setState(() {
          _isRunning = false;
        });
      }
    });
  }

  void resetTimer() {
    setState(() {
      currentTime = timerDuration;
    });

    if (_isRunning) {
      _timer?.cancel();
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (currentTime > 0) {
          setState(() {
            currentTime--;
          });
        } else {
          timer.cancel();
          setState(() {
            _isRunning = false;
          });
        }
      });
    }
  }

  void stopTimer() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      currentTime = timerDuration;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.isDarkMode ? Colors.black : Colors.white,
      appBar: AppBar(
        backgroundColor: widget.isDarkMode ? Colors.black : Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {
              showPlayerScreen(
                context: context,
                isDarkMode: widget.isDarkMode,
                onPlayersAndPresetSelected: (players, preset) {
                  setState(() {
                    numberOfPlayers = players;
                    _rotationHandler.updateNumberOfPlayers(players);
                  });
                },
                initialTimerDuration: timerDuration,
                onTimerDurationChanged: (newDuration) {
                  setState(() {
                    timerDuration = newDuration;
                    currentTime = newDuration;
                  });
                },
                onThemeChanged: widget.onThemeChanged,
              );
            },
            icon: Icon(Icons.settings, color: widget.isDarkMode ? Colors.white : Colors.black),
          ),
        ],
        flexibleSpace: GestureDetector(
          onTap: () {
            if (!_isRunning) {
              startTimer();
            } else {
              resetTimer();
            }
          },
          onLongPress: () {
            stopTimer();
          },
          child: Container(
            color: Colors.transparent,
          ),
        ),
      ),
      body: SafeArea(
        child: Center(
          // Ensures the timer is perfectly centered
          child: GestureDetector(
            onTap: () {
              if (!_isRunning) {
                startTimer();
              } else {
                resetTimer();
              }
            },
            onLongPress: () {
              stopTimer();
            },
            child: _rotationHandler.buildRotatingTimer(
              Container(
                width: double.infinity,
                height: double.infinity,
                color: Colors.transparent,
                alignment: Alignment.center,
                child: Text(
                  currentTime.toString(),
                  style: TextStyle(
                    fontSize: 48,
                    color:
                        widget.isDarkMode
                            ? Colors.white
                            : Colors.black, // Dynamic text color
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class PlayerRotationHandler {
  int currentPlayer = 0;
  int numberOfPlayers = 2;
  double rotationAngle = pi / 2; // Default to 90 degrees
  bool clockwise = true;
  Timer? _timer;

  void startRotationTimer(Duration duration, Function onPlayerChange) {
    _timer?.cancel(); // Cancel any existing timer
    _timer = Timer.periodic(duration, (timer) {
      rotateToNextPlayer();
      onPlayerChange(currentPlayer);
    });
  }

  void rotateToNextPlayer() {
    if (clockwise) {
      currentPlayer = (currentPlayer + 1) % numberOfPlayers;
    } else {
      currentPlayer = (currentPlayer - 1 + numberOfPlayers) % numberOfPlayers;
    }
  }

  Widget buildRotatingTimer(Widget child) {
    return Transform.rotate(
      angle: currentPlayer * rotationAngle * (clockwise ? 1 : -1),
      child: child,
    );
  }

  void updateNumberOfPlayers(int newNumberOfPlayers) {
    numberOfPlayers = newNumberOfPlayers;
    currentPlayer = 0; // Reset to the first player
  }

  void updateRotationAngle(double angle) {
    rotationAngle = angle;
  }

  void toggleRotationDirection() {
    clockwise = !clockwise;
  }

  void stopRotationTimer() {
    _timer?.cancel();
  }
}

class RotatingTimer extends StatefulWidget {
  final int initialNumberOfPlayers;

  const RotatingTimer({Key? key, required this.initialNumberOfPlayers})
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
  late int numberOfPlayers;

  @override
  void initState() {
    super.initState();
    numberOfPlayers = widget.initialNumberOfPlayers;
  }

  List<String> get players => List.generate(numberOfPlayers, (index) => 'Player ${index + 1}');

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
      _currentPlayerIndex = (_currentPlayerIndex + 1) % numberOfPlayers;
      _rotationAngle += 90.0;
      if (_rotationAngle >= 360) {
        _rotationAngle = 0;
      }
      _currentTime = 40;
    });
  }

  Widget _buildRotatingTimer() {
    return Transform.rotate(
      angle: _rotationAngle * (pi / 180),
      child: Container(
        padding: const EdgeInsets.all(20.0),
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Color(0xFFe70104),
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
              showPlayerScreen(
                context: context,
                isDarkMode: isDarkMode,
                onPlayersAndPresetSelected: (selected, preset) {
                  setState(() {
                    numberOfPlayers = selected;
                  });
                },
                initialTimerDuration: _currentTime,
                onTimerDurationChanged: (newDuration) {
                  setState(() {
                    _currentTime = newDuration;
                  });
                },
                onThemeChanged: (value) {
                  // Since RotatingTimer doesn't have direct access to theme changes,
                  // we'll just ignore this for now
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
