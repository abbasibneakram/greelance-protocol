const {
    ethGrlInstance,
    polGrlInstance,
    ethProvider,
    polProvider,
} = require('../config/web3Config')
const { decryptData } = require('../utilities/encryption')

const ethers = require('ethers')

async function transferGrl(encryptedBody) {
    const decryptedData = decryptData(encryptedBody)

    let contractInstance
    let provider

    if (decryptedData.network === 'ethereum') {
        contractInstance = ethGrlInstance
        provider = ethProvider
    } else if (decryptedData.network === 'polygon') {
        contractInstance = polGrlInstance
        provider = polProvider
    } else {
        throw new Error('Unsupported network')
    }

    try {
        console.log('Calling transfer function...')

        const feeData = await provider.getFeeData()
        const gasLimit = await contractInstance.transfer.estimateGas(
            decryptedData.addressOfWallet,
            decryptedData.grlAmount
        )
        const transactionResponse = await contractInstance.transfer(
            decryptedData.addressOfWallet,
            decryptedData.grlAmount,
            {
                maxPriorityFeePerGas: feeData.maxPriorityFeePerGas,
                maxFeePerGas: feeData.maxFeePerGas,
                gasLimit: gasLimit,
            }
        )

        const receipt = await transactionResponse.wait()
        if (receipt.status === 1) {
            console.log('Transaction successful!')
            console.log(`Transaction hash: ${transactionResponse.hash}`)
            return {
                success: true,
                transactionHash: transactionResponse.hash,
                network: decryptedData.network,
            }
        } else {
            console.log('Transaction failed!')
            return { success: false, error: 'Transaction failed.' }
        }
    } catch (error) {
        console.error('Error:', error)
        return { success: false, error: error.shortMessage }
    }
}

module.exports = { transferGrl }
