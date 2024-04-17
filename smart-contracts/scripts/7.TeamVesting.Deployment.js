const { ethers, run } = require('hardhat')

async function main() {
    console.log('Deploying Team Vesting...')
    const TeamVestingFactory = await ethers.getContractFactory('TeamVesting')
    const TeamVesting = await TeamVestingFactory.deploy()
    console.log(`BaseNFT deployed at: ${TeamVesting.address}`)

    console.log('Verifying ...')
    await TeamVesting.deployTransaction.wait(5)
    await run('verify:verify', {
        address: TeamVesting.address,
    })
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error)
        process.exit(1)
    })
