from fastapi import Request
import logging
from fastapi.responses import JSONResponse

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

# 통합 테스트용 엔드포인트
@app.get("/healthcheck")
async def healthcheck():
    return {"status": "ok"}

# 예외 처리 강화 예시
@app.exception_handler(Exception)
async def global_exception_handler(request, exc):
    logging.error(f"에러 발생: {exc}")
    return JSONResponse(status_code=500, content={"error": str(exc)}) 