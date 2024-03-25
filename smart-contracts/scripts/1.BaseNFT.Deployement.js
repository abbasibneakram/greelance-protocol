const { ethers, run } = require('hardhat')

async function main() {
    console.log('Deploying Base NFT...')
    const BaseNFTFactory = await ethers.getContractFactory('BaseNFT')
    const BaseNFT = await BaseNFTFactory.deploy()
    console.log(`BaseNFT deployed at: ${BaseNFT.address}`)

    console.log('Verifying ...')
    await BaseNFT.deployTransaction.wait(5)
    await run('verify:verify', {
        address: BaseNFT.address,
    })
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error)
        process.exit(1)
    })
