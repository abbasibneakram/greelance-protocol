const axios = require('axios')

// Replace 'YOUR_API_KEY' with your actual CoinMarketCap API key
const apiKey = 'd1b25e4d-6fe9-4fa0-8522-bebfe199e9ea'
const tokenSymbol = 'GRL' // Replace with the symbol of the token you want to check
const apiUrl = `https://pro-api.coinmarketcap.com/v1/cryptocurrency/quotes/latest?symbol=${tokenSymbol}`

// Function to get the token price
async function getTokenPrice() {
    try {
        const response = await axios.get(apiUrl, {
            headers: {
                'X-CMC_PRO_API_KEY': apiKey,
            },
        })

        // Extract the price from the response
        const tokenData = response.data.data[tokenSymbol]

        if (tokenData) {
            const price = tokenData.quote.USD.price
            console.log(`The price of ${tokenSymbol} is $${price}`)
        } else {
            console.log(`Token ${tokenSymbol} not found`)
        }
    } catch (error) {
        console.error('Error fetching the token price:', error)
    }
}

// Call the function to get the token price
getTokenPrice()
