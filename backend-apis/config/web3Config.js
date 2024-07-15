const express = require('express')
const ethers = require('ethers')
const dotenv = require('dotenv')
dotenv.config()

const grlPolAbi = require('./../constants/grlToken/grlPolAbi.json')
const grlEthAbi = require('./../constants/grlToken/grlEthAbi.json')
const baseNftAbi = require('./../constants/baseNftAbi.json')

const PRIVATE_KEY = process.env.PRIVATE_KEY
console.log(PRIVATE_KEY)

const ALCHEMY_API_KEY = process.env.ALCHEMY_API_KEY
const ETH_ALCHEMY_HTTP_ENDPOINT = process.env.ETH_ALCHEMY_HTTP_ENDPOINT
const POL_ALCHEMY_HTTP_ENDPOINT = process.env.POL_ALCHEMY_HTTP_ENDPOINT

console.log(POL_ALCHEMY_HTTP_ENDPOINT)
const grlPolContract = process.env.POL_GREELANCE_TOKEN
const grlEthContract = process.env.ETH_GREELANCE_TOKEN

console.log(grlPolContract, grlEthContract)
const baseNftContractAddress = process.env.BASE_NFT_CONTRACT_ADDRESS
const referralNftContractAddress = process.env.REFERRAL_NFT_CONTRACT_ADDRESS

// Setting up the provider and signer
// const ethProvider = new ethers.AlchemyProvider('homestead', ALCHEMY_API_KEY)
const polProvider = new ethers.AlchemyProvider('matic', ALCHEMY_API_KEY)

// const ethSigner = new ethers.Wallet(PRIVATE_KEY, ethProvider)
// const polSigner = new ethers.Wallet(PRIVATE_KEY, polProvider)

const ethProvider = new ethers.JsonRpcProvider(
    process.env.ETH_ALCHEMY_HTTP_ENDPOINT
)
// const polProvider = new ethers.JsonRpcProvider(
//     process.env.POL_ALCHEMY_HTTP_ENDPOINT
// )

console.log('Ethereum Provider', ethProvider)
console.log('Polygon Provider', polProvider)

const ethSigner = new ethers.Wallet(PRIVATE_KEY, ethProvider)
const polSigner = new ethers.Wallet(PRIVATE_KEY, polProvider)

const ethGrlInstance = new ethers.Contract(grlEthContract, grlEthAbi, ethSigner)
const polGrlInstance = new ethers.Contract(grlPolContract, grlPolAbi, polSigner)

module.exports = { ethGrlInstance, polGrlInstance, polProvider }
