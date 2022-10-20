import { ethers, upgrades } from "hardhat";
import { writeFileSync } from 'fs'

async function main() {
  const contractFactory = await ethers.getContractFactory("Ddakzi");
  const contract = await upgrades.deployProxy(contractFactory, {kind: "uups"});

  const txHash = contract.deployTransaction.hash;
  const txReceipt = await ethers.provider.waitForTransaction(txHash);
  
  await contract.deployed();

  const implementation = await upgrades.erc1967.getImplementationAddress(contract.address);
  console.log("Implementation Contract", implementation)
  console.log("Proxy Contract:", contract.address);

  writeFileSync(__dirname + '/../.proxy-contract', contract.address);
  writeFileSync(__dirname + '/../.implementation-contract', implementation);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
