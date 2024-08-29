// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {Token} from "../src/Token/Token.sol";

contract TokenScript is Script {
    Token public token;

    function setUp() public {}

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address deployerAddress = vm.addr(deployerPrivateKey);

        console.log("Deployer Address:", deployerAddress);

        vm.startBroadcast(deployerPrivateKey);

        token = new Token("Test Token", "TST", 1e20 * 10 ** 18);

        vm.stopBroadcast();
    }
}
