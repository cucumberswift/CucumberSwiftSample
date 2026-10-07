#!/usr/bin/env bash
# Builds the samples' documentation, the DocC catalog in Docs/, with warnings as errors.
#
#   .github/scripts/build-docs.sh <output directory> [version]
#
# Without a version, it builds the site once, for /CucumberSwiftSample/, into the
# output directory: the check a pull request runs.
#
# With a version X.Y.Z, the Release workflow's build: the overview gets "Version X.Y.Z"
# above its title, in a copy of the catalog, and the site is built twice, because DocC
# bakes the path into its output. The output directory gets docs-root.zip, built for
# /CucumberSwiftSample/, and docs-major.zip, built for /CucumberSwiftSample/X.x/.
# .github/scripts/publish-docs.sh decides which release goes where.
#
# It needs no Package.swift. DocC comes from DOCC if set, then the PATH, then Xcode
# (xcrun), then the Swift toolchain's directory: the ubuntu runners put only swift and
# swiftc on the PATH.
set -euo pipefail

repo_root=$(cd "$(dirname "$0")/../.." && pwd)
out=${1:?usage: build-docs.sh <output directory> [version]}
version=${2:-}
docs_path=CucumberSwiftSample
catalog="$repo_root/Docs/CucumberSwiftSample.docc"

if [ -n "${DOCC:-}" ]; then
  docc=$DOCC
elif command -v docc >/dev/null; then
  docc=$(command -v docc)
elif command -v xcrun >/dev/null; then
  docc=$(xcrun --find docc)
else
  docc="$(dirname "$(readlink -f "$(command -v swift)")")/docc"
fi

build() {
  "$docc" convert "$1" \
    --fallback-display-name CucumberSwiftSample \
    --fallback-bundle-identifier org.cucumberswift.samples \
    --transform-for-static-hosting \
    --hosting-base-path "$2" \
    --warnings-as-errors \
    --output-path "$3"
  [ -f "$3/documentation/cucumberswiftsample/index.html" ] ||
    { echo "::error::The build has no documentation/cucumberswiftsample/ page."; exit 1; }
}

mkdir -p "$out"
if [ -z "$version" ]; then
  build "$catalog" "$docs_path" "$out"
  exit 0
fi

[[ "$version" =~ ^(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)$ ]] ||
  { echo "::error::The version must be X.Y.Z."; exit 1; }
work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT

# The heading above the title, as in CucumberSwift's and CucumberSwiftExpressions' docs.
cp -R "$catalog" "$work/catalog.docc"
page="$work/catalog.docc/CucumberSwiftSample.md"
if [ "$(grep -c '^    @TechnologyRoot$' "$page")" != 1 ] || grep -q '@TitleHeading' "$page"; then
  echo "::error::The overview must have one @TechnologyRoot line and no @TitleHeading."
  exit 1
fi
perl -pi -e "s/^    \@TechnologyRoot\$/    \@TechnologyRoot\n    \@TitleHeading(\"Version $version\")/" "$page"

build "$work/catalog.docc" "$docs_path/${version%%.*}.x" "$work/major"
build "$work/catalog.docc" "$docs_path" "$work/root"
# Zipped, because artifact file names may not contain ":", which DocC uses.
(cd "$work/major" && zip -qr "$work/docs-major.zip" .)
(cd "$work/root" && zip -qr "$work/docs-root.zip" .)
mv "$work/docs-major.zip" "$work/docs-root.zip" "$out/"
echo "Built docs-major.zip and docs-root.zip for $version."
