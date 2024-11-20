let previousTime = 0;
let currentTime = 0;
let backward = [];
let forward = [];
var isDetected = false;
var speedIntervals = []; 
let save =0;
let touchlist = [];

var iosSpeedList = [];
let lastPlaybackRate = 1;

function recordSpeed(speed){
  let speedTime = document.querySelector('video').currentTime;
  iosSpeedList.push([speed, speedTime]);
};

setInterval(() => {
  let currentPlaybackRate = document.querySelector('video').playbackRate;
  if (Math.abs(currentPlaybackRate - lastPlaybackRate) >= 0.2) {
    recordSpeed(currentPlaybackRate);
  }
  lastPlaybackRate = currentPlaybackRate;
}, 100);



setInterval(() => {
  currentTime = document.querySelector('video').currentTime; 

  const timeDifference = currentTime - previousTime;
  if (timeDifference >= 9.5) {
        forward.push(currentTime);
  }
  if (timeDifference <= -2.5) {
        backward.push(currentTime);
  }
  previousTime = currentTime;
}, 500);

setInterval(function() {
    const element = document.querySelector('.player-controls-top-tooltip-label.typography-narrow-default-action-m');
    if (element && !isDetected) {
        speedIntervals.push([currentTime]); 
        isDetected = true;
    } else if (!element && isDetected) {
        speedIntervals[speedIntervals.length - 1].push(currentTime); 
        isDetected = false; 
    }
  if(currentTime!=0){
    save = currentTime;
  }
}, 1000);


function initializePlaybackRateButton() {
  // 기존의 player-controls-top 요소를 찾음
  const playerControlsTop = document.querySelector('.player-controls-top.with-video-details');

  if (!playerControlsTop) {
    console.error('player-controls-top 요소를 찾을 수 없습니다.');
    return;
  }

  // 새로운 버튼 생성
  const playbackRateButton = document.createElement('button');
  playbackRateButton.className = 'icon-button playback-rate-button';
  playbackRateButton.style.marginLeft = '10px'; // 약간의 간격 추가
  playbackRateButton.style.width = '120px'; // 버튼의 가로 길이 설정
  playbackRateButton.style.height = '50px'; // 버튼 높이 설정
  playbackRateButton.style.display = 'flex'; // 플렉스 박스 사용
  playbackRateButton.style.flexDirection = 'column'; // 텍스트를 위쪽에 배치
  playbackRateButton.style.justifyContent = 'flex-start'; // 텍스트를 상단에 고정
  playbackRateButton.style.alignItems = 'center'; // 중앙 정렬
  playbackRateButton.style.color = 'white'; // 텍스트 색상을 흰색으로 설정
  playbackRateButton.style.paddingTop = '17px'; // 텍스트 윗공간 조절 가능
  playbackRateButton.textContent = 'N/A'; // 기본 값 설정


  // 버튼 클릭 시 배속 표시 및 현재 재생 시간 반환 및 출력
  playbackRateButton.addEventListener('click', () => {
    const video = document.querySelector('video');
    if (video) {
      const playbackRate = video.playbackRate.toFixed(1); // 배속 값을 소수점 1자리로 표시
      const currentTime = video.currentTime.toFixed(2); // 현재 시간 값을 소수점 2자리로 표시

      // 버튼 텍스트 업데이트
      playbackRateButton.textContent = 'Rate: ' + playbackRate + 'x'; // 문자열 연결 방식으로 배속 표시

      // 현재 시간을 touchlist 배열에 추가
      touchlist.push(currentTime);

      return currentTime; // 현재 시간 반환
    } else {
      alert('비디오를 찾을 수 없습니다.');
    }
  });

  // 버튼을 player-controls-top의 첫 번째 자식으로 삽입
  playerControlsTop.insertBefore(playbackRateButton, playerControlsTop.firstChild);
}
