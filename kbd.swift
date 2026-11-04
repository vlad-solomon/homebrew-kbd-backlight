import Cocoa
import CoreGraphics

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

// CLI: `kbd get` / `kbd set 0.5` for testing
let args = CommandLine.arguments
if args.count >= 2 {
    switch args[1] {
    case "get": print(level()); exit(0)
    case "set" where args.count >= 3: setLevel(Float(args[2]) ?? 0); print(level()); exit(0)
    default: break
    }
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
guard let tap = CGEvent.tapCreate(tap: .cgSessionEventTap, place: .headInsertEventTap,
                                  options: .defaultTap, eventsOfInterest: mask,
                                  callback: callback, userInfo: nil) else {
    fputs("Failed to create event tap. Grant Accessibility + Input Monitoring to the terminal/binary.\n", stderr)
    exit(1)
}
let src = CFMachPortCreateRunLoopSource(nil, tap, 0)
CFRunLoopAddSource(CFRunLoopGetCurrent(), src, .commonModes)
CGEvent.tapEnable(tap: tap, enable: true)
CFRunLoopRun()
