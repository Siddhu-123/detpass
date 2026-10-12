// content_script.js
// Passive listener; only responds to explicit messages if needed.
// We intentionally do not auto-run anything or store anything.

chrome.runtime.onMessage && chrome.runtime.onMessage.addListener((msg, sender, sendResp) => {
  if (msg && msg.type === 'fillPassword' && msg.password) {
    const inputs = Array.from(document.querySelectorAll('input[type="password"], input[name*="pass"], input[id*="pass"]'));
    if (inputs.length > 0) {
      const field = inputs[0];
      field.focus();
      field.value = msg.password;
      field.dispatchEvent(new Event('input', { bubbles: true }));
      field.dispatchEvent(new Event('change', { bubbles: true }));
      sendResp({ ok: true });
    } else {
      sendResp({ ok: false, reason: 'no field' });
    }
  }
});
