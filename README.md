# mac-kbd-backlight

Keyboard backlight shortcuts for MacBooks that don't have dedicated backlight keys (2021+ MacBook Pros, and others). **fn+F1** dims, **fn+F2** brightens. No dependencies, no Karabiner, no menu bar icon.

## Install

1. Download `mac-kbd-backlight.zip` from [Releases](../../releases) and unzip it.
2. Move `mac-kbd-backlight.app` to `/Applications`.
3. Open it. The app isn't notarized, so the first time use **right-click → Open** (or run `xattr -dr com.apple.quarantine /Applications/mac-kbd-backlight.app`).
4. Allow it under **System Settings → Privacy & Security → Accessibility** and **Input Monitoring** when prompted.

That's it. It registers itself to start at login and runs in the background. Universal binary (Apple Silicon + Intel), macOS 13+.

To remove it: turn it off in System Settings → General → Login Items, quit it in Activity Monitor, and delete the app.

## How it works

- Brightness is read/set through the private `CoreBrightness` framework (`KeyboardBrightnessClient`).
- A `CGEventTap` listens for F1/F2 with the fn modifier, adjusts the backlight in 16 steps, and swallows the key press.
- Plain F1/F2 (display brightness) are not touched.

## Build from source

Requires Xcode command line tools.

```sh
make zip     # builds build/mac-kbd-backlight.app and .zip
```

## Notes

- If "Use F1, F2, etc. keys as standard function keys" is on, the combo becomes plain F1/F2 (no fn).
- Uses a **private API**; a future macOS update could break it. Tested on a MacBook Pro (M1 Pro, 2021).
- Change the keys or step size in `main.swift` (`kF1`, `kF2`, `step`).

## License

MIT
