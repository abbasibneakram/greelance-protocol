require('@nomicfoundation/hardhat-toolbox')
require('dotenv').config()
require('@nomicfoundation/hardhat-verify')

const PRIVATE_KEY = process.env.PRIVATE_KEY
const POLYGON_SCAN_KEY = process.env.POLYGON_SCAN_KEY
const ETHER_SCAN_KEY = process.env.ETHER_SCAN_KEY
const ALCHEMY_API_KEY = process.env.ALCHEMY_API_KEY

module.exports = {
    solidity: '0.8.20',
    networks: {
        sepolia: {
            url: `https://eth-sepolia.g.alchemy.com/v2/${ALCHEMY_API_KEY}`,
            accounts: [PRIVATE_KEY],
        },
        ethereum: {
            url: `https://eth-mainnet.g.alchemy.com/v2/${ALCHEMY_API_KEY}`,
            accounts: [PRIVATE_KEY],
        },
        amoy: {
            url: `https://polygon-amoy.g.alchemy.com/v2/${ALCHEMY_API_KEY}`,
            accounts: [PRIVATE_KEY],
        },
        polygon: {
            url: `https://polygon-mainnet.g.alchemy.com/v2/${ALCHEMY_API_KEY}`,
            accounts: [PRIVATE_KEY],
        },
    },
    etherscan: {
        apiKey: {
            sepolia: ETHER_SCAN_KEY,
            polygon: POLYGON_SCAN_KEY,
        },
    },
    sourcify: {
        enabled: false,
    },
}
