import 'package:flutter/material.dart';
import 'package:hybrid_n_back/services/bluetooth_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final BluetoothGameService _bluetoothService = BluetoothGameService();
  bool _tactileModeEnabled = false;
  bool _isConnected = false;
  
  // Game settings
  int _startingNLevel = 1;
  double _stimulusDuration = 3.0; // in seconds
  bool _soundFeedbackEnabled = true;

  @override
  void initState() {
    super.initState();
    // Check current Bluetooth connection status
    _isConnected = _bluetoothService.isConnected;
  }

  void _connectToESP32() async {
    try {
      await _bluetoothService.connect();
      
      if (mounted) {
        setState(() {
          _isConnected = _bluetoothService.isConnected;
        });
        
        if (_bluetoothService.isConnected) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Connected to ESP32'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No paired ESP32 found. Please pair in Bluetooth settings first.'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error connecting: $e')),
        );
      }
    }
  }

  void _disconnectDevice() {
    _bluetoothService.disconnect().then((_) {
      if (mounted) {
        setState(() {
          _isConnected = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Device disconnected'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    });
  }
  
  void _saveSettings() {
    // In a real app, this would save settings to persistent storage
    // For now, we'll just show a confirmation
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Settings saved'),
        backgroundColor: Colors.green,
      ),
    );
    
    // Return settings to the previous screen
    Navigator.pop(context, {
      'tactileModeEnabled': _tactileModeEnabled,
      'startingNLevel': _startingNLevel,
      'stimulusDuration': _stimulusDuration,
      'soundFeedbackEnabled': _soundFeedbackEnabled,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveSettings,
            tooltip: 'Save Settings',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tactile Mode Toggle
            SwitchListTile(
              title: const Text(
                'Enable Tactile Mode',
                style: TextStyle(fontSize: 18),
              ),
              subtitle: const Text(
                'Use a physical button instead of touchscreen',
              ),
              value: _tactileModeEnabled,
              onChanged: (value) {
                setState(() {
                  _tactileModeEnabled = value;
                });
              },
              secondary: Icon(
                Icons.touch_app,
                color: _tactileModeEnabled 
                    ? Theme.of(context).colorScheme.primary 
                    : Colors.grey,
              ),
            ),
            
            const Divider(height: 32),
            
            // Game Settings Section
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              child: Text(
                'Game Settings',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            
            // Starting N-Level
            ListTile(
              title: const Text('Starting N-Level'),
              subtitle: Text('Current: $_startingNLevel'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove),
                    onPressed: _startingNLevel > 1 
                        ? () {
                            setState(() {
                              _startingNLevel--;
                            });
                          } 
                        : null,
                  ),
                  Text(
                    '$_startingNLevel',
                    style: const TextStyle(fontSize: 18),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: _startingNLevel < 9 
                        ? () {
                            setState(() {
                              _startingNLevel++;
                            });
                          } 
                        : null,
                  ),
                ],
              ),
            ),
            
            // Stimulus Duration
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Stimulus Duration',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${_stimulusDuration.toStringAsFixed(1)} seconds',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  Slider(
                    value: _stimulusDuration,
                    min: 1.0,
                    max: 5.0,
                    divisions: 8,
                    label: '${_stimulusDuration.toStringAsFixed(1)}s',
                    onChanged: (value) {
                      setState(() {
                        _stimulusDuration = value;
                      });
                    },
                  ),
                ],
              ),
            ),
            
            // Sound Feedback
            SwitchListTile(
              title: const Text('Sound Feedback'),
              subtitle: const Text('Play sounds for feedback'),
              value: _soundFeedbackEnabled,
              onChanged: (value) {
                setState(() {
                  _soundFeedbackEnabled = value;
                });
              },
            ),
            
            const Divider(height: 32),
            
            // BLE Connection Section (only shown if tactile mode is enabled)
            if (_tactileModeEnabled) ...[
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'ESP32 Connection',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Connection status
                    if (_isConnected)
                      Card(
                        color: Colors.green.shade50,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.bluetooth_connected,
                                color: Colors.green,
                              ),
                              const SizedBox(width: 8),
                              const Expanded(
                                child: Text(
                                  'Connected to ESP32',
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              ElevatedButton(
                                onPressed: _disconnectDevice,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                ),
                                child: const Text('Disconnect'),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Not connected to ESP32',
                                style: TextStyle(
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Make sure ESP32 is paired in Bluetooth settings',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 12),
                              ElevatedButton.icon(
                                onPressed: _connectToESP32,
                                icon: const Icon(Icons.bluetooth),
                                label: const Text('Connect to ESP32'),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}