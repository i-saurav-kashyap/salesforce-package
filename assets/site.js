// Copy buttons (clipboard API needs a secure context; file:// often is not)
function markCopied(btn, label) {
  var old = btn.textContent;
  btn.textContent = label;
  setTimeout(function () { btn.textContent = old; }, 1200);
}

function copyWithFallback(text, btn) {
  function fallback() {
    var ta = document.createElement('textarea');
    ta.value = text;
    ta.setAttribute('readonly', '');
    ta.style.position = 'fixed';
    ta.style.top = '0';
    ta.style.left = '-9999px';
    document.body.appendChild(ta);
    ta.focus();
    ta.select();
    try {
      document.execCommand('copy');
      markCopied(btn, 'Copied');
    } catch (e) {
      markCopied(btn, 'Copy failed');
    }
    document.body.removeChild(ta);
  }
  if (navigator.clipboard && window.isSecureContext) {
    navigator.clipboard.writeText(text).then(function () {
      markCopied(btn, 'Copied');
    }).catch(fallback);
  } else {
    fallback();
  }
}

document.querySelectorAll('.codebar .copy').forEach(function (btn) {
  btn.addEventListener('click', function () {
    var code = btn.closest('.codewrap').querySelector('code');
    copyWithFallback(code.innerText, btn);
  });
});

// Mobile nav
var toggle = document.querySelector('.navtoggle');
var sidenav = document.getElementById('sidenav');
if (toggle && sidenav) {
  function setNavOpen(open) {
    sidenav.classList.toggle('open', open);
    toggle.setAttribute('aria-expanded', open ? 'true' : 'false');
  }
  toggle.setAttribute('aria-expanded', 'false');
  toggle.setAttribute('aria-controls', 'sidenav');
  toggle.addEventListener('click', function (e) {
    e.stopPropagation();
    setNavOpen(!sidenav.classList.contains('open'));
  });
  document.addEventListener('keydown', function (e) {
    if (e.key === 'Escape') setNavOpen(false);
  });
  document.addEventListener('click', function (e) {
    if (!sidenav.classList.contains('open')) return;
    if (sidenav.contains(e.target) || toggle.contains(e.target)) return;
    setNavOpen(false);
  });
  sidenav.querySelectorAll('a').forEach(function (a) {
    a.addEventListener('click', function () { setNavOpen(false); });
  });
}

// Persist checklist state per page
(function () {
  var key = 'sfcourse:' + location.pathname.split('/').pop();
  var saved = JSON.parse(localStorage.getItem(key) || '{}');
  document.querySelectorAll('ul.check > li').forEach(function (li, i) {
    var box = li.querySelector('input[type=checkbox]');
    if (!box) {
      box = document.createElement('input');
      box.type = 'checkbox';
      var span = document.createElement('span');
      span.innerHTML = li.innerHTML;
      li.innerHTML = '';
      li.appendChild(box);
      li.appendChild(span);
    }
    if (saved[i]) { box.checked = true; li.classList.add('done'); }
    box.addEventListener('change', function () {
      li.classList.toggle('done', box.checked);
      saved[i] = box.checked;
      localStorage.setItem(key, JSON.stringify(saved));
    });
  });
})();
