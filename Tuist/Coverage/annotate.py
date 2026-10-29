#!/usr/bin/env python3
"""Writes the coverage of each scenario as Xcode warnings and errors on the feature file.

    python3 annotate.py

The scheme runs it after the tests. It reads the newest run in the `coverage` folder, and writes
`coverage/annotations.txt`, which the CoverageAnnotations plugin prints on the next build, so that
Xcode shows each line at the feature file's line. Set the levels with environment variables:

    CUCUMBER_COVERAGE_WARNING_LEVEL  a warning below this percentage, 80 by default
    CUCUMBER_COVERAGE_ERROR_LEVEL    an error below this percentage, 50 by default

A scenario's percentage is its share of the functions that it ran. The feature's is the share of all the
code in Sources/Calculator that its scenarios ran. A scenario or feature at or above the warning level has
no line. Xcode shows warnings and errors only.
"""
import os
import urllib.parse

from coverage_tools import HERE, FOLDER, newest_run, regions

WARNING = float(os.environ.get("CUCUMBER_COVERAGE_WARNING_LEVEL", "80"))
ERROR = float(os.environ.get("CUCUMBER_COVERAGE_ERROR_LEVEL", "50"))


def level(percent):
    return "error" if percent < ERROR else "warning" if percent < WARNING else None


run, manifest = newest_run()
issues = []
features = {}
for scenario in manifest["scenarios"]:
    # The feature file in the project, not its copy in the test bundle.
    name = os.path.basename(urllib.parse.unquote(urllib.parse.urlparse(scenario["feature"]).path))
    path = os.path.join(HERE, "Tests", "Features", name)
    features.setdefault(path, []).extend(scenario["profiles"])
    covered, total, functions, _ = regions(run, manifest, scenario["profiles"], entered_only=True)
    percent = 100 * covered / total if total else 0
    if level(percent):
        issues.append(f"{path}:{scenario['line']}:1: {level(percent)}: "
                      f"Scenario coverage {percent:.0f}% of the {functions} functions it ran")

for path, profiles in features.items():
    covered, total, _, not_run = regions(run, manifest, profiles, entered_only=False)
    percent = 100 * covered / total if total else 0
    if level(percent):
        line = next(number for number, text in enumerate(open(path), 1) if text.startswith("Feature:"))
        missed = f". No scenario ran {', '.join(not_run)}" if not_run else ""
        issues.append(f"{path}:{line}:1: {level(percent)}: Feature coverage {percent:.0f}% of Sources/Calculator "
                      f"(warning below {WARNING:.0f}%, error below {ERROR:.0f}%){missed}")

# Xcode shows only the first issue that a command prints, and the plugin runs one command for each
# blank-line-separated block.
with open(os.path.join(FOLDER, "annotations.txt"), "w") as out:
    out.write("\n\n".join(issues) + ("\n" if issues else ""))
print(f"{len(issues)} coverage issues for the feature files, in {os.path.join(FOLDER, 'annotations.txt')}")
