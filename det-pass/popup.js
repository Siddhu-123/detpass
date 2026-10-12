// popup.js — ephemeral only. No storage, no persistence.

const secretInput = document.getElementById('secret');
const siteInput = document.getElementById('site');
const genBtn = document.getElementById('gen');
const passDiv = document.getElementById('pass');
const clickText = document.getElementById('click');
const icon = document.getElementById('icon');
const gene = document.getElementById('gene');
const lengthInput = 12;

// initially disable the click text
icon.style.display = 'none';
passDiv.style.display = 'none';
clickText.textContent = "Enter Details to Generate Password";

// Auto-detect site from active tab
(async function fillSiteFromTab() {
  try {
    const [tab] = await chrome.tabs.query({ active: true, currentWindow: true });
    if (tab && tab.url) {
      const url = new URL(tab.url);
      siteInput.value = url.hostname.replace(/^www\./, '');
    }
  } catch (e) {
    // ignore
  }
})();

// Derive password using Web Crypto PBKDF2
async function derivePassword(secret, site, length = 12, iterations = 100000) {
  if (!secret || !site) throw new Error('Enter Details');

  const enc = new TextEncoder();
  const saltStr = 'detpass-v1|' + site;
  const secretKey = await crypto.subtle.importKey(
    'raw',
    enc.encode(secret),
    { name: 'PBKDF2' },
    false,
    ['deriveBits']
  );

  const bits = await crypto.subtle.deriveBits(
    { name: 'PBKDF2', salt: enc.encode(saltStr), iterations, hash: 'SHA-256' },
    secretKey,
    256
  );

  const bytes = new Uint8Array(bits);
  const lower = 'abcdefghijklmnopqrstuvwxyz';
  const upper = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
  const digits = '0123456789';
  const specials = '@$-_';
  const all = lower + upper + digits + specials;

  let out = [];
  for (let i = 0; i < length; i++) {
    out.push(all[bytes[i % bytes.length] % all.length]);
  }

  // ensure at least one of each class
  function ensureClass(set, posIndex) {
    const pos = bytes[(length + posIndex) % bytes.length] % length;
    out[pos] = set[bytes[(posIndex + 10) % bytes.length] % set.length];
  }
  ensureClass(upper, 0);
  ensureClass(lower, 1);
  ensureClass(digits, 2);
  ensureClass(specials, 3);

  return out.join('');
}

// Copy to clipboard
function copyPassword(pwd) {
  navigator.clipboard.writeText(pwd).then(() => {
    chrome.runtime.sendMessage({ type: 'scheduleClipboardClear' });
    clickText.textContent = 'COPIED · CLEARS IN 30S';
    clickText.classList.add('copied');
    setTimeout(() => {
      clickText.textContent = 'CLICK TO COPY';
      clickText.classList.remove('copied');
    }, 1500);
  });
}

// Generate button
async function generatePassword() {
  try {
    const secret = secretInput.value;
    const site = siteInput.value.trim();
    const length = Math.max(8, parseInt(lengthInput) || 8);
    const pwd = await derivePassword(secret, site, length, 100000);
    passDiv.textContent = pwd;

    gene.style.display = 'none';
    icon.style.display = 'block';
    passDiv.classList.remove('animate'); // reset animation
    void passDiv.offsetWidth; // force reflow
    passDiv.classList.add('animate');
    passDiv.style.display = 'block';
    clickText.textContent = 'CLICK TO COPY';
    passDiv.onclick = () => copyPassword(pwd);
  } catch (e) {
    passDiv.textContent = ":(";
    clickText.textContent = e.message;
    passDiv.onclick = null;
    clickText.onclick = null;
  }
}

// Existing click listener
genBtn.addEventListener('click', generatePassword);

// Trigger password generation on Enter key
[secretInput, siteInput].forEach(input => {
  input.addEventListener('keydown', (e) => {
    if (e.key === 'Enter') {
      generatePassword();
    }
  });
});
