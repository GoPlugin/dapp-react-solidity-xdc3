const { ethers } = require('hardhat');
const { writeFileSync } = require('fs');

async function deploy(name, ...params) {
    const Contract = await ethers.getContractFactory(name);
    return await Contract.deploy(...params).then(f => f.deployed());
}

async function main() {
    const sample = await deploy('SampleContract', "0x33f4212b027e22af7e6ba21fc572843c0d701cd1");
    const realEstate = await deploy('RealEstateToken', process.env.OWNER_ADDRESS, "aryan", "ARX", "0x33f4212b027e22af7e6ba21fc572843c0d701cd1");
    const nftGen = await deploy('NFTGenerator', "0x33f4212b027e22af7e6ba21fc572843c0d701cd1");
    console.log("nftGen deployed to:", nftGen.address);
    writeFileSync('output.json', JSON.stringify({
        SampleContract: sample.address,
        RealEstateToken: realEstate.address,
        NFTGenerator: sample.address
    }, null, 2));

}
if (require.main === module) {
    main().then(() => process.exit(0))
        .catch(error => { console.error(error); process.exit(1); });
}