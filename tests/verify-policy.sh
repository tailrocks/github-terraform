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
    "vision", "tui-snap"
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

assert 'bypass_actors' not in mod, "No bypass_actors allowed on core protection"

print("SUCCESS: All canonical policy invariants verified in modules/repository-policy/main.tf.")
EOF

echo "=== 5. Verifying cross-root shared module parity ==="
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
