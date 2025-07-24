import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';

/// 백엔드 서버 연결을 관리하는 서비스
class NetworkService {
  static final NetworkService _instance = NetworkService._internal();
  factory NetworkService() => _instance;
  NetworkService._internal();

  bool _isConnected = false;
  String? _lastError;

  /// 서버 연결 상태 확인
  Future<bool> checkServerConnection() async {
    try {
      final response = await http.get(
        Uri.parse(AppConfig.baseUrl),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 5));

      _isConnected = response.statusCode == 200;
      _lastError = null;
      return _isConnected;
    } catch (e) {
      _isConnected = false;
      _lastError = e.toString();
      print('서버 연결 실패: $e');
      return false;
    }
  }

  /// 서버 상태 확인
  Future<Map<String, dynamic>> getServerStatus() async {
    try {
      final response = await http.get(
        Uri.parse('${AppConfig.baseUrl}/status'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          'status': 'error',
          'message': '서버 응답 오류: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {
        'status': 'error',
        'message': '서버 연결 실패: $e',
      };
    }
  }

  /// POST 요청 수행
  Future<Map<String, dynamic>?> postRequest(
    String endpoint,
    Map<String, dynamic> data, {
    Duration timeout = const Duration(seconds: 30),
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${AppConfig.baseUrl}$endpoint'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      ).timeout(timeout);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print('POST 요청 실패: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('POST 요청 오류: $e');
      return null;
    }
  }

  /// 파일 업로드 요청 수행
  Future<Map<String, dynamic>?> uploadFile(
    String endpoint,
    String filePath,
    String fieldName, {
    Duration timeout = const Duration(seconds: 60),
  }) async {
    try {
      final request = http.MultipartRequest('POST', Uri.parse('${AppConfig.baseUrl}$endpoint'))
        ..files.add(await http.MultipartFile.fromPath(fieldName, filePath));

      final streamedResponse = await request.send().timeout(timeout);
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print('파일 업로드 실패: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('파일 업로드 오류: $e');
      return null;
    }
  }

  /// 서버 연결 상태 getter
  bool get isConnected => _isConnected;
  String? get lastError => _lastError;

  /// 서버 URL getter
  String get serverUrl => AppConfig.baseUrl;
} 