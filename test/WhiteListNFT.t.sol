// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {WhiteListNFT} from "../src/WhiteListNFT/WhiteListNFT.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {IERC721Errors} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract WhiteListNFTTest is Test {
    WhiteListNFT public whiteListNFT;
    address owner = address(0x1);
    address user1 = address(0x11);
    address user2 = address(0x12);
    bytes32 merkle_root =
        0x731262b45de2f20e5fabe69c2bb3e6d0f6c1761eceace1ad610939ccb1c2d1c8;

    bytes32[] public proof;

    function setUp() public {
        whiteListNFT = new WhiteListNFT("Test NFT", "TNFT", owner);
        vm.label(owner, "owner");
    }

    function test_construction() public view {
        assertEq(whiteListNFT.name(), "Test NFT");
        assertEq(whiteListNFT.symbol(), "TNFT");
        assertEq(whiteListNFT.baseURI(), "xxx.xxx/");
    }

    function test_only_owner_can_setMerkleRoot() public {
        vm.expectRevert(
            abi.encodeWithSelector(
                Ownable.OwnableUnauthorizedAccount.selector,
                address(this)
            )
        );
        whiteListNFT.setMerkleRoot(merkle_root);
        assertEq(whiteListNFT.merkleRoot(), 0x0);

        vm.prank(owner);
        whiteListNFT.setMerkleRoot(merkle_root);
        assertEq(whiteListNFT.merkleRoot(), merkle_root);
    }

    function test_only_whiteList_can_mint() public {
        vm.prank(owner);
        whiteListNFT.setMerkleRoot(merkle_root);
        assertEq(whiteListNFT.merkleRoot(), merkle_root);

        // proof error
        vm.prank(address(user1));
        vm.expectRevert(
            abi.encodeWithSelector(WhiteListNFT.NotOnWhiteList.selector)
        );
        whiteListNFT.whiteListMint(3, 1, proof);

        proof.push(
            bytes32(
                0xfc34fa89b74a4ec118e3bbbd28b86f4bc80cb6dbbb38b62b0219ec8a438a0b62
            )
        );
        // account error
        vm.prank(address(user2));
        vm.expectRevert(
            abi.encodeWithSelector(WhiteListNFT.NotOnWhiteList.selector)
        );
        whiteListNFT.whiteListMint(3, 1, proof);

        // limit error
        vm.prank(address(user1));
        vm.expectRevert(
            abi.encodeWithSelector(WhiteListNFT.NotOnWhiteList.selector)
        );
        whiteListNFT.whiteListMint(4, 1, proof);
    }

    function test_mint_limit() public {
        vm.prank(owner);
        whiteListNFT.setMerkleRoot(merkle_root);
        vm.prank(address(user1));
        proof.push(
            bytes32(
                0xfc34fa89b74a4ec118e3bbbd28b86f4bc80cb6dbbb38b62b0219ec8a438a0b62
            )
        );
        vm.expectRevert(
            abi.encodeWithSelector(WhiteListNFT.ExceedLimit.selector)
        );
        whiteListNFT.whiteListMint(3, 4, proof);

        vm.prank(address(user1));
        whiteListNFT.whiteListMint(3, 1, proof);
        assertEq(whiteListNFT.balanceOf(user1), 1);
        assertEq(whiteListNFT.ownerOf(1), address(user1));
        vm.expectRevert(
            abi.encodeWithSelector(
                IERC721Errors.ERC721NonexistentToken.selector,
                2
            )
        );
        whiteListNFT.ownerOf(2);
        vm.prank(address(user1));
        whiteListNFT.whiteListMint(3, 2, proof);
        assertEq(whiteListNFT.balanceOf(user1), 3);
        assertEq(whiteListNFT.ownerOf(2), address(user1));
        assertEq(whiteListNFT.ownerOf(3), address(user1));
    }
}
