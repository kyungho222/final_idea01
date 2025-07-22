# prototype

Flutter + FastAPI 기반 AI 음성 비서 프로토타입

---

## 📌 프로젝트 목적
- **프로토타입 제작**: 실제 서비스 전, 핵심 기능을 빠르게 검증하고 시연할 수 있는 데모 앱 개발

## 🎯 주요 기능
- **음성 명령 기반 제어**: 앱을 활성화한 뒤, 사용자가 음성으로 명령을 입력하면 AI가 해석하여 동작
- **화면 캡처 및 가상 터치**: 명령에 따라 현재 화면을 캡처하고, AI 분석 결과에 따라 가상의 터치(자동 클릭 등) 기능 제공
- **AI와 직접 통신**: 사용자의 음성 요청을 AI(LLM, OpenAI 등)와 직접 연동하여 자연어 명령 해석 및 응답
- **TTS(음성 합성)**: AI의 응답을 음성(TTS)으로 변환하여 안내(추후 적용)

## 🏗️ 전체 시스템 구조
```
[Flutter 앱] <-> [FastAPI 백엔드]
    |                |
    |                +-- Google Speech-to-Text (음성 인식)
    |                +-- OpenAI (LLM, 자연어 처리)
    |                +-- pyttsx3 (TTS, 음성 합성)
    |
    +-- 화면 캡처, 가상 터치 등 네이티브 기능
```

## 🛠️ 기술 스택
- **프론트엔드**: Flutter (Dart)
- **백엔드**: FastAPI (Python)
- **AI/음성**: Google Speech-to-Text, OpenAI, pyttsx3
- **기타**: flutter_sound, audioplayers, permission_handler 등

## ⚙️ 설치 및 실행 방법
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
4. 백엔드(FastAPI) 설치 및 실행
   ```bash
   cd ../backend
   pip install -r requirements.txt
   python app.py
   ```
5. Flutter 앱 실행
   ```bash
   cd ../prototype
   flutter run
   ```

## 🗂️ 주요 폴더 구조
```
prototype/   # Flutter 앱
backend/     # FastAPI 백엔드 서버
```

## 🐾 전체 동작 플로우
1. **실시간 음성인식 대기** (마이크 ON)
2. **음성 입력 감지** (데시벨 변화)
3. **음성 인식(서버 전송 → 텍스트 변환)**
4. **화면 캡처** (임시/시뮬레이션)
5. **화면+음성 동시 분석 (서버 LLM+API)**
6. **가상터치** (좌표 반환 → performVirtualTouch → 터치 효과)
7. **UI/상태 피드백** (상태 텍스트, 배지, 애니메이션 등)

## ✅ 현재까지 실제 구현된 기능
- 실시간 음성인식 대기/감지/상태 표시
- 음성 인식(서버 전송, Google Speech-to-Text)
- 명령+화면(이미지) 동시 분석 (OpenAI LLM API 연동)
- 명령에 따라 프론트의 1번(구글 등) 좌표 반환 및 가상터치/터치효과
- UI/상태 피드백(텍스트, 컬러, 배지, 애니메이션)
- 기존 모달/재생중지 등 프론트 기능 유지

## ❗ TODO (미구현/보완 필요 기능)
- [ ] 실제 화면 이미지 분석(OCR/객체인식 등) (현재는 시뮬레이션/임시)
- [ ] 명령어와 화면 상태의 동적 매칭 (동적 그리드/좌표)
- [ ] 음성명령의 자연어 처리 고도화 (다양한 표현 robust 처리)
- [ ] 실제 기기에서의 마이크/음성인식 신뢰성 최적화
- [ ] 배터리 최적화/백그라운드 동작
- [ ] 에러/예외 처리 고도화 (서버 통신 실패, 좌표 매칭 실패 등)
- [ ] 보안/프라이버시(음성/화면 데이터 안전한 전송/저장/삭제)
- [ ] 멀티플랫폼/다국어 지원
- [ ] (필요시) 실제 스크린샷 저장/전송 기능(플랫폼별)

## ⚡ 사용된 주요 패키지
- flutter_sound: 음성 녹음
- audioplayers: 오디오 재생
- permission_handler: 권한 요청
- http: HTTP 통신
- flutter_dotenv: 환경변수 관리
- FastAPI, openai, google-cloud-speech, pyttsx3 (백엔드)

## 🐞 이슈 해결 팁
- **패키지 설치 오류**: `flutter pub get` 실행 시 파일 잠금 오류가 발생하면, 모든 에디터/탐색기/터미널을 닫고, LockHunter 등으로 잠금 해제 후 재시도하세요.
- **빌드 오류**: `flutter clean` 후 다시 빌드
- **pubspec.yaml 문법 오류**: [pub.dev YAML validator](https://pub.dev/tools/pubspec)로 검사

## 📄 라이선스
MIT License (필요시 수정)

---

## 📅 CHANGELOG (날짜별 업데이트 내역)

- **2024-05-10**
  - 백엔드(app.py)에 /speech-to-text, /llm, /tts 엔드포인트 추가
  - Flutter에서 음성 녹음 → 서버 전송 → 텍스트 변환 → LLM 호출 → TTS 재생 전체 플로우 구현
  - 플로팅 버튼 UI/로직 개선(녹음/정지/상태 표시)
- **2024-05-09**
  - 프로젝트 구조 정비 및 주요 기능 설계
  - FastAPI 백엔드/Flutter 프론트엔드 기본 세팅
