let previousTime = 0;
let currentTime = 0;
let backward = [];
let forward = [];
var isDetected = false;
var speedIntervals = []; 
let save =0;

var speedList = [];
let lastPlaybackRate = 1;
let lastUrl = "";

function recordSpeed(speed){
  let speedTime = document.querySelector('video').currentTime;
  speedList.push([speed, speedTime]);
};

setInterval(() => {
  let video = document.querySelector('video');
  if (location.href !== lastUrl && !location.href.includes("#")) {
    lastUrl = location.href;
    lastPlaybackRate = video.playbackRate;
    recordSpeed(lastPlaybackRate); 
  }

  let currentPlaybackRate = video.playbackRate;
  if (Math.abs(currentPlaybackRate - lastPlaybackRate) >= 0.2) {
    recordSpeed(currentPlaybackRate);
    lastPlaybackRate = currentPlaybackRate;
  }
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