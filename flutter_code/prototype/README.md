# LLM 음성 비서 프로토타입

## 📱 프로젝트 개요

Flutter 기반의 음성 인식 및 AI 분석을 통한 스마트 비서 애플리케이션입니다. 사용자의 음성 명령을 인식하고 AI가 분석하여 적절한 액션을 수행합니다.

## 🏗️ 아키텍처

### **프론트엔드 (Flutter)**
- **음성 녹음**: `flutter_sound` 패키지 사용
- **UI/UX**: Material Design 기반 반응형 인터페이스
- **상태 관리**: Flutter StatefulWidget
- **권한 관리**: `permission_handler` 패키지

### **백엔드 (FastAPI)**
- **음성 인식**: OpenAI Whisper API
- **자연어 처리**: OpenAI GPT 모델
- **TTS**: `pyttsx3` (서버 사이드)
- **오디오 처리**: `pydub`, `librosa`

### **핵심 기능**
- **실시간 음성 녹음**: 볼륨 감지 기반 자동 종료
- **AI 명령 분석**: 자연어를 구조화된 액션으로 변환
- **가상 터치**: 화면 요소 자동 클릭
- **URL 실행**: 외부 앱/웹사이트 자동 실행
- **TTS 피드백**: AI 응답 음성 재생

## 🚀 설치 및 실행

### **필수 요구사항**
- Flutter SDK 3.0+
- Python 3.8+
- Android Studio / VS Code
- Android 에뮬레이터 또는 실제 기기

### **1. 프로젝트 클론**
```bash
git clone <repository-url>
cd prototype
```

### **2. Flutter 의존성 설치**
```bash
flutter pub get
```

### **3. 백엔드 서버 설정**
```bash
# 백엔드 디렉토리로 이동
cd backend

# Python 가상환경 생성 (선택사항)
python -m venv venv
source venv/bin/activate  # Windows: venv\Scripts\activate

# 의존성 설치
pip install -r requirements.txt

# 환경 변수 설정
export OPENAI_API_KEY="your-openai-api-key"

# 서버 실행
python main.py
```

### **4. Flutter 앱 실행**
```bash
# 프로젝트 루트로 이동
cd ..

# 앱 실행
flutter run
```

## 📖 사용법

### **기본 사용 흐름**

1. **음성 녹음 시작**
   - 마이크 버튼을 탭하여 녹음 시작
   - 음성 입력 시 실시간 볼륨 감지
   - 무음 2초 또는 최대 5초 후 자동 종료

2. **음성 인식 결과 표시**
   - 인식된 텍스트가 화면 상단에 표시
   - 신뢰도 점수와 함께 표시

3. **AI 분석 및 응답**
   - 인식된 텍스트를 AI가 분석
   - AI 응답이 별도 영역에 표시
   - TTS로 응답 음성 재생

4. **액션 실행**
   - AI 분석 결과에 따른 자동 액션 수행
   - 앱 실행, 웹사이트 열기, 화면 터치 등

### **음성 입력 부족 시 대안**

음성 입력이 부족한 경우 (파일 크기 < 512 bytes):

1. **상태 표시**: "음성 입력 부족" 메시지와 "숫자 선택하기" 버튼이 상단에 표시
2. **숫자 선택**: 버튼 클릭 시 화면에 직접 오버레이로 1~5 숫자 선택 UI 표시
3. **선택 완료**: 숫자 선택 시 해당 번호의 앱/서비스 실행

### **숫자 선택 UI 특징**
- **직접 표시**: 모달창 대신 화면에 직접 오버레이
- **반투명 배경**: Colors.black54 배경으로 포커스 효과
- **원형 버튼**: 60x60 크기의 직관적인 숫자 버튼
- **취소 기능**: 언제든지 취소 가능

### **지원하는 음성 명령 예시**

#### **기본 명령**
- "1번을 클릭해줘" → 1번 앱 실행
- "페이스북 열어줘" → Facebook 앱/웹사이트 실행
- "유튜브 보여줘" → YouTube 실행
- "카카오톡 열어줘" → KakaoTalk 실행

#### **복합 명령**
- "3번 앱을 실행하고 로그인해줘"
- "페이스북에서 친구 찾기"
- "유튜브에서 음악 재생"

## 🛠️ 기술적 세부사항

### **음성 녹음 설정**
```dart
// 녹음 품질 설정
sampleRate: 44100,  // 고품질 샘플링
numChannels: 1,     // 모노 채널
codec: Codec.pcm16WAV,  // WAV 포맷
```

### **자동 종료 조건**
- **무음 감지**: 2초간 무음 시 자동 종료
- **최대 시간**: 5초 후 강제 종료
- **파일 크기**: 최소 512 bytes 이상 필요

### **볼륨 감지 알고리즘**
```dart
// 실시간 볼륨 모니터링
if (event.decibels! > -50) {
  // 음성 입력 감지
  _lastVoiceInputTime = DateTime.now();
  _silenceTimer?.cancel();
} else {
  // 무음 감지 - 2초 타이머 시작
  _silenceTimer ??= Timer(Duration(seconds: 2), () {
    _stopRecordingAndProcess();
  });
}
```

### **AI 분석 프로세스**
1. **음성 → 텍스트**: OpenAI Whisper API
2. **명령 분석**: OpenAI GPT 모델
3. **액션 결정**: 구조화된 JSON 응답
4. **실행**: Flutter에서 액션 수행

### **URL 자동 인식 시스템**
```dart
class UrlUtils {
  static String generateUrlFromService(String serviceName) {
    // 200+ 서비스 매핑
    final urlPatterns = {
      'google': 'https://www.google.com',
      'facebook': 'https://www.facebook.com',
      'youtube': 'https://www.youtube.com',
      // ... 더 많은 서비스
    };
  }
}
```

## 📱 UI/UX 개선사항

### **최신 UI 구조**

#### **메인 화면 레이아웃**
```
┌─────────────────────────────────────────────────────────┐
│ 📱 LLM 음성 비서 프로토타입                    ⚙️ │
├─────────────────────────────────────────────────────────┤
│ 🎤 음성 인식 결과 영역                              │
│ "안녕하세요, 무엇을 도와드릴까요?"                   │
│ 신뢰도: 0.95                                        │
├─────────────────────────────────────────────────────────┤
│ 🤖 AI 응답 영역                                     │
│ "1번 앱을 실행하겠습니다."                           │
├─────────────────────────────────────────────────────────┤
│ 📊 상태 표시                                        │
│ 음성인식 완료                                        │
├─────────────────────────────────────────────────────────┤
│ ⚠️ 음성 입력 부족                    [숫자 선택하기] │
├─────────────────────────────────────────────────────────┤
│ 📱 앱 그리드 (4x3)                                  │
│ [1] [2] [3] [4]                                     │
│ [5] [6] [7] [8]                                     │
│ [9] [10] [11] [12]                                  │
└─────────────────────────────────────────────────────────┘
```

#### **숫자 선택 오버레이**
```
┌─────────────────────────────────────────────────────────┐
│                    [반투명 배경]                      │
│                                                       │
│              ┌─────────────────────┐                  │
│              │     숫자 선택       │                  │
│              │                     │                  │
│              │  [1] [2] [3] [4] [5] │                  │
│              │                     │                  │
│              │       [취소]        │                  │
│              └─────────────────────┘                  │
│                                                       │
└─────────────────────────────────────────────────────────┘
```

### **UI 개선사항**

#### **1. 레이아웃 최적화**
- ❌ **제거**: 가운데 영역의 왼쪽 아래 '음성 입력 부족' 부분
- ✅ **이동**: '숫자 선택하기' 버튼을 위쪽으로 이동
- 🎯 **배치**: 음성 입력 부족 상태와 숫자 선택 버튼을 한 줄에 배치

#### **2. 숫자 선택 UI 개선**
- 🚫 **모달창 제거**: 기존 AlertDialog 방식 제거
- ✅ **직접 표시**: 화면에 직접 오버레이로 표시
- 🎨 **개선된 디자인**: 
  - 반투명 배경 (Colors.black54)
  - 흰색 컨테이너에 그림자 효과
  - 60x60 크기의 원형 숫자 버튼들
  - 취소 버튼 추가

#### **3. 사용자 경험 개선**
- **직관적 배치**: 관련 기능들을 논리적으로 그룹화
- **시각적 계층**: 중요도에 따른 UI 요소 배치
- **반응형 디자인**: 다양한 화면 크기에 대응

## 🔧 설정 및 구성

### **환경 변수**
```bash
# OpenAI API 키
export OPENAI_API_KEY="your-api-key"

# 서버 URL (기본값)
export LLM_SERVER_URL="http://localhost:8000"
```

### **권한 설정**
```xml
<!-- Android 권한 -->
<uses-permission android:name="android.permission.RECORD_AUDIO" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.MANAGE_EXTERNAL_STORAGE" />
```

## 🐛 문제 해결

### **일반적인 문제들**

#### **1. 음성 인식이 안 되는 경우**
```bash
# 권한 확인
flutter doctor

# 에뮬레이터 마이크 설정
# Settings > System > Languages & input > Virtual keyboard > Google Keyboard > Preferences > Voice input key
```

#### **2. 서버 연결 오류**
```bash
# 백엔드 서버 상태 확인
curl http://localhost:8000/health

# 포트 확인
netstat -an | grep 8000
```

#### **3. 파일 크기 부족 오류**
- **원인**: 짧은 음성 입력으로 인한 작은 파일
- **해결**: 더 명확하고 길게 발음
- **대안**: 숫자 선택 기능 사용

#### **4. 권한 오류**
```bash
# 권한 재설정
flutter clean
flutter pub get
flutter run
```

### **디버깅 팁**
```dart
// 로그 확인
print('🎤 볼륨 감지: ${event.decibels}dB');
print('📊 파일 크기: ${fileSize} bytes');
print('🎯 음성 인식 결과: $transcript');
```

## 📈 성능 최적화

### **녹음 품질 최적화**
- **샘플링 레이트**: 44100 Hz (고품질)
- **채널**: 모노 (1채널)
- **코덱**: PCM16 WAV (압축 없음)

### **메모리 관리**
- **자동 정리**: 임시 파일 자동 삭제
- **스트림 관리**: 녹음 스트림 적절한 해제
- **타이머 관리**: 메모리 누수 방지

### **네트워크 최적화**
- **타임아웃 설정**: 30초
- **재시도 로직**: 3회 시도
- **에러 핸들링**: 네트워크 오류 대응

## 🔄 최근 업데이트

### **v2.1.0 (현재)**
- ✅ **UI 레이아웃 개선**: 음성 입력 부족 영역 최적화
- ✅ **숫자 선택 UI 개선**: 모달창 → 직접 오버레이 표시
- ✅ **사용자 경험 향상**: 더 직관적인 인터페이스
- ✅ **성능 최적화**: 메모리 사용량 개선

### **v2.0.0**
- ✅ **음성 인식 시스템 교체**: speech_to_text → flutter_sound
- ✅ **실시간 볼륨 감지**: 자동 종료 기능
- ✅ **AI 분석 개선**: 더 정확한 명령 인식
- ✅ **URL 자동 인식**: 200+ 서비스 지원

### **v1.0.0**
- ✅ **기본 음성 인식**: OpenAI Whisper 통합
- ✅ **AI 명령 분석**: GPT 모델 연동
- ✅ **가상 터치**: 화면 요소 자동 클릭
- ✅ **TTS 피드백**: 음성 응답 시스템

## 🤝 기여하기

1. **Fork** the repository
2. **Create** a feature branch (`git checkout -b feature/AmazingFeature`)
3. **Commit** your changes (`git commit -m 'Add some AmazingFeature'`)
4. **Push** to the branch (`git push origin feature/AmazingFeature`)
5. **Open** a Pull Request

## 📄 라이선스

이 프로젝트는 MIT 라이선스 하에 배포됩니다. 자세한 내용은 `LICENSE` 파일을 참조하세요.

## 📞 지원

문제가 있거나 제안사항이 있으시면 이슈를 생성해 주세요.

---

**개발자**: AI Assistant  
**최종 업데이트**: 2024년 12월  
**버전**: 2.1.0
