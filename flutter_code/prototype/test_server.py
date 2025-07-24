from flask import Flask, request, jsonify
import json

app = Flask(__name__)

@app.route('/')
def home():
    return jsonify({"message": "서버가 실행 중입니다!"})

@app.route('/llm', methods=['POST'])
def llm():
    data = request.get_json()
    text = data.get('text', '')
    return jsonify({
        "result": f"분석된 텍스트: {text}",
        "action": {"type": "tap", "target": "1"}
    })

@app.route('/tts', methods=['POST'])
def tts():
    data = request.get_json()
    text = data.get('text', '')
    return jsonify({
        "audio_url": f"/static/audio/test.mp3",
        "text": text
    })

@app.route('/speech-to-text', methods=['POST'])
def stt():
    # 파일 업로드 처리
    return jsonify({
        "text": "음성 인식 결과입니다."
    })

@app.route('/find-element', methods=['POST'])
def find_element():
    data = request.get_json()
    voice_command = data.get('voice_command', '')
    ui_elements = data.get('ui_elements', [])
    
    return jsonify({
        "element": {
            "text": "찾은 요소",
            "type": "button",
            "bounds": {"left": 100, "top": 200, "right": 200, "bottom": 250}
        }
    })

if __name__ == '__main__':
    print("서버를 시작합니다... http://localhost:8000")
    app.run(host='0.0.0.0', port=8000, debug=True) 