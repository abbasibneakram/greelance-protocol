const { mintBaseNft, mintReferralNft } = require('./../services/mintNftService')

const mintBaseNftContoller = async (req, res) => {
    const { walletAddress, tokenId, metadataUrl } = req.body
    if (!walletAddress || !tokenId || !metadataUrl) {
        return res
            .status(400)
            .json({ success: false, error: 'Missing parameters.' })
    }
    try {
        const response = await mintBaseNft(walletAddress, tokenId, metadataUrl)
        res.json(response)
    } catch (error) {
        console.error('Error:', error)
        res.status(500).json({
            success: false,
            error: 'Internal server error.',
        })
    }
}

const mintReferralNftController = async (req, res) => {
    const { walletAddresses, tokenIds, metadataUrls } = req.body
    if (!walletAddresses || !tokenIds || !metadataUrls) {
        return res
            .status(400)
            .json({ success: false, error: 'Missing parameters.' })
    }
    try {
        const response = await mintReferralNft(
            walletAddresses,
            tokenIds,
            metadataUrls
        )
        res.json(response)
    } catch (error) {
        console.error('Error:', error)
        res.status(500).json({
            success: false,
            error: error,
        })
    }
}

module.exports = { mintBaseNftContoller, mintReferralNftController }
