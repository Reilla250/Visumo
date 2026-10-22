(function () {
  'use strict';

  // ---- Light / Dark Theme Toggle (Half Moon button) ----
  var themeToggle = document.getElementById('theme-toggle');
  if (themeToggle) {
    themeToggle.addEventListener('click', function () {
      var current = document.documentElement.getAttribute('data-theme') || 'light';
      var next = current === 'dark' ? 'light' : 'dark';
      document.documentElement.setAttribute('data-theme', next);
      try {
        localStorage.setItem('visumo_theme', next);
      } catch (_) {}
    });
  }

  // ---- Mobile nav toggle ----
  var btn = document.querySelector('.nav-toggle');
  var nav = document.getElementById('site-nav');
  if (btn && nav) {
    btn.addEventListener('click', function () {
      var open = nav.classList.toggle('open');
      btn.setAttribute('aria-expanded', open ? 'true' : 'false');
    });
    nav.addEventListener('click', function (e) {
      if (e.target.closest('a') && !e.target.closest('.has-dropdown > a')) {
        nav.classList.remove('open');
        btn.setAttribute('aria-expanded', 'false');
      }
    });
  }

  // ---- Dropdown toggle on mobile (touch devices) ----
  document.querySelectorAll('.has-dropdown > a').forEach(function (trigger) {
    trigger.addEventListener('click', function (e) {
      if (window.innerWidth <= 900) {
        var parent = trigger.parentElement;
        var wasOpen = parent.classList.contains('open');
        document.querySelectorAll('.has-dropdown.open').forEach(function (el) {
          el.classList.remove('open');
        });
        if (!wasOpen) {
          e.preventDefault();
          parent.classList.add('open');
        }
      }
    });
  });

  // ---- Language switcher (handles both .lang-dropdown and .lang-switcher) ----
  var langDropdown = document.getElementById('lang-dropdown') || document.querySelector('.lang-dropdown') || document.querySelector('.lang-switcher');
  var langBtn = document.querySelector('.lang-toggle') || document.querySelector('.lang-btn');
  if (langDropdown && langBtn) {
    langBtn.addEventListener('click', function (e) {
      e.stopPropagation();
      var isOpen = langDropdown.classList.toggle('open');
      langBtn.setAttribute('aria-expanded', isOpen ? 'true' : 'false');
    });
  }

  // ---- Close dropdowns and lang menu on outside click ----
  document.addEventListener('click', function (e) {
    if (langDropdown && !langDropdown.contains(e.target)) {
      langDropdown.classList.remove('open');
      if (langBtn) langBtn.setAttribute('aria-expanded', 'false');
    }
  });

  // ---- Close everything on Escape ----
  document.addEventListener('keydown', function (e) {
    if (e.key === 'Escape') {
      if (nav && nav.classList.contains('open')) {
        nav.classList.remove('open');
        if (btn) {
          btn.setAttribute('aria-expanded', 'false');
          btn.focus();
        }
      }
      if (langDropdown) {
        langDropdown.classList.remove('open');
        if (langBtn) langBtn.setAttribute('aria-expanded', 'false');
      }
      // Close lightbox
      var lightbox = document.getElementById('lightbox');
      if (lightbox && !lightbox.hidden) {
        lightbox.hidden = true;
      }
    }
  });

  // ---- Gallery Lightbox ----
  var lightbox = document.getElementById('lightbox');
  if (lightbox) {
    var lightboxImg = document.getElementById('lightbox-img');
    var lightboxCaption = document.getElementById('lightbox-caption');
    var items = document.querySelectorAll('.gallery-item');
    var currentIndex = 0;

    function showImage(index) {
      if (!items.length) return;
      if (index < 0) index = items.length - 1;
      if (index >= items.length) index = 0;
      currentIndex = index;
      var item = items[index];
      var img = item.querySelector('img');
      var caption = item.querySelector('figcaption');
      if (img && lightboxImg) {
        lightboxImg.src = img.src;
        lightboxImg.alt = img.alt || '';
      }
      if (lightboxCaption) {
        lightboxCaption.textContent = caption ? caption.textContent : '';
      }
    }

    items.forEach(function (item, idx) {
      item.addEventListener('click', function () {
        showImage(idx);
        lightbox.hidden = false;
      });
    });

    var closeBtn = lightbox.querySelector('.lightbox-close');
    if (closeBtn) closeBtn.addEventListener('click', function () { lightbox.hidden = true; });

    var prevBtn = lightbox.querySelector('.lightbox-prev');
    if (prevBtn) prevBtn.addEventListener('click', function () { showImage(currentIndex - 1); });

    var nextBtn = lightbox.querySelector('.lightbox-next');
    if (nextBtn) nextBtn.addEventListener('click', function () { showImage(currentIndex + 1); });

    lightbox.addEventListener('click', function (e) {
      if (e.target === lightbox) lightbox.hidden = true;
    });
  }
})();
