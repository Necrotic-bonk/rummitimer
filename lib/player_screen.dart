import 'package:flutter/material.dart';

class SeatingPreset {
  final String name;
  final String description;
  final int numberOfPlayers;

  const SeatingPreset({
    required this.name,
    required this.description,
    required this.numberOfPlayers,
  });
}

void showPlayerScreen({
  required BuildContext context,
  required bool isDarkMode,
  required Function(int, String) onPlayersAndPresetSelected,
  required int initialTimerDuration,
  required Function(int) onTimerDurationChanged,
  required Function(bool) onThemeChanged,
}) {
  Navigator.of(context).push(
    PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => PlayerScreen(
        isDarkMode: isDarkMode,
        onPlayersAndPresetSelected: onPlayersAndPresetSelected,
        initialTimerDuration: initialTimerDuration,
        onTimerDurationChanged: onTimerDurationChanged,
        onThemeChanged: onThemeChanged,
      ),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
    ),
  );
}

class PlayerScreen extends StatefulWidget {
  final bool isDarkMode;
  final Function(int, String) onPlayersAndPresetSelected;
  final int initialTimerDuration;
  final Function(int) onTimerDurationChanged;
  final Function(bool) onThemeChanged;

  const PlayerScreen({
    required this.isDarkMode,
    required this.onPlayersAndPresetSelected,
    required this.initialTimerDuration,
    required this.onTimerDurationChanged,
    required this.onThemeChanged,
    Key? key,
  }) : super(key: key);

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  late TextEditingController _playerController;
  late TextEditingController _timeController;
  int selectedPlayers = 4;
  String selectedPreset = 'Square';

  @override
  void initState() {
    super.initState();
    _playerController = TextEditingController(text: '4');
    _timeController = TextEditingController(text: widget.initialTimerDuration.toString());
  }

  @override
  void dispose() {
    _playerController.dispose();
    _timeController.dispose();
    super.dispose();
  }

  List<SeatingPreset> getPresetsForPlayers(int players) {
    switch (players) {
      case 2:
        return [
          const SeatingPreset(
            name: 'Opposite',
            description: 'Players sit across from each other',
            numberOfPlayers: 2,
          ),
          const SeatingPreset(
            name: 'Adjacent',
            description: 'Players sit next to each other',
            numberOfPlayers: 2,
          ),
        ];
      case 3:
        return [
          const SeatingPreset(
            name: 'Y-Shape',
            description: 'Players sit in a Y formation',
            numberOfPlayers: 3,
          ),
          const SeatingPreset(
            name: 'Right Triangle',
            description: 'Players sit in a right triangle formation',
            numberOfPlayers: 3,
          ),
        ];
      case 4:
        return [
          const SeatingPreset(
            name: 'Square',
            description: 'Players sit across from each other in a square',
            numberOfPlayers: 4,
          ),
          const SeatingPreset(
            name: 'Rectangle',
            description: 'Two players on each long side',
            numberOfPlayers: 4,
          ),
        ];
      default:
        return [
          const SeatingPreset(
            name: 'Square',
            description: 'Players sit across from each other in a square',
            numberOfPlayers: 4,
          ),
        ];
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color textColor = widget.isDarkMode ? Colors.white : Colors.black;
    final presets = getPresetsForPlayers(selectedPlayers);

    return Scaffold(
      backgroundColor: widget.isDarkMode ? Colors.black : Colors.white,
      appBar: AppBar(
        backgroundColor: widget.isDarkMode ? Colors.black : Colors.white,
        title: Text(
          'Settings',
          style: TextStyle(color: textColor),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            onPressed: () {
              widget.onThemeChanged(!widget.isDarkMode);
              Navigator.of(context).pop();
              // reopen screen to reflect theme change
              Future.delayed(Duration.zero, () {
                showPlayerScreen(
                  context: context,
                  isDarkMode: !widget.isDarkMode,
                  onPlayersAndPresetSelected: widget.onPlayersAndPresetSelected,
                  initialTimerDuration: widget.initialTimerDuration,
                  onTimerDurationChanged: widget.onTimerDurationChanged,
                  onThemeChanged: widget.onThemeChanged,
                );
              });
            },
            icon: Icon(
              widget.isDarkMode ? Icons.light_mode : Icons.dark_mode,
              color: textColor,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Number of Players:',
                    style: TextStyle(
                      color: textColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(
                    height: 40.0,
                    width: 60.0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      decoration: BoxDecoration(
                        color: widget.isDarkMode ? Colors.grey[800] : Colors.grey[200],
                        borderRadius: BorderRadius.circular(8.0),
                        border: Border.all(color: widget.isDarkMode ? Colors.white : Colors.black),
                      ),
                      child: TextField(
                        controller: _playerController,
                        style: TextStyle(color: textColor, fontSize: 18),
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          setState(() {
                            selectedPlayers = int.tryParse(value) ?? 4;
                            selectedPreset = getPresetsForPlayers(selectedPlayers).first.name;
                          });
                        },
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: '4',
                          hintStyle: TextStyle(color: widget.isDarkMode ? Colors.white70 : Colors.black54),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Timer Duration (seconds):',
                    style: TextStyle(
                      color: textColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(
                    height: 40.0,
                    width: 60.0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      decoration: BoxDecoration(
                        color: widget.isDarkMode ? Colors.grey[800] : Colors.grey[200],
                        borderRadius: BorderRadius.circular(8.0),
                        border: Border.all(color: widget.isDarkMode ? Colors.white : Colors.black),
                      ),
                      child: TextField(
                        controller: _timeController,
                        style: TextStyle(color: textColor, fontSize: 18),
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          final parsed = int.tryParse(value);
                          if (parsed != null) {
                            widget.onTimerDurationChanged(parsed);
                          }
                        },
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: '40',
                          hintStyle: TextStyle(color: widget.isDarkMode ? Colors.white70 : Colors.black54),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                'Select Seating Arrangement:',
                style: TextStyle(
                  color: textColor,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 1.5,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: presets.length,
                  itemBuilder: (context, index) {
                    final preset = presets[index];
                    return Card(
                      color: selectedPreset == preset.name
                          ? (widget.isDarkMode ? const Color(0xFFe70104).withOpacity(0.3) : Colors.grey[200])
                          : widget.isDarkMode ? Colors.grey[800] : Colors.grey[200],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        side: BorderSide(
                          color: selectedPreset == preset.name
                              ? (widget.isDarkMode ? const Color(0xFFe70104) : const Color(0xFFe70104))
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            selectedPreset = preset.name;
                          });
                        },
                        borderRadius: BorderRadius.circular(12.0),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                preset.name,
                                style: TextStyle(
                                  color: textColor,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                preset.description,
                                style: TextStyle(
                                  color: textColor.withOpacity(0.7),
                                  fontSize: 14,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    widget.onPlayersAndPresetSelected(selectedPlayers, selectedPreset);
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: widget.isDarkMode ? const Color(0xFFe70104) : const Color(0xFFe70104),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Confirm Selection',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Language:',
                    style: TextStyle(
                      color: textColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    decoration: BoxDecoration(
                      color: widget.isDarkMode ? Colors.grey[800] : Colors.grey[200],
                      borderRadius: BorderRadius.circular(8.0),
                      border: Border.all(color: widget.isDarkMode ? Colors.white : Colors.black),
                    ),
                    child: DropdownButton<String>(
                      value: 'English',
                      style: TextStyle(color: textColor),
                      underline: const SizedBox(),
                      items: const [
                        DropdownMenuItem(
                          value: 'English',
                          child: Text('English'),
                        ),
                        DropdownMenuItem(
                          value: 'Polish',
                          child: Text('Polish'),
                        ),
                        DropdownMenuItem(
                          value: 'German',
                          child: Text('German'),
                        ),
                      ],
                      onChanged: (String? newValue) {
                        // Will be implemented later
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
} 