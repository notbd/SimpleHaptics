#!/bin/bash
#
# Compiles SimpleHaptics for every platform in Package.swift, at the minimum version that the manifest
# declares, with warnings as errors.
#
# It calls the compiler directly instead of xcodebuild: it needs only the SDKs, not simulator runtimes,
# and it builds one architecture per platform. The platforms compile in parallel, and the script prints
# each result with its log in the order of the manifest. A platform that this script doesn't know fails
# the run, so adding one to Package.swift can't skip the check.
#
# Usage: scripts/build-platforms.sh

set -euo pipefail
cd "$(dirname "$0")/.."

output=$(mktemp -d)
trap 'kill $(jobs -p) 2> /dev/null || true; wait 2> /dev/null; rm -rf "$output"' EXIT
macos_sdk=$(xcrun --sdk macosx --show-sdk-path)
targets=()
pids=()

# compile <sdk> <target triple> [extra swiftc flags...]
# Starts the compile in the background, and writes its output to $output/<target triple>.log.
compile() {
  local sdk=$1 target=$2
  shift 2
  targets+=("$target")
  xcrun --sdk "$sdk" swiftc -c -wmo -parse-as-library -module-name SimpleHaptics \
    -swift-version "$swift_version" -warnings-as-errors -target "$target" "$@" \
    -o "$output/$target.o" Sources/SimpleHaptics/*.swift > "$output/$target.log" 2>&1 &
  pids+=("$!")
}

manifest=$(swift package dump-package)
swift_version=$(jq -r '.swiftLanguageVersions[0]' <<< "$manifest")

while read -r platform version; do
  case $platform in
    ios) compile iphoneos "arm64-apple-ios$version" ;;
    maccatalyst)
      compile macosx "arm64-apple-ios$version-macabi" \
        -Fsystem "$macos_sdk/System/iOSSupport/System/Library/Frameworks" \
        -I "$macos_sdk/System/iOSSupport/usr/lib/swift"
      ;;
    macos) compile macosx "arm64-apple-macosx$version" ;;
    tvos) compile appletvos "arm64-apple-tvos$version" ;;
    watchos) compile watchos "arm64_32-apple-watchos$version" ;;
    visionos) compile xros "arm64-apple-xros$version" ;;
    *)
      echo "error: scripts/build-platforms.sh doesn't know the platform '$platform' in Package.swift" >&2
      exit 1
      ;;
  esac
done < <(jq -r '.platforms[] | "\(.platformName) \(.version)"' <<< "$manifest")

# An empty or missing platform list would otherwise pass without compiling anything.
if [ "${#targets[@]}" -eq 0 ]; then
  echo "error: Package.swift lists no platforms, or scripts/build-platforms.sh couldn't read them" >&2
  exit 1
fi

failed=0
for index in "${!targets[@]}"; do
  target=${targets[$index]}
  if wait "${pids[$index]}"; then
    echo "==> $target: passed"
  else
    echo "==> $target: failed"
    failed=1
  fi
  cat "$output/$target.log"
done
exit "$failed"
