// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";
import {MerkleProof} from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

contract WhiteListNFT is ERC721, Ownable {
    using Strings for uint256;

    string public constant baseURI = "xxx.xxx/";
    string public baseUriSuffix = ".json";
    bytes32 public merkleRoot;

    uint256 private _tokenIdTracker;
    mapping(address => uint256) private _minted;

    error NotOnWhiteList();
    error ExceedLimit();

    constructor(
        string memory _name,
        string memory _symbol,
        address _owner
    ) ERC721(_name, _symbol) Ownable(_owner) {}

    function whiteListMint(
        uint256 limit,
        uint256 mintQuantity,
        bytes32[] memory merkleProof
    ) external {
        if (!_validateWhiteList(msg.sender, limit, merkleRoot, merkleProof))
            revert NotOnWhiteList();

        if (_minted[msg.sender] + mintQuantity > limit) revert ExceedLimit();

        unchecked {
            _minted[msg.sender] += mintQuantity;
        }

        for (uint256 i; i < mintQuantity; ) {
            _tokenIdTracker += 1;
            _mint(msg.sender, _tokenIdTracker);
            unchecked {
                ++i;
            }
        }
    }

    function validateWhiteList(
        address account,
        uint256 limit,
        bytes32[] memory merkleProof
    ) external view returns (bool valid) {
        return _validateWhiteList(account, limit, merkleRoot, merkleProof);
    }

    function _validateWhiteList(
        address _account,
        uint256 _limit,
        bytes32 _merkleRoot,
        bytes32[] memory _merkleProof
    ) private pure returns (bool valid) {
        bytes32 leaf = keccak256(abi.encodePacked(_account, _limit));
        valid = MerkleProof.verify(_merkleProof, _merkleRoot, leaf);
    }

    function setMerkleRoot(bytes32 _merkleRoot) external onlyOwner {
        merkleRoot = _merkleRoot;
    }

    function _baseURI() internal pure override returns (string memory) {
        return baseURI;
    }

    function tokenURI(
        uint256 tokenId
    ) public view virtual override returns (string memory) {
        _requireOwned(tokenId);
        string memory currentBaseURI = _baseURI();
        return
            bytes(currentBaseURI).length > 0
                ? string(
                    abi.encodePacked(
                        currentBaseURI,
                        tokenId.toString(),
                        baseUriSuffix
                    )
                )
                : "";
    }
}
