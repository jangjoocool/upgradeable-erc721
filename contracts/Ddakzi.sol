//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.9;

import "@openzeppelin/contracts-upgradeable/utils/CountersUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721URIStorageUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

contract Ddakzi is Initializable, ERC721URIStorageUpgradeable, OwnableUpgradeable, UUPSUpgradeable {
    using CountersUpgradeable for CountersUpgradeable.Counter;
    CountersUpgradeable.Counter private _tokenIds;

    function initialize() initializer public {
        __ERC721_init("DDAKZI", "DKZ");
        __UUPSUpgradeable_init();
        __Ownable_init();
    }

    function mintNFT(address recipient, string memory tokenURI) public {
        uint256 id = _tokenIds.current();
        _mint(recipient, id);
        _setTokenURI(id, tokenURI);
        _tokenIds.increment();
    }
    
    function burn(uint256 tokenId) public onlyOwner {
        _burn(tokenId);
    }

    function _authorizeUpgrade(address newImplementation) internal override onlyOwner {}
}
