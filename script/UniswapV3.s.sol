// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "src/UniswapV3.sol";

contract UniV3ProviderScript is Script {
    function setUp() public {}

    function run() public {
        vm.broadcast();
        UniV3Provider uni = new UniV3Provider(
            0xE592427A0AEce92De3Edee1F18E0157C05861564,
            0x0d500B1d8E8eF31E21C99d1Db9A6444d3ADf1270
        );
    }
}
