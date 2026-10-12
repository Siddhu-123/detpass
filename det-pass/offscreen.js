// Overwrites the clipboard with an empty string. An empty selection alone
// would not change it, so the copy event is overridden to write ''.
chrome.runtime.onMessage.addListener((message, sender, sendResponse) => {
  if (message.target !== 'offscreen' || message.type !== 'clearClipboard') {
    return;
  }

  const sink = document.getElementById('sink');
  const onCopy = (event) => {
    event.clipboardData.setData('text/plain', '');
    event.preventDefault();
  };

  document.addEventListener('copy', onCopy, { once: true });
  sink.focus();
  sink.select();
  document.execCommand('copy');
  document.removeEventListener('copy', onCopy);

  sendResponse({ ok: true });
});
