require('ethereum-waffle')
require('dotenv').config()
require('@nomiclabs/hardhat-waffle')
require('@nomiclabs/hardhat-etherscan')
require('@openzeppelin/hardhat-upgrades')

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
