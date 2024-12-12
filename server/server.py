from flask import Flask, request, jsonify
import re

app = Flask(__name__)

# 미리 설정된 리스트 예제
predefined_lists = [
    [1.0, 2.0, 3.0, "0xSiBpUdW4E"],
    [4.5, 6.7, 8.9, "abc123XYZ"],
    [1.1, 2.2, 3.3, "sampleID456"]
]

# 유튜브 URL에서 영상 ID 추출 함수
def extract_video_id(url):
    print(f"[DEBUG] Extracting video ID from URL: {url}")
    # 유튜브 영상 ID를 추출하기 위한 정규 표현식
    match = re.search(r"(?:v=|\/)([0-9A-Za-z_-]{11})", url)
    video_id = match.group(1) if match else None
    print(f"[DEBUG] Extracted video ID: {video_id}")
    return video_id

@app.route('/process', methods=['POST'])
def process():
    try:
        print("[DEBUG] Received a POST request to /process")

        # 요청 데이터 받기
        data = request.get_json()
        print(f"[DEBUG] Request JSON data: {data}")
        
        user_id = data.get('user_id')
        url = data.get('url')
        
        if not user_id or not url:
            print("[ERROR] Missing 'user_id' or 'url' in request")
            return jsonify({"error": "Missing 'user_id' or 'url'"}), 400

        # 유튜브 영상 ID 추출
        video_id = extract_video_id(url)
        if not video_id:
            print("[ERROR] Invalid YouTube URL provided")
            return jsonify([0, 1, 1, "0"]), 200  # 기본 배열 반환

        # 리스트에서 ID 확인
        print(f"[DEBUG] Searching for video ID: {video_id} in predefined lists")
        matching_list = next((lst for lst in predefined_lists if lst[3] == video_id), None)
        if matching_list:
            print(f"[DEBUG] Matching list found: {matching_list}")
            return jsonify(matching_list), 200
        else:
            print(f"[DEBUG] No matching list found for video ID: {video_id}")
            return jsonify([0, 1, 1, "0"]), 200  # 기본 배열 반환

    except Exception as e:
        print(f"[ERROR] An exception occurred: {str(e)}")
        return jsonify({"error": str(e)}), 500

if __name__ == '__main__':
    print("[DEBUG] Starting Flask server...")
    app.run(host='0.0.0.0', port=5000, threaded=True)
