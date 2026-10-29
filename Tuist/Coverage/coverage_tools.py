"""What report.py and annotate.py share: the newest run's manifest, and the regions that profiles ran."""
import glob
import json
import os
import subprocess
import sys
import tempfile

HERE = os.path.dirname(os.path.abspath(__file__))
FOLDER = os.environ.get("COVERAGE_FOLDER", os.path.join(HERE, "coverage"))
CODE = os.path.join(HERE, "Sources", "Calculator") + os.sep


def newest_run():
    """The newest run's folder and manifest, or exits with a message."""
    runs = sorted(glob.glob(os.path.join(FOLDER, "run-*")), key=os.path.getmtime)
    if not runs:
        sys.exit(f"No run in {FOLDER}. Run the tests first, with ⌘U or `mise run test Coverage`.")
    manifest = json.load(open(os.path.join(runs[-1], "manifest.json")))
    if manifest.get("problem"):
        sys.exit(f"CucumberSwift wrote no coverage: {manifest['problem']}")
    return runs[-1], manifest


def demangle(names):
    """Swift function names, from their mangled symbols."""
    result = subprocess.run(["xcrun", "swift-demangle", "--simplified"], input="\n".join(names), capture_output=True, text=True)
    return [line.split(" ---> ")[-1] for line in result.stdout.splitlines()]


def regions(run, manifest, profiles, entered_only):
    """The regions of Sources/Calculator that `profiles` ran, as (covered, total, functions, not_run).

    The total counts the regions of the functions that ran, or, without `entered_only`, of every function.
    `not_run` lists the functions that no profile entered."""
    covered = total = functions = 0
    not_run = []
    with tempfile.TemporaryDirectory() as temp:
        for binary in manifest["binaries"]:
            name = os.path.basename(binary["path"])
            mine = [os.path.join(run, p) for p in profiles if p.endswith(f"-{name}.profraw")]
            if not mine:
                continue
            merged = os.path.join(temp, name + ".profdata")
            subprocess.run(["xcrun", "llvm-profdata", "merge", *mine, "-o", merged], check=True)
            export = subprocess.run(["xcrun", "llvm-cov", "export", binary["path"], f"-instr-profile={merged}"],
                                    capture_output=True, text=True)
            if export.returncode != 0:
                continue
            for function in json.loads(export.stdout)["data"][0]["functions"]:
                if not function["filenames"][0].startswith(CODE):
                    continue
                if function["count"] == 0:
                    not_run.append(function["name"])
                    if entered_only:
                        continue
                functions += 1
                # A region is [line start, column start, line end, column end, count, file id, expanded file id, kind].
                code = [region for region in function["regions"] if region[7] == 0]
                total += len(code)
                covered += sum(1 for region in code if region[4] > 0)
    return covered, total, functions, demangle(not_run)
