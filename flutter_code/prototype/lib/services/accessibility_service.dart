import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import '../models/ui_element.dart';
import '../config/app_config.dart';

/// 안드로이드 접근성 서비스를 활용한 UI 요소 인식 및 제어 서비스
class AccessibilityService {
  static const MethodChannel _channel = MethodChannel('com.example.prototype/accessibility');
  
  // 싱글톤 패턴
  static final AccessibilityService _instance = AccessibilityService._internal();
  factory AccessibilityService() => _instance;
  AccessibilityService._internal();

  // 상태 변수
  bool _isServiceEnabled = false;
  bool _isListening = false;
  List<UIElement> _currentScreenElements = [];
  StreamController<List<UIElement>>? _elementsController;
  StreamController<UIElement>? _highlightController;

  // Getters
  bool get isServiceEnabled => _isServiceEnabled;
  bool get isListening => _isListening;
  Stream<List<UIElement>>? get elementsStream => _elementsController?.stream;
  Stream<UIElement>? get highlightStream => _highlightController?.stream;

  /// 접근성 서비스 초기화
  Future<void> initialize() async {
    try {
      // 네이티브 채널 설정
      _channel.setMethodCallHandler(_handleMethodCall);
      
      // 서비스 상태 확인
      _isServiceEnabled = await _checkServiceStatus();
      
      // 서비스가 비활성화되어 있으면 활성화 요청
      if (!_isServiceEnabled) {
        print('접근성 서비스가 비활성화되어 있습니다. 활성화를 요청합니다.');
        await requestAccessibilityPermission();
      }
      
      // 스트림 컨트롤러 초기화
      _elementsController = StreamController<List<UIElement>>.broadcast();
      _highlightController = StreamController<UIElement>.broadcast();
      
      print('접근성 서비스 초기화 완료: $_isServiceEnabled');
    } catch (e) {
      print('접근성 서비스 초기화 실패: $e');
    }
  }

  /// 접근성 서비스 활성화 상태 확인
  Future<bool> _checkServiceStatus() async {
    try {
      final result = await _channel.invokeMethod('isAccessibilityServiceEnabled');
      return result == true;
    } catch (e) {
      print('접근성 서비스 상태 확인 실패: $e');
      return false;
    }
  }

  /// 접근성 서비스 활성화 요청
  Future<bool> requestAccessibilityPermission() async {
    try {
      final result = await _channel.invokeMethod('requestAccessibilityPermission');
      _isServiceEnabled = result == true;
      return _isServiceEnabled;
    } catch (e) {
      print('접근성 서비스 활성화 실패: $e');
      return false;
    }
  }

  /// 현재 화면의 UI 요소들 가져오기
  Future<List<UIElement>> getCurrentScreenElements() async {
    if (!_isServiceEnabled) {
      print('접근성 서비스가 활성화되지 않았습니다.');
      return [];
    }

    try {
      final result = await _channel.invokeMethod('getScreenElements');
      if (result != null) {
        _currentScreenElements = _parseUIElements(result);
        _elementsController?.add(_currentScreenElements);
        return _currentScreenElements;
      }
      return [];
    } catch (e) {
      print('화면 요소 가져오기 실패: $e');
      return [];
    }
  }

  /// 음성 명령에 따른 UI 요소 검색
  Future<UIElement?> findElementByVoiceCommand(String voiceCommand) async {
    if (!_isServiceEnabled) {
      print('접근성 서비스가 활성화되지 않았습니다.');
      return null;
    }

    try {
      // 현재 화면 요소들 가져오기
      final elements = await getCurrentScreenElements();
      if (elements.isEmpty) {
        print('화면에 감지된 UI 요소가 없습니다.');
        return null;
      }

      // AI 서버에 음성 명령과 UI 요소들을 전송하여 매칭
      final matchedElement = await _findElementWithAI(voiceCommand, elements);
      
      if (matchedElement != null) {
        // 매칭된 요소 하이라이트
        _highlightController?.add(matchedElement);
        return matchedElement;
      }

      return null;
    } catch (e) {
      print('음성 명령으로 요소 검색 실패: $e');
      return null;
    }
  }

  /// AI 서버를 통한 요소 매칭
  Future<UIElement?> _findElementWithAI(String voiceCommand, List<UIElement> elements) async {
    try {
      final response = await http.post(
        Uri.parse('${AppConfig.baseUrl}/find-element'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'voice_command': voiceCommand,
          'ui_elements': elements.map((e) => e.toJson()).toList(),
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['matched_element'] != null) {
          return UIElement.fromJson(data['matched_element']);
        }
      }
      return null;
    } catch (e) {
      print('AI 요소 매칭 실패: $e');
      return null;
    }
  }

  /// UI 요소 클릭/터치
  Future<bool> performClick(UIElement element) async {
    if (!_isServiceEnabled) {
      print('접근성 서비스가 활성화되지 않았습니다.');
      return false;
    }

    try {
      final result = await _channel.invokeMethod('performClick', {
        'x': element.bounds.left + (element.bounds.width / 2),
        'y': element.bounds.top + (element.bounds.height / 2),
      });
      return result == true;
    } catch (e) {
      print('요소 클릭 실패: $e');
      return false;
    }
  }

  /// 스크롤 수행
  Future<bool> performScroll(String direction) async {
    if (!_isServiceEnabled) {
      print('접근성 서비스가 활성화되지 않았습니다.');
      return false;
    }

    try {
      final result = await _channel.invokeMethod('performScroll', {
        'direction': direction, // 'up', 'down', 'left', 'right'
      });
      return result == true;
    } catch (e) {
      print('스크롤 실패: $e');
      return false;
    }
  }

  /// 특정 텍스트로 스크롤
  Future<bool> scrollToElement(String text) async {
    if (!_isServiceEnabled) {
      print('접근성 서비스가 활성화되지 않았습니다.');
      return false;
    }

    try {
      final result = await _channel.invokeMethod('scrollToElement', {
        'text': text,
      });
      return result == true;
    } catch (e) {
      print('요소로 스크롤 실패: $e');
      return false;
    }
  }

  /// 네이티브 메서드 호출 처리
  Future<dynamic> _handleMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'onAccessibilityEvent':
        return _handleAccessibilityEvent(call.arguments);
      case 'onScreenElementsChanged':
        return _handleScreenElementsChanged(call.arguments);
      default:
        throw PlatformException(
          code: 'Unimplemented',
          details: 'Method ${call.method} not implemented',
        );
    }
  }

  /// 접근성 이벤트 처리
  Future<void> _handleAccessibilityEvent(dynamic arguments) async {
    try {
      // arguments가 String인 경우 JSON 파싱
      Map<String, dynamic> eventData;
      if (arguments is String) {
        eventData = Map<String, dynamic>.from(jsonDecode(arguments));
      } else if (arguments is Map) {
        eventData = Map<String, dynamic>.from(arguments);
      } else {
        print('지원하지 않는 arguments 타입: ${arguments.runtimeType}');
        return;
      }
      
      print('접근성 이벤트 수신: $eventData');
      
      // 화면 요소 업데이트
      if (eventData['elements'] != null) {
        _currentScreenElements = _parseUIElements(eventData['elements']);
        _elementsController?.add(_currentScreenElements);
      }
    } catch (e) {
      print('접근성 이벤트 처리 실패: $e');
    }
  }

  /// 화면 요소 변경 처리
  Future<void> _handleScreenElementsChanged(dynamic arguments) async {
    try {
      final elements = _parseUIElements(arguments);
      _currentScreenElements = elements;
      _elementsController?.add(elements);
      print('화면 요소 변경 감지: ${elements.length}개 요소');
    } catch (e) {
      print('화면 요소 변경 처리 실패: $e');
    }
  }

  /// UI 요소 파싱
  List<UIElement> _parseUIElements(dynamic data) {
    try {
      if (data is List) {
        return data.map((item) {
          if (item is Map) {
            return UIElement.fromJson(Map<String, dynamic>.from(item));
          } else if (item is String) {
            // String인 경우 JSON 파싱 시도
            try {
              final parsed = jsonDecode(item);
              if (parsed is Map) {
                return UIElement.fromJson(Map<String, dynamic>.from(parsed));
              }
            } catch (e) {
              print('String 파싱 실패: $e');
            }
          }
          // 기본값 반환
          return UIElement(
            id: '',
            text: '',
            type: UIElementType.unknown,
            bounds: UIBounds(
              left: 0,
              top: 0,
              right: 0,
              bottom: 0,
              width: 0,
              height: 0,
            ),
            isClickable: false,
            isEnabled: true,
            isVisible: true,
          );
        }).toList();
      } else if (data is Map) {
        return [UIElement.fromJson(Map<String, dynamic>.from(data))];
      } else if (data is String) {
        // String인 경우 JSON 파싱 시도
        try {
          final parsed = jsonDecode(data);
          if (parsed is List) {
            return _parseUIElements(parsed);
          } else if (parsed is Map) {
            return [UIElement.fromJson(Map<String, dynamic>.from(parsed))];
          }
        } catch (e) {
          print('String 파싱 실패: $e');
        }
      }
      return [];
    } catch (e) {
      print('UI 요소 파싱 실패: $e');
      return [];
    }
  }

  /// 서비스 정리
  void dispose() {
    _elementsController?.close();
    _highlightController?.close();
  }
} 