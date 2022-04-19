## MeMe Chain
![c11](https://raw.githubusercontent.com/MeMeCosmos/assetlists/main/logo/meme-banner.svg)


### How to Join MeMe Mainnet


### Recommended system setup

- 4 core CPU
- Memory: 4GB
- Disk: 100GB 
- Ubuntu 20.04


## Setup Guidelines


#### 1. Prerequisites
```bash:
# update the local package list and install any available upgrades 
sudo apt-get update && sudo apt upgrade -y 

# install toolchain and ensure accurate time synchronization 
sudo apt-get install make chrony build-essential gcc git jq  -y
```

#### 2. Install Go
Follow the instructions [here](https://golang.org/doc/install) to install Go.

Alternatively, for Ubuntu LTS, you can do:
```bash:

wget -q -O - https://git.io/vQhTU | bash -s -- --version 1.17.8
source ~/.bashrc

```

Unless you want to configure in a non standard way, then set these in the `.profile` in the user's home (i.e. `~/`) folder.

```bash:
cat <<EOF >> ~/.profile
export GOROOT=/usr/local/go
export GOPATH=$HOME/go
export GO111MODULE=on
export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin
EOF
source ~/.profile
go version
```
Output should be: `go version go1.17.5 linux/amd64`

### 3. Install meme from source
Fetch and install the current Mainnet MeMe version.


```bash:
git clone https://github.com/MeMeCosmos/meme
cd meme
git checkout main
make install
```
Note: there is no tag to build off of, just use main for now

### Init chain
```bash:
memed init $MONIKER_NAME --chain-id meme-1
```

### Download Genesis
Please download the genesis file, with the chain-id and airdrop balances.

```bash:
wget -O $HOME/.memed/config/genesis.json https://github.com/MeMeCosmos/mainnet/meme-1/genesis.json
```

### Setup seeds
Add these seeds here to the ~/.memed/config/config.toml file
Make sure to add the provided seed and the community peers found in [`seed.txt`](https://github.com/MeMeCosmos/mainnet/meme-1/seeds.txt) and [`peers.txt`](https://github.com/MeMeCosmos/mainnet/meme-1/peers.txt) by filling the `seeds` and `persistent_peers` fields resp.

### Setup `min-gas-price` to `0.025umeme` in `app.toml`
```
sed -i -E 's/minimum-gas-prices = \"\"/minimum-gas-prices = \"0.025umeme\"/g' ~/.memed/config/app.toml
```


### Add/recover Wallet
```bash:
# To create new keypair - please make sure you save the mnemonics!
memed keys add <WALLET-NAME> 

# Restore existing odin wallet with mnemonic seed phrase. 
# You will be prompted to enter mnemonic seed. 
memed keys add <WALLET-NAME> --recover
```


## Create the validator

Note : All validators set commission to at least 5%
Create your validator using the following transaction:

#### Create MeMe validator
```bash:
memed tx staking create-validator \
--pubkey=$(memed tendermint show-validator) \
--amount=1000000umeme \
--chain-id meme-1 \
--identity="<KEYBASE-ID>" \
--moniker="<MONIKER>" \
--details "<DESCRIPTION>" \
--website="<WEBSITE>" \
--security-contact="<EMAIL>" \
--website="" \
--commission-max-change-rate=0.01 \
--commission-max-rate=0.20 \
--commission-rate=0.05 \
--gas-prices=0.025umeme \
--from=<WALLET-NAME>
```


### Backup critical files
Private key to use as a validator in the consensus protocol. File priv_validator_key.json in ~/.memed/config/

```bash:
priv_validator_key.json
```


### Show your validator public key 


```bash:
memed tendermint show-validator
```


## Starting memed as a service

```
tee /etc/systemd/system/memed.service > /dev/null <<EOF
[Unit]
Description=MeMe Daemon
After=network-online.target

[Service]
User=$USER
ExecStart=$GOBIN/memed start
Restart=always
RestartSec=3
LimitNOFILE=65535
StandardOutput=file:/var/log/memed.log
StandardError=file:/var/log/memed.log

[Install]
WantedBy=multi-user.target
EOF
```


#### Initialize the log file:

```bash:
touch /var/log/memed.log
```

#### Start the memed service like this:

```bash:
systemctl enable memed
systemctl start memed
```


### Please backup critical files
```bash:
priv_validator_key.json
```


## Frequently used commands

#### Redeem commission rewards
```bash:
memed tx distribution withdraw-rewards <Operator Address> --from <WALLET-NAME> --commission  --chain-id=meme-1 --fees 10000umeme
```

Your validator <Operator Address> : memevaloperxxxxxxxxxxxx


#### Unjail validator
```bash:
memed tx slashing unjail --from <WALLET-NAME> --chain-id meme-1
```


## Starport

```
curl https://get.starport.network/MeMeCosmos/meme@latest | sudo bash
```
`memeChain/meme` should match the `username` and `repo_name` of the Github repository to which the source code was pushed. Learn more about [the install process](https://github.com/allinbits/starport-installer).

## Learn more

- [Starport](https://github.com/tendermint/starport)
- [Starport Docs](https://docs.starport.network)
- [Cosmos SDK documentation](https://docs.cosmos.network)
- [Cosmos SDK Tutorials](https://tutorials.cosmos.network)
- [Discord](https://discord.gg/cosmosnetwork)



