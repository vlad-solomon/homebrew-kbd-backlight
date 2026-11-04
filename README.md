# kbd-backlight

Keyboard backlight shortcuts for MacBooks that don't have dedicated backlight keys (2021+ MacBook Pros, and others). **fn+F1** dims, **fn+F2** brightens. No dependencies, no Karabiner, no menu bar icon.

## Install

```sh
brew install --cask vlad-solomon/kbd-backlight/kbd-backlight
```

It launches right away and registers itself to start at login. Allow it under **System Settings → Privacy & Security → Accessibility** and **Input Monitoring** (see [Permissions](#permissions)). Done. Universal binary (Apple Silicon + Intel), macOS 13+.

Remove with `brew uninstall --cask kbd-backlight` (this also quits it). To stop it from starting at login without uninstalling: System Settings → General → Login Items.

## Permissions

macOS will ask for two permissions. Both are required, and neither leaves your Mac (the app makes no network connections):

- **Accessibility**: lets the app intercept the fn+F1 / fn+F2 key presses so it can swallow them.
- **Input Monitoring**: lets the app see key presses to detect those shortcuts. It only looks at F1/F2 with fn held and ignores everything else.

The prompt only adds the app to the list, so you still need to switch it **on** under System Settings → Privacy & Security → **Accessibility** and **Input Monitoring**. No restart is needed; the app picks it up within a couple of seconds. If the shortcuts do nothing, this is almost always why.

## How it works

- Brightness is read/set through the private `CoreBrightness` framework (`KeyboardBrightnessClient`).
- A `CGEventTap` listens for F1/F2 with the fn modifier, adjusts the backlight in 16 steps, and swallows the key press.
- Plain F1/F2 (display brightness) are not touched.

## Build from source

Requires Xcode command line tools.

```sh
make zip     # builds build/kbd-backlight.app and .zip
```

## Notes

- If "Use F1, F2, etc. keys as standard function keys" is on, the combo becomes plain F1/F2 (no fn).
- Uses a **private API**; a future macOS update could break it. Tested on a MacBook Pro (M1 Pro, 2021).
- Change the keys or step size in `main.swift` (`kF1`, `kF2`, `step`).

## License

MIT
