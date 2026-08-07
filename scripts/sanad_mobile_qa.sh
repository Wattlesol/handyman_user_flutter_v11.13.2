#!/usr/bin/env bash
set -euo pipefail

export PATH="/usr/local/opt/openjdk@17/bin:/Users/xain/development/flutter/bin:/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:$PATH"

fail() {
  echo "FAIL: $*" >&2
  exit 1
}

pass() {
  echo "PASS: $*"
}

assert_contains() {
  local file="$1"
  local text="$2"

  grep -Fq "$text" "$file" || fail "$file is missing: $text"
  pass "$file contains: $text"
}

assert_no_pattern() {
  local pattern="$1"
  shift

  if rg -n "$pattern" "$@"; then
    fail "Forbidden pattern found: $pattern"
  fi

  pass "No forbidden pattern: $pattern"
}

cd "$(dirname "$0")/.."

echo "== Sanad customer mobile QA =="

assert_contains "android/app/src/main/AndroidManifest.xml" 'android:label="Sanad"'
assert_contains "ios/Runner/Info.plist" '<string>Sanad</string>'
assert_contains "lib/utils/configs.dart" "const APP_NAME = 'SANAD';"
assert_contains "lib/utils/configs.dart" 'const DOMAIN_URL = "https://kangoo.sa";'

privacy_files=(
  "lib/screens/booking/booking_detail_screen.dart"
  "lib/screens/service/service_detail_screen.dart"
  "lib/screens/service/component/service_component.dart"
  "lib/screens/newDashboard/dashboard_1/component/service_dashboard_component_1.dart"
  "lib/screens/newDashboard/dashboard_2/component/service_dashboard_component_2.dart"
  "lib/screens/newDashboard/dashboard_3/component/service_dashboard_component_3.dart"
  "lib/screens/newDashboard/dashboard_4/component/service_dashboard_component_4.dart"
)

assert_no_pattern "ProviderInfoScreen\\(|HandymanInfoScreen\\(|provider_info_screen|handyman_info_screen" "${privacy_files[@]}"
assert_no_pattern "provider-detail|handyman-detail|About Provider|About Handyman|Provider Demo|Handyman Demo|Post Job|Handyman Service|Kangoo" \
  "lib/locale/language_en.dart" \
  "lib/locale/languages_fr.dart" \
  "lib/locale/languages_de.dart" \
  "lib/locale/language_ar.dart" \
  "lib/locale/language_hi.dart" \
  "lib/utils/configs.dart" \
  "android/app/src/main/AndroidManifest.xml" \
  "ios/Runner/Info.plist"

echo "== Static analysis =="
dart analyze \
  lib/utils/configs.dart \
  lib/screens/booking/booking_detail_screen.dart \
  lib/screens/service/service_detail_screen.dart \
  lib/screens/service/component/service_component.dart \
  lib/screens/newDashboard/dashboard_1/component/service_dashboard_component_1.dart \
  lib/screens/newDashboard/dashboard_2/component/service_dashboard_component_2.dart \
  lib/screens/newDashboard/dashboard_3/component/service_dashboard_component_3.dart \
  lib/screens/newDashboard/dashboard_4/component/service_dashboard_component_4.dart

if [[ "${SANAD_SKIP_FLUTTER_BUILD:-false}" == "true" ]]; then
  echo "SKIP: flutter debug APK build"
else
  echo "== Debug APK build =="
  flutter build apk --debug
fi

echo "Sanad customer mobile QA passed."
