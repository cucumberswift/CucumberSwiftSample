#!/usr/bin/env bash
# Checks a samples release before anything is built or created. The Release workflow
# runs it; it creates nothing, so it can also be run by hand:
#
#   BRANCH=main VERSION=6.3.0 GH_TOKEN=$(gh auth token) .github/scripts/release-plan.sh
#
# A samples release carries the version of the CucumberSwift release it is for: samples
# 6.3.0 are tested with CucumberSwift 6.3.0. Not every CucumberSwift release needs one.
# It refuses, and names the reason, unless:
#
#   - VERSION is X.Y.Z, and a stable (not draft, not pre-release) CucumberSwift release;
#   - this repository has no tag VERSION yet;
#   - on main, VERSION is higher than every samples release; on support/N.x, its major
#     is N and it is higher than every N.x samples release;
#   - every sample in Tuist/ asks for CucumberSwift VERSION's major, at VERSION or lower,
#     or for exactly VERSION;
#   - the overview's subtitle says "for CucumberSwift N.x", with VERSION's major.
#
# Environment: BRANCH (main or support/N.x), VERSION, GH_TOKEN (reads public releases),
# GH_REPO (default cucumberswift/CucumberSwiftSample).
# Writes version, major, latest (true on main) and samples (a JSON list) to
# $GITHUB_OUTPUT, or to the terminal when that is not set.
set -euo pipefail

repo_root=$(cd "$(dirname "$0")/../.." && pwd)
output=${GITHUB_OUTPUT:-/dev/stdout}
repo=${GH_REPO:-cucumberswift/CucumberSwiftSample}
overview="$repo_root/Docs/CucumberSwiftSample.docc/CucumberSwiftSample.md"

fail() {
  echo "::error::$*"
  exit 1
}

version=${VERSION:-}
[[ "$version" =~ ^(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)$ ]] ||
  fail "The version must be X.Y.Z, such as 6.3.0."
major=${version%%.*}

branch=${BRANCH:-}
if [ "$branch" = main ]; then
  latest=true
elif [[ "$branch" =~ ^support/(0|[1-9][0-9]*)\.x$ ]]; then
  latest=false
  [ "${BASH_REMATCH[1]}" = "$major" ] || fail "$branch releases only ${BASH_REMATCH[1]}.x versions, not $version."
else
  fail "Releases run only on main or on a support/N.x branch."
fi

# 1. A stable CucumberSwift release.
state=$(gh api "repos/cucumberswift/CucumberSwift/releases/tags/$version" \
  --jq 'if .draft or .prerelease then "unstable" else "stable" end' 2>/dev/null) || state=missing
[ "$state" = stable ] || fail "CucumberSwift $version is not a stable release, so there is nothing to release the samples for."

# 2. Not released yet, and 3. higher than the samples releases it must follow.
tags=$(gh api --paginate "repos/$repo/tags?per_page=100" --jq '.[].name')
! grep -qxF "$version" <<<"$tags" || fail "The tag $version already exists in $repo."
released=$(grep -E '^(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)$' <<<"$tags" || true)
if [ "$branch" != main ]; then released=$(grep "^$major\." <<<"$released" || true); fi
highest=$(sort -V <<<"$released" | tail -1)
if [ -n "$highest" ] && [ "$(printf '%s\n%s\n' "$highest" "$version" | sort -V | tail -1)" != "$version" ]; then
  fail "$version is lower than the samples release $highest. On $branch, a release must be higher than every earlier one."
fi

# 4. Every sample works with this version: it asks for this major, and nothing newer.
samples=()
for manifest in "$repo_root"/Tuist/*/Project.swift; do
  sample=$(basename "$(dirname "$manifest")")
  samples+=("$sample")
  requirements=$(REQUIREMENTS_ONLY=1 "$repo_root/scripts/release-gate.sh" "$sample")
  [ -n "$requirements" ] || fail "$sample asks for no CucumberSwift version in its Project.swift."
  while read -r kind required; do
    if [ "$kind" = exact ]; then
      [ "$required" = "$version" ] || fail "$sample asks for exactly CucumberSwift $required, not $version."
    elif [ "${required%%.*}" != "$major" ]; then
      fail "$sample asks for CucumberSwift $required, which is not $major.x."
    elif [ "$(printf '%s\n%s\n' "$required" "$version" | sort -V | tail -1)" != "$version" ]; then
      fail "$sample needs CucumberSwift $required, which is newer than $version."
    fi
  done <<<"$requirements"
done
[ ${#samples[@]} -gt 0 ] || fail "There is no sample in Tuist/."

# 5. The subtitle names the major: the first paragraph after the title.
subtitle=$(awk 'NR > 1 && NF { print; exit }' "$overview")
grep -qF "for CucumberSwift $major.x" <<<"$subtitle" ||
  fail "The subtitle of ${overview#"$repo_root"/} must say \"for CucumberSwift $major.x\": $subtitle"

{
  echo "version=$version"
  echo "major=$major"
  echo "latest=$latest"
  echo "samples=$(printf '%s\n' "${samples[@]}" | jq -R . | jq -sc .)"
} >>"$output"
echo "This run releases the samples $version, for CucumberSwift $version, from $branch (Latest: $latest)."
