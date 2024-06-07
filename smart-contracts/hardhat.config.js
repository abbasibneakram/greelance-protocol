require('ethereum-waffle')
require('dotenv').config()
require('@nomiclabs/hardhat-waffle')
require('@nomiclabs/hardhat-etherscan')
require('@openzeppelin/hardhat-upgrades')
console.log('key', process.env.PRIVATE_KEY)
module.exports = {
    solidity: {
        version: '0.8.20',
        settings: {
            metadata: {
                bytecodeHash: 'none',
            },
            optimizer: {
                enabled: true,
                runs: 800,
            },
        },
    },

    paths: {
        artifacts: './artifacts',
    },

    networks: {
        polygon: {
            url: `https://rpc-amoy.polygon.technology/`,
            // accounts: [private_key],
            accounts: [
                '0x59ce98b41b9eb3a0ebfb24f585892bcae6816b3f060c44e85660b70af61a5d11',
            ],
        },

        polygonMainnet: {
            url: `https://polygon-rpc.com/`,
            // accounts: [private_key],
            accounts: [`${process.env.PRIVATE_KEY}`],
        },
        sepoliaTestnet: {
            url: `https://1rpc.io/sepolia`,
            // accounts: [private_key],
            accounts: [`${process.env.PRIVATE_KEY}`],
        },
        mainnet: {
            url: `https://1rpc.io/sepolia`,
            accounts: [`${process.env.PRIVATE_KEY}`],
        },
    },
    etherscan: {
        apiKey: `${process.env.ETHER_SCAN_KEY}`,
    },
}
