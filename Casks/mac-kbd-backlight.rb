cask "mac-kbd-backlight" do
  version "1.0.0"
  sha256 "d194b56d6f1c26ce379df3a9d9bfed8541bdf98aee0a166056c4a78775c5791a"

  url "https://github.com/vlad-solomon/homebrew-kbd-backlight/releases/download/v#{version}/mac-kbd-backlight.zip"
  name "mac-kbd-backlight"
  desc "Keyboard backlight shortcuts (fn+F1/F2) for MacBooks without backlight keys"
  homepage "https://github.com/vlad-solomon/homebrew-kbd-backlight"

  depends_on macos: :ventura

  app "mac-kbd-backlight.app"

  # The app is ad-hoc signed (not notarized); skip the Gatekeeper prompt and start it.
  postflight do
    system_command "/usr/bin/xattr",
                   args: ["-dr", "com.apple.quarantine", "#{appdir}/mac-kbd-backlight.app"]
    system_command "/usr/bin/open",
                   args: ["#{appdir}/mac-kbd-backlight.app"]
  end

  uninstall signal: ["TERM", "com.github.vlad-solomon.mac-kbd-backlight"]
end
