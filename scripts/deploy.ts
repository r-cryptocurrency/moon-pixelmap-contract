import { ethers } from "hardhat";

async function main() {
  const MoonPlace = await ethers.getContractFactory("MoonPlace");
  const moonPlace = await MoonPlace.deploy(
    "MOONPLACE",
    "MoonPlace",
    "0x0057ac2d777797d31cd3f8f13bf5e927571d6ad0",
    "0x000000000000000000000000000000000000dEaD",
    100,
    //    ethers.utils.parseEther("100"),
    0
  );
  await moonPlace.deployed();
  console.log("PixelMap Contract: ", moonPlace.address);
  // const NameService = await ethers.getContractFactory("RedditNameService");
  // const nameService = await NameService.deploy();
  // await nameService.deployed();
  // console.log(await nameService.address)
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
