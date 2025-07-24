/// 앱의 기본 설정을 관리하는 클래스
class AppConfig {
  static String baseUrl = 'http://10.0.2.2:8000';
  static String llmUrl = '$baseUrl/llm';
  static String ttsUrl = '$baseUrl/tts';
  static String sttUrl = '$baseUrl/stt';

  // 오디오 설정
  static int sampleRate = 16000;
  static int numChannels = 1;
  static double minDecibelThreshold = -50.0;
  static Duration voiceTimeout = const Duration(seconds: 2);
  static Duration maxRecordingTime = const Duration(seconds: 10);

  static Future<void> initialize() async {
    // 앱 초기화 로직
    print('앱 설정 초기화 시작');
    print('앱 설정 초기화 완료');
  }
} 