import 'package:flutter/foundation.dart';

class VoiceGuidanceService extends ChangeNotifier {
  bool _isVoiceEnabled = true;
  String? _lastSpokenPrompt;

  bool get isVoiceEnabled => _isVoiceEnabled;
  String? get lastSpokenPrompt => _lastSpokenPrompt;

  void toggleVoiceGuidance() {
    _isVoiceEnabled = !_isVoiceEnabled;
    notifyListeners();
  }

  Future<void> speakPrompt(String message) async {
    if (!_isVoiceEnabled || message.isEmpty || message == _lastSpokenPrompt) {
      return;
    }

    _lastSpokenPrompt = message;
    if (kDebugMode) {
      print("🔊 [Voice Navigation Prompt]: $message");
    }
    notifyListeners();
  }

  void stop() {
    _lastSpokenPrompt = null;
    notifyListeners();
  }
}
