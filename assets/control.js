function controlRate(up) {
    var settingsButton = document.querySelector('.icon-button.player-settings-icon');
    if (settingsButton) {
        settingsButton.click();
        setTimeout(function() {
            var elements = document.getElementsByClassName('yt-list-item-view-model-wiz');
            var targetElement;
            for (var i = 0; i < elements.length; i++) {
                var titleElement = elements[i].querySelector('.yt-core-attributed-string.yt-list-item-view-model-wiz__title.yt-core-attributed-string--white-space-pre-wrap');
                if (titleElement && titleElement.innerText === 'Speed' || titleElement.innerText === '속도') {
                    targetElement = elements[i];
                    break;
                }
            }
            if (targetElement) {
                targetElement.click(); 
                setTimeout(function() {
                    var speedText = String(up);  // 파라미터를 문자열로 변환
                    var subElements = document.getElementsByClassName('yt-list-item-view-model-wiz');
                    if (subElements.length > 1) {// 이조건 없애기
                        if (speedText === '1') {
                            speedText = '보통';
                        }
                        for (var i = 0; i < subElements.length; i++) {
                            // innerText가 문자열인지 확인하고, 공백을 제거한 후 비교
                            if (subElements[i].innerText.trim() === speedText) {
                                subElements[i].click();  // 조건에 맞는 요소 클릭
                                break;  // 원하는 요소를 클릭한 후 루프 종료
                            }
                        }
                        setTimeout(function() {
                            document.querySelector('video').playbackRate = 1.0; //시작배속 무조건 1배속 옮길까
                            increasePlaybackRate(up);
                        }, 10); //조정
                    } 
                }, 50); //조정
            }
        }, 20);//조정
    } 
}

function increasePlaybackRate(up) {
    const video = document.querySelector('video');
    let playbackRate = 1.0;  // 무조건 1.0에서 시작
    value= parseFloat(up);
    function increase() {
        if (playbackRate <= value) {
            if (Math.abs(video.playbackRate - playbackRate) < 0.1) {
                video.playbackRate = playbackRate;
                playbackRate += 0.01;
                setTimeout(increase, 100); 
            }
        }
    }
    increase();
}

function startMonitoringVideoTime(up,threshold = 0.11, interval = 100) {
    const intervalId = setInterval(function() {
        const videoElement = document.querySelector('video');
        const settingsIcon = document.querySelector('.icon-button.player-settings-icon');

        if (videoElement && videoElement.currentTime >= threshold && settingsIcon) {
            controlRate(up);
            clearInterval(intervalId);
        }
    }, interval);

    return intervalId;  // intervalId를 반환하여 필요 시 외부에서 제어 가능하게 함
}


