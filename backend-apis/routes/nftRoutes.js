const express = require('express')
const router = express.Router()
const {
    mintBaseNftContoller,
    mintReferralNftController,
} = require('./../controllers/nftController')

router.post('/mint-BaseNft', mintBaseNftContoller)

router.post('/mint-referralNft', mintReferralNftController)

module.exports = router
