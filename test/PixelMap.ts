import { time, loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { anyValue } from "@nomicfoundation/hardhat-chai-matchers/withArgs";
import { expect } from "chai";
import { ethers } from "hardhat";

describe("Lock", function () {
  async function deploy() {
    // Contracts are deployed using the first signer/account by default
    const [owner, burnAddress, addr1] = await ethers.getSigners();

    const Token = await ethers.getContractFactory("Token");
    const token = await Token.deploy("TEST", "TEST");

    const PixelMap = await ethers.getContractFactory("PixelMap");
    const pixelMap = await PixelMap.deploy("PIX", "PixelMAp", token.address, burnAddress.address, 1000, 2000, 2000);

    return { pixelMap, token, owner, burnAddress, addr1};
  }

  describe("Deployment", function () {
    it("Check buy Block", async function () {
      const { pixelMap, token, owner, burnAddress, addr1 } = await loadFixture(deploy);

      await token.transfer(addr1.address, ethers.BigNumber.from(100000));
      await token.connect(addr1).approve(pixelMap.address, ethers.BigNumber.from(10000));

      await pixelMap.connect(addr1).buy(2,2);
      await pixelMap.connect(addr1).buy(3,3);
      await pixelMap.connect(addr1).buy(4,4);

      console.log(await pixelMap.getAllSoldBlocks());

      console.log(await pixelMap.ownerOfBlock(3,2));
    });

    it("Check mint", async function() {
      const { pixelMap, token, owner, burnAddress, addr1 } = await loadFixture(deploy);

      await token.transfer(addr1.address, ethers.BigNumber.from(100000));
      await token.connect(addr1).approve(pixelMap.address, ethers.BigNumber.from(10000));

      await pixelMap.connect(addr1).buy(2,2);
      await pixelMap.connect(addr1).buy(3,3);
      await pixelMap.connect(addr1).buy(4,4);

      await pixelMap.connect(addr1).mint(2,2,"hey")

      console.log(await pixelMap.tokenURI(202))
      console.log(await pixelMap.ownerOf(202))

      await pixelMap.connect(addr1).transferFrom(addr1.address, owner.address, 202)
      console.log(await pixelMap.ownerOf(202))
      console.log(await pixelMap.ownerOf(303))
      console.log(await pixelMap.getAllSoldBlocks())

      console.log(await pixelMap.getBlockInfo(3,3))
    })
  });
});
