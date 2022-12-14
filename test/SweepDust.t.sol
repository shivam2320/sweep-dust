// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.7;

import "ds-test/test.sol";
import "src/SweepDust.sol";

// for cheatcodes
interface Vm {
    function prank(address) external;
}

interface USDT {
    function balanceOf(address) external view returns (uint256);
}

contract SweepDustTest is DSTest {
    SweepDust sweepDust;

    function setUp() public {
        sweepDust = new SweepDust();
    }

    function testsweepDust() public {}
}
