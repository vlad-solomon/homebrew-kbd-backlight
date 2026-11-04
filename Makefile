APP  := build/mac-kbd-backlight.app
EXE  := $(APP)/Contents/MacOS/mac-kbd-backlight
ZIP  := build/mac-kbd-backlight.zip

app: main.swift resources/Info.plist
	rm -rf $(APP)
	mkdir -p $(APP)/Contents/MacOS build/tmp
	swiftc -O -target arm64-apple-macos13.0  main.swift -o build/tmp/arm64
	swiftc -O -target x86_64-apple-macos13.0 main.swift -o build/tmp/x86_64
	lipo -create build/tmp/arm64 build/tmp/x86_64 -output $(EXE)
	cp resources/Info.plist $(APP)/Contents/Info.plist
	codesign --force --sign - $(APP)
	rm -rf build/tmp

zip: app
	cd build && ditto -c -k --keepParent mac-kbd-backlight.app mac-kbd-backlight.zip

clean:
	rm -rf build

.PHONY: app zip clean
