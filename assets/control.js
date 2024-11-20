//어차피 랩실험에서는 목표 배속까지 무조건 증가시키는게 중요, 사용자가 변환하든 말든,변환하면 그거 기록하면 되니깐
let isIncreasing = false; // 실행 상태를 추적하는 플래그 변수
let currentController = null;


function increasePlaybackRate(tap, cycle, up) {
    const video = document.querySelector('video');
    if (!video) {
        console.error("Video element not found!");
        return;
    }

    let playbackRate = 1.0; // 항상 1.0에서 시작
    const valueTap = parseFloat(tap);  // step 크기
    const valueCycle = parseFloat(cycle) * 1000; // 밀리초 변환
    const valueUp = parseFloat(up);  // 목표 배속

    isIncreasing = true; // 실행 시작 시 플래그를 활성화

    function increase() {
        if (!isIncreasing) {
            return; // 실행 중단
        }

        if (playbackRate <= valueUp) {
            video.playbackRate = playbackRate;
            playbackRate += valueTap;
            setTimeout(increase, valueCycle); // 재귀적으로 호출
        } else {
            isIncreasing = false; // 목표 배속 도달 시 중지
        }
    }
    increase();
}

// 실행 정지 함수
function stopIncreasePlaybackRate() {
    isIncreasing = false; // 플래그를 비활성화하여 실행 중단
}


function startMonitoringVideoTime(tap, cycle, up,threshold = 0.11, interval = 100) {
    const intervalId = setInterval(function() {
        const videoElement = document.querySelector('video');
        const settingsIcon = document.querySelector('.icon-button.player-settings-icon');

        if (videoElement && videoElement.currentTime >= threshold && settingsIcon) {
            setTimeout(function() {
                stopIncreasePlaybackRate(); // 기존 배속 증가 중단
                document.querySelector('video').playbackRate = 1.0; //시작배속 무조건 1배속 옮길까
                increasePlaybackRate(tap, cycle, up);
            }, 10); //조정
            clearInterval(intervalId);
        }
    }, interval);

    return intervalId;  // intervalId를 반환하여 필요 시 외부에서 제어 가능하게 함
}

function setPlaybackRates(schedule) {
  const video = document.querySelector('video');
  if (!video) {
    console.error('비디오 요소를 찾을 수 없습니다.');
    return;
  }

  schedule.sort((a, b) => a[0] - b[0]);

  let currentIndex = 0;
  let timerId = null; // 타이머 ID 저장
  let isStopped = false; // 정지 상태 플래그

  function applyNextRate() {
    if (currentIndex >= schedule.length || isStopped) return; // 모든 설정 완료 또는 정지 상태

    const [targetTime, playbackRate] = schedule[currentIndex];
    const currentTime = video.currentTime;

    if (currentTime >= targetTime) {
      video.playbackRate = playbackRate;
      console.log(`배속 변경: ${playbackRate}x at ${currentTime.toFixed(2)}초`);
      currentIndex++;
      applyNextRate(); // 다음 설정으로 이동
    } else {
      timerId = setTimeout(applyNextRate, 100); // 100ms 후 재시도
    }
  }

  video.addEventListener('play', () => {
    if (!isStopped) applyNextRate(); // 정지 상태가 아니면 시작
  });

  if (!video.paused) {
    applyNextRate();
  }

  // 정지 함수
  this.stop = function () {
    isStopped = true; // 정지 상태로 변경
    if (timerId) clearTimeout(timerId); // 등록된 타이머 취소
    console.log('배속 변경 작업이 정지되었습니다.');
  };
}

// 새 작업 실행 함수
function startNewPlaybackRates(schedule) {
  // 기존 실행 중지
  if (currentController) {
    currentController.stop();
  }

  // 새 작업 실행
  currentController = new setPlaybackRates(schedule);
}

//   function controlRate(tap, cycle, up) {
//     var settingsButton = document.querySelector('.icon-button.player-settings-icon');
//     if (settingsButton) {
//         settingsButton.click();
//         setTimeout(function() {
//             var elements = document.getElementsByClassName('yt-list-item-view-model-wiz');
//             var targetElement;
//             for (var i = 0; i < elements.length; i++) {
//                 var titleElement = elements[i].querySelector('.yt-core-attributed-string.yt-list-item-view-model-wiz__title.yt-core-attributed-string--white-space-pre-wrap');
//                 if (titleElement && titleElement.innerText === 'Speed' || titleElement.innerText === '속도') {
//                     targetElement = elements[i];
//                     break;
//                 }
//             }
//             if (targetElement) {
//                 targetElement.click(); 
//                 setTimeout(function() {
//                     var speedText = String(up);  // 파라미터를 문자열로 변환
//                     var subElements = document.getElementsByClassName('yt-list-item-view-model-wiz');
                    
//                     // 요소가 존재하는지 확인
//                     if (subElements.length > 0) {
//                         if (speedText === '1') {
//                             speedText = '보통';
//                         }
//                     } else {
//                         // 요소가 없으면 다른 클래스 사용
//                         subElements = document.getElementsByClassName('yt-spec-button-shape-next__button-text-content');
//                         speedText += 'x';  // speedText 뒤에 "x" 추가
//                     }
                    
//                     // subElements에 있는 요소들을 순회하며 비교
//                     for (var i = 0; i < subElements.length; i++) {
//                         // innerText가 문자열인지 확인하고, 공백을 제거한 후 비교
//                         if (subElements[i].innerText.trim() === speedText) {
//                             subElements[i].click();  // 조건에 맞는 요소 클릭
//                             break;  // 원하는 요소를 클릭한 후 루프 종료
//                         }
//                     }                    
                    
//                     setTimeout(function() {
//                         document.querySelector('video').playbackRate = 1.0; //시작배속 무조건 1배속 옮길까
//                         increasePlaybackRate(tap, cycle, up);
//                     }, 10); //조정
                     
//                 }, 80); //조정
//             }
//         }, 20);//조정
//     } 
// }