cask "killsnail" do
  version "0.1.2"
  sha256 "3868be6636d64af7507d545bc6990bbc5f68559bc74d392aa3e4f629e403c618"

  url "https://github.com/bssm-oss/killsnail/releases/download/v#{version}/KillSnail-v#{version}.dmg",
      verified: "github.com/bssm-oss/killsnail/"
  name "KillSnail"
  desc "Slowly chases your cursor until the red YOU DEAD overlay appears"
  homepage "https://github.com/bssm-oss/killsnail"

  app "KillSnail.app"

  zap trash: [
    "~/Library/Application Support/KillSnail",
    "~/Library/Preferences/oss.bssm.killsnail.plist"
  ]
end
