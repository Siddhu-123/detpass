# Det-Pass iOS

Native SwiftUI version of the current `det-pass` browser extension.

The password logic intentionally mirrors `det-pass/popup.js`:

- PBKDF2-HMAC-SHA256
- Salt: `detpass-v1|<site>`
- Iterations: `100000`
- Derived bits: `256`
- Length: `12`
- Alphabet: `abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789@$-_`
- Class overrides run in the same order as the extension: upper, lower, digit, special

The iOS app keeps the same no-storage behavior. The secret and site only live in view state, and the generated password is copied to the pasteboard only when the password box is tapped.

## Widget Behavior

The WidgetKit target mirrors the extension UI as a medium iPhone widget and deep-links into the app. WidgetKit supports links, buttons, and toggles, but not arbitrary secure text entry inside a Home Screen widget, so the exact generation flow lives in the app screen.

## Build

Open `DetPass.xcodeproj` in Xcode, select the `DetPass` scheme, and run on an iPhone simulator or device.

For a real device, set your Apple development team on both targets:

- `DetPass`
- `DetPassWidget`
