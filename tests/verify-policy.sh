#!/usr/bin/env bash
# SPDX-FileCopyrightText: 2026 Alexey Zhokhov
# SPDX-License-Identifier: Apache-2.0
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

echo "=== 1. Checking OpenTofu formatting ==="
tofu fmt -check -recursive

echo "=== 2. Validating OpenTofu configuration ==="
tofu validate

echo "=== 3. Verifying repository-policy ownership retirement ==="
python3 - <<'PY'
from pathlib import Path
import re
import sys

exceptions = ["renovate-rust", "tailrocks-logo", "tailrocks-sqldiff"]
variables = Path("variables.tf").read_text()
managed = re.search(r'variable "managed_repositories"\s*\{(.*?)\n\}', variables, re.S)
if not managed:
    sys.exit("FAILED: managed_repositories declaration not found")
repo_names = re.findall(r'"([a-z0-9-]+)"\s*=\s*\{', managed.group(1))
if sorted(repo_names) != sorted(exceptions):
    sys.exit(f"FAILED: expected only retained exceptions {exceptions}, found {repo_names}")
expected_guard = 'toset(keys(var.managed_repositories)) == toset(["renovate-rust", "tailrocks-logo", "tailrocks-sqldiff"])'
if expected_guard not in managed.group(1):
    sys.exit("FAILED: variable validation must prevent re-enabling centrally managed repositories")
for name in exceptions:
    entry = re.search(rf'"{re.escape(name)}"\s*=\s*\{{(.*?)\n\s*\}}', managed.group(1), re.S)
    if not entry:
        sys.exit(f"FAILED: exception {name} has no policy entry")
    for pattern, description in (
        (r'disposition\s*=\s*"FullRuleset"', 'disposition = "FullRuleset"'),
        (r'visibility\s*=\s*"public"', 'visibility = "public"'),
        (r'required_checks\s*=\s*\[\s*\]', 'required_checks = []'),
    ):
        if not re.search(pattern, entry.group(1)):
            sys.exit(f"FAILED: {name} must retain {description}")

repositories = Path("repositories.tf").read_text()
if not re.search(r'module "retained_policy_exceptions"\s*\{.*?repository_policies\s*=\s*var\.managed_repositories', repositories, re.S):
    sys.exit("FAILED: the retained policy module must receive only the validated exception inventory")
if not re.search(r'removed\s*\{\s*from\s*=\s*module\.repository_policy\s+lifecycle\s*\{\s*destroy\s*=\s*false\s*\}\s*\}', repositories, re.S):
    sys.exit("FAILED: the old policy module must be relinquished without deleting GitHub objects")
for name in exceptions:
    for resource in (
        f'github_repository.managed_settings["{name}"]',
        f'github_repository_ruleset.protect_main["{name}"]',
        f'github_repository_ruleset.protect_tags["{name}"]',
    ):
        if not re.search(rf'from\s*=\s*module\.repository_policy\.{re.escape(resource)}\s+to\s*=\s*module\.retained_policy_exceptions\.{re.escape(resource)}', repositories):
            sys.exit(f"FAILED: existing {name} state must be moved intact: {resource}")

imports = re.findall(r'import\s*\{[^}]*\}', Path("imports.tf").read_text(), re.S)
org_imports = [block for block in imports if "to = module." not in block]
repo_imports = [block for block in imports if "to = module." in block]
if len(org_imports) != 4:
    sys.exit(f"FAILED: expected all four organization-level imports, found {len(org_imports)}")
if len(repo_imports) != 9:
    sys.exit(f"FAILED: expected settings and both ruleset imports for three exceptions, found {len(repo_imports)}")
for name in exceptions:
    for kind in ("github_repository.managed_settings", "github_repository_ruleset.protect_main", "github_repository_ruleset.protect_tags"):
        if not any(f'module.retained_policy_exceptions.{kind}["{name}"]' in block for block in repo_imports):
            sys.exit(f"FAILED: missing import for {name} {kind}")
if any('module.repository_policy.' in block for block in imports):
    sys.exit("FAILED: stale imports would re-adopt resources into the retired module")

organization = Path("organization.tf").read_text()
data_sources = Path("data-sources.tf").read_text()
if "data.github_repository.runner_group_selected[name].repo_id" not in organization:
    sys.exit("FAILED: runner-group membership must not depend on repository-policy resource ownership")
if not re.search(r'data "github_repository" "runner_group_selected"\s*\{.*?for_each\s*=\s*var\.velnor_runner_group_repositories.*?full_name\s*=\s*"\$\{var\.github_organization\}/\$\{each\.value\}"', data_sources, re.S):
    sys.exit("FAILED: runner-group repository IDs must be read independently of policy resources")
if "module.retained_policy_exceptions" not in Path("outputs.tf").read_text():
    sys.exit("FAILED: outputs must refer to the retained local exceptions")
if "module.repository_policy." in organization + Path("outputs.tf").read_text():
    sys.exit("FAILED: organization settings or outputs still depend on retired repository policy resources")
if "ChainArgos control-plane root" not in Path("README.md").read_text():
    sys.exit("FAILED: README must point repository-policy contributors to the central control plane")

print("SUCCESS: only the three documented exclusions remain locally managed; other repository objects are retired without remote deletion.")
print("SUCCESS: organization settings, runner-group lookup, and organization imports remain independent.")
PY

echo "=== 4. Optional live audit for the retained exceptions ==="
if [ "${LIVE_AUDIT:-0}" != "1" ]; then
  echo "SKIPPED: set LIVE_AUDIT=1 to read the three retained repositories and rulesets via gh API."
else
  python3 - <<'PY'
import json
import subprocess
import sys

exceptions = {
    "renovate-rust": (20575222, 20575267),
    "tailrocks-logo": (24300482, 24300484),
    "tailrocks-sqldiff": (24300485, 24300486),
}

def gh(endpoint):
    result = subprocess.run(["gh", "api", endpoint], capture_output=True, text=True)
    if result.returncode:
        sys.exit(f"FAILED: gh api {endpoint}: {result.stderr.strip()[:200]}")
    return json.loads(result.stdout)

for name, (main_id, tags_id) in exceptions.items():
    repo = gh(f"repos/tailrocks/{name}")
    if repo.get("visibility") != "public" or repo.get("allow_update_branch") is not False:
        sys.exit(f"FAILED: {name} settings drifted: visibility={repo.get('visibility')}, allow_update_branch={repo.get('allow_update_branch')}")
    main = gh(f"repos/tailrocks/{name}/rulesets/{main_id}")
    tags = gh(f"repos/tailrocks/{name}/rulesets/{tags_id}")
    if main.get("name") != "protect-main" or main.get("enforcement") != "active":
        sys.exit(f"FAILED: {name} protect-main is missing or inactive")
    if tags.get("name") != "protect-tags" or tags.get("enforcement") != "active":
        sys.exit(f"FAILED: {name} protect-tags is missing or inactive")
    pr = next((rule for rule in main.get("rules", []) if rule.get("type") == "pull_request"), None)
    if not pr or pr["parameters"].get("required_review_thread_resolution") is not True:
        sys.exit(f"FAILED: {name} protect-main no longer requires resolved review threads")
    if any(rule.get("type") == "required_status_checks" for rule in main.get("rules", [])):
        sys.exit(f"FAILED: {name} has an unexpected required-status-check overlay")

print("SUCCESS: all three excluded repositories retain active rulesets, resolved-thread protection, and no required-status-check overlay.")
PY
fi

echo "=== ALL VERIFICATIONS PASSED ==="
