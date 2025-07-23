from fastapi import FastAPI, Request
import logging
from fastapi.responses import JSONResponse
import os
import base64
from google.cloud import speech
from google.oauth2 import service_account

app = FastAPI()

# 디버깅 및 서버 동작 로그 설정
logging.basicConfig(level=logging.INFO, format='%(asctime)s [%(levelname)s] %(message)s')

@app.get("/")
def read_root():
    logging.info("[라우트 진입] GET / - read_root 함수 실행")
    return {"message": "Hello, FastAPI!"}

@app.post("/llm")
async def llm_endpoint(request: Request):
    data = await request.json()
    logging.info(f"[라우트 진입] POST /llm - 데이터: {data}")
    # 실제 LLM 처리 로직은 추후 구현
    return JSONResponse(content={"result": "LLM 응답 예시", "received": data})

@app.post("/speech-to-text")
async def speech_to_text_endpoint(request: Request):
    data = await request.json()
    logging.info(f"[라우트 진입] POST /speech-to-text - 데이터: {data}")
    try:
        # 클라이언트에서 base64로 인코딩된 음성 파일을 전송한다고 가정
        audio_content = base64.b64decode(data["audio_base64"])
        language_code = data.get("language_code", "ko-KR")
        # 구글 서비스 계정 키 파일 경로
        credentials = service_account.Credentials.from_service_account_file(
            "app_key/client_secret_24471291350-8ld4rl16jgli0ghdp1gorr016h5957m6.apps.googleusercontent.com.json"
        )
        client = speech.SpeechClient(credentials=credentials)
        audio = speech.RecognitionAudio(content=audio_content)
        config = speech.RecognitionConfig(
            encoding=speech.RecognitionConfig.AudioEncoding.LINEAR16,
            sample_rate_hertz=16000,
            language_code=language_code,
        )
        response = client.recognize(config=config, audio=audio)
        transcript = "".join([result.alternatives[0].transcript for result in response.results])
        return JSONResponse(content={"result": transcript})
    except Exception as e:
        logging.error(f"[STT 오류] {e}")
        return JSONResponse(content={"error": str(e)}, status_code=500)

if __name__ == "__main__":
    import uvicorn
    uvicorn.run("app:app", host="127.0.0.1", port=8000, reload=True) 