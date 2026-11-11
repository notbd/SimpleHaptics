# Contributing

## Run the checks

CI runs these commands on every pull request. Run them on your Mac before you push:

```sh
swiftlint lint --strict      # lint
swiftformat --lint .         # formatting
scripts/build-platforms.sh   # compiles for every platform in Package.swift, at its minimum version
scripts/build-docs.sh        # builds the DocC documentation; a broken symbol link is an error
swift test                   # tests on macOS
xcodebuild build -quiet -project Examples/SimpleHapticsDemo/SimpleHapticsDemo.xcodeproj \
  -scheme SimpleHapticsDemo -destination "generic/platform=iOS Simulator" CODE_SIGNING_ALLOWED=NO
```

The scripts need `jq`. If `jq` isn't on your Mac, install it with `brew install jq`.

CI pins the SwiftLint and SwiftFormat versions in [`ci.yml`](./.github/workflows/ci.yml). Install the same
versions, because a different version can format differently.

The SwiftUI modifier tests run only on iOS. Run them on any iPhone simulator from
`xcrun simctl list devices available`:

```sh
xcodebuild test -scheme SimpleHaptics -destination "platform=iOS Simulator,name=<iPhone name>"
```

## How CI is organized

CI runs one job per Xcode instead of several, because GitHub often has no free macOS runner for more jobs.

| Job                                   | Runs                                                                          |
| ------------------------------------- | ----------------------------------------------------------------------------- |
| Newest Xcode on the macos-26 runner   | Lint, the platform builds, the documentation, the example app, and iOS tests  |
| Oldest supported Xcode                | macOS tests, and the platform builds with the oldest compiler that we support |

`scripts/build-platforms.sh` calls the compiler directly, so it doesn't need simulator runtimes. It reads the
platforms and minimum versions from Package.swift. When you add a platform there, the script fails until you add
the platform to it too.

## Deprecate API

Deprecate in a minor version and remove in the next major version, so that every user gets at least one release
with a warning:

1. Mark the declaration `@available(*, deprecated, message:)`. The message names the replacement and the version
   that removes the declaration. Add `renamed:` only when the replacement is a drop-in at every call site, so that
   the fix-it that Xcode offers compiles.
2. Move the declaration to `SimpleHaptics+Deprecated.swift`, and its tests to `DeprecatedTests.swift`. Mark the
   tests `@available(*, deprecated)`, so they build without warnings.
3. Add a DocC extension file with `@DeprecationSummary`, and list the declaration under **Deprecated** in
   `SimpleHaptics-enum.md`.
4. Add the declaration to CHANGELOG.md under **Deprecated**, and a row to the table in the README.

To remove deprecated API in a major version, delete the declaration, its tests, its DocC extension file, and its
entries in `SimpleHaptics-enum.md` and the README. Delete any file, topic group, or README section that this leaves
empty. Add the declaration to CHANGELOG.md under **Removed**, with its replacement.

## Release

1. In CHANGELOG.md, add a heading for the new version and date below **Unreleased**, move the entries there, and
   update the links at the bottom. For a major version, also update `from:` in the README.
2. Merge the pull request into `main` and wait for CI to pass.
3. Create the release from that commit:

   ```sh
   gh release create vX.Y.Z --target <commit SHA> --title vX.Y.Z --notes-file <release notes>
   ```

   The release notes are the new section of CHANGELOG.md.
