/**
 * Narration Player for Reveal.js slides
 * - Plays pre-generated MP3 audio for each slide
 * - Toggle play/stop via button click or Space key
 * - Auto-stops on slide change
 */
(function () {
  'use strict';

  var audio = null;
  var btn = null;
  var progressBar = null;
  var animFrame = null;

  // Detect chapter number from the URL path (e.g., "01" from "01-introduction.html")
  function getChapterNum() {
    var path = window.location.pathname;
    var match = path.match(/(\d{2})-[^/]+\.html/);
    return match ? match[1] : null;
  }

  // Build audio path for current slide
  function getAudioPath(slideIndex) {
    var chapter = getChapterNum();
    if (!chapter) return null;
    var slideNum = String(slideIndex + 1).padStart(2, '0');
    return 'audio/' + chapter + '/slide-' + slideNum + '.mp3';
  }

  // Check if current slide has narration
  function hasNarration() {
    var slide = Reveal.getCurrentSlide();
    return slide && slide.hasAttribute('data-narration');
  }

  // Create UI elements
  function createUI() {
    // Button
    btn = document.createElement('button');
    btn.className = 'narration-btn hidden';
    btn.setAttribute('aria-label', '나레이션 재생');
    btn.setAttribute('title', '나레이션 재생/정지 (Space)');
    btn.innerHTML =
      '<svg class="icon-play" viewBox="0 0 24 24"><polygon points="6,3 20,12 6,21"/></svg>' +
      '<svg class="icon-stop" viewBox="0 0 24 24"><rect x="5" y="5" width="14" height="14" rx="2"/></svg>';
    document.body.appendChild(btn);

    // Progress bar
    progressBar = document.createElement('div');
    progressBar.className = 'narration-progress';
    document.body.appendChild(progressBar);

    btn.addEventListener('click', toggle);
  }

  // Stop current playback
  function stop() {
    if (audio) {
      audio.pause();
      audio.currentTime = 0;
      audio = null;
    }
    if (btn) btn.classList.remove('playing');
    if (progressBar) {
      progressBar.classList.remove('active');
      progressBar.style.width = '0%';
    }
    if (animFrame) {
      cancelAnimationFrame(animFrame);
      animFrame = null;
    }
  }

  // Update progress bar
  function updateProgress() {
    if (!audio || audio.paused) return;
    if (audio.duration) {
      var pct = (audio.currentTime / audio.duration) * 100;
      progressBar.style.width = pct + '%';
    }
    animFrame = requestAnimationFrame(updateProgress);
  }

  // Play narration for current slide
  function play() {
    stop();

    var indices = Reveal.getIndices();
    var path = getAudioPath(indices.h);
    if (!path) return;

    audio = new Audio(path);
    audio.addEventListener('ended', function () {
      stop();
    });
    audio.addEventListener('error', function () {
      // Audio file not available - hide button
      stop();
      if (btn) btn.classList.add('hidden');
    });
    audio.addEventListener('canplaythrough', function () {
      btn.classList.add('playing');
      progressBar.classList.add('active');
      updateProgress();
    });
    audio.play().catch(function () {
      stop();
    });
  }

  // Toggle play/stop
  function toggle() {
    if (audio && !audio.paused) {
      stop();
    } else {
      play();
    }
  }

  // Update button visibility on slide change
  function onSlideChanged() {
    stop();
    if (hasNarration()) {
      btn.classList.remove('hidden');
    } else {
      btn.classList.add('hidden');
    }
  }

  // Initialize
  function init() {
    if (typeof Reveal === 'undefined') return;

    createUI();

    // Wait for Reveal.js ready
    if (Reveal.isReady && Reveal.isReady()) {
      onSlideChanged();
    }
    Reveal.on('ready', onSlideChanged);
    Reveal.on('slidechanged', onSlideChanged);

    // Keyboard shortcut: Space key (capture phase to intercept before Reveal.js)
    document.addEventListener('keydown', function (e) {
      if (e.key === ' ' || e.code === 'Space') {
        // Ignore if typing in input/textarea
        var tag = e.target.tagName.toLowerCase();
        if (tag === 'input' || tag === 'textarea' || tag === 'select') return;
        if (e.ctrlKey || e.altKey || e.metaKey) return;

        if (hasNarration()) {
          e.preventDefault();
          e.stopPropagation();
          toggle();
        }
      }
    }, true);
  }

  // Auto-init when DOM ready
  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', init);
  } else {
    // Delay slightly to ensure Reveal.js is initialized
    setTimeout(init, 100);
  }
})();
