## MEME Chain


### prepare Meme network v2.0.8
* DO NOT USE ON MAINNET
https://github.com/memecosmos/meme/releases/tag/v2.0.8

New version list:
| Go     | Cosmos SDK   | wasmd | wasmvm       | cosmwasm-std | ibc      | 
| ------ | ------------ | ----- | ------------ | ------------ |--------- |
| v1.8.5 | v0.45.6      | 0.28  | v1.0.0       | 1.0          | v3.0.0   |

Support Interchain account, Export and StoreKey bug fix.


* Software upgrade to v2.0.8 testnet and chain-id renew to meme-testnet-2 for fixed v2.0.5 issue:
[meme-testnet-2](https://github.com/memecosmos/testnet/tree/main/meme-testnet-2)

* Software upgrade to v2.0.5 testnet and issue we encountered and solutions:
[upgrade-memed-v1.0.0-v2.0.5.md](https://github.com/memecosmos/testnet/blob/main/upgrade-memed-v1.0.0-v2.0.5.md)


---

### How to Join MEME Mainnet


### Recommended system setup

- 4 core CPU
- Memory: 4GB
- Disk: 100GB 
- Ubuntu 20.04


## Meme Validator Node Snapshot & State-Sync
Thanks polkachu.com and nodersteam.com are providing a nodes State-Sync, snapshot and RPC to support fellow validators.

### Polkachu.com:

https://polkachu.com/tendermint_snapshots/meme

https://polkachu.com/state_sync/meme

### Nodersteam.com:

https://nodeservice.nodersteam.com/title/mainnet/meme





## Full chain setup guidelines


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
Output should be: `go version go1.17.8 linux/amd64`

### 3. Download memed binary

```
wget https://fix.meme.sx/memed-v1.0.0-fix.tar.gz
tar -xvzf memed-v1.0.0-fix.tar.gz
./memed version --long
#It should be -> commit: 3d3bb097154af6a8eaa83f43e8e47dc91dcdb8b2
sha256sum memed
#It should be -> 7456e62eb8ba79391d6e0719dc27d65e383d05493586230046a9340b03f16db5  memed
```

### Init chain
```bash:
memed init $MONIKER_NAME --chain-id meme-1
```

### Download Genesis
Please download the genesis file, with the chain-id and double check the hash of the genesis.

```bash:
wget -O $HOME/.memed/config/genesis.json https://raw.githubusercontent.com/memecosmos/mainnet/main/meme-1/genesis.json
echo "6e8e0e14fbdc2d978584a2af735c255f1d17bf6c50e8889aec83df33104851b8  genesis.json" | sha256sum -c
```


### Setup seeds
Add these seeds here to the ~/.memed/config/config.toml file
Make sure to add the provided peers found in [`peers.txt`](https://github.com/MeMeCosmos/mainnet/raw/main/meme-1/peers.txt) by filling the  `persistent_peers` fields resp.

Or type command
```
export PEERS="450b7b3515fc9b8112a0dee947e436dc52b0c600@173.212.220.98:26656,bce1338cf47af1bb0ee48da51c5e0abf20549eed@38.242.238.171:26651,7f8d0d370ea72608fa74d0b6698a7979ab510449@188.166.104.46:26656,bbce4f689582db49d7a93cb2baf94d95aa72f43b@137.184.13.23:26656,c57fce65a0e6be87763ae38d607b817b3acde620@173.212.215.104:26656,c81f07bb55b261adc7ab15dc5a6f9b8f48cb0e6e@144.76.90.249:26686,d06c06f03c94d1ee61e02f2a0a521a67f118efbf@64.227.40.96:26656,4a041dc92597526cb5370100b6773bb9b51cec11@185.239.208.71:26656,19e3f3be737e7c305e4518acdd22ee08fc44263d@159.89.182.27:26656,90570d614d01c617953645faa4b955616fbb8d64@205.209.120.105:26656"

sed -i.bak -e "s/^persistent_peers *=.*/persistent_peers = \"$PEERS\"/" ~/.memed/config/config.toml

```


### Setup `min-gas-price` to `0.025umeme` in `app.toml`
```
sed -i -E 's/minimum-gas-prices = \"\"/minimum-gas-prices = \"0.025umeme\"/g' ~/.memed/config/app.toml
```


### Add/recover Wallet
```bash:
# To create new keypair - please make sure you save the mnemonics!
memed keys add <WALLET-NAME> 

# Restore existing wallet with mnemonic seed phrase. 
# You will be prompted to enter mnemonic seed. 
memed keys add <WALLET-NAME> --recover
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
Description=MEME Daemon
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


## Create the validator

Note : All validators set commission to at least 5%
Create your validator using the following transaction:

#### Create MEME validator
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
--commission-max-change-rate=0.01 \
--commission-max-rate=0.20 \
--commission-rate=0.05 \
--gas-prices=0.025umeme \
--min-self-delegation="1" \
--from=<WALLET-NAME>
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





## Local testnet node

### You can use Meme dapp developer installer.
  
  One-line installer: https://github.com/memecosmos/testnet/tree/main/local-testnet
  
  
### Manual installation:
  
```
#customize the name of your key, the moniker, chain-id, keyring backend, and log level
KEY="mykey"
MONIKER="localtestnet"
CHAINID="meme-testnet-1"
KEYRING="test"
LOGLEVEL="info"

#Initialize the chain
memed init $MONIKER --chain-id=$CHAINID

#Create account
memed keys add $KEY --keyring-backend $KEYRING

#Allocate genesis accounts (cosmos formatted addresses)
memed add-genesis-account $KEY 1000000000umeme --keyring-backend $KEYRING

#Sign genesis transaction
memed gentx $KEY 100000000umeme --keyring-backend $KEYRING --chain-id $CHAINID

#Add the gentx to the genesis file
memed collect-gentxs

#Check the correctness of the genesis.json file
memed validate-genesis

#Start MEME testnet node
memed start
```




## MEME

[![Website](https://raw.githubusercontent.com/memecosmos/assetlists/main/logo/meme-icon-500.png)](https://meme.sx)

#### Crypto empowerment, even more MEMEingful.  
#### Aim to provide a platform and tools to our community to create, question, answer and define about meme.



## Learn more

- [Cosmos SDK documentation](https://docs.cosmos.network)
- [Cosmos SDK Tutorials](https://tutorials.cosmos.network)
- [Discord](https://discord.com/invite/pAXqq5dVD9)

