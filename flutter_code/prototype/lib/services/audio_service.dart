import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import '../config/app_config.dart';
import 'dart:async'; // Added missing import for Timer

/// 음성 인식 및 TTS 서비스
class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  FlutterSoundRecorder? _recorder;
  final AudioPlayer _player = AudioPlayer();
  bool _isInitialized = false;

  /// 서비스 초기화
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      _recorder = FlutterSoundRecorder();
      await _recorder!.openRecorder();
      _isInitialized = true;
      print('음성 서비스 초기화 완료');
    } catch (e) {
      print('음성 서비스 초기화 실패: $e');
    }
  }

  /// 음성 녹음 시작
  Future<String?> startRecording() async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      // 임시 파일 경로 생성
      final tempDir = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final filePath = '${tempDir.path}/recorded_$timestamp.wav';

      // 녹음 시작
      await _recorder!.startRecorder(
        toFile: filePath,
        codec: Codec.pcm16WAV,
        sampleRate: AppConfig.sampleRate,
        numChannels: AppConfig.numChannels,
      );

      print('음성 녹음 시작: $filePath');

      // 무음 감지 대기
      await _waitForSilence();

      // 녹음 중지
      final recordedFile = await _recorder!.stopRecorder();
      print('음성 녹음 완료: $recordedFile');

      if (recordedFile != null) {
        // 파일 크기 확인
        final file = File(recordedFile);
        final fileSize = await file.length();
        
        if (fileSize > 512) {
          // 서버로 전송하여 음성 인식
          return await _sendToSpeechToText(recordedFile);
        } else {
          print('음성 파일이 너무 작음: $fileSize bytes');
          return null;
        }
      }

      return null;
    } catch (e) {
      print('음성 녹음 실패: $e');
      return null;
    }
  }

  /// 무음 감지 대기
  Future<void> _waitForSilence() async {
    DateTime lastVoiceTime = DateTime.now();
    Timer? silenceTimer;

    _recorder!.onProgress!.listen((event) {
      if (event.decibels != null && event.decibels! > AppConfig.minDecibelThreshold) {
        lastVoiceTime = DateTime.now();
        silenceTimer?.cancel();
      } else {
        silenceTimer?.cancel();
        silenceTimer = Timer(AppConfig.voiceTimeout, () {
          // 무음 감지됨
        });
      }
    });

    // 최대 녹음 시간 대기
    await Future.delayed(AppConfig.maxRecordingTime);
  }

  /// 음성 파일을 서버로 전송하여 텍스트 변환
  Future<String?> _sendToSpeechToText(String filePath) async {
    try {
      final request = http.MultipartRequest('POST', Uri.parse(AppConfig.sttUrl))
        ..files.add(await http.MultipartFile.fromPath('audio', filePath));

      final streamedResponse = await request.send().timeout(
        const Duration(seconds: 30),
      );
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['transcript'];
      } else {
        print('음성 인식 서버 오류: ${response.body}');
        return null;
      }
    } catch (e) {
      print('음성 인식 실패: $e');
      return null;
    }
  }

  /// TTS 음성 재생
  Future<void> playTTS(String text) async {
    try {
      final response = await http.post(
        Uri.parse(AppConfig.ttsUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'text': text}),
      );

      if (response.statusCode == 200) {
        final bytes = response.bodyBytes;
        final tempDir = await getTemporaryDirectory();
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final file = File('${tempDir.path}/tts_output_$timestamp.mp3');
        await file.writeAsBytes(bytes);
        
        // 파일이 존재하는지 확인
        if (await file.exists()) {
          print('TTS 파일 생성 완료: ${file.path}');
          await _player.play(DeviceFileSource(file.path));
        } else {
          print('TTS 파일 생성 실패');
        }
      } else {
        print('TTS 서버 오류: ${response.body}');
      }
    } catch (e) {
      print('TTS 재생 실패: $e');
    }
  }

  /// 서비스 정리
  Future<void> dispose() async {
    await _recorder?.closeRecorder();
    await _player.dispose();
  }
} 