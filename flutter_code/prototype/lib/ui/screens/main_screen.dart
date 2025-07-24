import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:app_settings/app_settings.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../services/accessibility_service.dart';
import '../../services/audio_service.dart';
import '../../services/network_service.dart';
import '../../services/ai_service.dart';
import '../../models/ui_element.dart';
import '../widgets/accessibility_overlay.dart';
import '../widgets/touch_indicator.dart';
import '../../config/app_config.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final AccessibilityService _accessibilityService = AccessibilityService();
  final AudioService _audioService = AudioService();
  final NetworkService _networkService = NetworkService();
  final AIService _aiService = AIService();
  
  // 상태 변수
  bool _isAccessibilityEnabled = false;
  bool _isListening = false;
  String _voiceCommand = '';
  String _statusMessage = '접근성 서비스를 활성화해주세요';
  UIElement? _highlightedElement;
  List<UIElement> _currentElements = [];
  bool _showElementInfo = false;
  bool _isServerConnected = false;
  String _serverStatus = '서버 연결 확인 중...';
  
  // 가상터치 시각적 피드백
  Offset? _touchPosition;
  bool _showTouchIndicator = false;
  
  // 버튼 위치 추적을 위한 GlobalKey 리스트
  final List<GlobalKey> _buttonKeys = List.generate(12, (index) => GlobalKey());
  
  // 테스트용 그리드 버튼들 (크롬 기반 12개)
  final List<Map<String, dynamic>> _gridButtons = [
    {'id': '1', 'text': 'Google', 'url': 'https://google.com', 'description': '검색'},
    {'id': '2', 'text': 'YouTube', 'url': 'https://youtube.com', 'description': '동영상'},
    {'id': '3', 'text': 'Naver', 'url': 'https://naver.com', 'description': '포털'},
    {'id': '4', 'text': 'Daum', 'url': 'https://daum.net', 'description': '포털'},
    {'id': '5', 'text': 'GitHub', 'url': 'https://github.com', 'description': '개발'},
    {'id': '6', 'text': 'Stack', 'url': 'https://stackoverflow.com', 'description': '개발'},
    {'id': '7', 'text': 'Facebook', 'url': 'https://facebook.com', 'description': '소셜'},
    {'id': '8', 'text': 'Twitter', 'url': 'https://twitter.com', 'description': '소셜'},
    {'id': '9', 'text': 'Instagram', 'url': 'https://instagram.com', 'description': '소셜'},
    {'id': '10', 'text': 'LinkedIn', 'url': 'https://linkedin.com', 'description': '비즈니스'},
    {'id': '11', 'text': 'Reddit', 'url': 'https://reddit.com', 'description': '커뮤니티'},
    {'id': '12', 'text': 'Wikipedia', 'url': 'https://wikipedia.org', 'description': '백과사전'},
  ];

  // 가상터치 테스트용 버튼들 (크롬 기반)
  final List<Map<String, dynamic>> _testButtons = [
    {'id': '1', 'text': 'Google', 'description': '검색', 'x': 100, 'y': 200},
    {'id': '2', 'text': 'YouTube', 'description': '동영상', 'x': 300, 'y': 200},
    {'id': '3', 'text': 'Naver', 'description': '포털', 'x': 500, 'y': 200},
    {'id': '4', 'text': 'GitHub', 'description': '개발', 'x': 100, 'y': 400},
    {'id': '5', 'text': 'Facebook', 'description': '소셜', 'x': 300, 'y': 400},
  ];

  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    // 백엔드 서버 연결 테스트
    await _testBackendConnection();
    
    // 접근성 서비스 초기화
    await _accessibilityService.initialize();
    
    // 접근성 서비스 상태 확인
    final isEnabled = await _accessibilityService.requestAccessibilityPermission();
    setState(() {
      _isAccessibilityEnabled = isEnabled;
      _statusMessage = isEnabled 
          ? '음성 명령을 말씀해주세요' 
          : '설정에서 접근성 서비스를 활성화해주세요';
    });

    // 접근성 이벤트 리스너 설정
    _accessibilityService.elementsStream?.listen((elements) {
      setState(() {
        _currentElements = elements;
      });
    });

    // 하이라이트 이벤트 리스너 설정
    _accessibilityService.highlightStream?.listen((element) {
      setState(() {
        _highlightedElement = element;
      });
    });
  }

  /// 백엔드 서버 연결 테스트
  Future<void> _testBackendConnection() async {
    setState(() {
      _serverStatus = '서버 연결 테스트 중...';
    });

    try {
      // 서버 연결 확인
      final isConnected = await _networkService.checkServerConnection();
      
      if (isConnected) {
        // 서버 상태 확인
        final status = await _networkService.getServerStatus();
        
        setState(() {
          _isServerConnected = true;
          _serverStatus = '서버 연결 성공: ${status['status'] ?? 'OK'}';
        });
        
        print('✅ 백엔드 서버 연결 성공');
      } else {
        setState(() {
          _isServerConnected = false;
          _serverStatus = '서버 연결 실패: ${_networkService.lastError}';
        });
        
        print('❌ 백엔드 서버 연결 실패: ${_networkService.lastError}');
      }
    } catch (e) {
      setState(() {
        _isServerConnected = false;
        _serverStatus = '서버 연결 오류: $e';
      });
      
      print('❌ 백엔드 서버 연결 오류: $e');
    }
  }

  /// 백엔드 API 테스트
  Future<void> _testBackendAPIs() async {
    setState(() {
      _statusMessage = '백엔드 API 테스트 중...';
    });

    try {
      // 1. TTS 테스트
      final ttsResult = await _networkService.postRequest('/tts', {
        'text': '백엔드 연결 테스트입니다.'
      });
      
      if (ttsResult != null) {
        print('✅ TTS API 테스트 성공');
      } else {
        print('❌ TTS API 테스트 실패');
      }

      // 2. LLM 테스트
      final llmResult = await _networkService.postRequest('/llm', {
        'text': '안녕하세요',
        'confidence': '0.8',
        'screen_analysis': '테스트 화면'
      });
      
      if (llmResult != null) {
        print('✅ LLM API 테스트 성공');
        setState(() {
          _statusMessage = '백엔드 API 테스트 완료';
        });
      } else {
        print('❌ LLM API 테스트 실패');
      }

    } catch (e) {
      print('❌ 백엔드 API 테스트 오류: $e');
      setState(() {
        _statusMessage = '백엔드 API 테스트 실패: $e';
      });
    }
  }

  /// 음성 인식 시작
  Future<void> _startVoiceRecognition() async {
    if (!_isAccessibilityEnabled) {
      _showAccessibilityDialog();
      return;
    }

    setState(() {
      _isListening = true;
      _statusMessage = '음성을 듣고 있습니다...';
    });

    try {
      // 1. 음성 녹음 및 STT
      final transcript = await _audioService.startRecording();
      if (transcript != null && transcript.isNotEmpty) {
        setState(() {
          _voiceCommand = transcript;
          _statusMessage = '음성 분석 중...';
        });

        // 2. 백엔드로 음성 명령 전송하여 AI 분석
        final aiResult = await _aiService.analyzeVoiceCommand(transcript);
        
        if (aiResult != null && aiResult['action'] != null) {
          final action = aiResult['action'];
          final actionType = action['type'];
          final target = action['target'];
          
          setState(() {
            _statusMessage = 'AI 분석 완료: $actionType - $target';
          });

          // 3. 가상 터치 실행 (README.md 방향성)
          bool touchResult = false;
          
          if (actionType == 'tap' || actionType == 'click') {
            // 숫자 명령 처리 (1번, 2번 등)
            final buttonIndex = int.tryParse(target) ?? 0;
            if (buttonIndex > 0 && buttonIndex <= _gridButtons.length) {
              final button = _gridButtons[buttonIndex - 1];
              touchResult = await _performVirtualTouch(button);
            }
          } else if (actionType == 'open' || actionType == 'launch') {
            // 서비스명으로 직접 실행 (페이스북, 유튜브 등)
            final serviceName = target.toLowerCase();
            final matchingButton = _gridButtons.firstWhere(
              (button) => button['description'].toString().toLowerCase().contains(serviceName),
              orElse: () => _gridButtons[0],
            );
            touchResult = await _performVirtualTouch(matchingButton);
          } else if (actionType == 'scroll') {
            touchResult = await _accessibilityService.performScroll('down');
          }

          if (touchResult) {
            setState(() {
              _statusMessage = '가상 터치 실행 완료: $target';
            });
            await _audioService.playTTS('$target 실행 완료');
          } else {
            setState(() {
              _statusMessage = '가상 터치 실행 실패';
            });
            await _audioService.playTTS('실행에 실패했습니다');
          }
        } else {
          setState(() {
            _statusMessage = 'AI 분석 실패';
          });
          await _audioService.playTTS('명령을 이해할 수 없습니다');
        }
      } else {
        setState(() {
          _statusMessage = '음성을 인식할 수 없습니다';
        });
        await _audioService.playTTS('음성을 인식할 수 없습니다');
      }
    } catch (e) {
      setState(() {
        _statusMessage = '음성 인식 오류: $e';
      });
      print('음성 인식 오류: $e');
    } finally {
      setState(() {
        _isListening = false;
      });
    }
  }

  /// 가상 터치 실행 (README.md 방향성에 맞춰 URL 실행)
  Future<bool> _performVirtualTouch(Map<String, dynamic> button) async {
    try {
      final url = button['url'] as String;
      final text = button['text'] as String;
      final description = button['description'] as String;
      
      if (url.isNotEmpty) {
        print('🎯 가상 터치 실행: $text ($description) -> $url');
        
        // 상태 메시지 업데이트
        setState(() {
          _statusMessage = '$text ($description) 실행 중...';
        });
        
        // 가상터치 시각적 피드백 표시 (터치한 버튼 위치)
        final buttonIndex = _gridButtons.indexOf(button);
        print('🔍 버튼 인덱스: $buttonIndex');
        
        if (buttonIndex != -1) {
          final position = _getButtonPosition(buttonIndex);
          print('📍 버튼 위치 계산: $position');
          
          if (position != null) {
            _showTouchFeedback(position.dx, position.dy);
          } else {
            // 위치 계산 실패 시 화면 중앙에 표시
            print('⚠️ 버튼 위치 계산 실패, 화면 중앙에 표시');
            _showTouchFeedback(MediaQuery.of(context).size.width / 2, MediaQuery.of(context).size.height / 2);
          }
        } else {
          // 버튼을 찾을 수 없을 때 화면 중앙에 표시
          print('⚠️ 버튼을 찾을 수 없음, 화면 중앙에 표시');
          _showTouchFeedback(MediaQuery.of(context).size.width / 2, MediaQuery.of(context).size.height / 2);
        }
        
        // TTS로 실행 안내
        await _audioService.playTTS('$description을 실행합니다');
        
        // URL 정규화 (https:// 추가)
        String normalizedUrl = url;
        if (!normalizedUrl.startsWith('http://') && !normalizedUrl.startsWith('https://')) {
          normalizedUrl = 'https://$normalizedUrl';
        }
        
        // URL 실행 시도
        final uri = Uri.parse(normalizedUrl);
        print('🔗 URL 파싱 완료: $uri');
        
        // 여러 방법으로 URL 실행 시도
        bool launchSuccess = false;
        
        // 방법 1: 기본 방법
        try {
          final canLaunch = await canLaunchUrl(uri);
          print('🔍 canLaunchUrl 결과: $canLaunch');
          
          if (canLaunch) {
            launchSuccess = await launchUrl(uri, mode: LaunchMode.externalApplication);
            print('✅ URL 실행 성공 (방법 1): $normalizedUrl');
          }
        } catch (e) {
          print('❌ 방법 1 실패: $e');
        }
        
        // 방법 2: 다른 모드로 시도
        if (!launchSuccess) {
          try {
            launchSuccess = await launchUrl(uri, mode: LaunchMode.platformDefault);
            print('✅ URL 실행 성공 (방법 2): $normalizedUrl');
          } catch (e) {
            print('❌ 방법 2 실패: $e');
          }
        }
        
        // 방법 3: 인텐트로 시도
        if (!launchSuccess) {
          try {
            launchSuccess = await launchUrl(uri, mode: LaunchMode.inAppWebView);
            print('✅ URL 실행 성공 (방법 3): $normalizedUrl');
          } catch (e) {
            print('❌ 방법 3 실패: $e');
          }
        }
        
        if (launchSuccess) {
          setState(() {
            _statusMessage = '$text ($description) 실행 완료';
          });
          return true;
        } else {
          print('❌ 모든 URL 실행 방법 실패: $normalizedUrl');
          setState(() {
            _statusMessage = 'URL 실행 실패: $normalizedUrl (브라우저 확인 필요)';
          });
          return false;
        }
      }
      return false;
    } catch (e) {
      print('❌ 가상 터치 오류: $e');
      setState(() {
        _statusMessage = '가상 터치 실행 실패: $e';
      });
      return false;
    }
  }

  /// 가상터치 시각적 피드백 표시
  void _showTouchFeedback(double x, double y) {
    print('🎯 터치 임팩트 표시: ($x, $y)');
    setState(() {
      _touchPosition = Offset(x, y);
      _showTouchIndicator = true;
    });
    
    print('✅ 터치 임팩트 상태: $_showTouchIndicator, 위치: $_touchPosition');
    
    // 1초 후 피드백 숨기기
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _showTouchIndicator = false;
        });
        print('🔄 터치 임팩트 숨김');
      }
    });
  }

  /// 그리드 버튼의 실제 위치 계산
  Offset? _getButtonPosition(int index) {
    if (index < 0 || index >= _buttonKeys.length) return null;
    
    final key = _buttonKeys[index];
    final context = key.currentContext;
    if (context == null) return null;
    
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final position = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;
    
    // 버튼의 중앙 위치 반환
    return Offset(
      position.dx + size.width / 2,
      position.dy + size.height / 2,
    );
  }

  /// 가상터치 테스트 실행 (음성인식 시뮬레이션)
  Future<void> _performVirtualTouchTest(String buttonId) async {
    try {
      final testButton = _testButtons.firstWhere((btn) => btn['id'] == buttonId);
      final text = testButton['text'] as String;
      final description = testButton['description'] as String;
      
      print('🧪 가상터치 테스트: $text ($description)');
      
      setState(() {
        _statusMessage = '테스트 중: $text ($description)';
      });
      
      // 음성인식 시뮬레이션
      await _audioService.playTTS('$description 테스트를 실행합니다');
      
      // AI 분석 시뮬레이션
      final aiResult = await _aiService.analyzeVoiceCommand('$buttonId번 클릭해줘');
      
      if (aiResult != null && aiResult['action'] != null) {
        final action = aiResult['action'];
        final actionType = action['type'];
        final target = action['target'];
        
        setState(() {
          _statusMessage = 'AI 분석 완료: $actionType - $target';
        });
        
        // 실제 그리드 버튼 실행
        final buttonIndex = int.tryParse(target) ?? 0;
        if (buttonIndex > 0 && buttonIndex <= _gridButtons.length) {
          final button = _gridButtons[buttonIndex - 1];
          await _performVirtualTouch(button);
        }
      }
      
      setState(() {
        _statusMessage = '테스트 완료: $text';
      });
      
    } catch (e) {
      print('❌ 가상터치 테스트 오류: $e');
      setState(() {
        _statusMessage = '테스트 실패: $e';
      });
    }
  }

  /// 음성인식 설정으로 이동
  Future<void> _openVoiceRecognitionSettings() async {
    try {
      print('🔧 음성인식 설정으로 이동');
      setState(() {
        _statusMessage = '설정으로 이동 중...';
      });
      
      // 접근성 설정으로 이동
      await AppSettings.openAppSettings();
      
      setState(() {
        _statusMessage = '설정에서 접근성 서비스를 활성화해주세요';
      });
      
    } catch (e) {
      print('❌ 설정 이동 오류: $e');
      setState(() {
        _statusMessage = '설정 이동 실패: $e';
      });
    }
  }

  void _showAccessibilityDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('접근성 서비스 필요'),
        content: const Text(
          '이 기능을 사용하려면 접근성 서비스가 필요합니다.\n'
          '설정에서 접근성 서비스를 활성화해주세요.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _openAccessibilitySettings();
            },
            child: const Text('설정으로 이동'),
          ),
        ],
      ),
    );
  }

  void _openAccessibilitySettings() {
    // 접근성 설정 화면으로 이동
    // 실제 구현에서는 app_settings 패키지 사용
  }

  @override
  Widget build(BuildContext context) {
    final mainScaffold = Scaffold(
      appBar: AppBar(
        title: const Text('📱 LLM 프로토타입'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: Icon(_isAccessibilityEnabled ? Icons.check_circle : Icons.error),
            onPressed: () {
              if (!_isAccessibilityEnabled) {
                _showAccessibilityDialog();
              }
            },
            tooltip: _isAccessibilityEnabled ? '접근성 서비스 활성화됨' : '접근성 서비스 비활성화',
          ),
        ],
      ),
      body: Column(
        children: [
          // 상단 상태 표시
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // 서버 연결 상태
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _isServerConnected ? Colors.green[100] : Colors.red[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _isServerConnected ? Icons.check_circle : Icons.error,
                        color: _isServerConnected ? Colors.green : Colors.red,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _serverStatus,
                          style: TextStyle(
                            color: _isServerConnected ? Colors.green[800] : Colors.red[800],
                          ),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: _testBackendAPIs,
                        child: const Text('API 테스트'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                
                // 음성 인식 상태 (README.md 방향성)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _isListening ? Colors.blue[100] : Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(
                            _isListening ? Icons.mic : Icons.mic_off,
                            color: _isListening ? Colors.blue : Colors.grey,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _statusMessage,
                              style: TextStyle(
                                color: _isListening ? Colors.blue[800] : Colors.grey[800],
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (_voiceCommand.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.green[50],
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: Colors.green[200]!),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.check_circle, color: Colors.green, size: 16),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  '🎤 인식된 음성: $_voiceCommand',
                                  style: const TextStyle(
                                    fontStyle: FontStyle.italic,
                                    color: Colors.green,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 중앙 컨텐츠
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // 접근성 오버레이
                  if (_highlightedElement != null)
                    AccessibilityOverlay(
                      highlightedElement: _highlightedElement!,
                    ),
                  
                  // 화면 요소 정보
                  if (_currentElements.isNotEmpty) ...[
                    const Text('감지된 화면 요소:', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Expanded(
                      child: ListView.builder(
                        itemCount: _currentElements.length,
                        itemBuilder: (context, index) {
                          final element = _currentElements[index];
                          return ListTile(
                            title: Text(element.text.isEmpty ? '텍스트 없음' : element.text),
                            subtitle: Text('타입: ${element.type}, 클릭가능: ${element.isClickable}'),
                            trailing: element.isClickable
                                ? IconButton(
                                    icon: const Icon(Icons.touch_app),
                                    onPressed: () => _performClick(),
                                  )
                                : null,
                          );
                        },
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          // 하단 컨트롤 영역
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // 가상터치 테스트용 버튼들
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.orange[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange[200]!),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        '🧪 가상터치 테스트 (음성인식 시뮬레이션)',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 40,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _testButtons.length,
                          itemBuilder: (context, index) {
                            final button = _testButtons[index];
                            return Container(
                              margin: const EdgeInsets.only(right: 8),
                              child: ElevatedButton.icon(
                                onPressed: () => _performVirtualTouchTest(button['id']),
                                icon: const Icon(Icons.play_arrow, size: 12),
                                label: Text(
                                  button['text'], 
                                  style: const TextStyle(fontSize: 10),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.orange[100],
                                  foregroundColor: Colors.orange[800],
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  minimumSize: const Size(80, 32),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                
                // 설정 이동 버튼
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue[200]!),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.settings, color: Colors.blue),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          '음성인식 설정',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: _openVoiceRecognitionSettings,
                        icon: const Icon(Icons.arrow_forward, size: 16),
                        label: const Text('설정으로 이동'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[100],
                          foregroundColor: Colors.blue[800],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                
                // 터치 임팩트 테스트 버튼
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          _showTouchFeedback(100, 100);
                        },
                        child: const Text('🎯 터치 테스트 1'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () {
                          _showTouchFeedback(200, 200);
                        },
                        child: const Text('🎯 터치 테스트 2'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () {
                          _showTouchFeedback(300, 300);
                        },
                        child: const Text('🎯 터치 테스트 3'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                
                // 앱 그리드 버튼들
                const Text(
                  '🌐 크롬 기반 웹사이트 그리드 (4x3)',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 240, // 고정 높이로 스타일 깨짐 방지
                  child: GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                      childAspectRatio: 1.2,
                    ),
                    itemCount: _gridButtons.length,
                    itemBuilder: (context, index) {
                      final button = _gridButtons[index];
                      return Card(
                        key: _buttonKeys[index],
                        elevation: 2,
                        child: InkWell(
                          onTap: () => _performVirtualTouch(button),
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  button['text'],
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  button['description'],
                                  style: const TextStyle(
                                    fontSize: 8,
                                    color: Colors.grey,
                                  ),
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _startVoiceRecognition,
        child: Icon(_isListening ? Icons.stop : Icons.mic),
        backgroundColor: _isListening ? Colors.red : Colors.blue,
      ),
    );
    
    // TouchIndicator 오버레이 추가
    if (_showTouchIndicator && _touchPosition != null) {
      return Stack(
        children: [
          mainScaffold,
          Positioned.fill(
            child: TouchIndicator(
              position: _touchPosition!,
              color: Colors.red,
            ),
          ),
        ],
      );
    }
    
    return mainScaffold;
  }

  Future<void> _performClick() async {
    if (_highlightedElement != null) {
      final success = await _accessibilityService.performClick(_highlightedElement!);
      if (success) {
        setState(() {
          _statusMessage = '클릭을 수행했습니다';
        });
        await _audioService.playTTS('클릭을 수행했습니다');
      } else {
        setState(() {
          _statusMessage = '클릭에 실패했습니다';
        });
      }
    }
  }
} 