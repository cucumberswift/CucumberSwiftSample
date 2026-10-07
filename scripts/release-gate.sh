#!/bin/bash
# Decides whether CI's release job can build a sample yet:
#
#     scripts/release-gate.sh SampleName
#
# A sample's Project.swift, or a Bazel sample's MODULE.bazel, asks for a CucumberSwift
# version. When CucumberSwift has not released that version, SwiftPM or Bazel cannot fetch
# it, so the release job skips the sample
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
# CUCUMBER_SWIFT_LATEST=X.Y.Z replaces the lookup (it then stands for the only release), to try it without the network.
# REQUIREMENTS_ONLY=1 only prints the requirements, as "kind version" lines, and exits; the
# Release workflow reads them through .github/scripts/release-plan.sh.
set -euo pipefail

repo_root=$(cd "$(dirname "$0")/.." && pwd)
output=${GITHUB_OUTPUT:-/dev/stdout}
sample=${1:?usage: release-gate.sh SampleName}
manifest="$repo_root/Tuist/$sample/Project.swift"
[ -f "$manifest" ] || manifest="$repo_root/Bazel/$sample/MODULE.bazel"
[ -f "$manifest" ] || { echo "::error::$sample: no Tuist/$sample/Project.swift or Bazel/$sample/MODULE.bazel"; exit 1; }

# The requirements of CucumberSwift's own dependency declarations, as "kind version" lines. In a
# Project.swift, kind is
# `from` for `from: "6.3.0"` (which covers `.upToNextMajor(from:)` and `.upToNextMinor(from:)`)
# and `exact` for `exact: "6.3.0"` and `.exact("6.3.0")`. Comments are dropped first: `/* … */`
# blocks, and a `//` that starts the line or follows a space (the one in `https://` stays). The lines are then
# joined, so the URL and its requirement can sit on different lines, and each declaration is read up
# to its first `)`. A declaration of another package (CucumberSwiftExpressions) is not counted.
if [ "$(basename "$manifest")" = MODULE.bazel ]; then
  # A Bazel sample: `bazel_dep(name = "cucumberswift", version = "6.4.0")`, whose
  # git_override fetches the release tag. Bazel takes a bazel_dep's version as the
  # lowest it accepts, so it counts as `from`, like SwiftPM's `from:`. `#` comments are
  # dropped first, and cucumberswift_expressions is not counted.
  requirements=$(sed 's/#.*//' "$manifest" | tr '\n' ' ' |
    grep -oE 'bazel_dep\([^)]*name[[:space:]]*=[[:space:]]*"cucumberswift"[^)]*\)' |
    grep -oE 'version[[:space:]]*=[[:space:]]*"[0-9]+\.[0-9]+\.[0-9]+"' |
    sed -E 's/.*"([0-9.]+)"$/from \1/' | sort -k2,2V || true)
else
requirements=$(perl -0pe 's{/\*.*?\*/}{}gs; s{(^|\s)//[^\n]*}{}gm; tr/\n/ /' "$manifest" |
  grep -oiE '/cucumberswift(\.git)?"[^)]*\)' |
  grep -oE '(from:|exact:|\.exact\()[[:space:]]*"[0-9]+\.[0-9]+\.[0-9]+"' |
  sed -E 's/^from:.*"([0-9.]+)"$/from \1/; s/^(exact:|\.exact\().*"([0-9.]+)"$/exact \2/' | sort -k2,2V || true)
fi

if [ -n "${REQUIREMENTS_ONLY:-}" ]; then
  [ -z "$requirements" ] || echo "$requirements"
  exit 0
fi

if [ -z "$requirements" ]; then
  echo "$sample asks for no CucumberSwift version in $(basename "$manifest"), so the release job builds it."
  echo build=true >>"$output"
  exit 0
fi

# Every stable release's version, one per line. CUCUMBER_SWIFT_LATEST stands in for the list.
if [ -n "${CUCUMBER_SWIFT_LATEST:-}" ]; then
  released=$CUCUMBER_SWIFT_LATEST
else
  # Not releases/latest: that is the most recent release by date, which can be a support
  # branch's. The highest stable version is what decides whether a `from` version exists.
  if ! tags=$(gh api --paginate 'repos/cucumberswift/CucumberSwift/releases?per_page=100' \
    --jq '.[] | select(.draft == false and .prerelease == false) | .tag_name'); then
    echo "::warning::$sample: could not read CucumberSwift's releases, so the release job builds it."
    echo build=true >>"$output"
    exit 0
  fi
  released=$(grep -E '^v?[0-9]+\.[0-9]+\.[0-9]+$' <<<"$tags" | sed 's/^v//' || true)
fi
latest=$(sort -V <<<"$released" | tail -1)
if [ -z "$latest" ]; then
  echo "::warning::$sample: CucumberSwift has no stable release in the list, so the release job builds it."
  echo build=true >>"$output"
  exit 0
fi

# The oldest requirement SwiftPM cannot resolve: a `from` version above the highest release,
# or an `exact` version that was never released.
missing=""
while read -r kind version; do
  if [ "$kind" = exact ]; then
    grep -qxF "$version" <<<"$released" || missing=$version
  elif [ "$version" != "$latest" ] && [ "$(printf '%s\n%s\n' "$version" "$latest" | sort -V | tail -1)" = "$version" ]; then
    missing=$version
  fi
  [ -z "$missing" ] || break
done <<<"$requirements"

if [ -n "$missing" ]; then
  message="$sample needs CucumberSwift $missing; the latest release is $latest. The release job skips it until $missing is released; the main job still tests it."
  echo "::notice title=$sample release job skipped::$message"
  echo build=false >>"$output"
else
  echo "$sample's CucumberSwift requirements are released (latest release $latest), so the release job builds it."
  echo build=true >>"$output"
fi
