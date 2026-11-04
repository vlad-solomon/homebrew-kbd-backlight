# mac-kbd-backlight

Keyboard backlight shortcuts for MacBooks that don't have dedicated backlight keys (2021+ MacBook Pros, and others). **fn+F1** dims, **fn+F2** brightens. One Swift file, no dependencies, no Karabiner.

## How it works

- Brightness is read/set through the private `CoreBrightness` framework (`KeyboardBrightnessClient`).
- A `CGEventTap` listens for F1/F2 with the fn modifier, adjusts the backlight in 16 steps, and swallows the key press.
- Plain F1/F2 (display brightness) are not touched.

## Install

Requires Xcode command line tools.

```sh
make install     # builds and copies to ~/.local/bin/mac-kbd-backlight
mac-kbd-backlight    # runs the fn+F1/F2 listener
```

On first run macOS will block the event tap. Add the app that launched it (your terminal) under
**System Settings → Privacy & Security → Accessibility** and **Input Monitoring**, restart that app, and run again.

### Start at login

```sh
make agent
```

Then grant `~/.local/bin/mac-kbd-backlight` itself Accessibility and Input Monitoring (in the file picker press `⌘⇧G` and paste the path). Remove with `make uninstall`.

## Notes

- If "Use F1, F2, etc. keys as standard function keys" is on, the combo becomes plain F1/F2 (no fn).
- Uses a **private API**; a future macOS update could break it. Tested on a MacBook Pro (M1 Pro, 2021).
- Change the keys or step size in `kbd.swift` (`kF1`, `kF2`, `step`).

## License

MIT
