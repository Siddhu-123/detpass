# DetPass

A deterministic password generator that stores nothing. Type one secret and a site name, and the same strong password comes out every time, on your browser and on your iPhone. There is no vault, no sync and no account, because the password is recomputed on demand.

This repository holds two front ends that share the same algorithm:

| Folder | What it is |
| :--- | :--- |
| [`det-pass/`](det-pass) | Chrome extension (Manifest V3). Fills the site from the active tab. |
| [`ios/`](ios) | SwiftUI iPhone app plus a WidgetKit widget that deep-links into it. |

## How it works

```
password = f( PBKDF2-HMAC-SHA256( secret, salt = "detpass-v1|" + site, 100,000 iterations ) )
```

- 256 derived bits, mapped onto a 12-character password.
- Alphabet: `a-z A-Z 0-9 @ $ - _`.
- One character from each class (upper, lower, digit, special) is placed using further bytes of the derived key.
- Nothing is persisted. The secret and site live only in memory; the password is copied to the clipboard only when you tap or click it.
- Copied passwords are cleared after 30 seconds. The extension clears the clipboard from a background alarm, even if you copied something else in the meantime. On iPhone the pasteboard item expires after 30 seconds and is kept off Universal Clipboard.
- The Swift implementation reproduces the extension's output byte for byte. `ios/DetPassTests` pins the test vectors (for example `my little secret` + `example.com` → `Cfgd_lAexV9@`).

## Chrome extension

1. Open `chrome://extensions` and enable **Developer mode**.
2. Choose **Load unpacked** and select the `det-pass` folder.
3. Click the toolbar icon, enter your secret, press Enter, then click the password to copy it.

## iPhone app and widget

Requires Xcode 15 or later and iOS 17 or later.

1. Open `ios/DetPass.xcodeproj`.
2. For a real device, set your Apple development team on both the `DetPass` and `DetPassWidget` targets.
3. Select the `DetPass` scheme and run.

Run the unit tests with the `DetPassTests` target (`⌘U`).

WidgetKit cannot accept text input, so the Home Screen widget mirrors the extension's look and opens the app, where you enter the secret.

## Known limitations

This is a personal project and has not had an independent security review. Please read these before relying on it.

- **A required character class can occasionally be missing.** The class placement can overwrite itself; about 3% of random secrets produce a password without one of upper, lower, digit or special. Fixing it would change existing passwords, so it is left as is for now.
- **Your secret is the only secret.** Anyone who learns it and a site name can regenerate that password, and changing the secret changes every password. Use a long, unique passphrase.
- The widget cannot take the secret itself (a WidgetKit limit).

## Licence

MIT. See [LICENSE](LICENSE).
