#!/usr/bin/env bash
# Creates a NAMESPACED scratch org for day-to-day development and pushes source into it.
# Namespaced because we want to see our own prefixes while we build.
set -euo pipefail
ALIAS="${1:-dev1}"
DAYS="${2:-7}"

sf org create scratch \
  --definition-file config/project-scratch-def.json \
  --alias "$ALIAS" --duration-days "$DAYS" --set-default

sf project deploy start --target-org "$ALIAS"

sf org assign permset --name Ops_Core_User --name Ops_Field_Ops_User --target-org "$ALIAS"
sf apex run --file scripts/apex/seed-data.apex --target-org "$ALIAS"

echo "Scratch org $ALIAS ready."
sf org open --target-org "$ALIAS"
