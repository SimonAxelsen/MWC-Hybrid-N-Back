# ESP32 Bluetooth Setup Guide for Hybrid N-Back Game

## Hardware Requirements
- ESP32 development board (ESP32-WROOM-32 or similar)
- 2 push buttons
- 2 pull-up resistors (10kΩ) - or use internal pull-ups
- Breadboard and jumper wires

## Wiring Diagram
```
ESP32 Pin 2  ----[Button 1]---- GND  (Vision Button)
ESP32 Pin 4  ----[Button 2]---- GND  (Audio Button)
```

## Arduino Code (ESP32_NBack_Buttons.ino) - ULTRA SIMPLE

```cpp
#include "BluetoothSerial.h"

BluetoothSerial SerialBT;

// Button pins
const int VISION_BUTTON_PIN = 2;  // Button 1 - Vision (position)
const int AUDIO_BUTTON_PIN = 4;   // Button 2 - Audio (letter)

// Button states
bool lastVisionState = HIGH;
bool lastAudioState = HIGH;

void setup() {
  Serial.begin(115200);
  
  // Initialize Bluetooth Classic
  SerialBT.begin("ESP32_HybridNBack"); // Bluetooth device name
  Serial.println("ESP32 N-Back Controller Ready!");
  Serial.println("Pair with 'ESP32_HybridNBack' in Android Bluetooth settings");
  
  // Initialize buttons with internal pull-ups
  pinMode(VISION_BUTTON_PIN, INPUT_PULLUP);
  pinMode(AUDIO_BUTTON_PIN, INPUT_PULLUP);
  
  // Read initial button states
  lastVisionState = digitalRead(VISION_BUTTON_PIN);
  lastAudioState = digitalRead(AUDIO_BUTTON_PIN);
}

void loop() {
  // Read current button states
  bool currentVisionState = digitalRead(VISION_BUTTON_PIN);
  bool currentAudioState = digitalRead(AUDIO_BUTTON_PIN);
  
  // Check for vision button press (falling edge)
  if (lastVisionState == HIGH && currentVisionState == LOW) {
    Serial.println("Vision button pressed");
    SerialBT.write(1); // Send byte value 1 for vision/position
    delay(100); // Simple debounce
  }
  
  // Check for audio button press (falling edge)
  if (lastAudioState == HIGH && currentAudioState == LOW) {
    Serial.println("Audio button pressed");
    SerialBT.write(2); // Send byte value 2 for audio/letter
    delay(100); // Simple debounce
  }
  
  // Update last states
  lastVisionState = currentVisionState;
  lastAudioState = currentAudioState;
  
  delay(50); // Small delay to avoid excessive polling
}
```

## Flutter App Configuration

The Flutter app is configured with **dual mode** functionality:

### **Tactile Mode OFF (Touch Only)**:
- ✅ No Bluetooth scanning or connection attempts
- ✅ Only touchscreen input works
- ✅ Can play game normally without ESP32

### **Tactile Mode ON (Hardware Buttons)**:
1. **Uses already paired ESP32** from Android Bluetooth settings
2. **Button mapping**: `1` = Vision (position), `2` = Audio (letter) 
3. **No app scanning** - just listens for button presses during gameplay
4. **Works alongside touch** - both input methods active

### Important UUIDs (Update these in both ESP32 and Flutter code)

The current Flutter code uses these UUIDs:
- **Service UUID**: `12345678-1234-1234-1234-123456789abc`
- **Characteristic UUID**: `87654321-4321-4321-4321-cba987654321`

## Setup Steps

1. **Flash ESP32**:
   - Install Arduino IDE with ESP32 board support
   - Copy the Arduino code above to a new sketch
   - Upload to your ESP32

2. **Wire the buttons**:
   - Connect buttons between GPIO pins and GND
   - ESP32 internal pull-ups are enabled in code

3. **Pair with Android**:
   - Go to Android Settings → Bluetooth
   - Pair with "ESP32_HybridNBack" 
   - No need to connect in the app - pairing is enough

4. **Test**:
   - Press buttons on ESP32
   - Check Serial Monitor for debug output
   - App should receive button presses during game

## Troubleshooting

### ESP32 not found during scan:
- Make sure ESP32 is powered and running
- Check that Bluetooth is enabled on phone
- Try restarting both ESP32 and app

### Connection fails:
- Check that the device name matches
- Verify UUIDs match between ESP32 and Flutter code
- Ensure no other device is connected to ESP32

### Button presses not detected:
- Check wiring connections
- Monitor Serial output on ESP32
- Verify button debouncing is working

### Permission issues:
- Grant all Bluetooth permissions in phone settings
- Enable Location services (required for BLE scanning)

## Alternative: Bluetooth Classic Setup

If BLE doesn't work, you can modify the ESP32 code to use Bluetooth Classic:

```cpp
// Replace BLE setup with Bluetooth Classic
SerialBT.begin("ESP32_HybridNBack");
```

This requires updating the Flutter app to use `flutter_bluetooth_serial` instead of `flutter_blue_plus`.