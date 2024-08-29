// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {WhiteListNFT} from "../src/WhiteListNFT/WhiteListNFT.sol";

contract WhiteListNFTScript is Script {
    WhiteListNFT public whiteListNFT;

    function setUp() public {}

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address deployerAddress = vm.addr(deployerPrivateKey);

        console.log("Deployer Address:", deployerAddress);

        vm.startBroadcast(deployerPrivateKey);
        whiteListNFT = new WhiteListNFT("Test NFT", "TNFT", deployerAddress);

        bytes32 merkle_root = 0x731262b45de2f20e5fabe69c2bb3e6d0f6c1761eceace1ad610939ccb1c2d1c8;
        whiteListNFT.setMerkleRoot(merkle_root);

        vm.stopBroadcast();
    }
}
