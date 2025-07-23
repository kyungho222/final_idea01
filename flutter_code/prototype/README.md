# LLM 음성 비서 프로토타입 (최신)

## 주요 변경 및 최신 상태 (2025-07)

- **가상터치(터치 이펙트) UI 대폭 개선**: 터치 시 애니메이션 오버레이(빨간 원, 아이콘, 텍스트)로 명확하게 표시
- **디버그 로그 다이얼로그**: 앱 상단 🐞 버튼으로 debug.log를 바로 확인/복사 가능
- **url_launcher inAppWebView 적용**: 그리드 아이템 클릭 시 앱 내 웹뷰로 링크 열기(에뮬레이터/기기 호환성 개선)
- **AndroidManifest.xml에 인터넷 권한 포함**
- **서버 엔드포인트(/llm 등) 점검 및 404/Timeout 문제 해결**
- **flutter clean 등 빌드 산출물 정리**

---

## 프로젝트 개요

Flutter 기반의 음성 인식 및 AI 분석을 통한 스마트 비서 애플리케이션입니다. 사용자의 음성 명령을 인식하고 AI가 분석하여 적절한 액션을 수행합니다.

### 아키텍처
- **프론트엔드(Flutter)**: 음성 녹음, UI/UX, 가상터치, 디버그 로그, 링크 실행 등
- **백엔드(FastAPI)**: 음성 인식(OpenAI/Google), 자연어 처리, TTS, 명령 분석 등

### 주요 기능
- 실시간 음성 녹음 및 명령 분석
- AI 분석 결과에 따른 가상터치(시각적 이펙트)
- 앱/웹사이트 자동 실행 (in-app webview)
- 디버그 로그 실시간 확인/복사

---

## 설치 및 실행

### 1. Flutter 앱
- Flutter SDK 3.0+ 설치
- Android Studio/VS Code에서 프로젝트 열기
- AndroidManifest.xml에 인터넷 권한 포함 확인
- `flutter pub get` → `flutter run`

### 2. 백엔드 서버
- backend 폴더에서 `pip install -r requirements.txt`
- `uvicorn app:app --host 0.0.0.0 --port 8000 --reload`
- 서버 엔드포인트(/llm 등) 정상 동작 확인

---

## 사용법

- 마이크 버튼: 음성 녹음 및 명령 인식
- 숫자 선택: 음성 입력 부족 시 대체 입력
- 그리드 클릭: 앱/웹사이트(in-app webview) 실행
- 🐞 버튼: 디버그 로그 확인/복사

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
