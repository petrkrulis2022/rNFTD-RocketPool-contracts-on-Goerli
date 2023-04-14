const { ethers } = require("hardhat");

const main = async () => {
  const RNFTDollar = await ethers.getContractFactory("RNFTDollar");

  // Deploy the contract
  const rnftDollar = await RNFTDollar.deploy();
  await rnftDollar.deployed();

  // Print the address of the deployed contract
  console.log(`Contract rNFT Dollar deployed to:`, rnftDollar.address);

  // Wait for etherscan to notice that the contract has been deployed
  await rnftDollar.deployTransaction.wait(10);

  // Verify the contract after deploying
  await hre.run("verify:verify", {
    address: rnftDollar.address,
    constructorArguments: [],
  });
};

// Call the main function and catch if there is any error
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
