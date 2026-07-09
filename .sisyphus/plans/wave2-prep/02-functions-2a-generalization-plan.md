# Artifact 02 — Functions 2A Generalization Edit Plan

**Wave**: Wave 2 Subwave 2A — generalize Functions `cross-guide-baseline.md` before promoting into Architecture
**Status**: Design (pre-implementation)
**Blocked on**: P5 baseline conformance PR for Functions (Functions#69)
**Downstream dependency**: Subwave 2B (Architecture promotion PR) is blocked on THIS artifact landing first
**Owns**: One PR in `azure-functions-practical-guide` (in-place generalization)

## Related issues

- **[azure-functions-practical-guide#71](https://github.com/yeongseon/azure-functions-practical-guide/issues/71)** — Generalize `cross-guide-baseline.md` for series-wide adoption
- **[azure-architecture-practical-guide#43](https://github.com/yeongseon/azure-architecture-practical-guide/issues/43)** — Downstream: promote generalized baseline into Architecture as `docs/contributing/language-guide-baseline.md`

## Executive summary

Functions' [`docs/contributing/cross-guide-baseline.md`](../../../../azure-functions-practical-guide/docs/contributing/cross-guide-baseline.md) (414 lines) is the mature reference for how the four language-guide subdirectories (`python/`, `nodejs/`, `java/`, `dotnet/`) are structured. Wave 2 promotes this file into `azure-architecture-practical-guide/docs/contributing/` as the **series-wide language-guide baseline**, so that Container Apps (which has an identical 4-language structure) and any future 코드형 sibling can adopt it as a stable, cross-repo contract.

The file cannot be promoted as-is. It contains **Functions-specific language** (references to Azure Functions Core Tools, host.json, v2/v4/isolated-worker programming model names, MSLearn Functions URLs) that would be nonsensical in a series-wide baseline. This artifact enumerates every Functions-specific mention with a proposed generalized replacement.

**Total edits: 8 Functions-specific mentions + 24 language-guide references to generalize + 1 heading rewrite.**

After generalization, the file should:

- Talk about *language guides* and *reference language*, not specifically Functions.
- Reference no product-specific tooling by name in mandatory patterns (Core Tools, host.json).
- Cite series-neutral MSLearn URLs OR omit the Sources section entirely (per Architecture's Sources rule — allowed to omit if none exist).
- Still be readable as a normative baseline that a repo owner can point their language-guide contributors at.

## Scope: files affected in Functions PR

Only ONE file is modified in the Functions PR:

- `docs/contributing/cross-guide-baseline.md`

`mkdocs.yml` is not touched (the file stays at the same path). The Architecture promotion (Subwave 2B) copies the generalized version into a new file — no rename in Functions.

---

## Edit inventory

### Group A — Frontmatter Sources (lines 2-9)

**Lines 2-10** — `content_sources.references` list currently cites 3 Functions MSLearn URLs.

Current:

```yaml
content_sources:
  references:
    - type: mslearn-adapted
      url: https://learn.microsoft.com/en-us/azure/azure-functions/supported-languages
    - type: mslearn-adapted
      url: https://learn.microsoft.com/en-us/azure/azure-functions/functions-reference
    - type: mslearn-adapted
      url: https://learn.microsoft.com/en-us/azure/azure-functions/functions-best-practices
```

Proposed:

```yaml
content_sources:
  references:
    - type: self-generated
      justification: "Series-wide language-guide baseline. No direct Microsoft Learn source; synthesized from repeated language-guide practice across Functions, Container Apps, and App Service sibling repos."
```

Rationale: A series-wide baseline is by definition original repo-editorial content, not adapted from a single MSLearn page. Marking it `self-generated` with a documented justification is honest to Architecture's `content_sources` schema.

### Group B — Diagram (lines 20-38)

**Lines 20-38** — mermaid diagram literally names Python, Node.js, Java, .NET and the source document as "Cross-Guide Baseline".

Current node names:

```
Baseline → Python (reference implementation), NodeJS, Java, DotNet
Python -.->|template for| NodeJS
Python -.->|template for| Java
Python -.->|template for| DotNet
```

Proposed generalization:

```
Baseline → Reference Language, Language B, Language C, Language D
Reference Language -.->|template for| Language B
Reference Language -.->|template for| Language C
Reference Language -.->|template for| Language D
```

with a note under the diagram explaining that "Reference Language" is a per-repo choice (Python for Functions and Container Apps; Node.js could be the reference for a future TypeScript-centric repo). Diagram color scheme (Microsoft brand palette) is preserved.

**diagram-id comment**: line 20 already carries `<!-- diagram-id: why-this-baseline-exists -->` — keep as-is, the diagram's *purpose* is unchanged.

### Group C — Canonical file tree (lines 40-83)

**Lines 42-83** — the file tree hardcodes `48 files per language guide` and specific filenames like `host-json.md` and `platform-limits.md` that are Functions-specific.

Edits:

| Line | Current | Proposed |
|---:|---|---|
| 42 | `Every language guide (\`docs/language-guides/{lang}/\`) MUST contain the following files:` | `Every language guide (\`docs/language-guides/{lang}/\`) SHOULD contain the following files. Individual repos MAY omit or extend based on service-specific needs.` |
| 44-83 | Full file tree | Keep the tree BUT split into "core files" (index, tutorial/, recipes/, CLI cheatsheet, environment-variables, troubleshooting) and "service-specific files" (host-json — Functions only; add note that Container Apps uses `container-image-basics.md` instead) |
| 78 | `host-json.md                          # host.json configuration reference` | Move under "Service-specific files" subsection with note: `Functions only. Container Apps equivalent: container image configuration reference.` |
| 82 | `platform-limits.md                    # Quotas, timeouts, instance limits` | Reword: `service-limits.md                    # Service quotas, timeouts, instance limits — filename SHOULD align with service naming` |
| 85 | `**Total: 48 files per language guide.**` | Delete this line — series-wide total depends on how many service-specific files each repo includes. Replace with: `**Baseline: ~40 shared files per language guide + service-specific files at the repo owner's discretion.**` |

### Group D — Programming model naming (lines 88-94)

**Lines 88-94** — table hardcodes the four Functions programming-model names.

Current:

```
| Python  | v2-programming-model.md            | v2 decorator model      |
| Node.js | v4-programming-model.md            | v4 code-first model     |
| Java    | annotation-programming-model.md    | Annotation-based model  |
| .NET    | isolated-worker-model.md           | Isolated worker model   |
```

Proposed generalization: keep the table BUT reframe as "Example — Functions programming-model file naming":

- Add heading above the table: `### Example — Functions programming-model file naming`
- Add a paragraph before the table: `The programming-model file captures the language's currently-recommended way of authoring code in the service. Each repo picks the file name; the table below is the Functions example.`
- Add a note after the table: `For services without a distinct "programming model" concept (e.g., Container Apps runs any long-running process, no framework-imposed model), this file MAY be replaced by a service-specific concept doc such as \`container-startup.md\` or \`entrypoint-conventions.md\`.`

Do NOT delete the Functions table — it stays as the canonical worked example. This is the "reference implementation stays as demonstrator" pattern used throughout the file.

### Group E — Runtime file naming (lines 96-103)

**Lines 96-103** — small table listing per-language runtime filenames.

Similar treatment to Group D: reframe as "Example — Functions runtime file naming", add a note that services without a distinct "runtime" concept (Container Apps: the runtime is whatever the container image provides) MAY omit this file.

### Group F — Tutorial heading skeleton (lines 105-146)

**Lines 105-146** — heading skeleton for tutorials 01-07.

Two Functions-specific tokens in the Prerequisites table example (lines 118-122):

| Line | Current | Proposed |
|---:|---|---|
| 121 | `\| Azure Functions Core Tools \| v4 \| Local host and deployment \|` | Remove this row. Replace the whole Prerequisites table with a generic 2-row example: `\| {Language runtime} \| {version}+ \| Local runtime \| ` and `\| Azure CLI \| 2.61+ \| Provision and configure resources \|`. Add a note under the table: `Repos SHOULD add service-specific tooling rows (e.g., Core Tools for Functions, dev-tunnel for Container Apps).` |
| 126 | `Brief description of the function, trigger, and expected local validation result.` | Reword: `Brief description of the code artifact (function, endpoint, worker, job — whatever the service unit of deployment is), the interaction pattern (HTTP, trigger, message, schedule), and the expected local validation result.` |

### Group G — Tutorial-index requirements (lines 148-156)

**Lines 148-156** — `Tutorial Plan Chooser` section, item 1 mandates a mermaid flowchart, item 2 mandates a "plan comparison table" that references the four Functions plans (Consumption, Flex Consumption, Premium, Dedicated).

Proposed generalization:

- Item 2 currently: `Plan comparison table — features (scale-to-zero, VNet, slots, instances, timeout, memory, OS, pricing) across all four plans`
- Reword to: `Plan / SKU / tier comparison table — features across the deployment options the service exposes. For Functions this is the four plans. For Container Apps this is Consumption vs Dedicated workload profiles. For App Service this is App Service Plan tiers. The concept is a "deployment-option decision surface"; the specific dimensions are service-dependent.`

Item 3 (`Tutorial track tables — one table per plan listing all 7 steps with links`) is also Functions-plan-shaped. Reword to: `Tutorial track tables — one table per deployment option, listing tutorial step files with links. The number of steps (Functions uses 7, other repos MAY use fewer) is service-dependent.`

### Group H — See Also patterns (lines 267-317)

**Lines 267-317** — See Also link patterns for tutorials, index pages, model/runtime pages, and recipe pages.

Line 278 currently: `- [Platform: Hosting Plans](../../../../platform/hosting.md)` — "Hosting Plans" is Functions vocabulary.

Proposed: `- [Platform: Hosting Model / Deployment Model](../../../../platform/hosting.md)` — allow either wording per-service.

Line 316 currently: `- [Platform: Triggers and Bindings](../../../platform/triggers-and-bindings.md)` — "Triggers and Bindings" is Functions vocabulary.

Proposed: reword to a service-neutral integration-pattern link: `- [Platform: Integration Patterns](../../../platform/integration-patterns.md)` — with a note that services with distinct trigger/binding vocabulary MAY substitute the specific term.

### Group I — mkdocs.yml nav pattern (lines 319-379)

**Lines 319-379** — the Functions-shaped mkdocs.yml nav pattern hardcodes:

- Line 328-346: Tutorial section with per-plan sub-nav (Consumption / Flex Consumption / Premium / Dedicated) — Functions plan vocabulary.
- Line 341-345: `Flex Consumption (FC1)` — Functions SKU code.

Proposed: keep the pattern BUT reframe as "Example — Functions nav pattern" and add a version-2 pattern for `Container Apps` (Consumption vs Dedicated only). Two worked examples make the abstract pattern clear.

### Group J — Placeholder replacement table (lines 371-379)

**Lines 371-379** — `Language-Specific Values` table hardcodes Functions programming-model file names.

Same treatment as Groups D and E: reframe as "Example — Functions placeholder values".

### Group K — Consistency review checklist (lines 381-399)

**Lines 381-399** — 15-item consistency checklist.

Two Functions-specific items:

| Item # | Current | Proposed |
|---:|---|---|
| 1 | `All 48 files present per the canonical file tree` | `All baseline files present per the canonical file tree (service-specific extensions per repo)` |
| 11 | `All tutorials follow the heading skeleton (Prerequisites → What You'll Build → Steps → Verification → Next Steps → See Also → Sources)` | Keep as-is (heading skeleton IS series-wide) |

### Group L — See Also references (lines 401-408)

**Lines 401-408** — See Also section at the bottom of the file references four Functions language guides.

Current:

```
- [Python Language Guide (reference implementation)](../language-guides/python/index.md)
- [Node.js Language Guide](../language-guides/nodejs/index.md)
- [Java Language Guide](../language-guides/java/index.md)
- [.NET Language Guide](../language-guides/dotnet/index.md)
```

Proposed for the Architecture-promoted copy: replace with links to the reference implementations in each sibling repo:

```
- Container Apps: [Language Guides](https://yeongseon.github.io/azure-container-apps-practical-guide/language-guides/) — 4-language reference implementation
- Functions: [Language Guides](https://yeongseon.github.io/azure-functions-practical-guide/language-guides/) — 4-language × 4-plan matrix
- App Service: [Language Guides](https://yeongseon.github.io/azure-app-service-practical-guide/language-guides/) — 4-language reference implementation
```

For the Functions in-place copy (this PR): keep the current See Also as-is; Functions is the reference implementation for the Functions file.

### Group M — Sources (lines 410-414)

**Lines 410-414** — three MSLearn Functions URLs.

For the Functions in-place copy: keep as-is.

For the Architecture-promoted copy (Subwave 2B): delete `## Sources` entirely per Architecture's rule ("Sources is required only when external references are cited. Omit if none exist"). A self-generated baseline has no external sources.

---

## Two-pass execution model

Because the same file needs to end up in two states (Functions in-place: still Functions-native but with generalized *pattern* content; Architecture promoted: fully generalized including See Also and Sources), execution is a two-step:

### Pass 1 — Functions PR (this artifact)

Apply Groups A-K in place. Groups L and M stay Functions-shaped. Result: the Functions file becomes a "generalized-pattern-with-Functions-worked-examples" document. Functions users still see Functions-flavored language in See Also and Sources.

### Pass 2 — Architecture promotion (Subwave 2B, out of scope for this artifact)

Copy the Pass 1 output into `azure-architecture-practical-guide/docs/contributing/language-guide-baseline.md`. Apply Groups L and M (rewrite See Also to sibling-repo links; delete Sources). Add Architecture-specific frontmatter and `content_sources`. Rename to `language-guide-baseline.md` (Architecture doesn't use the "cross-guide" prefix — that's Functions-specific vocabulary for "cross the four Functions language directories").

## Verification checklist (Pass 1 completion)

- [ ] No occurrence of `Functions Core Tools` in normative pattern text (may appear only inside "Example — Functions ..." blocks).
- [ ] No occurrence of `host.json` in normative pattern text (may appear only inside "Example — Functions ..." blocks).
- [ ] No occurrence of Functions programming-model names (`v2-programming-model`, `v4-programming-model`, `annotation-programming-model`, `isolated-worker-model`) in normative pattern text.
- [ ] No occurrence of Functions plan names (`Consumption`, `Flex Consumption`, `Premium`, `Dedicated`) in normative pattern text.
- [ ] Every "Example — Functions ..." block has a companion note pointing at at least one other sibling repo's equivalent.
- [ ] The 15-item consistency checklist still reads as actionable (nothing broken by generalization).
- [ ] `mkdocs build --strict` passes in Functions repo with zero warnings.
- [ ] Diff `wc -l cross-guide-baseline.md` before/after — Pass 1 SHOULD add 30-60 lines (worked examples + notes take space), not lose lines.

## Verification checklist (Pass 2 downstream check)

Not owned by this artifact, but for reference:

- [ ] Pass 2 file has no Functions-specific vocabulary outside "Example — Functions ..." blocks.
- [ ] Pass 2 file's Sources section is deleted OR contains only series-neutral references.
- [ ] Pass 2 file is renamed to `language-guide-baseline.md`.

## Out of scope

- Editing Container Apps' language-guide files to match the generalized baseline (that would be a Wave 3 conformance effort — not in Wave 2 scope).
- Editing Functions' `docs/language-guides/*/` files (they already conform to the pre-generalization file; no downstream churn from this edit).
- Amending the series nav contract to reference `language-guide-baseline.md` (may be a follow-up in Wave 3; not this artifact).
- Adding a `content_validation` block — the promoted Architecture file will be `self-generated` and out of scope per `scripts/lib/content_scope.py` in Container Apps (Architecture uses its own content-validation scoping).

## References

- Functions cross-guide-baseline.md: [`docs/contributing/cross-guide-baseline.md`](../../../../azure-functions-practical-guide/docs/contributing/cross-guide-baseline.md) (414 lines, verified 2026-07-09)
- Wave 2 meta: [architecture#42](https://github.com/yeongseon/azure-architecture-practical-guide/issues/42)
- Series Nav Contract v1.1: [`docs/contributing/series-nav-contract.md`](../../../docs/contributing/series-nav-contract.md)
- Downstream child issue: [architecture#43](https://github.com/yeongseon/azure-architecture-practical-guide/issues/43)
