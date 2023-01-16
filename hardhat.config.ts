import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import dotenv from "dotenv";

dotenv.config();

const config: HardhatUserConfig = {
  solidity: "0.8.17",

  networks: {
    mumbai: {
      url: process.env.MUMBAI_RPC_URI,
      chainId: 80001,
      accounts: [process.env.PRIVATE_KEY ?? ""],
      timeout: 600000000,
    },
    arbitrum: {
      url: "https://nova.arbitrum.io/rpc",
      chainId: 42170,
      accounts: [process.env.PRIVATE_KEY ?? ""],
      timeout: 600000000,
    },
  },
  etherscan: {
    apiKey: {
      polygonMumbai: process.env.MUMBAI_API_KEY ?? "",
      arbitrumNova: process.env.ARBITRUM_API_KEY || "",
    },
    customChains: [
      {
        network: "arbitrumNova",
        chainId: 42170,
        urls: {
          apiURL: "https://api-nova.arbiscan.io/api",
          browserURL: "https://nova.arbiscan.io",
        },
      },
    ],
  },
};

export default config;
