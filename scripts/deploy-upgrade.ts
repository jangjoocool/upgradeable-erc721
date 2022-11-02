import { ethers, upgrades } from "hardhat";
import { readFileSync } from 'fs'

async function main() {
    const address = readFileSync(__dirname + '/../.proxy-contract', 'utf8').toString();
    const contractFactory = await ethers.getContractFactory("FDT"); 
    const contract = await upgrades.upgradeProxy(address, contractFactory);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
