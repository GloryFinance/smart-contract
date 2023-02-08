npm install truffle -g

npm install

npx truffle deploy --network testnet --reset --compile-none
npx truffle run verify XXX@{contract-address} --network {network-name}
# https://testnet.bscscan.com/proxyContractChecker?a={proxy-contract-address}

# Upgrate smart contract
npx truffle migrate --network testnet
npx truffle run verify  GloryICO@address --network testnet
# https://testnet.bscscan.com/proxyContractChecker?a=address