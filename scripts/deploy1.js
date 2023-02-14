const { ethers } = require('hardhat');
const { writeFileSync } = require('fs');

async function deploy(name, ...params) {
    const Contract = await ethers.getContractFactory(name);
    return await Contract.deploy(...params).then(f => f.deployed());
}

async function main() {
    console.log(process.env.OWNER_ADDRESS)
    const realEstate = await deploy('RealEstateToken', "xdc1d62299261b57b6a272e521a2350d8ae04246c8c", "aryan", "ARX", "0x33f4212b027e22af7e6ba21fc572843c0d701cd1");
    console.log("realEstate deployed to:", realEstate.address);
    writeFileSync('output1.json', JSON.stringify({
        RealEstateToken: realEstate.address
    }, null, 2));

}
if (require.main === module) {
    main().then(() => process.exit(0))
        .catch(error => { console.error(error); process.exit(1); });
}