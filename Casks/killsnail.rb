cask "killsnail" do
  version "0.1.1"
  sha256 "9835e44a189e09a35ff390f4ac399661e034dd1561bdce3be7b4ef545cd73ef3"

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
