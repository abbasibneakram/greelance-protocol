const express = require('express')
const bodyParser = require('body-parser')
const ethers = require('ethers')
const cors = require('cors')
const dotenv = require('dotenv')

dotenv.config()
app.use(cors())
const nftRoute = require('./routes/nftRoutes')

const app = express()
app.use(bodyParser.json())
app.use(bodyParser.urlencoded({ extended: true }))

const PORT = process.env.PORT || 3000
app.get('/', async (req, res) => {
    res.send('Hello API')
})
app.use('/api', nftRoute)
app.listen(PORT, () => {
    console.log(`Server is running on port ${PORT}`)
})
