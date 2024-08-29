// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import {Test, console} from "forge-std/Test.sol";
import {Staker} from "../src/Staker/Staker.sol";
import {Token} from "../src/Token/Token.sol";
import {NFT} from "../src/NFT/NFT.sol";
import {IERC721Errors} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import { UD60x18, ud } from "@prb/math/src/UD60x18.sol";

contract StakerTest is Test {
    Staker public staker;
    NFT public nft;
    Token public token;
    address owner = address(0x1);
    address user1 = address(0x11);
    address user2 = address(0x12);

    function setUp() public {
        nft = new NFT("Test NFT", "TNFT", owner);
        vm.prank(owner);
        token = new Token("Test Token", "TST", 1e20 * 10 ** 18);
        staker = new Staker(address(nft), address(token), 1.1e4);

        vm.prank(owner);
        nft.mint(user1);
        vm.prank(owner);
        token.transfer(address(staker), 1e20 * 10 ** 18);

        assertEq(nft.ownerOf(1), user1);
        vm.label(owner, "owner");
    }

    function test_construction() public view {
        assertEq(staker.rewardToken(), address(token));
        assertEq(staker.stakeNFT(), address(nft));
        assertEq(staker.interestMultiplierPoints(), 1.1e4);
    }

    function test_stake() public {
        vm.prank(user1);
        nft.setApprovalForAll(address(staker), true);
        vm.prank(user1);
        staker.stake(1);
        assertEq(nft.ownerOf(1), address(staker));
    }

    function test_claim() public {
        vm.prank(user1);
        nft.setApprovalForAll(address(staker), true);
        vm.prank(user1);
        staker.stake(1);
        assertEq(nft.ownerOf(1), address(staker));

        vm.warp(vm.getBlockTimestamp() + 1 days);
        vm.prank(user1);
        staker.claimRewards(1);
        assertEq(token.balanceOf(user1), 100e18);

        vm.warp(vm.getBlockTimestamp() + 200 days);
        vm.prank(user1);
        staker.claimRewards(1);
        assertEq(token.balanceOf(user1), 208895803106508006633311787634);
    }

    function test_unstake_and_restake() public {
        vm.prank(user1);
        nft.setApprovalForAll(address(staker), true);
        vm.prank(user1);
        staker.stake(1);
        vm.warp(vm.getBlockTimestamp() + 1 days);
        vm.prank(user1);
        staker.unstake(1);
        assertEq(nft.ownerOf(1), user1);
        
        assertEq(token.balanceOf(user1), 100e18);

        
        vm.prank(user1);
        staker.stake(1);
        assertEq(nft.ownerOf(1), address(staker));

        vm.warp(vm.getBlockTimestamp() + 2 days);
        vm.prank(user1);
        staker.unstake(1);
        assertEq(nft.ownerOf(1), user1);
        
        assertEq(token.balanceOf(user1), 310e18);
    }
}
