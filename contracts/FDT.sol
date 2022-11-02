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
        string id;
        address userAddress;
        string class;
        string name;
    }

    CountersUpgradeable.Counter private _tokenIds;
    mapping(uint256 => bool) private _lock;
    mapping(uint256 => User) private _user;
    mapping(string => uint256) private _voting;
    mapping(string => uint256) private _nextVoting;
    uint64 private currentYear;

    function initialize() initializer public {
        __ERC721_init("testing", "TEST");
        __UUPSUpgradeable_init();
        __Ownable_init();
    }

    function _authorizeUpgrade(address newImplementation) internal override onlyOwner {}

    /*
        TEST
     */
    function mintForTest(address recipient) public onlyOwner {
        uint256 maxCount = 100;
        for(uint256 i = 0; i < maxCount;i++) {
            uint256 id = _tokenIds.current();
            _mint(recipient, id);
            _tokenIds.increment();
            lock(id);
            User memory userInfo = User(
                "test-ID",
                recipient,
                "test-class",
                "test-name"
            );
            setUser(id, userInfo);
        }
        // while(_tokenIds.current() > maxCount) {
        //     uint256 id = _tokenIds.current();
        //     _mint(recipient, id);
        //     _tokenIds.increment();
        //     lock(id);
        //     User memory userInfo = User(
        //         "test-ID",
        //         recipient,
        //         "test-class",
        //         "test-name"
        //     );
        //     setUser(id, userInfo);
        // }
    }

    /*
        Mint & Burn
     */
    function mintWithLock(address recipient, string calldata tokenURI, User calldata userInfo) public {
        uint256 id = _tokenIds.current();
        setUser(id, userInfo);
        _mint(recipient, id);
        _setTokenURI(id, tokenURI);
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
    function setUser(uint256 tokenId, User memory userInfo) public onlyOwner {
        // require(address(0) == _user[tokenId].userAddress, "User already existed");
        _user[tokenId] = userInfo;
        addVoting(tokenId);
    }

    function classAdvancement(uint256 tokenId, string calldata class_) public onlyOwner {
        _user[tokenId].class = class_;
    }

    /*
        Voting
     */
    function votingOf(uint256 tokenId) public view returns(uint256) {
        return _voting[_user[tokenId].id];
    }

    function addVoting(uint256 tokenId) internal onlyOwner {
        string memory userId = _user[tokenId].id;
        _voting[userId] = _voting[userId].add(1);
    }

    function addNextVoting(uint256 tokenId) internal onlyOwner {
        string memory userId = _user[tokenId].id;
        _nextVoting[userId] = _nextVoting[userId].add(1);
    }

    function changeToNextVoting() external onlyOwner {
        uint256 currentTokenId = _tokenIds.current();
        for(uint256 i = 0; i < currentTokenId ;i++) {
            if(ownerOf(i) != address(0)) {
                string memory userId = _user[i].id;
                _voting[userId] = _nextVoting[userId];
            }
        }
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
