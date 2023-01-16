pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract PixelMap is ERC721URIStorage, Ownable {
    uint256 constant ROW_COUNT = 100;
    uint256 constant COL_COUNT = 100;

    address public tokenAddress;
    address public burningWallet;
    uint256 public costForBuy;
    uint256 public costForUpdate;

    uint256[] private allSoldBlocks;

    mapping(address => string) redditNames;

    constructor(
        string memory name,
        string memory symbol,
        address _tokenAddress,
        address _burnAddress,
        uint256 _costForBuy,
        uint256 _costForUpdate
    ) ERC721(name, symbol) {
        tokenAddress = _tokenAddress;
        burningWallet = _burnAddress;
        costForBuy = _costForBuy;
        costForUpdate = _costForUpdate;
    }

    event Named(address indexed user, string indexed name);

    event Buy(address indexed buyer, uint256 x, uint256 y);
    event BatchBuy(address indexed buyer, uint256[] x, uint256[] y);
    event Mint(address indexed owner, uint256 x, uint256 y, string tokenURI);
    event Update(address indexed owner, uint256 x, uint256 y, string tokenURI);

    modifier validBlock(uint256 _x, uint256 _y) {
        require(_isValidBlock(_x, _y), "Out of board");
        _;
    }

    modifier validName(string memory name) {
        bytes memory nameBytes = bytes(name);
        bytes memory prefixBytes = bytes("u/");
        for (uint256 index = 0; index < prefixBytes.length; index++) {
            if (nameBytes[index] != prefixBytes[index]) {
                revert("Invalid Reddit Name");
            }
        }
        _;
    }

    function buy(
        uint256 _x,
        uint256 _y,
        string memory _tokenURI
    ) external validBlock(_x, _y) {
        IERC20(tokenAddress).transferFrom(
            msg.sender,
            burningWallet,
            costForBuy
        );

        _buy(_x, _y, _tokenURI);

        emit Buy(msg.sender, _x, _y);
    }

    function batchBuy(
        uint256[] memory _x,
        uint256[] memory _y,
        string[] memory _tokenURIs
    ) external {
        require(
            _x.length == _y.length && _x.length == _tokenURIs.length,
            "Array length mismatch"
        );

        IERC20(tokenAddress).transferFrom(
            msg.sender,
            burningWallet,
            costForBuy * _x.length
        );

        for (uint256 index = 0; index < _x.length; index++) {
            require(_isValidBlock(_x[index], _y[index]), "Invalid block");

            _buy(_x[index], _y[index], _tokenURIs[index]);
        }

        emit BatchBuy(msg.sender, _x, _y);
    }

    function update(
        uint256 _x,
        uint256 _y,
        string memory _tokenURI
    ) external validBlock(_x, _y) {
        uint256 blockId = _x * 100 + _y;
        require(_ownerOf(blockId) == msg.sender, "Not owner");

        if (costForUpdate > 0) {
            IERC20(tokenAddress).transferFrom(
                msg.sender,
                burningWallet,
                costForUpdate
            );
        }

        _setTokenURI(blockId, _tokenURI);

        emit Update(msg.sender, _x, _y, _tokenURI);
    }

    function setName(string memory name) external validName(name) {
        address sender = msg.sender;
        redditNames[sender] = name;

        emit Named(sender, name);
    }

    function getName(address user) public view returns (string memory) {
        return redditNames[user];
    }

    function ownerOfBlock(uint256 _x, uint256 _y)
        public
        view
        validBlock(_x, _y)
        returns (address)
    {
        return ownerOf(_x * 100 + _y);
    }

    function getBlockInfo(uint256 _x, uint256 _y)
        public
        view
        validBlock(_x, _y)
        returns (
            address owner,
            string memory uri,
            string memory name
        )
    {
        uint256 blockId = _x * 100 + _y;
        address blockOwner = ownerOf(blockId);
        require(blockOwner != address(0), "No owner yet");
        return (blockOwner, tokenURI(blockId), redditNames[blockOwner]);
    }

    function getAllSoldBlocks() public view returns (uint256[] memory) {
        return allSoldBlocks;
    }

    function setBurningWallet(address _burningWallet) external onlyOwner {
        burningWallet = _burningWallet;
    }

    function setCostForBuy(uint256 _costForBuy) external onlyOwner {
        costForBuy = _costForBuy;
    }

    function setCostForUpdate(uint256 _costForUpdate) external onlyOwner {
        costForUpdate = _costForUpdate;
    }

    function _isValidBlock(uint256 _x, uint256 _y)
        internal
        pure
        returns (bool)
    {
        return _x < ROW_COUNT && _y < COL_COUNT;
    }

    function _buy(
        uint256 _x,
        uint256 _y,
        string memory _tokenURI
    ) internal {
        uint256 blockId = _x * 100 + _y;

        require(_ownerOf(blockId) == address(0), "Already sold");

        allSoldBlocks.push(blockId);

        _mint(msg.sender, blockId);
        _setTokenURI(blockId, _tokenURI);
    }
}
