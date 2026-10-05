#!/bin/bash
# Builds and tests one sample, or every sample in Tuist/ when no name is given:
#
#     scripts/test-sample.sh [SampleName]
#
# Runs through mise (`mise run test [SampleName]`), which provides the pinned Tuist and
# passes CUCUMBER_SWIFT_PATH on to the manifests. For each sample it generates the
# project, then runs every test plan in the sample's scheme, or the scheme's tests if it
# has no test plans. A test plan passes when every failed test is one the sample fails
# on purpose (see expected_failures below), and the sample's default test plan fails each
# of those, so a sample that stops showing its failure is caught too. A test plan that runs
# in parallel (see parallel_plans below) must also use more than one worker, and run as
# many tests as the sample's default test plan.
set -euo pipefail

repo_root=$(cd "$(dirname "$0")/.." && pwd)
results_dir="${RESULTS_DIR:-$repo_root/build/results}"
mkdir -p "$results_dir"

# Scenarios a sample fails on purpose, one per line, as written in its feature file.
expected_failures() {
  case "$1" in
    TestNavigator) echo "Apply a discount code" ;;
  esac
}

# Test plans that run a sample's scenarios with Xcode's parallel testing, one per line. The
# sample's other test plans run the same scenarios one after another, so every test plan
# must run the same number of tests: a scenario that a parallel run drops or runs twice
# changes the count. A parallel test plan must also run its tests in more than one worker.
parallel_plans() {
  case "$1" in
    ParallelTesting) echo "Parallel" ;;
  esac
}

# Lowercase letters and digits only, so a scenario matches its test whether test names
# are readable ("Checkout › Apply a discount code") or camel case ("ApplyADiscountCode").
normalize() {
  tr '[:upper:]' '[:lower:]' | tr -cd 'a-z0-9\n'
}

# Reads a field from a result bundle's summary (the JSON from xcresulttool):
# "count" prints how many tests ran, "failed" the failed tests' identifiers, one per line.
summary_field() {
  python3 -c 'import json, sys
summary = json.loads(sys.argv[2])
if sys.argv[1] == "count":
    print(summary.get("totalTestCount", 0))
else:
    print("\n".join(sorted({f["testIdentifierString"] for f in summary.get("testFailures", [])})))' "$1" "$2"
}

test_sample() {
  local sample=$1
  local dir="$repo_root/Tuist/$sample"
  local status=0
  echo "::group::$sample: generate"
  # set -e does not apply here: the function runs as `test_sample … || overall=1`. So each
  # step that can fail returns or sets status itself, rather than test a stale project.
  if ! tuist generate --no-open --path "$dir"; then
    echo "::endgroup::"
    echo "::error::$sample: tuist generate failed"
    return 1
  fi
  echo "::endgroup::"

  local plans_json plans
  if ! plans_json=$(xcodebuild -showTestPlans -project "$dir/$sample.xcodeproj" -scheme "$sample" -json); then
    echo "::error::$sample: could not read the scheme's test plans; see xcodebuild's output above"
    return 1
  fi
  plans=$(python3 -c 'import json, sys; print(" ".join(p["name"] for p in json.load(sys.stdin)["testPlans"] or []))' <<<"$plans_json")
  [ -n "$plans" ] || plans="-"

  local expected parallel
  expected=$(expected_failures "$sample")
  parallel=$(parallel_plans "$sample")
  local first_plan=true first_total=""
  local plan
  for plan in $plans; do
    local label="$sample"
    [ "$plan" = "-" ] || label="$sample ($plan)"
    local bundle="$results_dir/$sample-$plan.xcresult"
    local log="$results_dir/$sample-$plan.log"
    local plan_args=()
    [ "$plan" = "-" ] || plan_args=(-testPlan "$plan")
    rm -rf "$bundle"

    echo "::group::$label: test"
    local xcodebuild_status=0
    xcodebuild test -project "$dir/$sample.xcodeproj" -scheme "$sample" ${plan_args[@]+"${plan_args[@]}"} \
      -destination 'platform=macOS' -resultBundlePath "$bundle" 2>&1 | tee "$log" || xcodebuild_status=$?
    echo "::endgroup::"

    if [ ! -d "$bundle" ]; then
      echo "::error::$label: xcodebuild exited with $xcodebuild_status and left no test results"
      status=1
      continue
    fi

    local summary failed total
    if ! summary=$(xcrun xcresulttool get test-results summary --path "$bundle"); then
      echo "::error::$label: could not read the test results"
      status=1
      continue
    fi
    if ! failed=$(summary_field failed "$summary") || ! total=$(summary_field count "$summary") ||
      ! [[ "$total" =~ ^[0-9]+$ ]]; then
      echo "::error::$label: could not read the test results"
      status=1
      continue
    fi
    if [ "$total" -eq 0 ]; then
      echo "::error::$label: no tests ran"
      status=1
    fi
    if [ -n "$parallel" ]; then
      if [ -z "$first_total" ]; then
        first_total=$total
      elif [ "$total" -ne "$first_total" ]; then
        echo "::error::$label: ran $total tests, but the default test plan ran $first_total"
        status=1
      fi
      if grep -qxF "$plan" <<<"$parallel"; then
        # xcodebuild names each worker process: "started on 'My Mac - xctest (12345)'".
        local workers
        workers=$(grep -oE "started on '[^']*\([0-9]+\)'" "$log" | sort -u | wc -l | tr -d ' ')
        if [ "$workers" -lt 2 ]; then
          echo "::error::$label: ran its tests in $workers worker(s); a parallel test plan should use more than one"
          status=1
        else
          echo "$label: ran its tests in $workers workers"
        fi
      fi
    fi
    local unexpected=""
    local test_id
    while IFS= read -r test_id; do
      [ -n "$test_id" ] || continue
      local normalized_id
      normalized_id=$(normalize <<<"$test_id")
      local known=false
      local scenario
      while IFS= read -r scenario; do
        [ -n "$scenario" ] || continue
        if [[ "$normalized_id" == *"$(normalize <<<"$scenario")"* ]]; then known=true; fi
      done <<<"$expected"
      $known || unexpected+="$test_id"$'\n'
    done <<<"$failed"

    if [ -n "$unexpected" ]; then
      echo "::error::$label: unexpected failures:"$'\n'"$unexpected"
      status=1
    elif [ "$xcodebuild_status" -ne 0 ] && [ -z "$failed" ]; then
      echo "::error::$label: xcodebuild exited with $xcodebuild_status, but no test failed"
      status=1
    fi

    if $first_plan; then
      local normalized_failed
      normalized_failed=$(normalize <<<"$failed")
      while IFS= read -r scenario; do
        [ -n "$scenario" ] || continue
        if [[ "$normalized_failed" != *"$(normalize <<<"$scenario")"* ]]; then
          echo "::error::$label: \"$scenario\" should fail on purpose, but did not"
          status=1
        fi
      done <<<"$expected"
    fi
    first_plan=false
    [ "$status" -ne 0 ] || echo "$label: passed${failed:+, failing only where it fails on purpose}"
  done
  return "$status"
}

samples=("$@")
if [ ${#samples[@]} -eq 0 ] || [ -z "${samples[0]}" ]; then
  samples=()
  for dir in "$repo_root"/Tuist/*/; do samples+=("$(basename "$dir")"); done
fi

overall=0
for sample in "${samples[@]}"; do
  test_sample "$sample" || overall=1
done
exit "$overall"
