# 1GP learning project

This is the SAME core application, prepared for the first-generation managed package
exercise. Differences from `../packages/core`:

* **No `namespace` key in `sfdx-project.json`.** In 1GP the namespace lives in the
  packaging org, and the org applies it on deploy. Your local source stays unprefixed.
* **No package definition in the project.** The package is defined in the packaging
  org's UI (Setup -> Package Manager), not in this file. That is the whole point of
  1GP: the org is the source of truth and this folder is only a delivery mechanism.

## Deploy into the packaging org

    sf project deploy start --source-dir force-app --target-org pkgorg
    sf apex run test --target-org pkgorg --code-coverage --result-format human

Then continue in the packaging org UI: add components to the package and upload a version.
