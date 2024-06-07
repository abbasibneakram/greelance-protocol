const express = require('express')
const bodyParser = require('body-parser')
const ethers = require('ethers')
const dotenv = require('dotenv')
dotenv.config()

const nftRoute = require('./routes/nftRoutes')

const app = express()
app.use(bodyParser.json())
app.use(bodyParser.urlencoded({ extended: true }))

app.use((req, res, next) => {
    res.header('Access-Control-Allow-Origin', '*')
    res.header('Access-Control-Allow-Methods', 'GET,HEAD,OPTIONS,POST,PUT')
    res.header(
        'Access-Control-Allow-Headers',
        'Origin, X-Requested-With, Content-Type, Accept, Authorization'
    )
    next()
})

const PORT = process.env.PORT || 3000
app.get('/', async (req, res) => {
    res.send('Hello API')
})
app.use('/api', nftRoute)
app.listen(PORT, () => {
    console.log(`Server is running on port ${PORT}`)
})
