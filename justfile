# Install Sui CLI
install-cli:
    # Install Suim to install Sui CLI
    curl -o- https://raw.githubusercontent.com/nextuser/suim/refs/heads/main/install.sh | bash	# Ref. https://github.com/nextuser/suim

    # Install Walrus CLI
    curl -sSf https://docs.wal.app/setup/walrus-install.sh | sh -s -- -n testnet

    # Install sui-client-gen
    cargo install --locked --git https://github.com/kunalabs-io/sui-client-gen.git


switch-testnet:
    sui client switch --env testnet

switch-devnet:
    sui client switch --env devnet

setup-testnet-env:
    sui client new-env --alias testnet --rpc https://fullnode.testnet.sui.io:443
    sui client switch --env testnet

setup-devnet-env:
    sui client new-env --alias devnet --rpc https://fullnode.devnet.sui.io:443
    sui client switch --env devnet


test-move:
    cd contracts/e2e_test_cases && sui move test


faucet-devnet:
    sui client switch --env devnet
    sui client faucet
    sui client balance


# Create New Address
create-new-address:
    # sui client new-address secp256k1
    sui client new-address ed25519


# Switch Active Address
switch-active-address ADDRESS:
    sui client switch --address {{ADDRESS}}

# Request Sui from Faucet
request-sui ADDRESS:
    curl --location --request POST 'https://faucet.testnet.sui.io/gas' \
    --header 'Content-Type: application/json' \
    --data-raw '{ "FixedAmountRequest": { "recipient": "{{ADDRESS}}" } }'

publish-move PKG="justchat":
    cd contracts/{{PKG}} && sui client publish --gas-budget 100000000

publish-move-famfactory NETWORK="testnet":
    sui client switch --env {{NETWORK}}
    cd contracts/bump_fam_factory && sui client publish

build-move-famcoin:
    cd contracts/bump_fam_coin && sui move build --dump-bytecode-as-base64


# Install Dependencies
install-dependencies:
    bun install

# Start dApp in Development Mode
dev:
    bun run dev

# Build dApp for Deployment
build:
    bun run build

script-createOozeFamCoin:
    cd sdk && bunx tsx scripts/createOozeFamCoin.ts