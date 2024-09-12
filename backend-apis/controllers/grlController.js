const axios = require('axios')
const dotenv = require('dotenv')
dotenv.config()

const { transferGrl } = require('../services/transferGrlService')

const getGrlUsdPriceController = async (req, res) => {
    const tokenSymbol = 'GRL'
    const API_URL = `https://pro-api.coinmarketcap.com/v1/cryptocurrency/quotes/latest?symbol=${tokenSymbol}`
    const API_KEY = process.env.COINMARKETCAP_API_KEY

    try {
        const response = await axios.get(API_URL, {
            headers: {
                'X-CMC_PRO_API_KEY': API_KEY,
            },
        })

        // Extract the price from the response
        const tokenData = response.data.data[tokenSymbol]

        if (!tokenData) {
            console.log(`Token ${tokenSymbol} not found`)
            return res.status(404).json({
                success: false,
                error: `Token ${tokenSymbol} not found`,
            })
        }

        const price = tokenData.quote.USD.price
        console.log(`The price of 1 ${tokenSymbol} is $${price}`)

        const { amountOfGrl, amountOfUsd } = req.body

        if (amountOfGrl) {
            const totalPriceInUsd = amountOfGrl * price
            return res.status(200).json({ price: totalPriceInUsd })
        }

        if (amountOfUsd) {
            const equivalentGrlAmount = amountOfUsd / price
            return res.status(200).json({ amountOfGrl: equivalentGrlAmount })
        }

        return res.status(200).json({ price: price })
    } catch (error) {
        console.error('Error:', error)
        return res.status(500).json({
            success: false,
            error: error.message,
        })
    }
}

const transferGrlController = async (req, res) => {
    const { addressOfWallet, grlAmount, network, secretKey } = req.body
    const ENV_SECRET_KEY = process.env.SECRET_KEY

    if (!addressOfWallet || !grlAmount || !network || !secretKey) {
        return res
            .status(400)
            .json({ success: false, error: 'Missing parameters!' })
    }

    if (secretKey !== ENV_SECRET_KEY) {
        return res
            .status(403)
            .json({ success: false, error: 'Invalid secret key!' })
    }
    const bodyData = req.body
    try {
        const response = await transferGrl(bodyData)
        res.json(response)
    } catch (error) {
        console.error('Error:', error)
        res.status(500).json({
            success: false,
            error: error,
        })
    }
}

const purchaseGrlController = async (req, res) => {
    try {
        const {
            amountInUsd,
            amountInEth,
            paymentMethod,
            walletAddress,
            secretKey,
            network,
        } = req.body
        const ENV_SECRET_KEY = process.env.SECRET_KEY

        if (
            !req.body ||
            !paymentMethod ||
            !walletAddress ||
            !secretKey ||
            !network
        ) {
            return res.status(400).json({
                success: false,
                message: 'Missing required fields.',
            })
        }

        if (secretKey !== ENV_SECRET_KEY) {
            return res.status(403).json({
                success: false,
                message: 'Invalid secret key!',
            })
        }

        const supportedNetworks = ['polygon', 'ethereum']
        if (!supportedNetworks.includes(network)) {
            return res.status(400).json({
                success: false,
                message: `Unsupported network. Please use one of the following: ${supportedNetworks.join(
                    ', '
                )}.`,
            })
        }

        let amountInUsdFinal

        if (paymentMethod === 'usd') {
            if (!amountInUsd) {
                return res.status(400).json({
                    success: false,
                    message:
                        'Amount in USD is required when the payment method is USD.',
                })
            }

            amountInUsdFinal = amountInUsd
        } else if (paymentMethod === 'eth') {
            if (!amountInEth) {
                return res.status(400).json({
                    success: false,
                    message:
                        'Amount in ETH is required when the payment method is ETH.',
                })
            }

            const ethPriceResponse = await axios.get(
                'https://pro-api.coinmarketcap.com/v1/cryptocurrency/quotes/latest?symbol=ETH',
                {
                    headers: {
                        'X-CMC_PRO_API_KEY': process.env.COINMARKETCAP_API_KEY,
                    },
                }
            )
            const ethPriceInUsd = ethPriceResponse.data.data.ETH.quote.USD.price
            amountInUsdFinal = amountInEth * ethPriceInUsd
        } else {
            return res.status(400).json({
                success: false,
                message: 'Invalid payment method. Please use "usd" or "eth".',
            })
        }

        const grlPriceResponse = await axios.get(
            'https://app.greelance.com/api/grl-usd-price'
        )
        const grlPriceInUsd = grlPriceResponse.data.price
        console.log('grlPriceInUsd', grlPriceInUsd)

        let grlAmount = amountInUsdFinal / grlPriceInUsd
        grlAmount = parseFloat(grlAmount.toFixed(2))
        console.log('grlAmount', grlAmount)

        const transferResponse = await axios.post(
            'https://app.greelance.com/api/grlTransfer',
            {
                addressOfWallet: walletAddress,
                grlAmount: grlAmount * 10 ** 9,
                network: network,
                secretKey: ENV_SECRET_KEY,
            }
        )

        res.status(200).json({
            success: true,
            message: 'GRL successfully transferred',
            transferResult: transferResponse.data,
        })
    } catch (error) {
        console.error('Error:', error)
        res.status(500).json({
            success: false,
            error: error.message,
        })
    }
}

module.exports = {
    getGrlUsdPriceController,
    transferGrlController,
    purchaseGrlController,
}
