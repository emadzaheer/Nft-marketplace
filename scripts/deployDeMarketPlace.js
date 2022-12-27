const hre = require("hardhat");

async function main() {
  
  const DeMarketPlace = await hre.ethers.getContractFactory("DeMarketPlace");
  const deMarketPlace = await DeMarketPlace.deploy();                                 //constructor params go here. 

  await deMarketPlace.deployed();

  console.log(`DeMarketPlace deployed to ${deMarketPlace.address}` );
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
