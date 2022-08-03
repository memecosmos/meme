#!/bin/bash
set -o errexit -o nounset -o pipefail

BASE_ACCOUNT=$(memed keys show validator -a)
memed q account "$BASE_ACCOUNT" -o json | jq

echo "## Add new account"
memed keys add fred

echo "## Check balance"
NEW_ACCOUNT=$(memed keys show fred -a)
memed q bank balances "$NEW_ACCOUNT" -o json || true

echo "## Transfer tokens"
memed tx bank send validator "$NEW_ACCOUNT" 1ustake --gas 1000000 -y --chain-id=testing --node=http://localhost:26657 -b block -o json | jq

echo "## Check balance again"
memed q bank balances "$NEW_ACCOUNT" -o json | jq
