const { buildModule } = require('@nomicfoundation/hardhat-ignition/modules')

module.exports = buildModule('TestGrlModule', (m) => {
    const lock = m.contract('GreelanceTest')

    return { lock }
})
