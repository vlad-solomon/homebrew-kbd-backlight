# mac-kbd-backlight

Keyboard backlight shortcuts for MacBooks that don't have dedicated backlight keys (2021+ MacBook Pros, and others). **fn+F1** dims, **fn+F2** brightens. No dependencies, no Karabiner, no menu bar icon.

## Install

### Homebrew (recommended)

```sh
brew install --cask vlad-solomon/kbd-backlight/mac-kbd-backlight
```

It launches right away and registers itself to start at login. Allow it under **System Settings → Privacy & Security → Accessibility** and **Input Monitoring** when prompted. Done. Universal binary (Apple Silicon + Intel), macOS 13+.

Remove with `brew uninstall --cask mac-kbd-backlight` (this also quits it).

### Manual

1. Download `mac-kbd-backlight.zip` from [Releases](../../releases), unzip, and move the app to `/Applications`.
2. The app isn't notarized, so the first time use **right-click → Open** (or `xattr -dr com.apple.quarantine /Applications/mac-kbd-backlight.app`).
3. Allow Accessibility and Input Monitoring when prompted.

To stop it manually: `pkill -x mac-kbd-backlight`. To stop it starting at login: System Settings → General → Login Items.

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
