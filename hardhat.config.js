require("dotenv").config();
require("@nomicfoundation/hardhat-toolbox");
require("@nomiclabs/hardhat-ethers");
require("@nomiclabs/hardhat-etherscan");

module.exports = {
  defaultNetwork: "goerliTestNet",
  networks: {
    hardhat: {},
    goerliTestNet: {
      url: process.env.GOERLI_TEST_NET_PROVIDER_URL,
      accounts: [process.env.WALLET_PRIVATE_KEY],
      chainId: 5,
    },
    ethereumMainnet: {
      url: process.env.ETHEREUM_MAIN_NET_PROVIDER_URL,
      accounts: [process.env.WALLET_PRIVATE_KEY],
      chainId: 1,
    },
  },
  solidity: {
    version: "0.8.18",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200,
      },
    },
  },
  etherscan: {
    apiKey: process.env.ETH_SCAN_API_KEY,
  },
};
