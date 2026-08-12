#!/usr/bin/env bash
#
# Build and stage an iOS release archive.
#
#   ./scripts/release_ios.sh          build with the current build number
#   ./scripts/release_ios.sh --bump   increment the build number first
#
# Ends with exactly one archive in Xcode's Organizer folder, so there is nothing
# to pick wrong. Refuses to stage anything that fails verification.
#
# Every check here exists because that failure actually happened. See
# docs/RELEASE.md for the incidents.

set -euo pipefail

cd "$(dirname "$0")/.."

RED=$'\033[0;31m'; GREEN=$'\033[0;32m'; YELLOW=$'\033[0;33m'; NC=$'\033[0m'
ok()   { echo "${GREEN}✓${NC} $1"; }
warn() { echo "${YELLOW}!${NC} $1"; }
die()  { echo "${RED}✗ $1${NC}" >&2; exit 1; }

ARCHIVE=build/ios/archive/Runner.xcarchive
IPA=build/ios/ipa/flutter_vocabulary_card.ipa
ORGANIZER=~/Library/Developer/Xcode/Archives/$(date +%F)

# --- build number ---------------------------------------------------------

current=$(grep '^version:' pubspec.yaml | sed 's/^version: //')
name=${current%+*}
number=${current#*+}

if [[ "${1:-}" == "--bump" ]]; then
  number=$((number + 1))
  sed -i '' "s/^version: .*/version: ${name}+${number}/" pubspec.yaml
  ok "build number ${current#*+} → ${number}"
else
  warn "沿用 build number ${number}（重複上傳會被 Apple 退件；要遞增請加 --bump）"
fi

echo "→ 建置 ${name}+${number}"

# --- build ----------------------------------------------------------------

# clean is not optional: objective_c.framework comes from Flutter's native
# assets pipeline and its cache is reused across targets, so a previous
# `flutter run` on the simulator leaves a simulator slice that Apple rejects
# with "Invalid executable" (code 91169).
flutter clean >/dev/null
flutter pub get >/dev/null
flutter build ipa --release

# --- verify ---------------------------------------------------------------

APP="$ARCHIVE/Products/Applications/Runner.app"
[[ -d "$APP" ]] || die "找不到 archive：$ARCHIVE"
[[ -f "$IPA" ]] || die "找不到 IPA：$IPA"

built=$(/usr/libexec/PlistBuddy -c "Print :CFBundleVersion" "$APP/Info.plist")
[[ "$built" == "$number" ]] || die "archive 的 build number 是 $built，應為 $number（拿到舊產物）"
ok "build number $built"

bundle=$(/usr/libexec/PlistBuddy -c "Print :CFBundleIdentifier" "$APP/Info.plist")
[[ "$bundle" == "com.gman.gocabapp" ]] || die "bundle ID 是 $bundle，應為 com.gman.gocabapp"
ok "bundle ID $bundle"

# Any framework carrying a simulator slice is rejected at upload.
sim=$(find "$APP/Frameworks" -type f -perm +111 -exec sh -c \
  'vtool -show-build-version "$1" 2>/dev/null | grep -q IOSSIMULATOR && basename "$(dirname "$1")"' _ {} \; || true)
[[ -z "$sim" ]] || die "以下 framework 是模擬器版本：$sim"
ok "所有 framework 皆為裝置版本"

# The exported IPA is what carries the distribution signature; the archive
# itself is development-signed, which is normal.
signer=$(codesign -dvvv "$APP" 2>&1 | grep '^Authority=' | head -1 | sed 's/Authority=//')
tmp=$(mktemp -d)
unzip -q "$IPA" -d "$tmp"
ipa_signer=$(codesign -dvvv "$tmp/Payload/Runner.app" 2>&1 | grep '^Authority=' | head -1 | sed 's/Authority=//')
rm -rf "$tmp"
[[ "$ipa_signer" == Apple\ Distribution* ]] || die "IPA 簽章是「$ipa_signer」，應為 Apple Distribution"
ok "IPA 簽章 $ipa_signer"
echo "  （archive 為 $signer，屬正常）"

# --- stage ----------------------------------------------------------------

mkdir -p "$ORGANIZER"
staged="$ORGANIZER/Gocab-${name}+${number}-$(date +%H%M).xcarchive"

# Old archives in the Organizer list are indistinguishable at a glance and have
# been uploaded by mistake before. Leave exactly one.
stale=$(find "$ORGANIZER" -maxdepth 1 -name '*.xcarchive' | wc -l | tr -d ' ')
if [[ "$stale" -gt 0 ]]; then
  find "$ORGANIZER" -maxdepth 1 -name '*.xcarchive' -exec rm -rf {} +
  warn "已移除 $stale 個先前的 archive，避免在 Organizer 中選錯"
fi

cp -R "$ARCHIVE" "$staged"
ok "已放入 Organizer：$(basename "$staged")"

cat <<EOF

${GREEN}建置完成，可以上傳${NC}

  Xcode → Window → Organizer（已開啟的話請關掉重開）
  選 $(basename "$staged")
  Distribute App → App Store Connect → Upload

  ${YELLOW}務必取消勾選 Manage Version and Build Number${NC}
  它會在 build number 重複時自動遞增，使「上傳到錯的 archive」看起來正常。

上傳後別忘了提交版號：
  git add pubspec.yaml && git commit -m "chore: 遞增 build number 至 ${name}+${number}"
EOF
