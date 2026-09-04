# Salesforce AppExchange From Zero

A self-contained course + working code scaffold that takes you from an empty laptop to a
managed package a customer can install and upgrade — in **both** packaging generations.

## Open the site

```bash
# Preferred: Copy buttons need a local server (file:// is not a secure context)
cd /Users/saurav.k/Desktop/salesforce-package
python3 -m http.server
# then open http://localhost:8000

# Also works offline as files, with weaker clipboard support
open /Users/saurav.k/Desktop/salesforce-package/index.html
```

Everything is static HTML with no external requests, so it works offline.

Start on **index.html → Stage 0**, and do not move to the next stage until that stage's
verification checklist passes. Checkboxes on the pages persist in your browser.

## What's here

```
salesforce-package/
├── index.html … 20-quiz.html   ← the generated course site (21 pages)
├── content/                    ← page sources (edit these, not the built HTML)
├── assets/site.css, site.js    ← shared styling + copy buttons + checkbox persistence
├── build.py                    ← regenerates the site:  python3 build.py
└── sample-project/             ← the real DX project the course builds
    ├── sfdx-project.json           two 2GP packages, one dependency, namespace
    ├── config/                     dev + customer-like scratch org definitions
    ├── scripts/                    create-dev-org, create-install-test-org, build-versions
    ├── packages/core/              PACKAGE A: object, fields, CMDT, labels, Apex, permset, tab
    ├── packages/field-ops/         PACKAGE B: LWC, controller, Lightning app, permset (depends on A)
    ├── 1gp/                        the same core app prepared for a 1GP packaging org
    └── .github/workflows/          PR validation + package build/install/promote pipelines
```

## Page map

| Page | Covers |
| --- | --- |
| `index.html` | Architecture, minimum + professional org setup, **Stage 0 exercise** |
| `01-big-picture` | Every term defined; ID prefixes; which orgs belong to which generation |
| `02-orgs` | Org-by-org: who creates/owns it, auth, lifetime, what breaks if it's lost |
| `03-prereqs` | Salesforce, local and knowledge prerequisites |
| `04-the-app` | The Ops Toolkit application, why each component type is included, full source |
| `05-1gp` / `06-1gp-lifecycle` | 1GP concepts (19 questions) and the full build→release→upgrade loop |
| `07-2gp` / `08-2gp-build` | 2GP concepts and the same app as a 2GP, command by command |
| `09-scratch-orgs` | Definitions, namespaced vs not, source tracking, lifecycle |
| `10-compare` | 1GP vs 2GP table + plain-English differences + the migration question |
| `11-dependencies` | A→B→C in 2GP, the 1GP→2GP scenario, dependency graphs, CLI inspection |
| `12-install` | Install internals, the seven install tests, upgrade behaviour per component |
| `13-security` | Security Review requirements, a deliberately vulnerable class, readiness checklist |
| `14-cicd` | JWT auth, two working GitHub Actions workflows, branch/version strategy |
| `15-appexchange` | Package vs solution vs listing vs installation; the publishing path |
| `16-day-plan` | The 14-day plan with per-day verification |
| `17-debugging` | 30 failure drills: error → think first → root cause → investigate → fix → prevention |
| `17b-error-index` | Symptom→cause lookup tables, diagnostic playbooks, debug-log reading, subscriber-org debugging, governor limits |
| `18-backend` | What each command does internally, marked Documented / Inference / Verify |
| `19-commands` | Command → purpose → org → expected result cheat sheet |
| `20-quiz` | Escalating architect-level questions |

## Editing

Edit files in `content/`, then:

```bash
python3 build.py
```

Authoring helpers inside content fragments:

- `[[code bash]] … [[/code]]` — escaped code block with a copy button
- `[[diagram]] … [[/diagram]]` — escaped ASCII diagram
- `[[file sample-project/path/to/File.cls apex]]` — embeds a real file from the scaffold

## Accuracy convention

Every non-obvious claim is tagged:

- **Documented** — published Salesforce behaviour
- **Inference** — reasonable conclusion from observable behaviour, not Salesforce's words
- **Verify** — not publicly exposed, edition-specific, or changes often; check current docs

Salesforce changes packaging behaviour between releases. Confirm anything you are about to
rely on in production against the current
[ISVforce / Packaging guides](https://developer.salesforce.com/docs/atlas.en-us.packagingGuide.meta/packagingGuide/)
and [Salesforce DX Developer Guide](https://developer.salesforce.com/docs/atlas.en-us.sfdx_dev.meta/sfdx_dev/).
