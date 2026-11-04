cask "kbd-backlight" do
  version "1.1.0"
  sha256 "3b972e3dfcaeb1733ca9a0aec26a7840fcefce66ec0054fbe7a30682fefea0db"

  url "https://github.com/vlad-solomon/homebrew-kbd-backlight/releases/download/v#{version}/kbd-backlight.zip"
  name "kbd-backlight"
  desc "Keyboard backlight shortcuts (fn+F1/F2) for MacBooks without backlight keys"
  homepage "https://github.com/vlad-solomon/homebrew-kbd-backlight"

  depends_on macos: :ventura

  app "kbd-backlight.app"

  # The app is ad-hoc signed (not notarized); skip the Gatekeeper prompt and start it.
  postflight do
    system_command "/usr/bin/xattr",
                   args: ["-dr", "com.apple.quarantine", "#{appdir}/kbd-backlight.app"]
    system_command "/usr/bin/open",
                   args: ["#{appdir}/kbd-backlight.app"]
  end

  uninstall signal: ["TERM", "com.github.vlad-solomon.kbd-backlight"]
end
