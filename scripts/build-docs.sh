#!/bin/bash
#
# Builds the DocC documentation with warnings as errors, so a broken symbol link fails the run.
#
# Usage: scripts/build-docs.sh

set -euo pipefail
cd "$(dirname "$0")/.."

work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT
swift_version=$(swift package dump-package | jq -r '.swiftLanguageVersions[0]')

# The extension block symbols let DocC resolve links to the View extension, such as ``SwiftUICore/View``.
xcrun swiftc -emit-module -emit-module-path "$work/SimpleHaptics.swiftmodule" -wmo -parse-as-library \
  -module-name SimpleHaptics -swift-version "$swift_version" \
  -emit-symbol-graph -emit-symbol-graph-dir "$work" -emit-extension-block-symbols \
  -symbol-graph-minimum-access-level public \
  Sources/SimpleHaptics/*.swift

xcrun docc convert Sources/SimpleHaptics/SimpleHaptics.docc --additional-symbol-graph-dir "$work" \
  --warnings-as-errors --output-path "$work/SimpleHaptics.doccarchive"
