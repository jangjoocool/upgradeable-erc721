//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.9;

import "@openzeppelin/contracts-upgradeable/utils/CountersUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721URIStorageUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "./lib/IERC5192.sol";

contract FDT is Initializable, ERC721URIStorageUpgradeable, IERC5192, OwnableUpgradeable, UUPSUpgradeable {
    using CountersUpgradeable for CountersUpgradeable.Counter;
    CountersUpgradeable.Counter private _tokenIds;
    mapping(uint256 => bool) private lock;

    function initialize() initializer public {
        __ERC721_init("Figlio De Taejon", "FDT");
        __UUPSUpgradeable_init();
        __Ownable_init();
    }

    function mintNFTWithLock(address recipient, string memory tokenURI) public {
        uint256 id = _tokenIds.current();
        _mint(recipient, id);
        _setTokenURI(id, tokenURI);
        lock[id] = true;
        emit Locked(id);
        _tokenIds.increment();
    }
    
    function locked(uint256 tokenId) public view returns (bool) {
        return lock[tokenId];
    }

    function burn(uint256 tokenId) public onlyOwner {
        _burn(tokenId);
    }

    function _beforeTokenTransfer(address from, address to, uint256 tokenId) internal virtual override {
        require(locked(tokenId) == false, "token is locked");
    }

    function _authorizeUpgrade(address newImplementation) internal override onlyOwner {}
}
