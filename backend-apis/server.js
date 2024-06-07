const express = require('express')
const bodyParser = require('body-parser')
const cors = require('cors')
const dotenv = require('dotenv')
dotenv.config()

const nftRoute = require('./routes/nftRoutes')

const app = express()
app.use(express.json())

const PORT = process.env.PORT || 3000
app.get('/', async (req, res) => {
    res.send('Hello API')
})

app.use(cors())

app.options('*', cors())
app.use('/api', nftRoute)
app.listen(PORT, () => {
    console.log(`Server is running on port ${PORT}`)
})
