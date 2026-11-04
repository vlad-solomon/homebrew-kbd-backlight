APP  := build/kbd-backlight.app
EXE  := $(APP)/Contents/MacOS/kbd-backlight
ZIP  := build/kbd-backlight.zip

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
	cd build && ditto -c -k --keepParent kbd-backlight.app kbd-backlight.zip

clean:
	rm -rf build

.PHONY: app zip clean
