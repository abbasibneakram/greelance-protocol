const { buildModule } = require('@nomicfoundation/hardhat-ignition/modules')
require('dotenv').config()

const grlAddress = process.env.GRL_POL
const wethAddress = process.env.WMATIC_POL
const routerAddress = process.env.ROUTER_POL
const aggregatorAddress = process.env.AGGREGATOR_POL

module.exports = buildModule('PaymentPriceGuaranteeModule', (m) => {
    const grlContract = m.getParameter('grlContract', grlAddress)
    const wethContract = m.getParameter('wethContract', wethAddress)
    const routerContract = m.getParameter('routerContract', routerAddress)
    const aggregatorContract = m.getParameter(
        'aggregatorContract',
        aggregatorAddress
    )

    const lock = m.contract('PaymentPriceGuaranteeStakingTest', [
        grlContract,
        wethContract,
        routerContract,
        aggregatorContract,
    ])

    return { lock }
})
