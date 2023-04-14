const { ethers } = require("hardhat");

const main = async () => {
  const RNFTDollarDeposit = await ethers.getContractFactory(
    "RNFTDollarDeposit"
  );

  // Deploy the contract
  const rnftDollarDeposit = await RNFTDollarDeposit.deploy(
    "0x2d9FC9A76Db8559fC382311f147Eae43354A5a9c"
  );
  await rnftDollarDeposit.deployed();

  // Print the address of the deployed contract
  console.log(
    `Contract RNFTDollarDeposit deployed to:`,
    rnftDollarDeposit.address
  );

  // Wait for etherscan to notice that the contract has been deployed
  await rnftDollarDeposit.deployTransaction.wait(10);

  // Verify the contract after deploying
  await hre.run("verify:verify", {
    address: rnftDollarDeposit.address,
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
