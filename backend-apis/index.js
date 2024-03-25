// Importing the ethers.js library for Ethereum blockchain interaction
require('dotenv').config()
const ethers = require('ethers')

// Configuration for QuickNode endpoint and user's private key
const PRIVATE_KEY = process.env.PRIVATE_KEY
const API_KEY = process.env.API_KEY

// Setting up the provider and signer to connect to the Ethereum network via QuickNode
// const provider = new ethers.JsonRpcProvider(
//     'https://eth-sepolia.g.alchemy.com/v2/hj6YvuqEX8zop2Wtjnh3A4rXdpT-C0j9'
// )
const provider = new ethers.AlchemyProvider('sepolia', API_KEY)
console.log('provider', provider)
const signer = new ethers.Wallet(PRIVATE_KEY, provider)

const userAddress = signer.address

// Contract details: WETH contract on the Sepolia test network
const contractAddress = '0xC83B3C43908b598c07C88680461E91c43836e30E'
const contractABI = [
    { inputs: [], stateMutability: 'nonpayable', type: 'constructor' },
    {
        anonymous: false,
        inputs: [
            {
                indexed: true,
                internalType: 'address',
                name: 'owner',
                type: 'address',
            },
            {
                indexed: true,
                internalType: 'address',
                name: 'approved',
                type: 'address',
            },
            {
                indexed: true,
                internalType: 'uint256',
                name: 'tokenId',
                type: 'uint256',
            },
        ],
        name: 'Approval',
        type: 'event',
    },
    {
        anonymous: false,
        inputs: [
            {
                indexed: true,
                internalType: 'address',
                name: 'owner',
                type: 'address',
            },
            {
                indexed: true,
                internalType: 'address',
                name: 'operator',
                type: 'address',
            },
            {
                indexed: false,
                internalType: 'bool',
                name: 'approved',
                type: 'bool',
            },
        ],
        name: 'ApprovalForAll',
        type: 'event',
    },
    {
        anonymous: false,
        inputs: [
            {
                indexed: true,
                internalType: 'address',
                name: 'previousOwner',
                type: 'address',
            },
            {
                indexed: true,
                internalType: 'address',
                name: 'newOwner',
                type: 'address',
            },
        ],
        name: 'OwnershipTransferred',
        type: 'event',
    },
    {
        anonymous: false,
        inputs: [
            {
                indexed: true,
                internalType: 'address',
                name: 'from',
                type: 'address',
            },
            {
                indexed: true,
                internalType: 'address',
                name: 'to',
                type: 'address',
            },
            {
                indexed: true,
                internalType: 'uint256',
                name: 'tokenId',
                type: 'uint256',
            },
        ],
        name: 'Transfer',
        type: 'event',
    },
    {
        inputs: [{ internalType: 'address', name: 'owner', type: 'address' }],
        name: 'balanceOf',
        outputs: [{ internalType: 'uint256', name: '', type: 'uint256' }],
        stateMutability: 'view',
        type: 'function',
    },
    {
        inputs: [
            { internalType: 'address', name: '_user', type: 'address' },
            { internalType: 'uint256', name: '_tokenId', type: 'uint256' },
            { internalType: 'string', name: '_uri', type: 'string' },
        ],
        name: 'mint',
        outputs: [],
        stateMutability: 'nonpayable',
        type: 'function',
    },
    {
        inputs: [],
        name: 'name',
        outputs: [{ internalType: 'string', name: '', type: 'string' }],
        stateMutability: 'view',
        type: 'function',
    },
    {
        inputs: [],
        name: 'owner',
        outputs: [{ internalType: 'address', name: '', type: 'address' }],
        stateMutability: 'view',
        type: 'function',
    },
    {
        inputs: [{ internalType: 'uint256', name: 'tokenId', type: 'uint256' }],
        name: 'ownerOf',
        outputs: [{ internalType: 'address', name: '', type: 'address' }],
        stateMutability: 'view',
        type: 'function',
    },
    {
        inputs: [
            { internalType: 'bytes4', name: 'interfaceId', type: 'bytes4' },
        ],
        name: 'supportsInterface',
        outputs: [{ internalType: 'bool', name: '', type: 'bool' }],
        stateMutability: 'view',
        type: 'function',
    },
    {
        inputs: [],
        name: 'symbol',
        outputs: [{ internalType: 'string', name: '', type: 'string' }],
        stateMutability: 'view',
        type: 'function',
    },
    {
        inputs: [{ internalType: 'uint256', name: 'tokenId', type: 'uint256' }],
        name: 'tokenURI',
        outputs: [{ internalType: 'string', name: '', type: 'string' }],
        stateMutability: 'view',
        type: 'function',
    },
    {
        inputs: [],
        name: 'totalSupply',
        outputs: [{ internalType: 'uint256', name: '', type: 'uint256' }],
        stateMutability: 'view',
        type: 'function',
    },
    {
        inputs: [
            { internalType: 'address', name: 'newOwner', type: 'address' },
        ],
        name: 'transferOwnership',
        outputs: [],
        stateMutability: 'nonpayable',
        type: 'function',
    },
]

// Instantiating the contract object for interacting with the WETH contract
const contract = new ethers.Contract(contractAddress, contractABI, signer)
const contractWithSigner = contract.connect(signer)

// Reading from the contract
// READ FUNCTION WILL BE HERE

// Reading from the contract
// async function readContract() {
//     console.log('Reading the Total Supply...')
//     // Query the contract for the balance of the specified user address
//     const balance = await contract.totalSupply()
//     console.log(`Total Supply is: ${balance}`)
// }

// Writing to the contract
// WRITING FUNCTION WILL BE HERE

// Writing to the contract
async function writeContract() {
    console.log('Calling mint function...')
    const transactionResponse = await contract.mint(
        signer.address,
        8,
        'https://ipfs/abc'
    )
    const receipt = await transactionResponse.wait()
    if (receipt.status === 1) {
        console.log('Transaction successful!')
        console.log(`Transaction hash: ${transactionResponse.hash}`)
    } else {
        console.log('Transaction failed!')
    }
}

// Call the functions
;(async () => {
    // First, read the contract to get the initial state
    await readContract()
    // Next, write to the contract and wait for the transaction to complete
    await writeContract()
    // Finally, read the contract again to see the changes made by the write operation
    await readContract()
})().catch(console.error)
