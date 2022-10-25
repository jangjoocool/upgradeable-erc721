import "@nomiclabs/hardhat-waffle";
import "@typechain/hardhat";
import "@nomiclabs/hardhat-ethers";
import "@openzeppelin/hardhat-upgrades"
import "@nomiclabs/hardhat-etherscan";
import * as dotenv from "dotenv";

import { HardhatUserConfig } from "hardhat/config";

dotenv.config();

const config: HardhatUserConfig = {
  solidity: "0.8.9",
  networks: {
    mumbai: {
      url: process.env.MUMBAI_URL || '',
      accounts: [process.env.PRIVATE_KEY || '']
    },
    zk: {
      url: "https://public.zkevm-test.net:2083" || "",
      accounts: [process.env.PRIVATE_KEY || '']
    },
    polygon: {
      url: process.env.POLYGON_URL || '',
      accounts: [process.env.PRIVATE_KEY || '']
    }
  },
  etherscan: {
    apiKey: {
      polygon: process.env.POLYGONSCAN_API_KEY || "",
      polygonMumbai: process.env.POLYGONSCAN_API_KEY || ""
    }
  }
};

export default config;
