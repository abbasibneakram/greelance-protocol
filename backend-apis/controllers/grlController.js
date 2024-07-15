const axios = require('axios')
const dotenv = require('dotenv')
dotenv.config()

const { transferGrl } = require('../services/transferGrlService')
const { encryptData } = require('../utilities/encryption')

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
    const { addressOfWallet, grlAmount, network } = req.body
    if (!addressOfWallet || !grlAmount || !network) {
        return res
            .status(400)
            .json({ success: false, error: 'Missing parameters.' })
    }
    const encryptedBody = encryptData(req.body)
    try {
        const response = await transferGrl(encryptedBody)
        res.json(response)
    } catch (error) {
        console.error('Error:', error)
        res.status(500).json({
            success: false,
            error: error,
        })
    }
}

module.exports = { getGrlUsdPriceController, transferGrlController }
