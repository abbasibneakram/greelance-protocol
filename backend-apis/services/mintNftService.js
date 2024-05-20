const {
    baseNftContract,
    referralNftContract,
} = require('./../config/web3Config')
const { decryptData } = require('./../utilities/encryption')

async function mintBaseNft(encryptedBody) {
    const decryptedData = decryptData(encryptedBody)

    try {
        console.log('Calling mint function...')
        const transactionResponse = await baseNftContract.mint(
            decryptedData.walletAddress,
            decryptedData.tokenId,
            decryptedData.metadataUrl
        )
        console.log('encrypted Body: ', encryptedBody)

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
        console.error('Error:', error.shortMessage)
        return { success: false, error: error.shortMessage }
    }
}

async function mintReferralNft(walletAddresses, tokenIds, metadataUrls) {
    try {
        console.log('Calling bulkMint function...')
        const transactionResponse = await referralNftContract.bulkMint(
            walletAddresses,
            tokenIds,
            metadataUrls
        )
        console.log(walletAddresses, tokenIds, metadataUrls)

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
        return { success: false, error: error.shortMessage }
    }
}

module.exports = { mintBaseNft, mintReferralNft }
