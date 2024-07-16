function removeElements() {
    const classesToRemove = [
      'companion-ad-container',
      'ytp-ad-button-text',
      'ytp-ad-player-overlay-instream-info',
      'ytp-ad-text ytp-video-ad-top-bar-title'
    ];
    classesToRemove.forEach(className => {
      const elements = document.querySelectorAll(`.${className.replace(/ /g, '.')}`);
      elements.forEach(element => element.remove());
    });
    const skipButton = document.querySelector('.ytp-ad-skip-button-modern.ytp-button');
      if (skipButton) {
        skipButton.click();
      }
    if (document.querySelectorAll('.ad-showing').length > 0) {
      const video = document.querySelector('video');
      if(video) {
        video.currentTime = video.duration;
      }
    }
  }
  
  setInterval(removeElements, 100);
  