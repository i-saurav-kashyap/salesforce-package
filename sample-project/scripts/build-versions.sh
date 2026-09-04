#!/usr/bin/env bash
# Builds BETA versions of both packages, in dependency order.
# Core must exist as a version before Field Ops can be built against it.
set -euo pipefail
KEY="${1:-LearnPackaging123}"

echo "==> Building Ops Toolkit Core"
sf package version create \
  --package "Ops Toolkit Core" \
  --installation-key "$KEY" \
  --code-coverage --wait 30

echo "==> Building Ops Toolkit Field Ops (resolves the Core dependency)"
sf package version create \
  --package "Ops Toolkit Field Ops" \
  --installation-key "$KEY" \
  --code-coverage --wait 40

echo "==> Version list"
sf package version list --verbose

echo
echo "Remember: sfdx-project.json packageAliases changed. Commit it."
