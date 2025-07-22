# prototype

Flutter 기반 모바일 앱 프로젝트입니다.

## 📱 주요 기능
- 음성 인식 (speech_to_text)
- 권한 요청 (permission_handler)
- HTTP 통신 (http)
- 오디오 재생 (audioplayers)
- 이미지 선택/캡처 (image_picker)
- 파일 경로 관리 (path_provider)
- 설정 저장 (shared_preferences)
- URL 실행 (url_launcher)
- iOS/Android/Windows/Linux/MacOS/Web 지원

## 🛠️ 설치 및 실행 방법
1. Flutter SDK 설치 ([공식 사이트](https://flutter.dev/docs/get-started/install))
2. 프로젝트 클론
   ```bash
   git clone https://github.com/your-repo/your-project.git
   cd prototype
   ```
3. 패키지 설치
   ```bash
   flutter pub get
   ```
4. 디버그 빌드 및 실행
   ```bash
   flutter run
   # 또는
   flutter build apk --debug
   ```

## ⚡ 사용된 주요 패키지
- speech_to_text: 음성 인식
- permission_handler: 권한 요청
- http: HTTP 통신
- audioplayers: 오디오 재생
- cupertino_icons: 아이콘
- url_launcher: 외부 URL 실행
- image_picker: 이미지 선택/캡처
- path_provider: 파일 경로 관리
- shared_preferences: 로컬 설정 저장

## 🐞 이슈 해결 팁
- **패키지 설치 오류**: `flutter pub get` 실행 시 파일 잠금 오류가 발생하면, 모든 에디터/탐색기/터미널을 닫고, LockHunter 등으로 잠금 해제 후 재시도하세요.
- **빌드 오류**: `flutter clean` 후 다시 빌드
- **pubspec.yaml 문법 오류**: [pub.dev YAML validator](https://pub.dev/tools/pubspec)로 검사

## 📄 라이선스
MIT License (필요시 수정)
