import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';

class AIService {
  static final AIService _instance = AIService._internal();
  factory AIService() => _instance;
  AIService._internal();

  Future<Map<String, dynamic>?> analyzeVoiceCommand(String command) async {
    try {
      final response = await http.post(
        Uri.parse('${AppConfig.baseUrl}/analyze'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'command': command}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      print('AI 분석 오류: $e');
      return null;
    }
  }
} 