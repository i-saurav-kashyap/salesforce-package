#!/usr/bin/env bash
# Creates a NON-NAMESPACED, customer-like scratch org and installs a package version
# exactly the way a subscriber would. Nothing from your local source is pushed here.
#
#   ./scripts/create-install-test-org.sh 04tXXXXXXXXXXXXXXX [installation-key]
set -euo pipefail
VERSION_ID="${1:?usage: create-install-test-org.sh <04t package version id> [key]}"
KEY="${2:-}"
ALIAS="customer1"

sf org create scratch \
  --definition-file config/customer-like-scratch-def.json \
  --alias "$ALIAS" --duration-days 2 --no-namespace

if [ -n "$KEY" ]; then
  sf package install --package "$VERSION_ID" --installation-key "$KEY" \
    --target-org "$ALIAS" --wait 20 --publish-wait 20 --no-prompt
else
  sf package install --package "$VERSION_ID" \
    --target-org "$ALIAS" --wait 20 --publish-wait 20 --no-prompt
fi

sf package installed list --target-org "$ALIAS"
sf org open --target-org "$ALIAS"
