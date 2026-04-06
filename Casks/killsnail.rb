cask "killsnail" do
  version "0.1.0"
  sha256 "RELEASE_SHA256_WILL_BE_FILLED_BY_WORKFLOW"

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
