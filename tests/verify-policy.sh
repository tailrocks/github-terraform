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

echo "=== 3. Verifying mandatory target inventory coverage ==="
python3 - << 'EOF'
import re, sys

with open("variables.tf") as f:
    content = f.read()

mandatory = [
    "velnor", "holla-apt", "homebrew-holla", "homebrew-tablerock", "homebrew-ruxel",
    "tablerock", "parallax", "schemalane", "ruxel", "pg-bigdecimal",
    "velnor-actions-fixture", "github-terraform", "tracing-request-level", "velnor-apt",
    "cloudflare-tofu", "homebrew-velnor", "termpane", "termrock",
    "parallax-telemetry-playground", "homebrew-parallax", "holla",
    "tailrocks-typescript-skills", "tailrocks-skill-authoring-skills", "tailrocks-rust-skills",
    "tailrocks-roadmap-skills", "tailrocks-pull-request-skills", "tailrocks-open-source-skills",
    "tailrocks-macos-skills", "tailrocks-code-quality-skills", "tailrocks-skills",
    "vision", "tui-snap", "terminal-components-claude", "velnor-new",
    "graphql-java-datetime", "jambalaya", "pgquill", "renovate-rust",
    "tailrocks-gradle-conventions", "tailrocks-logo", "tailrocks-sqldiff"
]

missing = []
for repo in mandatory:
    pattern = rf'"{re.escape(repo)}"\s*=\s*\{{'
    if not re.search(pattern, content):
        missing.append(repo)

if missing:
    print(f"FAILED: Missing mandatory repositories in variables.tf: {missing}")
    sys.exit(1)

print(f"SUCCESS: All {len(mandatory)} mandatory TailRocks target repositories are declared.")
EOF

echo "=== 4. Verifying canonical policy invariants in module ==="
python3 - << 'EOF'
import re, sys

with open("modules/repository-policy/main.tf") as f:
    mod = f.read()

def check_pattern(pattern, desc):
    if not re.search(pattern, mod):
        print(f"FAILED invariant: {desc}")
        sys.exit(1)

check_pattern(r'allow_squash_merge\s*=\s*true', "allow_squash_merge = true")
check_pattern(r'allow_merge_commit\s*=\s*false', "allow_merge_commit = false")
check_pattern(r'allow_rebase_merge\s*=\s*false', "allow_rebase_merge = false")
check_pattern(r'squash_merge_commit_title\s*=\s*"PR_TITLE"', "squash_merge_commit_title = PR_TITLE")
check_pattern(r'squash_merge_commit_message\s*=\s*"PR_BODY"', "squash_merge_commit_message = PR_BODY")
check_pattern(r'allow_update_branch\s*=\s*true', "allow_update_branch = true")
check_pattern(r'delete_branch_on_merge\s*=\s*true', "delete_branch_on_merge = true")
check_pattern(r'allowed_merge_methods\s*=\s*\[\s*"squash"\s*\]', "allowed_merge_methods = ['squash']")
check_pattern(r'required_linear_history\s*=\s*true', "required_linear_history = true")
check_pattern(r'deletion\s*=\s*true', "deletion = true")
check_pattern(r'non_fast_forward\s*=\s*true', "non_fast_forward = true")
check_pattern(r'required_review_thread_resolution\s*=\s*true', "required_review_thread_resolution = true")
check_pattern(
    r'strict_required_status_checks_policy\s*=\s*var\.repository_policies\[each\.value\]\.strict_required_status_checks_policy',
    "strict_required_status_checks_policy is configured per repository",
)

assert 'bypass_actors' not in mod, "No bypass_actors allowed on core protection"

print("SUCCESS: All canonical policy invariants verified in modules/repository-policy/main.tf.")
EOF

echo "=== 5. Verifying required checks match live rulesets (config drift guard) ==="
python3 - << 'EOF'
import re, sys

with open("variables.tf") as f:
    content = f.read()

# Every FullRuleset entry must declare required_checks explicitly (possibly empty).
blocks = re.findall(r'"([a-z0-9\-]+)"\s*=\s*\{\s*disposition\s*=\s*"([^"]+)"\s*visibility\s*=\s*"([^"]+)"\s*required_checks\s*=\s*(\[[^\]]*\])', content)
if not blocks:
    print("FAILED: could not parse managed_repositories from variables.tf")
    sys.exit(1)
if len(blocks) != 41:
    print(f"FAILED: parsed {len(blocks)} repositories, expected 41 (field order changed or entries added/removed?)")
    sys.exit(1)

full = [b for b in blocks if b[1] == "FullRuleset"]
print(f"SUCCESS: {len(full)}/{len(blocks)} managed repositories are FullRuleset with explicit required_checks.")

self_repo = next((b for b in blocks if b[0] == "github-terraform"), None)
if self_repo is None:
    print("FAILED: github-terraform is missing from managed_repositories")
    sys.exit(1)
self_checks = re.findall(r'"([^"]+)"', self_repo[3])
if self_checks != ["DCO", "Required"]:
    print(f"FAILED: github-terraform required_checks={self_checks}, expected ['DCO', 'Required']")
    sys.exit(1)

if not re.search(r'strict_required_status_checks_policy\s*=\s*optional\(bool,\s*true\)', content):
    print("FAILED: strict_required_status_checks_policy must default to true for existing repository entries.")
    sys.exit(1)

repo_bodies = re.findall(r'"([a-z0-9\-]+)"\s*=\s*\{([^{}]*)\}', content)
strict_false_repositories = [
    name
    for name, body in repo_bodies
    if re.search(r'strict_required_status_checks_policy\s*=\s*false', body)
]
if strict_false_repositories != ["github-terraform"]:
    print(f"FAILED: only github-terraform may disable strict freshness; found {strict_false_repositories}")
    sys.exit(1)

with open("checks.tf") as f:
    checks = f.read()
if not re.search(
    r'var\.managed_repositories\["github-terraform"\]\.required_checks\s*==\s*tolist\(\s*\["DCO"\s*,\s*"Required"\]\s*\)',
    checks,
):
    print("FAILED: github-terraform required_checks invariant must compare list values with tolist().")
    sys.exit(1)
if not re.search(
    r'policy\.strict_required_status_checks_policy\s*==\s*\(name\s*!=\s*"github-terraform"\)',
    checks,
):
    print("FAILED: Terraform must preserve strict freshness for every repository except github-terraform.")
    sys.exit(1)

print("SUCCESS: github-terraform alone uses current-head checks and requires DCO, Required, and resolved threads.")
EOF

echo "=== 6. Live GitHub audit (opt-in: LIVE_AUDIT=1) ==="
if [ "${LIVE_AUDIT:-0}" != "1" ]; then
  echo "SKIPPED: set LIVE_AUDIT=1 to audit live rulesets, visibility, and checks via gh API."
else
  python3 - << 'EOF'
import json, re, subprocess, sys

with open("variables.tf") as f:
    content = f.read()

blocks = re.findall(r'"([a-z0-9\-]+)"\s*=\s*\{\s*disposition\s*=\s*"([^"]+)"\s*visibility\s*=\s*"([^"]+)"\s*required_checks\s*=\s*(\[[^\]]*\])', content)
if len(blocks) != 41:
    print(f"FAILED: parsed {len(blocks)} repositories, expected 41 (field order changed or entries added/removed?)")
    sys.exit(1)
repos = {
    name: {
        "disposition": d,
        "visibility": v,
        "checks": set(re.findall(r'"([^"]+)"', checks)),
        "strict": name != "github-terraform",
    }
    for name, d, v, checks in blocks
}

def gh(*args):
    out = subprocess.run(["gh", "api", *args], capture_output=True, text=True)
    if out.returncode != 0:
        print(f"FAILED: gh api {' '.join(args)}: {out.stderr.strip()[:200]}")
        sys.exit(1)
    return json.loads(out.stdout)

failures = []
for name, want in sorted(repos.items()):
    if want["disposition"] != "FullRuleset":
        continue
    repo = gh(f"repos/tailrocks/{name}", "--jq", "{visibility}")
    if repo["visibility"] != want["visibility"]:
        failures.append(f"{name}: visibility live={repo['visibility']} want={want['visibility']}")
    rulesets = gh(f"repos/tailrocks/{name}/rulesets")
    main = next((r for r in rulesets if r["name"] == "protect-main"), None)
    tags = next((r for r in rulesets if r["name"] == "protect-tags"), None)
    if main is None or tags is None:
        failures.append(f"{name}: missing protect-main or protect-tags ruleset")
        continue
    if tags.get("enforcement") != "active":
        failures.append(f"{name}: protect-tags enforcement={tags.get('enforcement')}")
    detail = gh(f"repos/tailrocks/{name}/rulesets/{main['id']}")
    if detail["enforcement"] != "active":
        failures.append(f"{name}: protect-main enforcement={detail['enforcement']}")
    pr = next((r for r in detail["rules"] if r["type"] == "pull_request"), None)
    if not pr or pr["parameters"].get("required_review_thread_resolution") is not True:
        failures.append(f"{name}: thread resolution not enforced")
    status_rules = [r for r in detail["rules"] if r["type"] == "required_status_checks"]
    live_checks = {
        check["context"]
        for rule in status_rules
        for check in rule["parameters"].get("required_status_checks", [])
    }
    if live_checks != want["checks"]:
        failures.append(f"{name}: checks live={sorted(live_checks)} want={sorted(want['checks'])}")
    if name == "github-terraform" and live_checks != {"DCO", "Required"}:
        failures.append(f"github-terraform: live required checks={sorted(live_checks)} want=['DCO', 'Required']")
    if want["checks"] and any(
        rule["parameters"].get("strict_required_status_checks_policy") is not want["strict"]
        for rule in status_rules
    ):
        live_strict = [rule["parameters"].get("strict_required_status_checks_policy") for rule in status_rules]
        failures.append(f"{name}: strict_required_status_checks_policy live={live_strict} want={want['strict']}")

if failures:
    print("FAILED live audit:")
    for f in failures:
        print(f"  - {f}")
    sys.exit(1)
empty = sum(1 for r in repos.values() if r["disposition"] == "FullRuleset" and not r["checks"])
print(f"INFO: {empty} FullRuleset repositories have empty required_checks (drift guard only, not a posture audit).")
print(f"SUCCESS: live audit passed for {sum(1 for r in repos.values() if r['disposition']=='FullRuleset')} FullRuleset repositories.")
EOF
fi

echo "=== 7. Verifying cross-root shared module parity ==="
if [ -d "../jackin-github-terraform/modules/repository-policy" ]; then
  HASH_LOCAL=$(sha256sum modules/repository-policy/main.tf | awk '{print $1}')
  HASH_JACKIN=$(sha256sum ../jackin-github-terraform/modules/repository-policy/main.tf | awk '{print $1}')
  if [ "$HASH_LOCAL" != "$HASH_JACKIN" ]; then
    echo "FAILED: Module main.tf diverged from jackin shared module!"
    exit 1
  fi
  echo "SUCCESS: 100% cryptographic SHA-256 byte-for-byte parity with jackin module."
fi

echo "=== ALL VERIFICATIONS PASSED ==="
