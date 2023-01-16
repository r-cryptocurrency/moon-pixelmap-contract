import { time, loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { anyValue } from "@nomicfoundation/hardhat-chai-matchers/withArgs";
import { expect } from "chai";
import { ethers } from "hardhat";

describe("Lock", function () {
  async function deploy() {
    // Contracts are deployed using the first signer/account by default
    const [owner, burnAddress, addr1] = await ethers.getSigners();

    const NameService = await ethers.getContractFactory("RedditNameService");
    const nameService = await NameService.deploy();

    return { nameService, owner };
  }

  describe("Deployment", function () {
    it("Check buy Block", async function () {
      const { nameService, owner } = await loadFixture(deploy);

      await nameService.setName(owner.address, "u/asf");
      console.log(await nameService.getName(owner.address))
      await nameService.setName(owner.address, "u/asf1");
      console.log(await nameService.getName(owner.address))
    });
  });
});
