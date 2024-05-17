const express = require('express')
const bodyParser = require('body-parser')
const ethers = require('ethers')
const dotenv = require('dotenv')
dotenv.config()

const nftRoute = require('./routes/nftRoutes')

const app = express()
app.use(bodyParser.json())
app.use(bodyParser.urlencoded({ extended: true }))

const PORT = process.env.PORT || 3000
app.use('/api', nftRoute)
app.listen(PORT, () => {
    console.log(`Server is running on port ${PORT}`)
})
