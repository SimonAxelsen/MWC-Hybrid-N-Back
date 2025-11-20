import 'dart:async';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';

class BluetoothGameService {
  static final BluetoothGameService _instance = BluetoothGameService._internal();
  factory BluetoothGameService() => _instance;
  BluetoothGameService._internal();
  
  BluetoothDevice? _connectedDevice;
  bool _isConnected = false;
  
  final _buttonPressController = StreamController<ButtonType>.broadcast();
  final _debugController = StreamController<String>.broadcast();
  
  Stream<ButtonType> get buttonPressStream => _buttonPressController.stream;
  Stream<String> get debugStream => _debugController.stream;
  bool get isConnected => _isConnected;
  
  // Request Bluetooth permissions for Android 12+
  Future<bool> _requestPermissions() async {
    // Request Bluetooth permissions
    Map<Permission, PermissionStatus> statuses = await [
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.location,
    ].request();
    
    // Check if all permissions are granted
    bool allGranted = statuses.values.every((status) => status.isGranted);
    
    if (!allGranted) {
      print('Bluetooth permissions not granted');
      return false;
    }
    
    return true;
  }
  
  // Connect to first paired ESP32 device
  Future<void> connect() async {
    try {
      // Request permissions first
      bool permissionsGranted = await _requestPermissions();
      if (!permissionsGranted) {
        print('Bluetooth permissions denied');
        return;
      }
      
      var bondedDevices = await FlutterBluePlus.bondedDevices;
      
      for (var device in bondedDevices) {
        if (device.platformName.toLowerCase().contains('esp32')) {
          await device.connect();
          _connectedDevice = device;
          _isConnected = true;
          
          // Listen for button notifications
          var services = await device.discoverServices();
          for (var service in services) {
            for (var char in service.characteristics) {
              if (char.properties.notify) {
                await char.setNotifyValue(true);
                char.lastValueStream.listen((value) {
                  _debugController.add('DEBUG: Received BLE value: $value');
                  if (value.isNotEmpty) {
                    if (value[0] == 1) {
                      _debugController.add('DEBUG: Triggering vision button');
                      _buttonPressController.add(ButtonType.vision);
                    }
                    if (value[0] == 2) {
                      _debugController.add('DEBUG: Triggering audio button');
                      _buttonPressController.add(ButtonType.audio);
                    }
                  }
                });
              }
            }
          }
          break;
        }
      }
    } catch (e) {
      print('Connection error: $e');
    }
  }
  
  Future<void> disconnect() async {
    await _connectedDevice?.disconnect();
    _connectedDevice = null;
    _isConnected = false;
  }
  
  void dispose() {
    disconnect();
    _buttonPressController.close();
    _debugController.close();
  }
}

enum ButtonType {
  vision,  // Changed from 'visual' to match your request
  audio,
}