#!/bin/bash
set -o errexit -o nounset -o pipefail

PASSWORD=${PASSWORD:-1234567890}
STAKE=${STAKE_TOKEN:-ustake}
FEE=${FEE_TOKEN:-ucosm}
CHAIN_ID=${CHAIN_ID:-testing}
MONIKER=${MONIKER:-node001}

memed init --chain-id "$CHAIN_ID" "$MONIKER"
# staking/governance token is hardcoded in config, change this
## OSX requires: -i.
sed -i. "s/\"stake\"/\"$STAKE\"/" "$HOME"/.memed/config/genesis.json
if ! memed keys show validator; then
  (
    echo "$PASSWORD"
    echo "$PASSWORD"
  ) | memed keys add validator
fi
# hardcode the validator account for this instance
echo "$PASSWORD" | memed add-genesis-account validator "1000000000$STAKE,1000000000$FEE"
# (optionally) add a few more genesis accounts
for addr in "$@"; do
  echo "$addr"
  memed add-genesis-account "$addr" "1000000000$STAKE,1000000000$FEE"
done
# submit a genesis validator tx
## Workraround for https://github.com/cosmos/cosmos-sdk/issues/8251
(
  echo "$PASSWORD"
  echo "$PASSWORD"
  echo "$PASSWORD"
) | memed gentx validator "250000000$STAKE" --chain-id="$CHAIN_ID" --amount="250000000$STAKE"
## should be:
# (echo "$PASSWORD"; echo "$PASSWORD"; echo "$PASSWORD") | memed gentx validator "250000000$STAKE" --chain-id="$CHAIN_ID"
memed collect-gentxs
