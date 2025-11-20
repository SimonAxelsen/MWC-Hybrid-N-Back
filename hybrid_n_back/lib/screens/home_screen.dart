import 'package:flutter/material.dart';
import 'package:hybrid_n_back/screens/session_screen.dart';
import 'package:hybrid_n_back/screens/settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _tactileModeEnabled = false;
  int _startingNLevel = 1;
  double _stimulusDuration = 3.0;
  bool _soundFeedbackEnabled = true;
  
  @override
  void initState() {
    super.initState();
    // Load settings (in a real app, this would come from SharedPreferences)
    // For now, we're just using default values
    _loadSettings();
  }
  
  void _loadSettings() {
    // In a real app, this would load from SharedPreferences
    // For now, we're using hardcoded values for other settings
    setState(() {
      // _tactileModeEnabled is managed by settings screen return value
      _startingNLevel = 1;
      _stimulusDuration = 3.0;
      _soundFeedbackEnabled = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hybrid N-Back'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 40),
            // Start New Session Button
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SessionScreen(
                      isTactileMode: _tactileModeEnabled,
                      startingNLevel: _startingNLevel,
                      stimulusDuration: _stimulusDuration,
                      soundFeedbackEnabled: _soundFeedbackEnabled,
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 20),
              ),
              child: const Text(
                'Start New Session',
                style: TextStyle(fontSize: 20),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Settings Button
            ElevatedButton(
              onPressed: () async {
                // Navigate to settings and wait for result
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SettingsScreen(),
                  ),
                );
                
                // Update settings if result is returned
                if (result != null && result is Map<String, dynamic>) {
                  setState(() {
                    _tactileModeEnabled = result['tactileModeEnabled'] ?? _tactileModeEnabled;
                    _startingNLevel = result['startingNLevel'] ?? _startingNLevel;
                    _stimulusDuration = result['stimulusDuration'] ?? _stimulusDuration;
                    _soundFeedbackEnabled = result['soundFeedbackEnabled'] ?? _soundFeedbackEnabled;
                  });
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueGrey[700],
              ),
              child: const Text('Settings'),
            ),
            
            const SizedBox(height: 40),
            
            // Current settings summary
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Current Settings',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Tactile Mode:'),
                      Text(
                        _tactileModeEnabled ? 'Enabled' : 'Disabled',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: _tactileModeEnabled 
                              ? Theme.of(context).colorScheme.primary 
                              : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Starting N-Level:'),
                      Text(
                        '$_startingNLevel',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Stimulus Duration:'),
                      Text(
                        '${_stimulusDuration.toStringAsFixed(1)} seconds',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Sound Feedback:'),
                      Text(
                        _soundFeedbackEnabled ? 'Enabled' : 'Disabled',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Tactile Mode Info (only show when enabled)
            if (_tactileModeEnabled)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline,
                      color: Colors.blue,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Tactile Mode: Pair ESP32 in Android Bluetooth settings first',
                        style: TextStyle(
                          color: Colors.blue[300],
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}