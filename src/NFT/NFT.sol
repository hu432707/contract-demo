// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";

contract NFT is ERC721, Ownable {
    using Strings for uint256;

    string public constant baseURI = "xxx.xxx/";
    string public constant baseUriSuffix = ".json";

    uint256 private _tokenIdTracker;

    constructor(
        string memory _name,
        string memory _symbol,
        address _owner
    ) ERC721(_name, _symbol) Ownable(_owner) {}

    function mint(address to) external onlyOwner {
        _tokenIdTracker += 1;
        _mint(to, _tokenIdTracker);
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
