#!/bin/bash
# Decides whether CI's release job can build a sample yet:
#
#     scripts/release-gate.sh SampleName
#
# A sample's Project.swift asks for a CucumberSwift version. When CucumberSwift has not
# released that version, SwiftPM cannot resolve it, so the release job skips the sample
# (the main job still tests it) instead of failing. This script reads the oldest version
# the manifest asks for, compares it with the highest stable release of CucumberSwift,
# and writes `build=true` or `build=false`. It prints a notice naming both versions when it
# skips.
#
# The release job runs it only for the release leg, with GH_TOKEN set (contents: read is
# enough). A manifest that asks for no version (a local path only), and a lookup that
# fails, both mean build=true: the job then behaves as it did before this script.
#
# The answer goes to $GITHUB_OUTPUT, or to the terminal when that is not set.
# CUCUMBER_SWIFT_LATEST=X.Y.Z replaces the lookup, to try it without the network.
set -euo pipefail

repo_root=$(cd "$(dirname "$0")/.." && pwd)
output=${GITHUB_OUTPUT:-/dev/stdout}
sample=${1:?usage: release-gate.sh SampleName}
manifest="$repo_root/Tuist/$sample/Project.swift"
[ -f "$manifest" ] || { echo "::error::$sample: no $manifest"; exit 1; }

# The versions on CucumberSwift's own dependency lines: `from: "6.3.0"` covers `from:` and
# `.upToNextMajor(from:)` / `.upToNextMinor(from:)`, `exact:` and `.exact("…")` the exact form.
# A line that names another package (CucumberSwiftExpressions) is not counted.
oldest=$(grep -iE 'cucumberswift(\.git)?"' "$manifest" | grep -viE 'cucumberswift[a-z]' |
  grep -oE '(from:|exact:|\.exact\()[[:space:]]*"[0-9]+\.[0-9]+\.[0-9]+"' | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' |
  sort -V | head -1 || true)

if [ -z "$oldest" ]; then
  echo "$sample asks for no CucumberSwift version in its Project.swift, so the release job builds it."
  echo build=true >>"$output"
  exit 0
fi

latest=${CUCUMBER_SWIFT_LATEST:-}
if [ -z "$latest" ]; then
  # Not releases/latest: that is the most recent release by date, which can be a support
  # branch's. The highest stable version is what decides whether a version exists.
  if ! tags=$(gh api --paginate 'repos/cucumberswift/CucumberSwift/releases?per_page=100' \
    --jq '.[] | select(.draft == false and .prerelease == false) | .tag_name'); then
    echo "::warning::$sample: could not read CucumberSwift's releases, so the release job builds it."
    echo build=true >>"$output"
    exit 0
  fi
  latest=$(grep -E '^v?[0-9]+\.[0-9]+\.[0-9]+$' <<<"$tags" | sed 's/^v//' | sort -V | tail -1 || true)
  if [ -z "$latest" ]; then
    echo "::warning::$sample: CucumberSwift has no stable release in the list, so the release job builds it."
    echo build=true >>"$output"
    exit 0
  fi
fi

if [ "$oldest" != "$latest" ] && [ "$(printf '%s\n%s\n' "$oldest" "$latest" | sort -V | tail -1)" = "$oldest" ]; then
  message="$sample needs CucumberSwift $oldest; the latest release is $latest. The release job skips it until $oldest is released; the main job still tests it."
  echo "::notice title=$sample release job skipped::$message"
  echo build=false >>"$output"
else
  echo "$sample needs CucumberSwift $oldest, and the latest release is $latest, so the release job builds it."
  echo build=true >>"$output"
fi
