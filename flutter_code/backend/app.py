import time
from fastapi import FastAPI, Request
from fastapi.responses import JSONResponse
import logging

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