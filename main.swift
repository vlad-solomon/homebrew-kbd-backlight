import Cocoa
import CoreGraphics
import ServiceManagement

// --- Keyboard backlight via private CoreBrightness framework ---
dlopen("/System/Library/PrivateFrameworks/CoreBrightness.framework/CoreBrightness", RTLD_NOW)
guard let cls = NSClassFromString("KeyboardBrightnessClient") as? NSObject.Type else {
    fputs("KeyboardBrightnessClient not found\n", stderr); exit(1)
}
let client = cls.init()

typealias GetFn = @convention(c) (AnyObject, Selector, UInt64) -> Float
typealias SetFn = @convention(c) (AnyObject, Selector, Float, UInt64) -> Bool
typealias IDsFn = @convention(c) (AnyObject, Selector) -> Unmanaged<NSArray>?

let idsSel = NSSelectorFromString("copyKeyboardBacklightIDs")
let getSel = NSSelectorFromString("brightnessForKeyboard:")
let setSel = NSSelectorFromString("setBrightness:forKeyboard:")

let kbID: UInt64 = {
    if let arr = unsafeBitCast(client.method(for: idsSel), to: IDsFn.self)(client, idsSel)?.takeRetainedValue(),
       let n = arr.firstObject as? NSNumber { return n.uint64Value }
    return 1
}()

func level() -> Float { unsafeBitCast(client.method(for: getSel), to: GetFn.self)(client, getSel, kbID) }
func setLevel(_ v: Float) {
    _ = unsafeBitCast(client.method(for: setSel), to: SetFn.self)(client, setSel, max(0, min(1, v)), kbID)
}

// --- fn+F1 / fn+F2 hotkeys via event tap ---
let step: Float = 1.0 / 16.0
let kF1: Int64 = 122, kF2: Int64 = 120

let callback: CGEventTapCallBack = { _, type, event, _ in
    if type == .tapDisabledByTimeout || type == .tapDisabledByUserInput { return Unmanaged.passUnretained(event) }
    guard type == .keyDown || type == .keyUp else { return Unmanaged.passUnretained(event) }
    let code = event.getIntegerValueField(.keyboardEventKeycode)
    guard (code == kF1 || code == kF2), event.flags.contains(.maskSecondaryFn) else {
        return Unmanaged.passUnretained(event)
    }
    if type == .keyDown {
        setLevel(level() + (code == kF2 ? step : -step))
    }
    return nil // swallow
}

let mask = CGEventMask(1 << CGEventType.keyDown.rawValue) | CGEventMask(1 << CGEventType.keyUp.rawValue)

func installTap() -> Bool {
    guard let tap = CGEvent.tapCreate(tap: .cgSessionEventTap, place: .headInsertEventTap,
                                      options: .defaultTap, eventsOfInterest: mask,
                                      callback: callback, userInfo: nil) else { return false }
    let src = CFMachPortCreateRunLoopSource(nil, tap, 0)
    CFRunLoopAddSource(CFRunLoopGetMain(), src, .commonModes)
    CGEvent.tapEnable(tap: tap, enable: true)
    return true
}

// --- App lifecycle: background agent, starts at login, waits for permissions ---
let app = NSApplication.shared
app.setActivationPolicy(.accessory)

// Register as a login item (macOS 13+). Shows up in System Settings > General > Login Items.
if SMAppService.mainApp.status != .enabled {
    try? SMAppService.mainApp.register()
}

// Ask for permissions (shows the system prompts), then keep retrying until granted.
let opts = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true] as CFDictionary
_ = AXIsProcessTrustedWithOptions(opts)
_ = CGRequestListenEventAccess()

if !installTap() {
    Timer.scheduledTimer(withTimeInterval: 2, repeats: true) { t in
        if installTap() { t.invalidate() }
    }
}
app.run()
