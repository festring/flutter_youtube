function monitorPlaybackRateAndClass() {
    let lastPlaybackRate = document.querySelector('video').playbackRate;
    let originalPlaybackRate = null;
    let isBackgroundHiddenDetected = false;

    setInterval(() => {
        const videoElement = document.querySelector('video');
        const currentPlaybackRate = videoElement.playbackRate;

        const element = document.querySelector('.new-controls.bigbar.medium-modification.animation-enabled.enable-fullscreen-controls.fs-watch-system.fadein');
        
        if (element && element.classList.contains('background-hidden')) {
            if (!isBackgroundHiddenDetected) {
                isBackgroundHiddenDetected = true;
                originalPlaybackRate = lastPlaybackRate;
            }
        } else if (isBackgroundHiddenDetected) {
            videoElement.playbackRate = originalPlaybackRate;
            isBackgroundHiddenDetected = false;
        }
        
        lastPlaybackRate = currentPlaybackRate;
    }, 500);
}
monitorPlaybackRateAndClass();
