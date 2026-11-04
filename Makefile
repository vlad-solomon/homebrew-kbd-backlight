PREFIX ?= $(HOME)/.local
BIN    := $(PREFIX)/bin/mac-kbd-backlight
PLIST  := $(HOME)/Library/LaunchAgents/com.github.mac-kbd-backlight.plist

kbd: kbd.swift
	swiftc -O kbd.swift -o kbd

install: kbd
	mkdir -p $(PREFIX)/bin
	cp kbd $(BIN)
	@echo "Installed to $(BIN)"

# Start at login. Grant $(BIN) Accessibility + Input Monitoring first.
agent: install
	sed "s|__BIN__|$(BIN)|" com.github.mac-kbd-backlight.plist > $(PLIST)
	launchctl bootout gui/$$(id -u) $(PLIST) 2>/dev/null || true
	launchctl bootstrap gui/$$(id -u) $(PLIST)

uninstall:
	launchctl bootout gui/$$(id -u) $(PLIST) 2>/dev/null || true
	rm -f $(PLIST) $(BIN)

clean:
	rm -f kbd

.PHONY: install agent uninstall clean
