<!--
PR body rules:
- One paragraph per section, no hard-wrap (GitHub flows the text).
- Explain the shipped feature shape, not every implementation detail.
- No design rationale narration here — link out to a contributor doc instead.
- No file-by-file changelog (use the diff). No full check list (use CI output).
- Every Verify-locally command is copy-pasteable and states its expected
  outcome when a bare exit code does not disambiguate pass from fail.
- Drop the headings you do not need. "Related pull requests" is only when the
  PR spans multiple repos (for example coordinated parity changes across the
  github-terraform repos). "Behavior changes" is only when it adds signal
  beyond "What ships". "Not included" is only when scope boundaries or
  deferred work are useful to call out.
-->

## Related pull requests

<When this PR is part of a coordinated set spanning multiple repositories, list every PR here — just the link, no description. Drop this section entirely when the PR stands alone.>

- <https://github.com/org/repo/pull/N>

## Summary

<One paragraph answering: what is this pull request for? Name the shipped change to organization or repository management, who runs it, and how it changes their flow. Keep this short.>

## What ships

<Feature-level bullets grouped by operator-visible outcome: repositories onboarded, policy enforced, provider or wiring changes, documentation changes. Avoid resource names and file lists — the diff already shows those.>

- <Capability or policy that now exists>
- <Configuration, documentation, or workflow change operators can rely on>

## Behavior changes

<Operator-visible deltas: changed required checks, changed merge settings, changed token or permission requirements, changed runbook steps. Drop this section when it would only repeat "What ships".>

- <Existing behavior that changes>

## What this addresses

<Bullets naming the practical problem, drift, or operational pain now resolved. Name the issue when one exists.>

- <Problem or gap addressed>

## Not included

<Scope boundaries and deferred work: repositories not yet onboarded, follow-up PRs, policy left unchanged deliberately. Drop this section entirely when nothing meaningful is excluded.>

- <Out-of-scope behavior or deferred follow-up>

## Verify locally

### Checkout

```sh
gh pr checkout <PR_NUMBER>
```

### Static checks

<The format and validate gates, exactly as CI runs them in the tofu-workspace job. Expected: `tofu validate` prints "Success! The configuration is valid.">

```sh
tofu fmt -check -recursive
tofu init -backend=false -input=false -lockfile=readonly
tofu validate -no-color
```

### Smoke

<Include when the PR changes plan-visible behavior: repositories, rulesets, org settings, providers. Drop when the PR only touches docs or comments. Requires GITHUB_TOKEN exported with org admin on tailrocks and Administration: write on every managed repository.>

```sh
tofu plan -no-color
```

Expected: <the plan renders with no provider or permission errors; name the key actions the reviewer should see, or "No changes" when the PR is already applied>.

## Migration notes

<One paragraph naming what operators must do — token permission changes, state moves, re-imports. "None." is fine. Drop the section when it would only say that.>
