import time
from fastapi import FastAPI, Request, HTTPException
from fastapi.responses import JSONResponse
import logging
import os
from gtts import gTTS
from hashlib import md5
import re

# 로깅 설정
logging.basicConfig(level=logging.INFO, format='%(asctime)s [%(levelname)s] %(message)s')

app = FastAPI()

@app.on_event("startup")
def on_startup():
    logging.info("[서버 시작] FastAPI 서버가 시작되었습니다.")

@app.on_event("shutdown")
def on_shutdown():
    logging.info("[서버 종료] FastAPI 서버가 종료됩니다.")

@app.middleware("http")
async def log_request_response(request: Request, call_next):
    logging.info(f"[요청 진입] {request.method} {request.url}")
    start_time = time.time()
    response = await call_next(request)
    process_time = (time.time() - start_time) * 1000
    logging.info(f"[응답 반환] {request.method} {request.url} - 상태코드: {response.status_code} - 처리시간: {process_time:.2f}ms")
    return response

@app.get("/")
def read_root():
    logging.info("[라우트 진입] GET / - read_root 함수 실행")
    return {"Hello": "World"}

@app.post("/llm")
async def llm_endpoint(request: Request):
    try:
        data = await request.json()
    except Exception:
        raise HTTPException(status_code=400, detail="JSON 형식의 body가 필요합니다.")
    user_text = data.get("text", "")
    if not user_text:
        raise HTTPException(status_code=400, detail="text 필드가 필요합니다.")
    # 간단한 명령 분석: 숫자 추출 또는 label 추출
    target = None
    # 숫자(1~24) 추출
    m = re.search(r"([1-9]|1[0-9]|2[0-4])번", user_text)
    if m:
        target = m.group(1)
    # label 예시: '페이스북', '유튜브' 등
    elif "페이스북" in user_text:
        target = "페이스북"
    elif "유튜브" in user_text:
        target = "유튜브"
    # action 필드 구성
    action = {"type": "tap", "target": target} if target else None
    result = {"result": f"분석된 텍스트: {user_text}"}
    if action:
        result["action"] = action
    return result

@app.post("/tts")
async def tts_endpoint(request: Request):
    try:
        data = await request.json()
    except Exception:
        raise HTTPException(status_code=400, detail="JSON 형식의 body가 필요합니다.")
    text = data.get("text", "")
    if not text:
        raise HTTPException(status_code=400, detail="text 필드가 필요합니다.")
    # static/audio 폴더 생성
    audio_dir = os.path.join(os.getcwd(), "static", "audio")
    os.makedirs(audio_dir, exist_ok=True)
    # 파일명 안전하게 처리
    safe_filename = md5(text.encode("utf-8")).hexdigest() + ".mp3"
    audio_path = os.path.join(audio_dir, safe_filename)
    # gTTS로 mp3 생성 및 저장
    tts = gTTS(text, lang="ko")
    tts.save(audio_path)
    # 반환 URL
    audio_url = f"/static/audio/{safe_filename}"
    return {"audio_url": audio_url}

@app.post("/audio_cleanup")
async def audio_cleanup(request: Request):
    try:
        data = await request.json()
    except Exception:
        raise HTTPException(status_code=400, detail="JSON 형식의 body가 필요합니다.")
    # text 또는 audio_url 중 하나를 받음
    text = data.get("text")
    audio_url = data.get("audio_url")
    audio_path = None
    if text:
        from hashlib import md5
        safe_filename = md5(text.encode("utf-8")).hexdigest() + ".mp3"
        audio_path = os.path.join(os.getcwd(), "static", "audio", safe_filename)
    elif audio_url:
        # audio_url이 /static/audio/파일명.mp3 형태라고 가정
        filename = os.path.basename(audio_url)
        audio_path = os.path.join(os.getcwd(), "static", "audio", filename)
    else:
        raise HTTPException(status_code=400, detail="text 또는 audio_url 필드가 필요합니다.")
    # 파일 삭제
    if audio_path and os.path.exists(audio_path):
        os.remove(audio_path)
        return {"result": "deleted"}
    else:
        raise HTTPException(status_code=404, detail="파일을 찾을 수 없습니다.")

@app.post("/command")
async def command_endpoint(request: Request):
    try:
        data = await request.json()
    except Exception:
        raise HTTPException(status_code=400, detail="JSON 형식의 body가 필요합니다.")
    logging.info(f"[명령 기록] {data}")
    return {"status": "ok"} 