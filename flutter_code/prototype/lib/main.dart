import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:audioplayers/audioplayers.dart';
import 'dart:ui' as ui;
import 'package:url_launcher/url_launcher.dart';
import 'dart:async';
import 'package:permission_handler/permission_handler.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart'; // 삭제
import 'package:flutter_sound/flutter_sound.dart';

// 서버 연결 설정
class ServerConfig {
  // 개발 환경별 서버 URL 설정
  static const String baseUrl = 'http://10.0.2.2:8000'; // 에뮬레이터용
  // static const String baseUrl = 'http://192.168.1.100:8000';  // 실제 디바이스용 (컴퓨터 IP)
  // static const String baseUrl = 'https://your-server.com/api';  // 원격 서버용

  static const String llmEndpoint = '/llm';
  static const String ttsEndpoint = '/tts';

  static String get llmUrl => '$baseUrl$llmEndpoint';
  static String get ttsUrl => '$baseUrl$ttsEndpoint';
}

// 대화 맥락 저장용
List<Map<String, dynamic>> conversationHistory = [];
// 음성 인식 결과 히스토리
List<String> transcriptHistory = [];

// 민감한 정보 패턴 정의
class SensitiveDataPatterns {
  static final List<String> sensitiveKeywords = [
    'password',
    '비밀번호',
    'pw',
    'pass',
    'credit',
    '카드',
    'card',
    '신용카드',
    'ssn',
    '주민번호',
    'social security',
    'phone',
    '전화번호',
    'tel',
    '010',
    '02',
    'email',
    '이메일',
    '@',
    'gmail',
    'naver',
    'address',
    '주소',
    'address',
    'bank',
    '은행',
    '계좌',
    'account',
    'private',
    '개인',
    'secret',
    '비밀',
  ];

  static final List<RegExp> sensitivePatterns = [
    // 이메일 패턴
    RegExp(r'\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}\b'),
    // 전화번호 패턴 (한국)
    RegExp(r'(\d{2,3}-\d{3,4}-\d{4}|\d{10,11})'),
    // 신용카드 패턴
    RegExp(r'\b\d{4}[- ]?\d{4}[- ]?\d{4}[- ]?\d{4}\b'),
    // 주민번호 패턴
    RegExp(r'\d{6}-\d{7}'),
  ];
}

// 권한 관리자
class PermissionManager {
  static bool _hasScreenCapturePermission = false;
  static bool _hasTouchPermission = false;
  static bool _hasAccessibilityPermission = false;
  static bool _hasAudioPermission = false;
  static bool _hasStoragePermission = false;
  static bool _hasCameraPermission = false;

  static bool get hasScreenCapturePermission => _hasScreenCapturePermission;
  static bool get hasTouchPermission => _hasTouchPermission;
  static bool get hasAccessibilityPermission => _hasAccessibilityPermission;
  static bool get hasAudioPermission => _hasAudioPermission;
  static bool get hasStoragePermission => _hasStoragePermission;
  static bool get hasCameraPermission => _hasCameraPermission;

  // 실제 권한 요청 함수들
  static Future<bool> requestAudioPermission() async {
    final status = await Permission.microphone.request();
    _hasAudioPermission = status.isGranted;
    return _hasAudioPermission;
  }

  static Future<bool> requestStoragePermission() async {
    final status = await Permission.storage.request();
    _hasStoragePermission = status.isGranted;
    return _hasStoragePermission;
  }

  static Future<bool> requestCameraPermission() async {
    final status = await Permission.camera.request();
    _hasCameraPermission = status.isGranted;
    return _hasCameraPermission;
  }

  static Future<bool> requestScreenCapturePermission() async {
    // 실제로는 MediaProjection API 권한 요청 필요 (여기선 storage/camera로 대체)
    _hasScreenCapturePermission =
        await requestStoragePermission() && await requestCameraPermission();
    return _hasScreenCapturePermission;
  }

  static Future<bool> requestTouchPermission() async {
    // 실제 Accessibility Service 권한 요청 필요 (Flutter에서는 직접 불가)
    _hasTouchPermission = true;
    return true;
  }

  static Future<bool> requestAccessibilityPermission() async {
    _hasAccessibilityPermission = true;
    return true;
  }

  static bool checkAllPermissions() {
    return _hasScreenCapturePermission &&
        _hasTouchPermission &&
        _hasAccessibilityPermission &&
        _hasAudioPermission &&
        _hasStoragePermission &&
        _hasCameraPermission;
  }

  static Future<bool> requestAllPermissions() async {
    final results = await Future.wait([
      requestAudioPermission(),
      requestStoragePermission(),
      requestCameraPermission(),
      requestScreenCapturePermission(),
      requestTouchPermission(),
      requestAccessibilityPermission(),
    ]);
    return results.every((result) => result);
  }
}

// 배터리 최적화 관리자
class BatteryOptimizer {
  static bool _isLowPowerMode = false;
  static DateTime? _lastActivityTime;
  static const Duration _inactivityTimeout = Duration(minutes: 5);

  static void setLowPowerMode(bool enabled) {
    _isLowPowerMode = enabled;
    print('배터리 최적화 모드: ${enabled ? "활성화" : "비활성화"}');
  }

  static bool get isLowPowerMode => _isLowPowerMode;

  static void updateActivityTime() {
    _lastActivityTime = DateTime.now();
  }

  static bool shouldReduceActivity() {
    if (_isLowPowerMode) return true;

    if (_lastActivityTime != null) {
      final timeSinceLastActivity = DateTime.now().difference(
        _lastActivityTime!,
      );
      return timeSinceLastActivity > _inactivityTimeout;
    }
    return false;
  }

  static Future<void> optimizeForBattery() async {
    if (shouldReduceActivity()) {
      print('배터리 최적화: 활동 감소 모드 활성화');
      // 화면 밝기 감소, 주기적 업데이트 중단 등
    }
  }
}

// 그리드 아이템 데이터
class GridItem {
  final int number;
  final IconData icon;
  final String label;
  final String url;
  final Color color;

  GridItem({
    required this.number,
    required this.icon,
    required this.label,
    required this.url,
    required this.color,
  });
}

// 그리드 아이템 리스트
final List<GridItem> gridItems = [
  GridItem(
    number: 1,
    icon: Icons.search,
    label: 'Google',
    url: 'https://www.google.com',
    color: Colors.blue,
  ),
  GridItem(
    number: 2,
    icon: Icons.facebook,
    label: 'Facebook',
    url: 'https://www.facebook.com',
    color: Colors.indigo,
  ),
  GridItem(
    number: 3,
    icon: Icons.web,
    label: 'Naver',
    url: 'https://www.naver.com',
    color: Colors.green,
  ),
  GridItem(
    number: 4,
    icon: Icons.chat,
    label: 'ChatGPT',
    url: 'https://chat.openai.com',
    color: Colors.teal,
  ),
  GridItem(
    number: 5,
    icon: Icons.auto_awesome,
    label: 'Gemini',
    url: 'https://gemini.google.com',
    color: Colors.purple,
  ),
  GridItem(
    number: 6,
    icon: Icons.video_library,
    label: 'YouTube',
    url: 'https://www.youtube.com',
    color: Colors.red,
  ),
  GridItem(
    number: 7,
    icon: Icons.shopping_cart,
    label: 'Amazon',
    url: 'https://www.amazon.com',
    color: Colors.orange,
  ),
  GridItem(
    number: 8,
    icon: Icons.code,
    label: 'GitHub',
    url: 'https://github.com',
    color: Colors.black,
  ),
  GridItem(
    number: 9,
    icon: Icons.flutter_dash,
    label: 'Flutter',
    url: 'https://flutter.dev',
    color: Colors.cyan,
  ),
  GridItem(
    number: 10,
    icon: Icons.android,
    label: 'Android',
    url: 'https://developer.android.com',
    color: Colors.green,
  ),
  GridItem(
    number: 11,
    icon: Icons.apple,
    label: 'Apple',
    url: 'https://www.apple.com',
    color: Colors.grey,
  ),
  GridItem(
    number: 12,
    icon: Icons.music_note,
    label: 'Spotify',
    url: 'https://open.spotify.com',
    color: Colors.green,
  ),
];

// 화면 인식 및 가상 터치 관리자
class ScreenTouchManager {
  static String? _currentScreenshotPath;

  static Future<String> captureScreen() async {
    try {
      // 임시 파일 경로 생성
      final tempDir = Directory.systemTemp;
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      _currentScreenshotPath = '${tempDir.path}/screenshot_$timestamp.png';

      // Flutter에서 화면 캡처는 복잡하므로 임시로 시뮬레이션
      // 실제로는 MediaProjection API나 flutter_screenshot 패키지 사용
      print('화면 캡처 완료: $_currentScreenshotPath');

      return "화면 캡처 완료 - 현재 앱 화면";
    } catch (e) {
      return "화면 캡처 실패: $e";
    }
  }

  static Future<String> analyzeScreen(String screenData) async {
    try {
      // 배터리 최적화 체크
      BatteryOptimizer.updateActivityTime();
      if (BatteryOptimizer.shouldReduceActivity()) {
        return "배터리 최적화 모드: 화면 분석 제한됨";
      }

      // 권한 체크
      if (!PermissionManager.hasScreenCapturePermission) {
        return "화면 캡처 권한이 없습니다.";
      }

      // 민감한 정보 감지
      final sensitiveInfo = _detectSensitiveData(screenData);
      if (sensitiveInfo.isNotEmpty) {
        // 캡처 파일 즉시 삭제
        await cleanupScreenshot();
        return "민감한 정보가 포함되어 있습니다. 캡처 파일이 삭제되었습니다.";
      }

      // 화면 분석 시뮬레이션
      // 실제로는 OCR이나 이미지 분석 라이브러리 사용
      return "화면 분석 결과: 마이크 버튼, 설정 버튼, 대화 기록 영역, 4x3 그리드 영역 감지됨";
    } catch (e) {
      return "화면 분석 실패: $e";
    }
  }

  static List<String> _detectSensitiveData(String screenData) {
    List<String> detectedSensitiveInfo = [];

    // 키워드 기반 검사
    for (final keyword in SensitiveDataPatterns.sensitiveKeywords) {
      if (screenData.toLowerCase().contains(keyword.toLowerCase())) {
        detectedSensitiveInfo.add(keyword);
      }
    }

    // 정규식 패턴 검사
    for (final pattern in SensitiveDataPatterns.sensitivePatterns) {
      final matches = pattern.allMatches(screenData);
      if (matches.isNotEmpty) {
        detectedSensitiveInfo.add('패턴 매치: ${pattern.pattern}');
      }
    }

    return detectedSensitiveInfo;
  }

  static Future<void> cleanupScreenshot() async {
    try {
      if (_currentScreenshotPath != null) {
        final file = File(_currentScreenshotPath!);
        if (await file.exists()) {
          await file.delete();
          print('스크린샷 삭제 완료: $_currentScreenshotPath');
        }
        _currentScreenshotPath = null;
      }
    } catch (e) {
      print('스크린샷 삭제 실패: $e');
    }
  }

  static Future<bool> performVirtualTouch(
    double x,
    double y, {
    String gesture = 'tap',
  }) async {
    try {
      // 배터리 최적화 체크
      if (BatteryOptimizer.shouldReduceActivity()) {
        print('배터리 최적화 모드: 터치 동작 제한됨');
        return false;
      }

      // 권한 체크
      if (!PermissionManager.hasTouchPermission) {
        print('터치 권한이 없습니다.');
        return false;
      }

      // 가상 터치 시뮬레이션
      print('가상 터치 실행: ($x, $y) - $gesture');

      // 실제로는 Android의 Accessibility Service나
      // iOS의 UI Automation을 사용해야 함

      return true;
    } catch (e) {
      print('가상 터치 실패: $e');
      return false;
    }
  }

  static Future<bool> findAndTapElement(
    String elementName,
    Function(double, double, String)? onTouchCallback,
  ) async {
    try {
      // 요소 찾기 및 터치 시뮬레이션
      switch (elementName.toLowerCase()) {
        case '마이크':
        case 'mic':
        case 'microphone':
          final success = await performVirtualTouch(300, 600);
          if (success && onTouchCallback != null) {
            onTouchCallback(300, 600, '마이크 버튼');
          }
          return success;
        case '설정':
        case 'settings':
          final success = await performVirtualTouch(350, 50);
          if (success && onTouchCallback != null) {
            onTouchCallback(350, 50, '설정 버튼');
          }
          return success;
        default:
          // 그리드 아이템 번호로 찾기 (1~12)
          final number = int.tryParse(elementName);
          if (number != null && number >= 1 && number <= 12) {
            final index = number - 1;
            final x = 100.0 + (index % 4) * 80.0;
            final y = 400.0 + (index ~/ 4) * 80.0;
            final success = await performVirtualTouch(x, y);
            if (success && onTouchCallback != null) {
              onTouchCallback(x, y, '${number}번');
            }
            return success;
          }

          // 그리드 아이템 제목으로 찾기
          for (int i = 0; i < gridItems.length; i++) {
            final item = gridItems[i];
            if (elementName.toLowerCase() == item.label.toLowerCase() ||
                elementName.toLowerCase() ==
                    item.label.toLowerCase().replaceAll(' ', '') ||
                elementName.toLowerCase().contains(item.label.toLowerCase())) {
              final x = 100.0 + (i % 4) * 80.0;
              final y = 400.0 + (i ~/ 4) * 80.0;
              final success = await performVirtualTouch(x, y);
              if (success && onTouchCallback != null) {
                onTouchCallback(x, y, item.label);
              }
              return success;
            }
          }

          print('알 수 없는 요소: $elementName');
          return false;
      }
    } catch (e) {
      print('요소 찾기 실패: $e');
      return false;
    }
  }
}

// 화면 위 그리기 관리자
class OverlayManager {
  static bool _isOverlayActive = false;
  static Timer? _autoShutdownTimer;
  static const Duration _autoShutdownDuration = Duration(minutes: 2);

  static bool get isOverlayActive => _isOverlayActive;

  static void startOverlay() {
    _isOverlayActive = true;
    print('화면 위 그리기 활성화');

    // 자동 종료 타이머 시작
    _startAutoShutdownTimer();
  }

  static void stopOverlay() {
    _isOverlayActive = false;
    print('화면 위 그리기 비활성화');

    // 자동 종료 타이머 중지
    _stopAutoShutdownTimer();
  }

  static void _startAutoShutdownTimer() {
    _stopAutoShutdownTimer(); // 기존 타이머 중지

    _autoShutdownTimer = Timer(_autoShutdownDuration, () {
      print('2분 경과: 앱 자동 종료');
      _isOverlayActive = false;
      // 실제로는 앱 종료 로직 실행
      exit(0);
    });
  }

  static void _stopAutoShutdownTimer() {
    _autoShutdownTimer?.cancel();
    _autoShutdownTimer = null;
  }

  static void resetTimer() {
    if (_isOverlayActive) {
      _startAutoShutdownTimer();
      print('자동 종료 타이머 재설정');
    }
  }

  static String getRemainingTime() {
    if (_autoShutdownTimer == null) return '00:00';

    // 타이머의 남은 시간을 계산 (정확한 구현은 복잡하므로 시뮬레이션)
    return '01:45'; // 예시 값
  }
}

// 백그라운드 실행 표시 위젯
class BackgroundIndicator extends StatelessWidget {
  const BackgroundIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    if (!OverlayManager.isOverlayActive) return const SizedBox.shrink();

    return Positioned(
      top: 50,
      right: 20,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.9),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.record_voice_over, color: Colors.white, size: 16),
            const SizedBox(width: 6),
            Text(
              '음성 비서 실행 중',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              OverlayManager.getRemainingTime(),
              style: const TextStyle(color: Colors.white, fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }
}

// 설정 화면
class SettingsPage extends StatelessWidget {
  final bool confirmationEnabled;
  final ValueChanged<bool> onChanged;
  const SettingsPage({
    required this.confirmationEnabled,
    required this.onChanged,
    super.key,
  });
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('설정')),
      body: Column(
        children: [
          SwitchListTile(
            title: const Text('반문 기능 사용'),
            value: confirmationEnabled,
            onChanged: onChanged,
          ),
          const Divider(),
          // 보안 및 권한 설정
          const ListTile(
            title: Text(
              '보안 및 권한 설정',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            leading: Icon(Icons.security),
          ),
          SwitchListTile(
            title: const Text('민감한 정보 감지'),
            subtitle: const Text('화면에 민감한 정보가 포함되면 자동 삭제'),
            value: true,
            onChanged: (value) {
              // 민감한 정보 감지 설정
            },
          ),
          SwitchListTile(
            title: const Text('배터리 최적화'),
            subtitle: const Text('배터리 소모를 줄이기 위한 최적화'),
            value: BatteryOptimizer.isLowPowerMode,
            onChanged: (value) {
              BatteryOptimizer.setLowPowerMode(value);
            },
          ),
          ListTile(
            title: const Text('권한 요청'),
            subtitle: const Text('필요한 권한들을 요청합니다'),
            trailing: const Icon(Icons.admin_panel_settings),
            onTap: () async {
              await PermissionManager.requestScreenCapturePermission();
              await PermissionManager.requestTouchPermission();
              await PermissionManager.requestAccessibilityPermission();

              if (context.mounted) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('권한 요청 완료')));
              }
            },
          ),
          const Divider(),
          // 테스트 기능
          const ListTile(
            title: Text(
              '테스트 기능',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            leading: const Icon(Icons.science),
          ),
          ListTile(
            title: const Text('화면 인식 테스트'),
            subtitle: const Text('현재 화면을 캡처하고 분석합니다'),
            trailing: const Icon(Icons.camera_alt),
            onTap: () async {
              final screenData = await ScreenTouchManager.captureScreen();
              final analysis = await ScreenTouchManager.analyzeScreen(
                screenData,
              );

              if (context.mounted) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text('화면 분석: $analysis')));
              }
            },
          ),
          ListTile(
            title: const Text('가상 터치 테스트 (마이크)'),
            subtitle: const Text('마이크 버튼을 가상으로 터치합니다'),
            trailing: const Icon(Icons.touch_app),
            onTap: () async {
              final success = await ScreenTouchManager.findAndTapElement(
                '마이크',
                null, // SettingsPage에서는 콜백을 사용할 수 없으므로 null
              );

              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(success ? '가상 터치 성공!' : '가상 터치 실패'),
                    backgroundColor: success ? Colors.green : Colors.red,
                  ),
                );
              }
            },
          ),
          ListTile(
            title: const Text('가상 터치 테스트 (페이스북)'),
            subtitle: const Text('페이스북을 제목으로 찾아 터치합니다'),
            trailing: const Icon(Icons.facebook),
            onTap: () async {
              final success = await ScreenTouchManager.findAndTapElement(
                '페이스북',
                null,
              );

              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(success ? '페이스북 터치 성공!' : '페이스북 터치 실패'),
                    backgroundColor: success ? Colors.green : Colors.red,
                  ),
                );
              }
            },
          ),
          ListTile(
            title: const Text('가상 터치 테스트 (1번)'),
            subtitle: const Text('1번 그리드를 숫자로 찾아 터치합니다'),
            trailing: const Icon(Icons.tag),
            onTap: () async {
              final success = await ScreenTouchManager.findAndTapElement(
                '1',
                null,
              );

              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(success ? '1번 터치 성공!' : '1번 터치 실패'),
                    backgroundColor: success ? Colors.green : Colors.red,
                  ),
                );
              }
            },
          ),
          const Divider(),
          // 화면 위 그리기 제어
          const ListTile(
            title: Text(
              '화면 위 그리기 제어',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            leading: Icon(Icons.layers),
          ),
          SwitchListTile(
            title: const Text('화면 위 그리기 활성화'),
            subtitle: const Text('다른 앱 위에서 음성 비서 실행'),
            value: OverlayManager.isOverlayActive,
            onChanged: (value) {
              if (value) {
                OverlayManager.startOverlay();
              } else {
                OverlayManager.stopOverlay();
              }
            },
          ),
          ListTile(
            title: const Text('타이머 재설정'),
            subtitle: const Text('자동 종료 타이머를 2분으로 재설정'),
            trailing: const Icon(Icons.timer),
            onTap: () {
              OverlayManager.resetTimer();
              if (context.mounted) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('타이머가 재설정되었습니다.')));
              }
            },
          ),
          ListTile(
            title: const Text('앱 종료'),
            subtitle: const Text('음성 비서를 완전히 종료합니다'),
            trailing: const Icon(Icons.exit_to_app),
            onTap: () {
              exit(0);
            },
          ),
          const Divider(),
          // 권한 관리
          const ListTile(
            title: Text('권한 관리', style: TextStyle(fontWeight: FontWeight.bold)),
            leading: Icon(Icons.security),
          ),
          ListTile(
            title: const Text('모든 권한 요청'),
            subtitle: const Text('마이크, 저장소, 카메라, 화면 캡처 권한을 요청합니다'),
            trailing: const Icon(Icons.admin_panel_settings),
            onTap: () async {
              final success = await PermissionManager.requestAllPermissions();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success ? '모든 권한이 허용되었습니다!' : '일부 권한이 거부되었습니다.',
                    ),
                    backgroundColor: success ? Colors.green : Colors.orange,
                  ),
                );
              }
            },
          ),
          ListTile(
            title: const Text('마이크 권한 요청'),
            subtitle: const Text('음성 인식을 위한 마이크 권한을 요청합니다'),
            trailing: const Icon(Icons.mic),
            onTap: () async {
              final success = await PermissionManager.requestAudioPermission();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success ? '마이크 권한이 허용되었습니다!' : '마이크 권한이 거부되었습니다.',
                    ),
                    backgroundColor: success ? Colors.green : Colors.red,
                  ),
                );
              }
            },
          ),
          ListTile(
            title: const Text('저장소 권한 요청'),
            subtitle: const Text('파일 저장을 위한 저장소 권한을 요청합니다'),
            trailing: const Icon(Icons.folder),
            onTap: () async {
              final success =
                  await PermissionManager.requestStoragePermission();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success ? '저장소 권한이 허용되었습니다!' : '저장소 권한이 거부되었습니다.',
                    ),
                    backgroundColor: success ? Colors.green : Colors.red,
                  ),
                );
              }
            },
          ),
          ListTile(
            title: const Text('카메라 권한 요청'),
            subtitle: const Text('화면 캡처를 위한 카메라 권한을 요청합니다'),
            trailing: const Icon(Icons.camera_alt),
            onTap: () async {
              final success = await PermissionManager.requestCameraPermission();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success ? '카메라 권한이 허용되었습니다!' : '카메라 권한이 거부되었습니다.',
                    ),
                    backgroundColor: success ? Colors.green : Colors.red,
                  ),
                );
              }
            },
          ),
          const Divider(),
          // 서버 연결 테스트
          const ListTile(
            title: Text(
              '서버 연결 테스트',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            leading: Icon(Icons.cloud),
          ),
          ListTile(
            title: const Text('LLM 서버 연결 테스트'),
            subtitle: Text('현재 서버: ${ServerConfig.llmUrl}'),
            trailing: const Icon(Icons.wifi),
            onTap: () async {
              try {
                final response = await http.get(
                  Uri.parse(ServerConfig.baseUrl),
                );
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('서버 연결 성공: ${response.statusCode}'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('서버 연결 실패: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
          ),
          ListTile(
            title: const Text('TTS 서버 연결 테스트'),
            subtitle: Text('현재 서버: ${ServerConfig.ttsUrl}'),
            trailing: const Icon(Icons.volume_up),
            onTap: () async {
              try {
                final response = await http.post(
                  Uri.parse(ServerConfig.ttsUrl),
                  body: {'text': '테스트 음성입니다.'},
                );
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('TTS 서버 연결 성공: ${response.statusCode}'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('TTS 서버 연결 실패: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
          ),
        ],
      ),
    );
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _text = '';
  double _confidence = 0.0;
  String _response = '';
  bool _isListening = false;
  bool isWaiting = false;
  String _screenAnalysis = '';
  List<Map<String, dynamic>> _touchIndicators = [];
  bool _showTouchIndicators = false;
  bool confirmationEnabled = true;
  final player = AudioPlayer();
  FlutterSoundRecorder? _recorder;
  bool _isRecording = false;
  String? _recordedFilePath;
  Timer? _recordingTimeoutTimer;
  DateTime _lastVoiceInputTime = DateTime.now();
  final int _timeoutSeconds = 3; // 무음 대기 시간(초)
  bool _isHotwordMode = false; // 대기/반복 인식 모드
  // 상태 변수
  String _voiceStatus = '';
  Color _voiceStatusColor = Colors.blue;
  Timer? _silenceTimer;
  StreamSubscription? _recorderSubscription;

  // 실제 음성 인식 객체
  // stt.SpeechToText? _speechToText; // 삭제
  bool _speechEnabled = false;

  @override
  void initState() {
    super.initState();
    _recorder = FlutterSoundRecorder();
    _initRecorder();
    _requestPermissions();
  }

  Future<void> _initRecorder() async {
    await _recorder!.openRecorder();
  }

  Future<void> _startHotwordMode() async {
    setState(() {
      _isHotwordMode = true;
      _voiceStatus = '실시간 음성인식 대기중';
      _voiceStatusColor = Colors.grey;
    });
    await _startContinuousRecording();
  }

  Future<void> _startContinuousRecording() async {
    final tempDir = await Directory.systemTemp.createTemp();
    _recordedFilePath = '${tempDir.path}/recorded.wav';
    _lastVoiceInputTime = DateTime.now();
    _silenceTimer?.cancel();
    await _recorder!.startRecorder(
      toFile: _recordedFilePath,
      codec: Codec.pcm16WAV,
    );
    setState(() { _isRecording = true; });
    _recorderSubscription = _recorder!.onProgress!.listen((event) {
      if (event.decibels != null && event.decibels! > -40) {
        // 음성 입력 감지됨
        if (_voiceStatus != '음성인식중') {
          setState(() {
            _voiceStatus = '음성인식중';
            _voiceStatusColor = Colors.blue;
          });
        }
        _lastVoiceInputTime = DateTime.now();
        _silenceTimer?.cancel();
      } else {
        // 무음 감지: 1초 이상 무음이면 자동 종료 및 분석
        _silenceTimer ??= Timer(Duration(seconds: 1), () async {
          await _recorder!.stopRecorder();
          _recorderSubscription?.cancel();
          setState(() {
            _isRecording = false;
            _voiceStatus = '분석중';
            _voiceStatusColor = Colors.orange;
          });
          await Future.delayed(Duration(seconds: 1));
          if (_recordedFilePath != null) {
            final file = File(_recordedFilePath!);
            if (await file.length() < 500) {
              setState(() {
                _voiceStatus = '무음 또는 소음만 감지됨';
                _voiceStatusColor = Colors.red;
              });
              print('[INFO] 무음/소음만 감지됨, 분석/터치 생략. 파일 크기: ${await file.length()}B');
            } else {
              setState(() {
                _voiceStatus = '작동중';
                _voiceStatusColor = Colors.green;
              });
              final transcript = await sendAudioToServer(_recordedFilePath!);
              setState(() {
                _text = transcript ?? '음성 인식 실패';
                if (transcript != null && transcript.isNotEmpty) {
                  _voiceStatus = '작동중';
                  _voiceStatusColor = Colors.green;
                  transcriptHistory.add(transcript);
                } else {
                  _voiceStatus = '음성 인식 실패';
                  _voiceStatusColor = Colors.red;
                }
              });
              if (transcript != null && transcript.isNotEmpty) {
                await captureScreenAndSendToServer(transcript);
              }
            }
          }
          // 분석이 끝나면 다시 실시간 대기 상태로 복귀
          setState(() {
            _voiceStatus = '실시간 음성인식 대기중';
            _voiceStatusColor = Colors.grey;
          });
          // 바로 다시 녹음 시작
          await _startContinuousRecording();
          _silenceTimer = null;
        });
      }
    });
  }

  Future<void> _stopHotwordMode() async {
    setState(() {
      _isHotwordMode = false;
      _isRecording = false;
      _voiceStatus = '음성인식 꺼짐';
      _voiceStatusColor = Colors.grey;
    });
    await _recorder?.stopRecorder();
    _recorderSubscription?.cancel();
    _silenceTimer?.cancel();
  }

  Future<void> _startRecordingAndProcessOnce() async {
    final tempDir = await Directory.systemTemp.createTemp();
    _recordedFilePath = '${tempDir.path}/recorded.wav';
    _lastVoiceInputTime = DateTime.now();
    _silenceTimer?.cancel();
    setState(() {
      _voiceStatus = '음성인식중';
      _voiceStatusColor = Colors.blue;
    });

    await _recorder!.startRecorder(
      toFile: _recordedFilePath,
      codec: Codec.pcm16WAV,
    );
    setState(() { _isRecording = true; });

    // 실시간 볼륨 감지
    _recorderSubscription = _recorder!.onProgress!.listen((event) {
      if (event.decibels != null && event.decibels! > -40) {
        _lastVoiceInputTime = DateTime.now();
        _silenceTimer?.cancel();
      } else {
        _silenceTimer ??= Timer(Duration(seconds: 1), () async {
          await _processAfterRecording();
          _silenceTimer = null;
        });
      }
    });

    // 분석/작동을 await 없이 비동기로 실행
    _processAfterRecording();
  }

  Future<void> _processAfterRecording() async {
    _recordingTimeoutTimer?.cancel();
    _silenceTimer?.cancel();
    await _recorder!.stopRecorder();
    _recorderSubscription?.cancel();
    setState(() {
      _isRecording = false;
      _voiceStatus = '분석중';
      _voiceStatusColor = Colors.orange;
    });
    await Future.delayed(Duration(seconds: 1));
    if (_recordedFilePath != null) {
      final file = File(_recordedFilePath!);
      if (await file.length() < 500) {
        setState(() {
          _voiceStatus = '무음 또는 소음만 감지됨';
          _voiceStatusColor = Colors.red;
        });
        print('[INFO] 무음/소음만 감지됨, 분석/터치 생략. 파일 크기: ${await file.length()}B');
        return;
      }
      setState(() {
        _voiceStatus = '작동중';
        _voiceStatusColor = Colors.green;
      });
      final transcript = await sendAudioToServer(_recordedFilePath!);
      setState(() {
        _text = transcript ?? '음성 인식 실패';
        if (transcript != null && transcript.isNotEmpty) {
          _voiceStatus = '작동중';
          _voiceStatusColor = Colors.green;
          transcriptHistory.add(transcript);
        } else {
          _voiceStatus = '음성 인식 실패';
          _voiceStatusColor = Colors.red;
        }
      });
      if (transcript != null && transcript.isNotEmpty) {
        await captureScreenAndSendToServer(transcript);
      }
    }
  }

  Future<void> captureScreenAndSendToServer(String userCommand) async {
    String screenshotPath = await ScreenTouchManager.captureScreen();
    File imageFile = File(screenshotPath);
    String imageBase64 = base64Encode(await imageFile.readAsBytes());
    final response = await http.post(
      Uri.parse('${ServerConfig.baseUrl}/analyze-image'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'image': imageBase64, 'command': userCommand}),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      double x = data['x']?.toDouble() ?? 0;
      double y = data['y']?.toDouble() ?? 0;
      await ScreenTouchManager.performVirtualTouch(x, y);
      _addTouchIndicator(x, y, 'AI 터치');
    } else {
      print('이미지 분석 서버 오류: ${response.body}');
    }
  }

  @override
  void dispose() {
    _recorderSubscription?.cancel();
    _recorder?.closeRecorder();
    _recordingTimeoutTimer?.cancel();
    _silenceTimer?.cancel();
    super.dispose();
  }

  // Future<void> _initializeSpeech() async { // 삭제
  //   _speechToText = stt.SpeechToText(); // 삭제
  //   _speechEnabled = await _speechToText!.initialize(); // 삭제
  //   print('음성 인식 초기화: $_speechEnabled'); // 삭제
  // } // 삭제

  Future<void> _requestPermissions() async {
    final success = await PermissionManager.requestAllPermissions();
    if (success) {
      print('모든 권한이 허용되었습니다.');
    } else {
      print('일부 권한이 거부되었습니다.');
    }
  }

  void _addTouchIndicator(double x, double y, String label) {
    setState(() {
      _touchIndicators.add({
        'x': x,
        'y': y,
        'label': label,
        'timestamp': DateTime.now(),
      });
      _showTouchIndicators = true;
    });

    // 3초 후 터치 표시 제거
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _touchIndicators.removeWhere(
            (indicator) =>
                indicator['timestamp'] == _touchIndicators.last['timestamp'],
          );
          if (_touchIndicators.isEmpty) {
            _showTouchIndicators = false;
          }
        });
      }
    });
  }

  Future<void> _listen() async {
    // if (!PermissionManager.hasAudioPermission) { // 삭제
    //   print('마이크 권한이 없습니다. 권한을 요청합니다.'); // 삭제
    //   final granted = await PermissionManager.requestAudioPermission(); // 삭제
    //   if (!granted) { // 삭제
    //     setState(() { // 삭제
    //       _text = "마이크 권한이 필요합니다. 설정에서 권한을 허용해주세요."; // 삭제
    //       _confidence = 0.0; // 삭제
    //     }); // 삭제
    //     return; // 삭제
    //   } // 삭제
    // } // 삭제
    setState(() {
      _isListening = true;
    });
    try {
      // if (_speechEnabled && _speechToText != null) { // 삭제
      //   await _speechToText!.listen( // 삭제
      //     onResult: (result) { // 삭제
      //       setState(() { // 삭제
      //         _text = result.recognizedWords; // 삭제
      //         _confidence = result.confidence; // 삭제
      //         _isListening = false; // 삭제
      //       }); // 삭제
      //     }, // 삭제
      //   ); // 삭제
      // } else { // 삭제
      //   setState(() { // 삭제
      //     _text = "음성 인식이 초기화되지 않았습니다."; // 삭제
      //     _confidence = 0.0; // 삭제
      //     _isListening = false; // 삭제
      //   }); // 삭제
      // } // 삭제
      // 화면 위 그리기 활성화 및 타이머 재설정
      OverlayManager.startOverlay();
      OverlayManager.resetTimer();
      // 화면 인식 및 분석
      await _analyzeCurrentScreen();
      // LLM 호출
      await _sendToLLM(_text, _confidence);
    } catch (e) {
      setState(() {
        _text = "음성 인식 중 오류가 발생했습니다: $e";
        _confidence = 0.0;
        _isListening = false;
      });
    }
  }

  Future<void> _analyzeCurrentScreen() async {
    try {
      final screenData = await ScreenTouchManager.captureScreen();
      final analysis = await ScreenTouchManager.analyzeScreen(screenData);

      setState(() {
        _screenAnalysis = analysis;
      });
    } catch (e) {
      setState(() {
        _screenAnalysis = '화면 분석 실패: $e';
      });
    }
  }

  Future<void> _sendToLLM(String text, double confidence) async {
    setState(() {
      isWaiting = true;
    });

    final startTime = DateTime.now();
    String logMessage = '';

    try {
      logMessage += '[${startTime.toIso8601String()}] LLM 요청 시작\n';
      logMessage += '- 입력 텍스트: $text\n';
      logMessage += '- 신뢰도: $confidence\n';
      logMessage += '- 화면 분석: $_screenAnalysis\n';

      final response = await http.post(
        Uri.parse(ServerConfig.llmUrl),
        body: {
          'text': text,
          'confidence': confidence.toString(),
          'screen_analysis': _screenAnalysis,
        },
      );

      final endTime = DateTime.now();
      final duration = endTime.difference(startTime);

      logMessage +=
          '[${endTime.toIso8601String()}] LLM 응답 수신 (${duration.inMilliseconds}ms)\n';
      logMessage += '- HTTP 상태: ${response.statusCode}\n';

      final data = json.decode(response.body);
      logMessage += '- 응답 데이터: ${data.toString()}\n';

      setState(() {
        _response = data['response_text'] ?? '서버 응답을 받았습니다.';
        conversationHistory.add(data);
        isWaiting = false;
      });

      await _playTTS(_response);

      // 명령어 처리(가상 터치 등)
      if (data['action'] != null) {
        logMessage += '- 액션 감지: ${data['action']}\n';
        await _handleAction(data['action']);
      }

      // 반문 루프
      if (data['confirmation_required'] == true && confirmationEnabled) {
        logMessage += '- 반문 루프 시작\n';
        // 다시 음성 인식 루프
        await _listen();
      }

      // 화면 캡처 자동 삭제
      await ScreenTouchManager.cleanupScreenshot();
      logMessage += '- 화면 캡처 파일 삭제 완료\n';

      // 로그 출력
      print('=== LLM 처리 로그 ===');
      print(logMessage);
      print('=====================');
    } catch (e) {
      final errorTime = DateTime.now();
      final duration = errorTime.difference(startTime);

      logMessage +=
          '[${errorTime.toIso8601String()}] 오류 발생 (${duration.inMilliseconds}ms)\n';
      logMessage += '- 오류 내용: $e\n';

      print('=== LLM 처리 로그 (오류) ===');
      print(logMessage);
      print('==========================');

      setState(() {
        _response = '서버 연결 오류: $e';
        isWaiting = false;
      });
    }
  }

  Future<void> _handleAction(Map<String, dynamic> action) async {
    try {
      final actionType = action['type'] as String?;
      final target = action['target'] as String?;

      // 작업 전 확인 음성 출력
      String confirmationMessage = '';
      if (actionType == 'tap' && target != null) {
        // 그리드 아이템인지 확인
        final number = int.tryParse(target);
        if (number != null && number >= 1 && number <= 12) {
          final item = gridItems[number - 1];
          confirmationMessage = '${item.label}을 열어드리겠습니다.';
        } else {
          // 제목으로 찾기
          for (final item in gridItems) {
            if (target.toLowerCase() == item.label.toLowerCase() ||
                target.toLowerCase() ==
                    item.label.toLowerCase().replaceAll(' ', '') ||
                target.toLowerCase().contains(item.label.toLowerCase())) {
              confirmationMessage = '${item.label}을 열어드리겠습니다.';
              break;
            }
          }
        }

        if (confirmationMessage.isEmpty) {
          confirmationMessage = '$target을 터치하겠습니다.';
        }
      } else {
        confirmationMessage = '요청하신 작업을 실행하겠습니다.';
      }

      // 디버그 내역 출력
      print('=== 작업 확인 메시지 ===');
      print(confirmationMessage);
      print('=======================');

      // 확인 음성 출력 (디버그 내역 사용)
      await _playTTS(confirmationMessage);

      // 잠시 대기 후 작업 실행
      await Future.delayed(const Duration(seconds: 1));

      switch (actionType) {
        case 'tap':
          if (target != null) {
            await ScreenTouchManager.findAndTapElement(
              target,
              _addTouchIndicator,
            );
          }
          break;
        case 'swipe':
          // 스와이프 제스처 처리
          break;
        case 'long_press':
          // 롱 프레스 처리
          break;
        default:
          print('알 수 없는 액션: $actionType');
      }

      // 서버에 명령 실행 결과 전송
      await http.post(
        Uri.parse('http://10.0.2.2:8000/command'),
        body: json.encode({
          'action': action,
          'result': 'success',
          'timestamp': DateTime.now().toIso8601String(),
        }),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      print('액션 처리 실패: $e');
    }
  }

  Future<void> _playTTS(String text) async {
    try {
      final response = await http.post(
        Uri.parse(ServerConfig.ttsUrl),
        body: {'text': text},
      );
      final bytes = response.bodyBytes;
      final file = File('${Directory.systemTemp.path}/output.mp3');
      await file.writeAsBytes(bytes);
      await player.play(DeviceFileSource(file.path));
    } catch (e) {
      print('TTS 오류: $e');
    }
  }

  /// (1) 음성 파일을 서버로 전송해 텍스트로 변환
  Future<String?> sendAudioToServer(String filePath) async {
    File audioFile = File(filePath);
    List<int> audioBytes = await audioFile.readAsBytes();
    String audioBase64 = base64Encode(audioBytes);

    final response = await http.post(
      Uri.parse('${ServerConfig.baseUrl}/speech-to-text'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'audio': audioBase64}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['transcript'];
    } else {
      print('서버 오류: \n${response.body}');
      return null;
    }
  }

  /// (2) 텍스트 명령을 서버로 전송해 AI 응답을 받는 함수
  Future<String?> sendTextToLLM(String text) async {
    final response = await http.post(
      Uri.parse(ServerConfig.llmUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'text': text}),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['response_text'];
    } else {
      print('LLM 서버 오류: \n${response.body}');
      return null;
    }
  }

  /// (3) 텍스트를 서버로 전송해 TTS 음성(mp3) 파일을 받아 재생하는 함수
  Future<void> playTTSAudioFromServer(String text) async {
    final response = await http.post(
      Uri.parse(ServerConfig.ttsUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'text': text}),
    );
    if (response.statusCode == 200) {
      final bytes = response.bodyBytes;
      final file = File('${Directory.systemTemp.path}/output.mp3');
      await file.writeAsBytes(bytes);
      final player = AudioPlayer();
      await player.play(DeviceFileSource(file.path));
    } else {
      print('TTS 서버 오류: \n${response.body}');
    }
  }

  /// Google Speech-to-Text API를 호출하여 음성 파일을 텍스트로 변환하는 함수
  // Future<String?> speechToTextFromFile(String filePath) async { // 삭제
  //   final apiKey = dotenv.env['GOOGLE_SPEECH_API_KEY'] ?? ''; // 삭제
  //   if (apiKey.isEmpty) { // 삭제
  //     print('API 키가 설정되어 있지 않습니다.'); // 삭제
  //     return null; // 삭제
  //   } // 삭제
  //   try { // 삭제
  //     File audioFile = File(filePath); // 삭제
  //     List<int> audioBytes = await audioFile.readAsBytes(); // 삭제
  //     String audioBase64 = base64Encode(audioBytes); // 삭제
  // 삭제
  //     final url = 'https://speech.googleapis.com/v1/speech:recognize?key=$apiKey'; // 삭제
  //     final body = jsonEncode({ // 삭제
  //       "config": { // 삭제
  //         "encoding": "LINEAR16", // 삭제
  //         "sampleRateHertz": 16000, // 삭제
  //         "languageCode": "ko-KR" // 삭제
  //       }, // 삭제
  //       "audio": { // 삭제
  //         "content": audioBase64 // 삭제
  //       } // 삭제
  //     }); // 삭제
  // 삭제
  //     final response = await http.post( // 삭제
  //       Uri.parse(url), // 삭제
  //       headers: {"Content-Type": "application/json"}, // 삭제
  //       body: body, // 삭제
  //     ); // 삭제
  // 삭제
  //     if (response.statusCode == 200) { // 삭제
  //       final data = jsonDecode(response.body); // 삭제
  //       return data['results']?[0]?['alternatives']?[0]?['transcript']; // 삭제
  //     } else { // 삭제
  //       print('Google Speech-to-Text 오류: \n${response.body}'); // 삭제
  //       return null; // 삭제
  //     } // 삭제
  //   } catch (e) { // 삭제
  //     print('음성 파일 변환 오류: $e'); // 삭제
  //     return null; // 삭제
  //   } // 삭제
  // } // 삭제

  @override
  Widget build(BuildContext context) {
    print('build 함수 호출');
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('LLM 음성 비서 프로토타입'),
          actions: [
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SettingsPage(
                      confirmationEnabled: confirmationEnabled,
                      onChanged: (val) {
                        setState(() {
                          confirmationEnabled = val;
                        });
                        Navigator.pop(context);
                      },
                    ),
                  ),
                );
              },
            ),
          ],
        ),
        floatingActionButton: Stack(
          children: [
            Positioned(
              right: 0,
              bottom: 0,
              child: FloatingActionButton(
                onPressed: _isHotwordMode ? _stopHotwordMode : _startHotwordMode,
                backgroundColor: _isHotwordMode ? Colors.red : null,
                child: Icon(_isHotwordMode ? Icons.stop : Icons.mic),
              ),
            ),
            if (_isRecording)
              const Positioned(
                right: 70,
                bottom: 10,
                child: Icon(Icons.hearing, color: Colors.green, size: 40),
              ),
          ],
        ),
        body: Stack(
          children: [
            Column(
              children: [
                if (isWaiting) const LinearProgressIndicator(),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('음성 인식 결과: $_text'),
                      Text(
                        '상태: $_voiceStatus',
                        style: TextStyle(
                          color: _voiceStatusColor,
                          fontSize: 24, // 1.5배 크기
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text('신뢰도: $_confidence'),
                      Text('AI 응답: $_response'),
                      const SizedBox(height: 16),
                      if (_screenAnalysis.isNotEmpty) ...[
                        const Text(
                          '화면 분석:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          _screenAnalysis,
                          style: const TextStyle(fontSize: 12),
                        ),
                        const SizedBox(height: 16),
                      ],
                      const Text('대화 맥락(최근 5개):'),
                      if (transcriptHistory.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: transcriptHistory.reversed.take(5).map((t) => Text(
                              '• $t',
                              style: TextStyle(fontSize: 16, color: Colors.black87),
                            )).toList(),
                          ),
                        ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      // 대화 기록
                      Container(
                        height: 150,
                        child: ListView(
                          children: conversationHistory.reversed
                              .take(3)
                              .map(
                                (e) => ListTile(
                                  title: Text(e['response_text'] ?? ''),
                                  subtitle: Text(e.toString()),
                                ),
                              )
                              .toList(),
                        ),
                      ),
                      const Divider(),
                      // 4x3 그리드 영역
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(16.0),
                          child: GridView.builder(
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 4,
                                  crossAxisSpacing: 8.0,
                                  mainAxisSpacing: 8.0,
                                  childAspectRatio: 1.0,
                                ),
                            itemCount: gridItems.length,
                            itemBuilder: (context, index) {
                              final item = gridItems[index];
                              return GestureDetector(
                                onTap: () async {
                                  // 화면 위 그리기 활성화
                                  OverlayManager.startOverlay();

                                  // 터치 표시 추가
                                  _addTouchIndicator(
                                    100 + (index % 4) * 80,
                                    400 + (index ~/ 4) * 80,
                                    '${item.number}번',
                                  );

                                  // URL 실행
                                  try {
                                    final uri = Uri.parse(item.url);
                                    if (await canLaunchUrl(uri)) {
                                      await launchUrl(
                                        uri,
                                        mode: LaunchMode.externalApplication,
                                      );
                                    }
                                  } catch (e) {
                                    print('URL 실행 실패: $e');
                                  }
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: item.color.withOpacity(0.8),
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.2),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        item.icon,
                                        color: Colors.white,
                                        size: 24,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${item.number}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      Text(
                                        item.label,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                        ),
                                        textAlign: TextAlign.center,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            // 가상 터치 표시 오버레이
            if (_showTouchIndicators)
              ...(_touchIndicators
                  .map(
                    (indicator) => Positioned(
                      left: indicator['x'] - 25,
                      top: indicator['y'] - 25,
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.7),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: Center(
                          child: Text(
                            indicator['label'],
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                  )
                  .toList()),
            // 백그라운드 실행 표시
            const BackgroundIndicator(),
            // 마이크 ON 배지
            if (_isHotwordMode || _isRecording)
              Positioned(
                top: 16,
                left: 16,
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 300),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: _voiceStatus == '음성인식중'
                        ? Colors.redAccent
                        : Colors.green.shade600,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedContainer(
                        duration: Duration(milliseconds: 300),
                        width: _voiceStatus == '음성인식중' ? 32 : 24,
                        height: _voiceStatus == '음성인식중' ? 32 : 24,
                        child: Icon(Icons.mic, color: Colors.white),
                      ),
                      SizedBox(width: 8),
                      Text(
                        _voiceStatus == '음성인식중' ? '음성입력중' : '마이크 ON',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

Future<void> main() async {
  print('main 시작');
  // await dotenv.load(); // 삭제
  print('dotenv 로드 완료'); // 필요시 삭제
  runApp(const MyApp());
}

// 예시: dotenv에서 API 키 읽기
// String apiKey = dotenv.env['GOOGLE_SPEECH_API_KEY'] ?? '';
