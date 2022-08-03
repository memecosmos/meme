#!/bin/bash
# init_two_chainz_relayer creates two memed chains and configures the relayer

SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
WASMD_DATA="$(pwd)/data"
RELAYER_CONF="$(pwd)/.relayer"

# Ensure relayer is installed
if ! [ -x "$(which rly)" ]; then
  echo "Error: memed is not installed. Try running 'make build-memed'" >&2
  exit 1
fi

# Ensure memed is installed
if ! [ -x "$(which memed)" ]; then
  echo "Error: memed is not installed. Try running 'make build-memed'" >&2
  exit 1
fi

# Display software version for testers
echo "WASMD VERSION INFO:"
memed version --long

# Ensure jq is installed
if [[ ! -x "$(which jq)" ]]; then
  echo "jq (a tool for parsing json in the command line) is required..."
  echo "https://stedolan.github.io/jq/download/"
  exit 1
fi

# Delete data from old runs
rm -rf $WASMD_DATA &> /dev/null
rm -rf $RELAYER_CONF &> /dev/null

# Stop existing memed processes
killall memed &> /dev/null

set -e

chainid0=ibc-0
chainid1=ibc-1

echo "Generating memed configurations..."
mkdir -p $WASMD_DATA && cd $WASMD_DATA && cd ../
./one_chain.sh memed $chainid0 ./data 26657 26656 6060 9090
./one_chain.sh memed $chainid1 ./data 26557 26556 6061 9091

[ -f $WASMD_DATA/$chainid0.log ] && echo "$chainid0 initialized. Watch file $WASMD_DATA/$chainid0.log to see its execution."
[ -f $WASMD_DATA/$chainid1.log ] && echo "$chainid1 initialized. Watch file $WASMD_DATA/$chainid1.log to see its execution."


echo "Generating rly configurations..."
rly config init
rly config add-chains configs/memed/chains
rly config add-paths configs/memed/paths

SEED0=$(jq -r '.mnemonic' $WASMD_DATA/ibc-0/key_seed.json)
SEED1=$(jq -r '.mnemonic' $WASMD_DATA/ibc-1/key_seed.json)
echo "Key $(rly keys restore ibc-0 testkey "$SEED0") imported from ibc-0 to relayer..."
echo "Key $(rly keys restore ibc-1 testkey "$SEED1") imported from ibc-1 to relayer..."
echo "Creating light clients..."
sleep 3
rly light init ibc-0 -f
rly light init ibc-1 -f
