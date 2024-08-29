// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {StakerV2} from "../src/Staker/StakerV2.sol";
import {Token} from "../src/Token/Token.sol";

contract StakerV2Script is Script {
    StakerV2 public staker;

    function setUp() public {}

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address deployerAddress = vm.addr(deployerPrivateKey);

        console.log("Deployer Address:", deployerAddress);
        address rewardTokenAddress = vm.envAddress("REWARD_TOKEN");
        address stakeNftAddress = vm.envAddress("STAKE_NFT");

        vm.startBroadcast(deployerPrivateKey);

        staker = new StakerV2(
            address(stakeNftAddress),
            rewardTokenAddress,
            1.1e18
        );
        Token(rewardTokenAddress).transfer(address(staker), 1e10 * 10 ** 18);

        vm.stopBroadcast();
    }
}
