# Install Sui CLI
install-cli:
    # Install Suim to install Sui CLI
    curl -o- https://raw.githubusercontent.com/nextuser/suim/refs/heads/main/install.sh | bash	# Ref. https://github.com/nextuser/suim

    # Install Walrus CLI
    curl -sSf https://docs.wal.app/setup/walrus-install.sh | sh -s -- -n testnet

    # Install sui-client-gen
    cargo install --locked --git https://github.com/kunalabs-io/sui-client-gen.git

# Generate Sui client code for testnet
suigen-testnet:
    cd sdk && bun run suigen:testnet

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


sdk-format:
    cd sdk && bun run format

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

publish-npm:
    cd sdk && npm publish --dry-run



# JustChat

build-move-justchat PKG="justchat" NETWORK="testnet":
    sui client switch --env {{NETWORK}}
    cd contracts/{{PKG}} && sui move build

publish-move-justchat PKG="justchat" NETWORK="testnet":
    sui client switch --env {{NETWORK}}
    cd contracts/{{PKG}} && sui client publish


MESSAGING_PACKAGE_ID := "0x366ffbcaf9c51db02857ff81141702f114f3b5675dd960be74f3c5f34e2ba3c3"
FEE_CAP_ID := "0xd5c0f61d9c02a72ce8af482d1dcb9e47ead607d9ae23904ebb0c1696852e684f"

send-message NETWORK="testnet":
    sui client switch --env {{NETWORK}}
    sui client ptb \
      --split-coins gas '[1000]' \
      --assign fee_coin \
      --move-call {{MESSAGING_PACKAGE_ID}}::messaging::send_message \
      @{{FEE_CAP_ID}} \
      '"Hello, suisui!"' \
      fee_coin \
      --gas-budget 100000000


script-sendChat:
    cd sdk && bunx tsx scripts/sendChat.ts

poll-justchat-events:
    cd sdk && bunx tsx scripts/listenChatEvent.ts


memo:
    bunx @mysten/prettier-plugin-move  --use-module-label=true  -w meme_registry.move