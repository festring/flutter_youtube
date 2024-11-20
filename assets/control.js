//어차피 랩실험에서는 목표 배속까지 무조건 증가시키는게 중요, 사용자가 변환하든 말든,변환하면 그거 기록하면 되니깐
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

    function increase() {
        if (playbackRate <= valueUp) {
            video.playbackRate = playbackRate;
            playbackRate += valueTap;
            setTimeout(increase, valueCycle); // 재귀적으로 호출
        }
    }
    increase();
}


function startMonitoringVideoTime(tap, cycle, up,threshold = 0.11, interval = 100) {
    const intervalId = setInterval(function() {
        const videoElement = document.querySelector('video');
        const settingsIcon = document.querySelector('.icon-button.player-settings-icon');

        if (videoElement && videoElement.currentTime >= threshold && settingsIcon) {
            setTimeout(function() {
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
  
    // 재생 시간과 배속을 시간 순으로 정렬
    schedule.sort((a, b) => a[0] - b[0]);
  
    let currentIndex = 0;
  
    function applyNextRate() {
      if (currentIndex >= schedule.length) return; // 모든 설정 완료
  
      const [targetTime, playbackRate] = schedule[currentIndex];
      const currentTime = video.currentTime;
  
      if (currentTime >= targetTime) {
        // 현재 시간이 설정 시간 이상이면 배속 변경
        video.playbackRate = playbackRate;
        console.log(`배속 변경: ${playbackRate}x at ${currentTime.toFixed(2)}초`);
        currentIndex++;
        applyNextRate(); // 다음 설정으로 이동
      } else {
        // 다음 설정까지 대기
        setTimeout(applyNextRate, 100); // 100ms 후 재시도
      }
    }
  
    // 비디오 재생 상태 변화 감지 및 시작
    video.addEventListener('play', () => {
      applyNextRate();
    });
  
    // 현재 시간이 배열의 첫 번째 시간 이후일 경우만 적용
    if (!video.paused) {
      applyNextRate();
    }
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