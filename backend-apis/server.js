const express = require('express')
const bodyParser = require('body-parser')
const cors = require('cors')
const dotenv = require('dotenv')
const morgan = require('morgan')
dotenv.config()

const nftRoute = require('./routes/nftRoutes')
const grlRoute = require('./routes/grlRoutes')

const app = express()
app.use(express.json())
app.use(morgan('tiny'))

const PORT = process.env.PORT || 3000
app.get('/', async (req, res) => {
    res.send('Hello API')
})

app.use(cors())

app.use('/api', nftRoute)
app.use('/api', grlRoute)
app.listen(PORT, () => {
    console.log(`Server is running on port ${PORT}`)
})
