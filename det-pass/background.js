const CLEAR_ALARM = 'detpass-clear-clipboard';
const OFFSCREEN_URL = 'offscreen.html';

// Popup timers die when the popup closes, so the clear is scheduled here.
chrome.runtime.onMessage.addListener((message) => {
  if (message && message.type === 'scheduleClipboardClear') {
    // 30 s is the Chrome minimum; re-copying resets the alarm.
    chrome.alarms.create(CLEAR_ALARM, { delayInMinutes: 0.5 });
  }
});

chrome.alarms.onAlarm.addListener((alarm) => {
  if (alarm.name === CLEAR_ALARM) {
    clearClipboard();
  }
});

async function hasOffscreenDocument() {
  const contexts = await chrome.runtime.getContexts({
    contextTypes: ['OFFSCREEN_DOCUMENT'],
    documentUrls: [chrome.runtime.getURL(OFFSCREEN_URL)]
  });
  return contexts.length > 0;
}

async function clearClipboard() {
  if (!(await hasOffscreenDocument())) {
    await chrome.offscreen.createDocument({
      url: OFFSCREEN_URL,
      reasons: ['CLIPBOARD'],
      justification: 'Clear the copied password from the clipboard after 30 seconds'
    });
  }
  try {
    await chrome.runtime.sendMessage({ type: 'clearClipboard', target: 'offscreen' });
  } finally {
    await chrome.offscreen.closeDocument();
  }
}
