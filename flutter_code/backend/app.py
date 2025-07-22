from fastapi import Request, FastAPI
import logging
from fastapi.responses import JSONResponse, FileResponse
import os
import base64
import re

# (추가) Google Speech-to-Text, OpenAI, pyttsx3 import
try:
    from google.cloud import speech
    import openai
    import pyttsx3
except ImportError:
    speech = None
    openai = None
    pyttsx3 = None

app = FastAPI()

# 로그 설정
logging.basicConfig(level=logging.INFO)

# 가상 터치/앱 실행 시뮬레이션 (샘플)
def simulate_touch(action, app_name=None):
    if action == "open_app" and app_name:
        logging.info(f"[SIM] 앱 실행: {app_name}")
        return True
    elif action == "click_button":
        logging.info("[SIM] 버튼 클릭")
        return True
    return False

# Tasker 연동 샘플 (실제 구현은 Tasker REST API 등 필요)
def trigger_tasker(task_name):
    logging.info(f"[SIM] Tasker 태스크 실행: {task_name}")
    return True

# 대화 맥락 관리 (간단 예시)
conversation_history = []

@app.post("/command")
async def command(request: Request):
    data = await request.json()
    action = data.get("action")
    app_name = data.get("app_name")
    # 가상 터치/앱 실행 시뮬레이션
    result = simulate_touch(action, app_name)
    # Tasker 연동 예시
    if action == "run_tasker":
        trigger_tasker(data.get("task_name", ""))
    # 대화 맥락 저장
    conversation_history.append(data)
    return {"result": result, "history": conversation_history[-5:]}

# (추가) Speech-to-Text 엔드포인트
@app.post("/speech-to-text")
async def speech_to_text(request: Request):
    if speech is None:
        return JSONResponse(status_code=500, content={"error": "google-cloud-speech 미설치"})
    data = await request.json()
    audio_b64 = data['audio']
    audio_bytes = base64.b64decode(audio_b64)
    # 서비스 계정 키 환경변수 필요
    os.environ["GOOGLE_APPLICATION_CREDENTIALS"] = os.path.join(os.path.dirname(__file__), "api_key/client_secret_24471291350-8ld4rl16jgli0ghdp1gorr016h5957m6.apps.googleusercontent.com.json")
    client = speech.SpeechClient()
    audio = speech.RecognitionAudio(content=audio_bytes)
    config = speech.RecognitionConfig(
        encoding=speech.RecognitionConfig.AudioEncoding.LINEAR16,
        sample_rate_hertz=16000,
        language_code="ko-KR"
    )
    response = client.recognize(config=config, audio=audio)
    transcript = ""
    for result in response.results:
        transcript += result.alternatives[0].transcript
    return {"transcript": transcript}

# (추가) LLM(OpenAI) 엔드포인트
@app.post("/llm")
async def llm(request: Request):
    if openai is None:
        return JSONResponse(status_code=500, content={"error": "openai 미설치"})
    data = await request.json()
    prompt = data['text']
    openai.api_key = os.getenv("OPENAI_API_KEY", "")
    response = openai.ChatCompletion.create(
        model="gpt-3.5-turbo",
        messages=[{"role": "user", "content": prompt}]
    )
    return {"response_text": response.choices[0].message.content}

# (추가) TTS 엔드포인트
@app.post("/tts")
async def tts(request: Request):
    if pyttsx3 is None:
        return JSONResponse(status_code=500, content={"error": "pyttsx3 미설치"})
    data = await request.json()
    text = data['text']
    engine = pyttsx3.init()
    engine.save_to_file(text, "output.mp3")
    engine.runAndWait()
    return FileResponse("output.mp3", media_type="audio/mpeg")

# (실제) analyze-image 엔드포인트: 명령+이미지 받아서 좌표 반환
@app.post('/analyze-image')
async def analyze_image(request: Request):
    data = await request.json()
    image_b64 = data.get('image')
    command = data.get('command', '').strip()

    # (1) OpenAI LLM을 활용해 명령+이미지 동시 분석
    if openai is not None:
        openai.api_key = os.getenv("OPENAI_API_KEY", "")
        # 프롬프트 예시: 이미지(캡처)와 명령을 함께 전달
        prompt = f"""
        사용자가 화면을 캡처한 이미지(Base64)와 명령을 입력했습니다.
        - 명령: {command}
        - 이미지(Base64): {image_b64[:100]}...(생략)
        아래 명령이 프론트의 1~3번 그리드 중 어디에 해당하는지 판단해서 번호만 반환하세요.
        예시: '1번', '2번', '3번' 등
        """
        try:
            response = openai.ChatCompletion.create(
                model="gpt-3.5-turbo",
                messages=[{"role": "user", "content": prompt}]
            )
            llm_result = response.choices[0].message.content.strip()
            # 번호 추출
            import re
            m = re.search(r'(\d+)번', llm_result)
            target_num = int(m.group(1)) if m else None
        except Exception as e:
            return JSONResponse(status_code=500, content={'error': f'LLM 분석 오류: {e}'})
    else:
        target_num = None

    # (2) 기존 패턴 매칭(백업)
    if target_num is None:
        grid_map = {
            1: {'label': '구글', 'x': 100, 'y': 400, 'url': 'https://www.google.com'},
            2: {'label': '페이스북', 'x': 180, 'y': 400, 'url': 'https://www.facebook.com'},
            3: {'label': '네이버', 'x': 260, 'y': 400, 'url': 'https://www.naver.com'},
        }
        # 1) '1번', '1번 눌러줘', '1번 터치해줘' 등 숫자 추출
        m = re.search(r'(\d+)번', command)
        if m:
            target_num = int(m.group(1))
        # 2) '구글 열어줘', '구글' 등 label로 매칭
        if target_num is None:
            for num, info in grid_map.items():
                if info['label'] in command:
                    target_num = num
                    break
        if target_num in grid_map:
            x = grid_map[target_num]['x']
            y = grid_map[target_num]['y']
            return {'x': x, 'y': y}
        return JSONResponse(status_code=400, content={'error': '명령에서 유효한 그리드 번호/이름을 찾을 수 없습니다.'})

    # (3) LLM 결과로 좌표 반환
    grid_map = {
        1: {'label': '구글', 'x': 100, 'y': 400, 'url': 'https://www.google.com'},
        2: {'label': '페이스북', 'x': 180, 'y': 400, 'url': 'https://www.facebook.com'},
        3: {'label': '네이버', 'x': 260, 'y': 400, 'url': 'https://www.naver.com'},
    }
    if target_num in grid_map:
        x = grid_map[target_num]['x']
        y = grid_map[target_num]['y']
        return {'x': x, 'y': y}
    return JSONResponse(status_code=400, content={'error': 'LLM 분석 결과에서 유효한 번호를 찾을 수 없습니다.'})

# 통합 테스트용 엔드포인트
@app.get("/healthcheck")
async def healthcheck():
    return {"status": "ok"}

# 예외 처리 강화 예시
@app.exception_handler(Exception)
async def global_exception_handler(request, exc):
    logging.error(f"에러 발생: {exc}")
    return JSONResponse(status_code=500, content={"error": str(exc)}) 