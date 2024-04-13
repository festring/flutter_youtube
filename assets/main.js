// 이전 URL 저장 변수
let previousUrl = window.location.href;
// 초기값 설정
let previousTime = 0;
let currentTime = 0;
let backward = 0;
let forward = 0;

// URL 변경 감지 함수
function handleUrlChange() {
    const currentUrl = window.location.href;

    // 이전 URL과 현재 URL이 다르고, 현재 URL이 "#dialog"을 포함하지 않을 경우에만 출력
    if (previousUrl !== currentUrl && !currentUrl.includes("#dialog")) {
        //console.log("URL 변경 감지:", currentUrl);
				//영상 새로 들어갈 때마다 URL 및 변수 초기화
        previousUrl = currentUrl; // 이전 URL 갱신
				previousTime = 0;
				currentTime = 0;
				backward = 0;
				forward = 0;
    }
}

// 1초마다 URL 변경 감지 함수 호출 
setInterval(handleUrlChange, 1000);

// 1초마다 실행되는 이동 감지 함수
setInterval(() => {
  // YouTube 플레이어 가져오기
  const ytplayer = document.getElementById("movie_player");
  // 현재 시간 가져오기
  currentTime = ytplayer.getCurrentTime();

  // 이전 시간과 현재 시간 출력
  //console.log(`이전 시간: ${previousTime}, 현재 시간: ${currentTime}`);

  // 현재 시간과 이전 시간의 차이 계산
  const timeDifference = currentTime - previousTime;

  // 차이가 +9.5 이상인 경우 출력
  if (timeDifference >= 9.5) {
		forward +=1;
		console.log(`앞으로 이동 횟수: ${forward}`);
    //console.log(`차이가 +9.5 이상입니다: ${timeDifference}`);
  }

  // 차이가 -9.5 이하인 경우 출력
  if (timeDifference <= -9.5) {
		backward +=1;
		console.log(`뒤로 이동 횟수: ${backward}`);
    //console.log(`차이가 -9.5 이하입니다: ${timeDifference}`);
  }

  // 현재 시간을 이전 시간으로 업데이트
  previousTime = currentTime;
}, 1000);


