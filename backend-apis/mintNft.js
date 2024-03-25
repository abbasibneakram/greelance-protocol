const express = require('express')
const bodyParser = require('body-parser')
const ethers = require('ethers')
const dotenv = require('dotenv')
dotenv.config()

const app = express()
app.use(bodyParser.json())
app.use(bodyParser.urlencoded({ extended: true }))

const PORT = process.env.PORT || 3000
const PRIVATE_KEY = process.env.PRIVATE_KEY
const API_KEY = process.env.API_KEY
const contractAddress = process.env.CONTRACT_ADDRESS
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

// Setting up the provider and signer
const provider = new ethers.AlchemyProvider('sepolia', API_KEY)
const signer = new ethers.Wallet(PRIVATE_KEY, provider)
const contract = new ethers.Contract(contractAddress, contractABI, signer)

// Write contract function
async function writeContract(walletAddress, tokenId, metadataUrl) {
    try {
        console.log('Calling mint function...')
        const transactionResponse = await contract.mint(
            walletAddress,
            tokenId,
            metadataUrl
        )
        console.log(walletAddress, tokenId, metadataUrl)

        const receipt = await transactionResponse.wait()
        if (receipt.status === 1) {
            console.log('Transaction successful!')
            console.log(`Transaction hash: ${transactionResponse.hash}`)
            return { success: true, transactionHash: transactionResponse.hash }
        } else {
            console.log('Transaction failed!')
            return { success: false, error: 'Transaction failed.' }
        }
    } catch (error) {
        console.error('Error:', error)
        return { success: false, error: 'An error occurred.' }
    }
}

// POST API endpoint
app.post('/writeContract', async (req, res) => {
    const { walletAddress, tokenId, metadataUrl } = req.body
    if (!walletAddress || !tokenId || !metadataUrl) {
        return res
            .status(400)
            .json({ success: false, error: 'Missing parameters.' })
    }
    try {
        const response = await writeContract(
            walletAddress,
            tokenId,
            metadataUrl
        )
        res.json(response)
    } catch (error) {
        console.error('Error:', error)
        res.status(500).json({
            success: false,
            error: 'Internal server error.',
        })
    }
})

app.listen(PORT, () => {
    console.log(`Server is running on port ${PORT}`)
})
