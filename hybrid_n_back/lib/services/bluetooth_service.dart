import 'dart:async';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BluetoothGameService {
  static final BluetoothGameService _instance = BluetoothGameService._internal();
  factory BluetoothGameService() => _instance;
  BluetoothGameService._internal();
  
  BluetoothDevice? _connectedDevice;
  bool _isConnected = false;
  String _deviceName = '';
  
  // Stream controllers for button presses and connection status
  final _buttonPressController = StreamController<ButtonType>.broadcast();
  final _connectionStatusController = StreamController<bool>.broadcast();
  
  // Streams
  Stream<ButtonType> get buttonPressStream => _buttonPressController.stream;
  Stream<bool> get connectionStatusStream => _connectionStatusController.stream;
  
  // Getters
  bool get isConnected => _isConnected;
  String get deviceName => _deviceName;
  
  // Check for already paired ESP32 devices and listen for button presses
  Future<void> startListening() async {
    try {
      // Get bonded (paired) devices
      var bondedDevices = await FlutterBluePlus.bondedDevices;
      
      // Look for ESP32 in bonded devices
      for (var device in bondedDevices) {
        String deviceName = device.platformName.toLowerCase();
        if (deviceName.contains('esp32') || deviceName.contains('hybrid') || deviceName.contains('nback')) {
          await _connectToDevice(device);
          break;
        }
      }
    } catch (e) {
      print('Error checking paired devices: $e');
    }
  }

  // Connect to specific device (simplified)
  Future<void> _connectToDevice(BluetoothDevice device) async {
    try {
      await device.connect();
      _connectedDevice = device;
      _isConnected = true;
      _deviceName = device.platformName.isNotEmpty ? device.platformName : 'ESP32 Device';
      
      _connectionStatusController.add(_isConnected);
      
      // Discover services and listen for button notifications
      List<BluetoothService> services = await device.discoverServices();
      
      for (BluetoothService service in services) {
        for (BluetoothCharacteristic characteristic in service.characteristics) {
          // Listen for notifications from buttons
          if (characteristic.properties.notify) {
            await characteristic.setNotifyValue(true);
            characteristic.lastValueStream.listen((value) {
              _handleButtonPress(value);
            });
          }
        }
      }
      
      // Listen for disconnection
      device.connectionState.listen((state) {
        if (state == BluetoothConnectionState.disconnected) {
          _handleDisconnection();
        }
      });
      
    } catch (e) {
      print('Error connecting to device: $e');
    }
  }

  // Handle button press (simplified)
  void _handleButtonPress(List<int> value) {
    if (value.isNotEmpty) {
      // Button 1 (value[0] == 1) = Vision, Button 2 (value[0] == 2) = Audio
      if (value[0] == 1) {
        _buttonPressController.add(ButtonType.vision);
      } else if (value[0] == 2) {
        _buttonPressController.add(ButtonType.audio);
      }
    }
  }

  // Handle disconnection
  void _handleDisconnection() {
    _isConnected = false;
    _deviceName = '';
    _connectedDevice = null;
    _connectionStatusController.add(_isConnected);
  }
  
  // Disconnect from device
  Future<void> disconnect() async {
    try {
      if (_connectedDevice != null) {
        await _connectedDevice!.disconnect();
      }
      _handleDisconnection();
    } catch (e) {
      print('Error disconnecting: $e');
    }
  }

  // Get available devices for manual connection (for settings screen)
  Future<List<Map<String, String>>> getAvailableDevices() async {
    try {
      await FlutterBluePlus.startScan(timeout: const Duration(seconds: 4));
      await Future.delayed(const Duration(seconds: 5)); // Wait for scan to complete
      
      var results = await FlutterBluePlus.scanResults.first;
      return results.where((result) {
        String deviceName = result.device.platformName.toLowerCase();
        return deviceName.contains('esp32') || deviceName.contains('hybrid') || deviceName.contains('nback');
      }).map((result) => {
        'name': result.device.platformName.isNotEmpty 
            ? result.device.platformName 
            : 'Unknown ESP32',
        'id': result.device.remoteId.toString(),
      }).toList();
    } catch (e) {
      return [];
    }
  }

  // Connect to device by name/id (for settings screen)
  Future<bool> connectToDevice(String name, String id) async {
    try {
      var results = await FlutterBluePlus.scanResults.first;
      var targetDevice = results
          .firstWhere((result) => result.device.remoteId.toString() == id)
          .device;
      
      await _connectToDevice(targetDevice);
      return _isConnected;
    } catch (e) {
      print('Error connecting to device: $e');
      return false;
    }
  }

  // Start scanning (for settings screen)
  Future<void> startScan() async {
    await startListening();
  }
  
  // Dispose resources
  void dispose() {
    disconnect();
    _buttonPressController.close();
    _connectionStatusController.close();
  }
}

enum ButtonType {
  vision,  // Changed from 'visual' to match your request
  audio,
}