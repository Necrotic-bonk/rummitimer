import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rummitimer/player_dialog.dart'; // Ensure correct import for showPlayerDialog

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
          backgroundColor: Colors.blue, // Light mode AppBar color
          titleTextStyle: TextStyle(color: Colors.black, fontSize: 20),
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
    _timer?.cancel();
    setState(() {
      currentTime = timerDuration;
    });
  }

  void stopTimer() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      currentTime = timerDuration;
    });
  }

  void showSettingsDialog(
    BuildContext context,
    bool isDarkMode,
    Function(bool) onThemeChanged,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return _SettingsDialog(
          isDarkMode: isDarkMode,
          onThemeChanged: onThemeChanged,
          initialTimerDuration: timerDuration,
          onTimerDurationChanged: (newDuration) {
            setState(() {
              timerDuration = newDuration;
              currentTime = newDuration;
            });
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            onPressed: () {
              showPlayerDialog(
                context: context,
                isDarkMode:
                    widget
                        .isDarkMode, // Pass the isDarkMode from the parent widget
                onPlayersSelected: (players) {
                  setState(() {
                    numberOfPlayers =
                        players; // Update the number of players in the state
                    _rotationHandler.updateNumberOfPlayers(players);
                  });
                },
              );
            },
            icon: const Icon(Icons.diversity_3, color: Colors.white),
          ),
          IconButton(
            onPressed: () {
              showSettingsDialog(
                context,
                widget.isDarkMode,
                widget.onThemeChanged,
              );
            },
            icon: const Icon(Icons.settings, color: Colors.white),
          ),
        ],
      ),
      body: Center(
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
    );
  }
}

class _SettingsDialog extends StatefulWidget {
  final bool isDarkMode;
  final Function(bool) onThemeChanged;
  final int initialTimerDuration;
  final Function(int) onTimerDurationChanged;

  const _SettingsDialog({
    required this.isDarkMode,
    required this.onThemeChanged,
    required this.initialTimerDuration,
    required this.onTimerDurationChanged,
    Key? key,
  }) : super(key: key);

  @override
  State<_SettingsDialog> createState() => _SettingsDialogState();
}

class _SettingsDialogState extends State<_SettingsDialog> {
  late bool _isDarkMode;
  late TextEditingController _timeController;

  @override
  void initState() {
    super.initState();
    _isDarkMode = widget.isDarkMode;
    _timeController = TextEditingController(
      text: widget.initialTimerDuration.toString(),
    );
  }

  @override
  void dispose() {
    _timeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = _isDarkMode;

    final Color textColor = isDark ? Colors.white : Colors.black;
    final Color bgColor = isDark ? Colors.grey[900]! : Colors.white;
    final Color fieldBg = isDark ? Colors.grey[800]! : Colors.grey[300]!;
    final Color borderColor = isDark ? Colors.white : Colors.black;
    final Color hintTextColor = isDark ? Colors.grey : Colors.black54;

    return AlertDialog(
      backgroundColor: bgColor,
      title: Text('Settings', style: TextStyle(color: textColor)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Dark Mode', style: TextStyle(color: textColor)),
              Switch(
                value: _isDarkMode,
                onChanged: (value) {
                  setState(() {
                    _isDarkMode = value;
                  });
                  widget.onThemeChanged(value);
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Time:', style: TextStyle(color: textColor)),
              SizedBox(
                height: 36.0,
                width: 60.0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  decoration: BoxDecoration(
                    color: fieldBg,
                    borderRadius: BorderRadius.circular(8.0),
                    border: Border.all(color: borderColor),
                  ),
                  child: TextField(
                    controller: _timeController,
                    style: TextStyle(color: textColor),
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: '40',
                      hintStyle: TextStyle(color: hintTextColor),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            final parsed = int.tryParse(_timeController.text.trim());
            if (parsed != null) {
              widget.onTimerDurationChanged(
                parsed,
              ); // Pass the new duration to the parent
            }
            Navigator.of(context).pop();
          },
          child: Text('Close', style: TextStyle(color: textColor)),
        ),
      ],
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
