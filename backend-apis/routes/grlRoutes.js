const express = require('express')
const router = express.Router()
const {
    getGrlUsdPriceController,
    transferGrlController,
    purchaseGrlController,
} = require('../controllers/grlController')

router.get('/grl-usd-price', getGrlUsdPriceController)
router.post('/grlTransfer', transferGrlController)
router.post('/purchaseGrl', purchaseGrlController)

//router.post('/mint-referralNft', mintReferralNftController)

module.exports = router
