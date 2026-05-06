cask "killsnail" do
  version "0.1.2"
  sha256 "dbf33df8c504a57b2227b08178f76727750423090fd6fa9be0fb4a787fd5497f"

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
