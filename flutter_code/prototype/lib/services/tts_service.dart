import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';

class TTSService {
  static final TTSService _instance = TTSService._internal();
  factory TTSService() => _instance;
  TTSService._internal();

  Future<bool> playTTS(String text) async {
    try {
      final response = await http.post(
        Uri.parse('${AppConfig.baseUrl}/tts'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'text': text}),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('TTS 오류: $e');
      return false;
    }
  }
} 