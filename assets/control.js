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
                    var subElements = document.getElementsByClassName('yt-list-item-view-model-wiz');
                    if (subElements.length > 1) {
                        subElements[5].click();  // 선택한 배속으로 보이게 하는 설정
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


