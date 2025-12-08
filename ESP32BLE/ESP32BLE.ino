#include <BLEDevice.h>
#include <BLEServer.h>
#include <BLEUtils.h>
#include <BLE2902.h>

const int VISION_BUTTON_PIN = 27;
const int AUDIO_BUTTON_PIN = 15;

#define SERVICE_UUID        "12345678-1234-1234-1234-123456789abc"
#define CHARACTERISTIC_UUID "87654321-4321-4321-4321-cba987654321"

BLEServer* pServer = NULL;
BLECharacteristic* pCharacteristic = NULL;
bool deviceConnected = false;
bool lastVisionState = HIGH;
bool lastAudioState = HIGH;

class MyServerCallbacks : public BLEServerCallbacks {
    void onConnect(BLEServer* pServer) {
        deviceConnected = true;
        Serial.println("BLE: Device connected");
        delay(500);  // Give time to settle
    }
    void onDisconnect(BLEServer* pServer) {
        deviceConnected = false;
        Serial.println("BLE: Device disconnected");
        delay(500);  // Give time to settle
        // Restart advertising immediately
        BLEAdvertising *pAdvertising = BLEDevice::getAdvertising();
        pAdvertising->start();
        Serial.println("BLE: Restarted advertising");
    }
};

void setup() {
    Serial.begin(115200);
    
    pinMode(VISION_BUTTON_PIN, INPUT_PULLUP);
    pinMode(AUDIO_BUTTON_PIN, INPUT_PULLUP);
    
    lastVisionState = digitalRead(VISION_BUTTON_PIN);
    lastAudioState = digitalRead(AUDIO_BUTTON_PIN);
    
    BLEDevice::init("ESP32_HybridNBack");
    BLEDevice::setMTU(517);
    
    pServer = BLEDevice::createServer();
    pServer->setCallbacks(new MyServerCallbacks());
    
    BLEService *pService = pServer->createService(SERVICE_UUID);
    
    pCharacteristic = pService->createCharacteristic(
        CHARACTERISTIC_UUID,
        BLECharacteristic::PROPERTY_NOTIFY
    );
    
    pCharacteristic->addDescriptor(new BLE2902());
    
    pService->start();
    
    BLEAdvertising *pAdvertising = BLEDevice::getAdvertising();
    pAdvertising->addServiceUUID(SERVICE_UUID);
    pAdvertising->setScanResponse(true);
    pAdvertising->setMinPreferred(0x06);
    pAdvertising->setMinPreferred(0x12);
    BLEDevice::startAdvertising();
    
    Serial.println("BLE: Setup complete. Advertising as 'ESP32_HybridNBack'.");
}

void loop() {
    bool currentVisionState = digitalRead(VISION_BUTTON_PIN);
    bool currentAudioState = digitalRead(AUDIO_BUTTON_PIN);
    
    if (lastVisionState == HIGH && currentVisionState == LOW && deviceConnected) {
        Serial.println("DEBUG: Vision button pressed, sending 1");
        uint8_t value = 1;
        pCharacteristic->setValue(&value, 1);
        pCharacteristic->notify();
        delay(200);
    }
    
    if (lastAudioState == HIGH && currentAudioState == LOW && deviceConnected) {
        Serial.println("DEBUG: Audio button pressed, sending 2");
        uint8_t value = 2;
        pCharacteristic->setValue(&value, 1);
        pCharacteristic->notify();
        delay(200);
    }
    
    lastVisionState = currentVisionState;
    lastAudioState = currentAudioState;
    
    delay(50);
}
