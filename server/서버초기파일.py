import subprocess
from datetime import datetime
import os
import time
import random
from youtube_transcript_api import YouTubeTranscriptApi, TranscriptsDisabled, NoTranscriptFound
import cv2
import pytesseract
import re
import threading
from flask import Flask, request, jsonify
import json

def download_video(url):
    download_start = time.time() # 다운로드 시작 시간 기록
    format = 'bestvideo[height<=360]+bestaudio/best[height<=360]'
    current_time = datetime.now().strftime('%Y%m%d%H%M%S')
    output_file = f'downloaded_video_{current_time}'
    output_trimmed_file = f'trimmed_video_{current_time}' 
    command = [
        'yt-dlp',
        url,
        '-f',
        format,
        '-o', output_file 
    ]
    result = subprocess.run(command, capture_output=True, text=True) 
    download_end = time.time()  # 다운로드 끝나는 시간 기록
    download_duration = download_end - download_start  # 다운로드에 걸린 시간 계산
    if result.returncode == 0:
        trim_start = time.time()
        trim_command = [
            'ffmpeg',
            '-i', f'{output_file}.webm',  # 입력 파일
            '-t', '60',  # 자를 길이(60초)
            '-c', 'copy',  # 인코딩 없이 복사
            f'{output_trimmed_file}.webm'  # 출력 파일
        ]
        trim_result = subprocess.run(trim_command, capture_output=True, text=True)
        trim_end = time.time()  # 자르기 끝나는 시간 기록
        trim_duration = trim_end - trim_start  # 자르기에 걸린 시간 계산
        if trim_result.returncode == 0:
            try:
                os.remove(f'{output_file}.webm')
                # print(f"Video download time: {download_duration:.2f} seconds")
                # print(f"Video trimming time: {trim_duration:.2f} seconds")
                return f"{output_trimmed_file}.webm"
            except OSError as e:
                print(f"Error deleting original video: {e}")
                return f"{output_trimmed_file}.webm"
        else:
            return None
    else:
        return None

def detect_subtitles(video_path):
    cap = cv2.VideoCapture(video_path)
    subtitle_detected = 0

    while cap.isOpened():
        ret, frame = cap.read()
        if not ret:
            break
        current_frame_time = cap.get(cv2.CAP_PROP_POS_MSEC) / 1000

        if int(current_frame_time) % 1 == 0:
            height, width, _ = frame.shape
            cropped_frame = frame[int(height * 3 / 4):height, 0:width]
            gray = cv2.cvtColor(cropped_frame, cv2.COLOR_BGR2GRAY)
            text = pytesseract.image_to_string(gray, lang='kor')
            valid_text = re.findall(r'[가-힣]{2,}', text)
            if valid_text:
                subtitle_detected = 1
                break  
        cap.set(cv2.CAP_PROP_POS_MSEC, (current_frame_time + 1) * 1000)

    cap.release()
    cv2.destroyAllWindows()

    return subtitle_detected

def process_youtube_transcript(url, preferred_languages=['ko']):
    match = re.search(r"v=([a-zA-Z0-9_-]+)", url)
    if match:
        video_id = match.group(1)
    else:
        print("유효한 유튜브 비디오 ID를 추출할 수 없습니다.")
        return

    try:
        transcripts = YouTubeTranscriptApi.list_transcripts(video_id)
        selected_transcript = None
        for transcript in transcripts:
            if transcript.language_code == 'ko' and transcript.is_generated:
                selected_transcript = transcript
                break
        if not selected_transcript:
            for language in preferred_languages:
                try:
                    selected_transcript = transcripts.find_manually_created_transcript([language])
                    break
                except NoTranscriptFound:
                    continue
        if not selected_transcript or selected_transcript.language_code != 'ko':
            raise NoTranscriptFound("한국어 자막을 찾을 수 없습니다.")
        transcript_data = selected_transcript.fetch()
        total_duration = transcript_data[-1]['start'] + transcript_data[-1]['duration']
        segments = []

        for _ in range(20):
            start_time = random.uniform(0, max(0, total_duration - 9)) 
            end_time = start_time + 9

            segment_text = ''
            for entry in transcript_data:
                if entry['start'] >= start_time and entry['start'] <= end_time:
                    segment_text += entry['text']
            cleaned_text = re.sub(r'[^a-zA-Z0-9가-힣]', '', segment_text)

            segments.append({
                'start_time': start_time,
                'end_time': end_time,
                'char_count': len(cleaned_text)
            })

        segments = sorted(segments, key=lambda x: x['char_count'], reverse=True)
        top_5_segments = segments[:5]
        avg_top_5_char_count = sum([seg['char_count'] for seg in top_5_segments]) / len(top_5_segments)
        return avg_top_5_char_count

    except TranscriptsDisabled:
        return -1
    except NoTranscriptFound as e:
        return -2
    except Exception as e:
        return -3

app = Flask(__name__)

# 사용자별 상태 저장 (user_id -> 결과값 배열)
user_results = {}
request_cancel_flags = {}

# 기존 분석 결과 저장 (url -> 분석 결과)
url_analysis_cache = {}

# 기본 배열 값
default_result = [1, 0, 0, 0]

def initialize_user_result(user_id):
    """사용자의 결과 배열을 기본 값으로 초기화"""
    user_results[user_id] = default_result.copy()

def process_request(user_id, url):
    """새로운 요청을 처리"""

    # 사용자 결과 배열을 기본값으로 초기화
    initialize_user_result(user_id)

    # 다운로드 시작 (생략된 함수 가정)
    download_start = time.time()
    video_name = download_video(url)

    # OCR 및 자막 분석 처리 (생략된 함수 가정)
    result_ocr = detect_subtitles(video_name)
    result_speech = process_youtube_transcript(url)


    # 처리 완료 시 사용자 결과 배열 업데이트 및 URL 추가
    control = calculate_control(result_speech, result_ocr)
    end = time.time()
    duration = end - download_start

    # 분석 결과에 URL 추가
    result_array = [control, result_speech, result_ocr, duration, url]

    # 분석 결과 캐싱
    url_analysis_cache[url] = result_array

    # 사용자 결과 저장
    user_results[user_id] = result_array

    try:
        os.remove(f'{video_name}')
    except OSError as e:
        print(f"Error deleting trimmed video: {e}")

def calculate_control(result_speech, result_ocr):
    """Control 값 계산"""
    if 0 <= result_speech <= 60:
        return 2 if result_ocr == 1 else 1.75
    elif result_speech > 60:
        return 1.5 if result_ocr == 1 else 1.25
    else:
        return 1 if result_ocr == 1 else 0.75

@app.route('/process', methods=['POST'])
def process_and_get_result():
    data = request.json
    url = data.get('url')
    user_id = data.get('user_id')  # 사용자 ID를 요청에서 받아옴
    print(f"Processing request for user {user_id} with URL: {url}")

    if not url or not user_id:
        return jsonify({"error": "URL and user_id are required"}), 400

    # 중복 URL 요청 처리: 기존 분석 결과가 있으면 바로 반환
    if url in url_analysis_cache:
        return jsonify(url_analysis_cache[url])

    # 새로운 요청 처리 시작
    thread = threading.Thread(target=process_request, args=(user_id, url))
    thread.start()

    # Long Polling: 작업이 완료될 때까지 대기 (최대 20초)
    timeout = 20
    waited = 0
    poll_interval = 1  # 1초 간격으로 확인

    while waited < timeout:
        if user_id in user_results and user_results[user_id] != default_result:
            # 결과가 있으면 반환
            return jsonify(user_results[user_id])
        time.sleep(poll_interval)  # 1초 대기
        waited += poll_interval

    # 대기 시간 초과 시 204 No Content 응답
    return jsonify({"message": "No result yet."}), 204

def save_cache_to_file():
    """캐시 데이터를 텍스트 파일에 저장하는 함수 (8시간마다 실행)"""
    while True:
        time.sleep(12 * 3600)  # 시간마다 실행 (8 * 3600초)

        if url_analysis_cache:
            # 파일 이름에 타임스탬프 추가
            timestamp = datetime.now().strftime('%Y%m%d%H%M%S')
            file_name = f'cache_backup_{timestamp}.txt'

            # 캐시 데이터를 파일에 저장
            with open(file_name, 'w') as file:
                json.dump(url_analysis_cache, file)

            print(f"Cache saved to {file_name}")

# 캐시 저장 작업을 별도의 스레드로 실행
cache_saver_thread = threading.Thread(target=save_cache_to_file)
cache_saver_thread.daemon = True  # 백그라운드에서 실행되도록 설정
cache_saver_thread.start()

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)