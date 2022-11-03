//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.9;

import "@openzeppelin/contracts-upgradeable/utils/CountersUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721URIStorageUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/math/SafeMathUpgradeable.sol";
import "./lib/IERC5192.sol";

contract FDT is Initializable, ERC721URIStorageUpgradeable, IERC5192, OwnableUpgradeable, UUPSUpgradeable {
    using SafeMathUpgradeable for uint256;
    using CountersUpgradeable for CountersUpgradeable.Counter;

    struct User {
        bytes32 id;
        string class;
        string name;
    }

    CountersUpgradeable.Counter private _tokenIds;
    mapping(bytes32 => bool) private _whiteList;
    mapping(uint256 => User) private _user;
    mapping(uint256 => bool) private _lock;
    mapping(bytes32 => address) private _registedUser;
    uint256 private _generateCodeCount;
    string private _neighborhoodURI;

    function initialize() initializer public {
        __ERC721_init("Figlio De Taejon", "FDT");
        __UUPSUpgradeable_init();
        __Ownable_init();
    }

    function _authorizeUpgrade(address newImplementation) internal override onlyOwner {}

    /**
        whiteList
     */
    function generateWhiteListCode(uint256 count) external onlyOwner returns(bytes32[] memory) {
        bytes32[] memory result = new bytes32[](count);
        for(uint256 i = 0; i < count; i++) {
            bytes32 whiteListCode = keccak256(abi.encodePacked(block.timestamp, i, _generateCodeCount, "Figlio De Taejon"));
            _whiteList[whiteListCode] = true;
            result[i] = whiteListCode;
            _generateCodeCount++;
        }
        return result;
    }

    /**
        URI
     */
    function setNeighborhoodURI(string memory uri) external onlyOwner {
        _neighborhoodURI = uri;
    }

    function neighborhoodURI() internal view returns(string memory) {
        return _neighborhoodURI;
    }

    function tokenURI(uint256 tokenId) public view override returns(string memory) {
        if(keccak256(abi.encodePacked(_user[tokenId].class)) == keccak256(abi.encodePacked("Brotherhood"))) {
            super.tokenURI(tokenId);
        }
        return neighborhoodURI();
    }

    /*
        Mint & Burn
     */
    function mintForNeighborhood(address recipient, bytes32 userId, string calldata userName) public {
        require(_whiteList[userId], "Caller is Not Whitelist");
        require(_registedUser[userId] == address(0), "Caller is already registed");

        uint256 id = _tokenIds.current();
        _mint(recipient, id);
        _user[id] = User(userId, "Neighborhood", userName);
        lock(id);
        _tokenIds.increment();
    }

    function burn(uint256 tokenId) public {
        require((_msgSender() == ownerOf(tokenId)) || (_msgSender() == owner()),
            "Caller is not the owner or has not the token");
        delete _lock[tokenId];
        _burn(tokenId);
    }

    /*
        User
    */
    function setUser(uint256 tokenId, User memory userInfo) internal onlyOwner {
        _user[tokenId] = userInfo;
    }

    function classAdvancement(uint256 tokenId, string calldata class_) internal onlyOwner {
        _user[tokenId].class = class_;
    }

    /*
        Lock
     */
    function locked(uint256 tokenId) public view override returns (bool) {
        return _lock[tokenId];
    }

    function lock(uint256 tokenId) public onlyOwner {
        _lock[tokenId] = true;
        emit Locked(tokenId);
    }

    function unlock(uint256 tokenId) public onlyOwner {
        _lock[tokenId] = false;
        emit Unlocked(tokenId);
    }

    function _beforeTokenTransfer(address from, address to, uint256 tokenId) internal virtual override {
        require(locked(tokenId) != true, "token is locked");
    }
}
