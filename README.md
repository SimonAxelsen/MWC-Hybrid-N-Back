# MWC-Hybrid-N-Back

A dual N-Back cognitive training application for Android built with Flutter, developed for the Mobile and Wearable Computing (MWC) course.

Hybrid N-Back implements the classic working memory assessment paradigm with simultaneous visual and auditory sequences.

The "hybrid" aspect refers to the dual input modalities: standard touchscreen controls or an optional ESP32-based physical controller for tangible interaction.

## Key Features

- **Dual-task paradigm**: Visual (grid position) + auditory (spoken letters) stimuli
- **BLE peripheral support**: Optional ESP32 controller with physical response buttons
- **Adaptive difficulty**: N-level automatically increases every 10 correct responses
- **Text-to-speech**: Synchronized auditory cues via flutter_tts
- **Performance tracking**: Session summaries with accuracy, highest N reached, and false alarms

## Tech Stack

- **Framework**: Flutter (Dart)
- **Bluetooth**: flutter_blue_plus
- **TTS**: flutter_tts
- **Hardware**: ESP32-S2 with custom firmware

## Architecture

The system consists of two components:
1. **Mobile app**: Game logic, stimulus generation, UI, and BLE central
2. **ESP32 controller**: BLE peripheral with two physical buttons (vision/audio)

## Status
Prototype developed for the Mobile and Wearable Computing course at Aalborg University. 
