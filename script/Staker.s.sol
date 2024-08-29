// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {Staker} from "../src/Staker/Staker.sol";
import {Token} from "../src/Token/Token.sol";

contract StakerScript is Script {
    Staker public staker;

    function setUp() public {}

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address deployerAddress = vm.addr(deployerPrivateKey);

        console.log("Deployer Address:", deployerAddress);
        address rewardTokenAddress = vm.envAddress("REWARD_TOKEN");
        address stakeNftAddress = vm.envAddress("STAKE_NFT");

        vm.startBroadcast(deployerPrivateKey);

        staker = new Staker(
            address(stakeNftAddress),
            rewardTokenAddress,
            11000
        );
        Token(rewardTokenAddress).transfer(address(staker), 1e10 * 10 ** 18);

        vm.stopBroadcast();
    }
}
