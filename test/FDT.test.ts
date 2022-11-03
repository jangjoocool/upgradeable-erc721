import { waffle } from 'hardhat';
import { expect } from 'chai';
import { deployContract } from 'ethereum-waffle';

import FDTArtifact from '../artifacts/contracts/FDT.sol/FDT.json';
import { FDT } from '../typechain-types/contracts/FDT'

describe("FDT", async () => {
    let contract: FDT;
    
    const provider = waffle.provider;
    const [ADMIN, USER] = provider.getWallets();
    const ADMIN_ADDRESS = await ADMIN.getAddress();
    const USER_ADDRESS = await USER.getAddress();

    const TOKEN_ID = 0;
    const TOKEN_URI = 'https://bafkreibfr5jkq75mi2lzjqdmazsqfkwdkldx7cixuifcnpgxwqzks4yysi.ipfs.nftstorage.link/';

    beforeEach(async () => {
        contract = await deployContract(
            ADMIN,
            FDTArtifact
        ) as FDT

        // await contract.connect(ADMIN).mintNFT(ADMIN_ADDRESS,TOKEN_URI);
    });

    context('Deploy', async () => {
        it('has given data', async () => {
            expect(await contract.name()).to.be.equal("Figlio De Taejon")
            expect(await contract.symbol()).to.be.equal("FDT")
        })
    });

    context('Whitelist', async () => {
        it('generate code', async () => {
            
        })
    });

    // context('Mint', async () => {
    //     it('Minting', async () => {
    //         await contract.connect(ADMIN).mintNFT(ADMIN_ADDRESS,TOKEN_URI);
    //         expect(await contract.balanceOf(ADMIN_ADDRESS)).to.be.equal(2);
    //     })
    // });
    
    // context('Burn', async () => {
    //     it('Burning', async () => {
    //         await contract.connect(ADMIN).burn(TOKEN_ID);
    //         expect(await contract.balanceOf(ADMIN_ADDRESS)).to.be.equal(0);
    //     })
    // });

    // context('Transfer', async () => {
    //     it('SafeTransferFrom', async () => {
    //         await contract.connect(ADMIN)['safeTransferFrom(address,address,uint256)'](ADMIN_ADDRESS, USER_ADDRESS, TOKEN_ID);
    //         expect(await contract.balanceOf(ADMIN_ADDRESS)).to.be.equal(0);
    //         expect(await contract.balanceOf(USER_ADDRESS)).to.be.equal(1);
    //     })
    // })
});