# LLM 음성 비서 프로토타입 (최신)

## 주요 변경 및 최신 상태 (2025-07)

- **가상터치(터치 이펙트) UI 대폭 개선**
- **디버그 로그 다이얼로그**
- **url_launcher inAppWebView 적용**
- **AndroidManifest.xml에 인터넷 권한 포함**
- **서버 엔드포인트(/llm, /tts, /audio_cleanup, /command) 구현 및 404/Timeout 문제 해결**
- **음원파일(TTS) 자동 삭제 정책 적용**
- **flutter clean 등 빌드 산출물 정리**

---

## 프로젝트 개요

Flutter 기반의 음성 인식 및 AI 분석을 통한 스마트 비서 애플리케이션입니다. 사용자의 음성 명령을 인식하고 AI가 분석하여 적절한 액션을 수행합니다.

### 아키텍처
- **프론트엔드(Flutter)**: 음성 녹음, UI/UX, 가상터치, 디버그 로그, 링크 실행 등
- **백엔드(FastAPI)**: 음성 인식(OpenAI/Google), 자연어 처리, TTS, 명령 분석, 명령 기록 등

### 주요 기능
- 실시간 음성 녹음 및 명령 분석
- AI 분석 결과에 따른 가상터치(시각적 이펙트)
- 앱/웹사이트 자동 실행 (in-app webview)
- 디버그 로그 실시간 확인/복사
- TTS 음성 파일 생성 및 자동 삭제
- 명령(action) 실행 결과 서버 기록

---

## 설치 및 실행

### 1. Flutter 앱
- Flutter SDK 3.0+ 설치
- Android Studio/VS Code에서 프로젝트 열기
- AndroidManifest.xml에 인터넷 권한 포함 확인
- `flutter pub get` → `flutter run`

### 2. 백엔드 서버
- backend 폴더에서 `pip install -r requirements.txt`
- `uvicorn app:app --host 127.0.0.1 --port 8000`
- 서버 엔드포인트(/llm, /tts, /audio_cleanup, /command) 정상 동작 확인

---

## 백엔드 API 명세

### 1. `/llm` (POST)
- **설명:** 음성 명령 또는 숫자 선택을 분석하여 action(가상터치 등) 정보를 반환
- **요청 예시:**
  ```json
  { "text": "2번을 클릭해줘" }
  ```
- **응답 예시:**
  ```json
  {
    "result": "분석된 텍스트: 2번을 클릭해줘",
    "action": { "type": "tap", "target": "2" }
  }
  ```
- **비고:** target은 번호("2") 또는 label("페이스북" 등) 모두 가능

### 2. `/tts` (POST)
- **설명:** 텍스트를 mp3 음성 파일로 변환하여 저장, 파일 URL 반환
- **요청 예시:**
  ```json
  { "text": "안녕하세요" }
  ```
- **응답 예시:**
  ```json
  { "audio_url": "/static/audio/해시값.mp3" }
  ```
- **비고:** 같은 텍스트는 같은 파일명(해시)으로 저장됨

### 3. `/audio_cleanup` (POST)
- **설명:** 가상터치 작업 후 사용된 음원(mp3) 파일 삭제
- **요청 예시:**
  ```json
  { "text": "안녕하세요" }
  // 또는
  { "audio_url": "/static/audio/해시값.mp3" }
  ```
- **응답 예시:**
  ```json
  { "result": "deleted" }
  ```

### 4. `/command` (POST)
- **설명:** 클라이언트에서 action 실행 결과를 서버에 기록(로깅)
- **요청 예시:**
  ```json
  {
    "action": { "type": "tap", "target": "2" },
    "result": "success",
    "timestamp": "2025-07-23T13:05:14.186054"
  }
  ```
- **응답 예시:**
  ```json
  { "status": "ok" }
  ```

---

## 음원파일(TTS) 자동 삭제 정책
- 클라이언트가 가상터치 등 action을 완료하면 `/audio_cleanup`으로 해당 음원파일 삭제 요청을 보냅니다.
- 서버는 text 또는 audio_url을 받아 mp3 파일을 삭제합니다.
- 불필요한 음원파일이 서버에 남지 않도록 관리됩니다.

---

## Troubleshooting

- **링크 연결 안 됨**: inAppWebView 적용, 인터넷 권한, 브라우저 앱 활성화, url_launcher 최신 버전 확인
- **AI 분석 Timeout/404**: 서버 실행, 엔드포인트(/llm 등) 구현, 네트워크 연결 확인
- **가상터치 효과 안 보임**: UI 오버레이 정상 동작, MaterialLocalizations 에러 해결
- **빌드 파일 삭제**: `flutter clean` 명령어 사용

---

## 기타
- 실제 기기/에뮬레이터 환경에 따라 일부 기능(브라우저, 인텐트 등) 차이 있음
- 서버/클라이언트 로그(debug.log, 콘솔)로 문제 추적 가능

---

**문의/이슈는 GitHub Issue 또는 디버그 로그와 함께 문의해 주세요.**
