function controlRate() {
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
                        subElements[5].click();  // 일반적으로 1.0배속 위치
                        setTimeout(function() {
                            document.querySelector('video').playbackRate = 1.0;
                            increasePlaybackRate();
                        }, 10); 
                    } 
                }, 50); 
            }
        }, 50);
    } 
}

function increasePlaybackRate() {
    const video = document.querySelector('video');
    let playbackRate = 1.0;  // 무조건 1.0에서 시작
    function increase() {
        if (playbackRate <= 1.5) {
            if (Math.abs(video.playbackRate - playbackRate) < 0.1) {
                video.playbackRate = playbackRate;
                playbackRate += 0.01;
                setTimeout(increase, 100); 
            }
        }
    }
    increase();
}

function startMonitoringVideoTime(threshold = 1, interval = 1000) {
    const intervalId = setInterval(function() {
        if (document.querySelector('video').currentTime >= threshold) {
            controlRate();
            clearInterval(intervalId);
        }
    }, interval);

    return intervalId;  // intervalId를 반환하여 필요 시 외부에서 제어 가능하게 함
}

