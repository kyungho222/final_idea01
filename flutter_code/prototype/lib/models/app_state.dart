import 'package:flutter/foundation.dart';

class AppState extends ChangeNotifier {
  bool _isListening = false;
  bool _isAccessibilityEnabled = false;
  String _statusMessage = '';
  String _voiceCommand = '';

  bool get isListening => _isListening;
  bool get isAccessibilityEnabled => _isAccessibilityEnabled;
  String get statusMessage => _statusMessage;
  String get voiceCommand => _voiceCommand;

  void setListening(bool listening) {
    _isListening = listening;
    notifyListeners();
  }

  void setAccessibilityEnabled(bool enabled) {
    _isAccessibilityEnabled = enabled;
    notifyListeners();
  }

  void setStatusMessage(String message) {
    _statusMessage = message;
    notifyListeners();
  }

  void setVoiceCommand(String command) {
    _voiceCommand = command;
    notifyListeners();
  }
} 