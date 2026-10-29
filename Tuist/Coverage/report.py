#!/usr/bin/env python3
"""Prints how much of Sources/Calculator each scenario covered, and what the whole run covered.

    python3 report.py

Reads the newest run in the `coverage` folder next to this file: the
manifest that CucumberSwift wrote, and the `.profraw` file of each scenario. `llvm-profdata`
and `llvm-cov` come with Xcode.
"""
from coverage_tools import regions, newest_run

run, manifest = newest_run()

print("Each scenario, of the functions it ran:")
print(f"  {'Scenario':<32} {'Regions':>9} {'Covered':>8}   Functions run")
for scenario in manifest["scenarios"]:
    covered, total, functions, _ = regions(run, manifest, scenario["profiles"], entered_only=True)
    percent = 100 * covered / total if total else 0
    print(f"  {scenario['name']:<32} {covered:>4}/{total:<4} {percent:>7.0f}%   {functions}")
everything = [profile for scenario in manifest["scenarios"] for profile in scenario["profiles"]]
covered, total, functions, not_run = regions(run, manifest, everything, entered_only=False)
percent = 100 * covered / total if total else 0
print()
print(f"All scenarios together, of all the code in Sources/Calculator: {covered}/{total} regions, {percent:.0f}%")
if not_run:
    print("No scenario ran: " + ", ".join(not_run))
