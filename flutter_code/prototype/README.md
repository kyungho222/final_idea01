# 📱 LLM 음성 비서 프로토타입

## 🎯 프로젝트 개요

Android 접근성 서비스를 활용한 스마트폰 화면 요소 음성 인식 및 가상 터치 시스템입니다. 사용자의 음성 명령을 통해 화면의 UI 요소를 자동으로 클릭하고 조작할 수 있습니다.

### 🌟 핵심 기능
- **🎤 음성 인식**: 실시간 음성 명령 인식
- **👁️ 화면 분석**: Android 접근성 서비스로 UI 요소 감지
- **🎯 가상 터치**: 음성 명령에 따른 자동 터치 실행
- **🌐 웹 브라우징**: 크롬 브라우저 내 요소 자동 클릭
- **📱 앱 제어**: 다양한 앱의 UI 요소 자동 조작
- **✨ 터치 임팩트**: 시각적 피드백이 있는 터치 애니메이션

## 🏗️ 아키텍처

### **프론트엔드 (Flutter)**
- **음성 녹음**: `flutter_sound` 패키지 사용
- **UI/UX**: Material Design 기반 반응형 인터페이스
- **상태 관리**: Provider 패턴 기반 상태 관리
- **권한 관리**: `permission_handler` 패키지
- **접근성 서비스**: Android AccessibilityService 연동
- **터치 피드백**: TouchIndicator 애니메이션 시스템

### **백엔드 (Python Flask)**
- **음성 인식**: OpenAI Whisper API
- **자연어 처리**: OpenAI GPT 모델
- **TTS**: `pyttsx3` (서버 사이드)
- **오디오 처리**: `pydub`, `librosa`

### **Android 네이티브 (Kotlin)**
- **접근성 서비스**: `MyAccessibilityService.kt`
- **화면 요소 감지**: AccessibilityEvent 처리
- **가상 터치**: GestureDescription API
- **권한 관리**: 접근성 서비스 권한

### **핵심 기능**
- **실시간 음성 녹음**: 볼륨 감지 기반 자동 종료
- **화면 요소 분석**: 접근성 서비스로 UI 요소 실시간 감지
- **가상 터치**: 음성 명령에 따른 정확한 터치 실행
- **웹 브라우징**: 크롬 브라우저 내 요소 자동 클릭
- **터치 피드백**: 애니메이션 효과가 있는 터치 임팩트
- **서버 연결 상태**: 실시간 백엔드 연결 상태 모니터링

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
# Python 가상환경 생성 (선택사항)
python -m venv venv
source venv/bin/activate  # Windows: venv\Scripts\activate

# 의존성 설치
pip install flask openai pydub librosa pyttsx3

# 환경 변수 설정
export OPENAI_API_KEY="your-openai-api-key"

# 서버 실행
python test_server.py
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

1. **접근성 서비스 활성화**
   - 설정 → 접근성 → 프로토타입 앱 활성화
   - 마이크 권한 허용

2. **음성 녹음 시작**
   - 마이크 버튼을 탭하여 녹음 시작
   - 음성 입력 시 실시간 볼륨 감지
   - 무음 2초 또는 최대 10초 후 자동 종료

3. **화면 요소 분석**
   - 접근성 서비스가 현재 화면의 UI 요소들을 실시간 감지
   - 버튼, 텍스트, 이미지 등 모든 클릭 가능한 요소 인식

4. **음성 명령 인식**
   - 인식된 텍스트가 화면 상단에 표시
   - AI가 음성 명령을 분석하여 적절한 UI 요소 선택

5. **가상 터치 실행**
   - 선택된 UI 요소에 애니메이션 효과와 함께 터치 실행
   - 터치 임팩트로 시각적 피드백 제공

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
- "네이버 클릭해줘" → 네이버 버튼 자동 클릭
- "로그인 버튼 눌러줘" → 로그인 버튼 자동 터치
- "검색창 클릭해줘" → 검색창 자동 선택
- "메뉴 버튼 눌러줘" → 메뉴 버튼 자동 클릭

#### **웹 브라우징 명령**
- "네이버에서 검색해줘" → 네이버 검색창 클릭
- "유튜브 재생 버튼 눌러줘" → 재생 버튼 자동 클릭
- "페이스북 로그인해줘" → 로그인 버튼 자동 터치

#### **복합 명령**
- "네이버에서 검색하고 첫 번째 결과 클릭해줘"
- "유튜브에서 동영상 재생하고 다음 버튼 눌러줘"
- "페이스북에서 친구 찾기 버튼 클릭해줘"

## 🛠️ 기술적 세부사항

### **음성 녹음 설정**
```dart
// 녹음 품질 설정
sampleRate: 16000,  // 음성 인식 최적화
numChannels: 1,     // 모노 채널
codec: Codec.pcm16WAV,  // WAV 포맷
minDecibelThreshold: -50.0,  // 음성 감지 임계값
voiceTimeout: Duration(seconds: 2),  // 무음 타임아웃
maxRecordingTime: Duration(seconds: 10),  // 최대 녹음 시간
```

### **접근성 서비스 설정**
```xml
<!-- accessibility_service_config.xml -->
<accessibility-service
    android:description="@string/accessibility_service_description"
    android:accessibilityEventTypes="typeAllMask"
    android:accessibilityFlags="flagDefault|flagIncludeNotImportantViews|flagRequestTouchExplorationMode|flagRequestEnhancedWebAccessibility|flagReportViewIds|flagRetrieveInteractiveWindows"
    android:accessibilityFeedbackType="feedbackGeneric"
    android:notificationTimeout="100"
    android:canRetrieveWindowContent="true"
    android:settingsActivity="com.example.prototype.MainActivity" />
```

### **가상 터치 설정**
```kotlin
// MyAccessibilityService.kt
fun performClick(x: Float, y: Float) {
    val path = Path()
    path.moveTo(x, y)
    
    val gesture = GestureDescription.Builder()
        .addStroke(GestureDescription.StrokeDescription(path, 0, 100))
        .build()
    
    dispatchGesture(gesture, null, null)
}
```

### **볼륨 감지 알고리즘**
```dart
// 실시간 볼륨 모니터링
if (event.decibels! > AppConfig.minDecibelThreshold) {
  // 음성 입력 감지
  _lastVoiceInputTime = DateTime.now();
  _silenceTimer?.cancel();
} else {
  // 무음 감지 - 2초 타이머 시작
  _silenceTimer ??= Timer(AppConfig.voiceTimeout, () {
    _stopRecordingAndProcess();
  });
}
```

### **화면 요소 분석 프로세스**
1. **접근성 이벤트 수신**: AccessibilityEvent 처리
2. **UI 요소 파싱**: JSON 형태로 구조화
3. **클릭 가능 요소 필터링**: isClickable = true인 요소들
4. **좌표 계산**: 화면 좌표계 변환

### **가상 터치 프로세스**
1. **음성 명령 인식**: OpenAI Whisper API
2. **명령 분석**: OpenAI GPT 모델로 UI 요소 매칭
3. **좌표 계산**: 선택된 요소의 중앙 좌표 계산
4. **터치 실행**: GestureDescription API로 가상 터치
5. **피드백 표시**: TouchIndicator 애니메이션

### **터치 임팩트 시스템**
```dart
class TouchIndicator extends StatefulWidget {
  // 애니메이션 효과가 있는 터치 피드백
  - 크기: 60x60 (확대된 크기)
  - 애니메이션: elasticOut 커브로 자연스러운 효과
  - 그림자: blurRadius 10, spreadRadius 2
  - 투명도: 0.6 (선명한 표시)
  - 지속시간: 300ms + 500ms 지연
  - 위치: 터치한 버튼의 실제 위치에 표시
}
```

### **접근성 이벤트 처리**
```kotlin
// MyAccessibilityService.kt
override fun onAccessibilityEvent(event: AccessibilityEvent) {
    when (event.eventType) {
        AccessibilityEvent.TYPE_VIEW_CLICKED -> {
            // 클릭 이벤트 처리
        }
        AccessibilityEvent.TYPE_WINDOW_CONTENT_CHANGED -> {
            // 화면 내용 변경 감지
        }
        AccessibilityEvent.TYPE_VIEW_SCROLLED -> {
            // 스크롤 이벤트 처리
        }
    }
}
```

## 📱 UI/UX 구조

### **현재 UI 구조**

#### **메인 화면 레이아웃**
```
┌─────────────────────────────────────────────────────────┐
│ 📱 LLM 음성 비서 프로토타입                    🎤 │
├─────────────────────────────────────────────────────────┤
│ 🎤 음성 인식 결과 영역                              │
│ "네이버 클릭해줘"                                   │
│ 신뢰도: 0.95                                        │
├─────────────────────────────────────────────────────────┤
│ 🤖 AI 응답 영역                                     │
│ "네이버 버튼을 클릭하겠습니다."                      │
├─────────────────────────────────────────────────────────┤
│ 📊 상태 표시                                        │
│ 서버 연결 성공/실패                                  │
├─────────────────────────────────────────────────────────┤
│ 👁️ 접근성 서비스 상태                               │
│ 접근성 이벤트 수신 중...                             │
├─────────────────────────────────────────────────────────┤
│ 📱 테스트 그리드 (4x3)                              │
│ [Google] [YouTube] [Naver] [GitHub]                  │
│ [Facebook] [Twitter] [Instagram] [LinkedIn]          │
│ [Reddit] [StackOverflow] [Wikipedia] [Netflix]       │
└─────────────────────────────────────────────────────────┘
```

#### **터치 임팩트 오버레이**
```
┌─────────────────────────────────────────────────────────┐
│                    [화면 전체]                        │
│                                                       │
│              🎯 터치 임팩트                          │
│              ⭕ (애니메이션)                          │
│              🔴 빨간색 원형                          │
│              📱 터치 아이콘                          │
│              📍 실제 터치 위치                        │
│                                                       │
└─────────────────────────────────────────────────────────┘
```

### **UI 특징**

#### **1. 접근성 서비스 통합**
- ✅ **실시간 화면 분석**: AccessibilityEvent로 UI 요소 감지
- ✅ **터치 피드백**: TouchIndicator 애니메이션 효과
- ✅ **상태 표시**: 서버 연결 및 접근성 서비스 상태 실시간 표시
- ✅ **위치 기반 임팩트**: 터치한 버튼의 실제 위치에 임팩트 표시

#### **2. 음성 인식 UI**
- 🎤 **마이크 버튼**: 우상단에 위치한 음성 녹음 버튼
- 📊 **실시간 피드백**: 볼륨 레벨 및 녹음 상태 표시
- ⏱️ **자동 종료**: 무음 감지 또는 최대 시간 후 자동 종료

#### **3. 테스트 그리드**
- 📱 **12개 테스트 버튼**: 4x3 그리드 레이아웃
- 🔗 **URL 연결**: 각 버튼 클릭 시 해당 웹사이트 열기
- 🎯 **가상 터치 테스트**: 버튼 클릭으로 가상 터치 기능 테스트
- 📍 **위치 추적**: GlobalKey를 사용한 정확한 버튼 위치 추적

#### **4. 터치 임팩트 시스템**
- 🎯 **시각적 피드백**: 터치 위치에 빨간색 원형 표시
- ⭕ **애니메이션**: elasticOut 커브로 자연스러운 확대/축소
- 🔴 **그림자 효과**: blurRadius 10, spreadRadius 2
- ⏱️ **지속시간**: 300ms + 500ms 지연으로 명확한 표시
- 📍 **정확한 위치**: 터치한 버튼의 실제 중앙 좌표에 표시

#### **5. 서버 연결 상태**
- 🌐 **실시간 모니터링**: 백엔드 서버 연결 상태 표시
- ⚠️ **오류 처리**: 연결 실패 시 상세한 오류 메시지
- 🔄 **자동 재연결**: 네트워크 오류 시 자동 재시도

## 🔧 설정 및 구성

### **환경 변수**
```bash
# OpenAI API 키
export OPENAI_API_KEY="your-api-key"

# 서버 URL (기본값)
export LLM_SERVER_URL="http://10.0.2.2:8000"  # Android 에뮬레이터용
```

### **Android 권한 설정**
```xml
<!-- AndroidManifest.xml -->
<uses-permission android:name="android.permission.RECORD_AUDIO" />
<uses-permission android:name="android.permission.BIND_ACCESSIBILITY_SERVICE" />
<uses-permission android:name="android.permission.SYSTEM_ALERT_WINDOW" />

<!-- 접근성 서비스 설정 -->
<service
    android:name=".MyAccessibilityService"
    android:permission="android.permission.BIND_ACCESSIBILITY_SERVICE"
    android:exported="true">
    <intent-filter>
        <action android:name="android.accessibilityservice.AccessibilityService" />
    </intent-filter>
    <meta-data
        android:name="android.accessibilityservice"
        android:resource="@xml/accessibility_service_config" />
</service>
```

## 🐛 문제 해결

### **일반적인 문제들**

#### **1. 접근성 서비스 활성화 문제**
```bash
# 설정에서 접근성 서비스 활성화
Settings > Accessibility > 프로토타입 앱 > ON

# 권한 확인
flutter doctor
```

#### **2. 서버 연결 오류**
```bash
# 백엔드 서버 상태 확인
curl http://127.0.0.1:8000

# Android 에뮬레이터 네트워크 설정
# 10.0.2.2:8000으로 연결 확인
```

#### **3. 가상 터치가 작동하지 않는 경우**
- **원인**: 접근성 서비스 권한 부족
- **해결**: 설정에서 접근성 서비스 재활성화
- **확인**: 로그에서 "접근성 이벤트 수신" 메시지 확인

#### **4. 음성 인식 오류**
```bash
# 마이크 권한 확인
Settings > Apps > 프로토타입 > Permissions > Microphone

# 앱 재시작
flutter clean
flutter pub get
flutter run
```

#### **5. 터치 임팩트가 보이지 않는 경우**
- **원인**: TouchIndicator import 누락 또는 위치 계산 오류
- **해결**: GlobalKey를 사용한 정확한 위치 계산
- **확인**: 터치한 버튼의 실제 위치에 임팩트 표시 확인

### **디버깅 팁**
```dart
// 접근성 이벤트 로그 확인
print('👁️ 접근성 이벤트 수신: $eventData');

// 가상 터치 로그 확인
print('🎯 가상 터치 실행: ($x, $y)');

// 음성 인식 로그 확인
print('🎤 볼륨 감지: ${event.decibels}dB');
print('📊 파일 크기: ${fileSize} bytes');
print('🎯 음성 인식 결과: $transcript');

// 터치 임팩트 로그 확인
print('✨ 터치 임팩트 표시: ($x, $y)');
```

## 📈 성능 최적화

### **녹음 품질 최적화**
- **샘플링 레이트**: 16000 Hz (음성 인식 최적화)
- **채널**: 모노 (1채널)
- **코덱**: PCM16 WAV (압축 없음)

### **메모리 관리**
- **자동 정리**: 임시 파일 자동 삭제
- **스트림 관리**: 녹음 스트림 적절한 해제
- **타이머 관리**: 메모리 누수 방지

### **네트워크 최적화**
- **타임아웃 설정**: 5초
- **재시도 로직**: 3회 시도
- **에러 핸들링**: 네트워크 오류 대응

### **터치 임팩트 최적화**
- **애니메이션 성능**: 60fps 유지
- **메모리 효율성**: 자동 해제로 메모리 누수 방지
- **위치 정확성**: GlobalKey 기반 정확한 좌표 계산

## 🔄 최근 업데이트

### **v3.1.0 (현재)**
- ✅ **터치 임팩트 개선**: 실제 터치 위치에 정확한 임팩트 표시
- ✅ **GlobalKey 시스템**: 버튼 위치 정확한 추적
- ✅ **애니메이션 최적화**: elasticOut 커브로 자연스러운 효과
- ✅ **서버 연결 상태**: 실시간 백엔드 연결 모니터링
- ✅ **오류 처리 개선**: 상세한 오류 메시지 및 재시도 로직

### **v3.0.0**
- ✅ **Android 접근성 서비스 통합**: MyAccessibilityService.kt 구현
- ✅ **실시간 화면 요소 감지**: AccessibilityEvent 처리
- ✅ **가상 터치 시스템**: GestureDescription API 활용
- ✅ **터치 임팩트 애니메이션**: TouchIndicator 위젯 개선
- ✅ **웹 브라우징 지원**: 크롬 브라우저 내 요소 자동 클릭

### **v2.1.0**
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
**버전**: 3.1.0

### 🎯 **현재 구현된 기능들**

#### **✅ 완료된 기능**
- **Android 접근성 서비스**: MyAccessibilityService.kt 구현
- **실시간 화면 분석**: AccessibilityEvent 처리
- **가상 터치 시스템**: GestureDescription API 활용
- **터치 피드백**: TouchIndicator 애니메이션 (실제 위치 기반)
- **음성 인식**: OpenAI Whisper API 연동
- **AI 분석**: OpenAI GPT 모델 연동
- **웹 브라우징**: 크롬 브라우저 내 요소 클릭
- **테스트 UI**: 12개 웹사이트 테스트 버튼 (4x3 그리드)
- **서버 연결 상태**: 실시간 백엔드 연결 모니터링

#### **🔄 현재 작동 중인 기능**
- 접근성 이벤트 실시간 수신
- 화면 UI 요소 자동 감지
- 터치 임팩트 시각적 피드백 (정확한 위치)
- 서버 연결 상태 표시
- 음성 녹음 및 인식
- 가상 터치 실행
- GlobalKey 기반 버튼 위치 추적

#### **📱 테스트 가능한 기능**
- 크롬 브라우저에서 네이버 페이지 탐색
- 웹페이지 내 버튼 자동 클릭
- 터치 임팩트 애니메이션 확인 (실제 터치 위치)
- 접근성 이벤트 로그 확인
- 서버 연결 상태 실시간 모니터링
