// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.7;

import "ds-test/test.sol";
import "forge-std/Test.sol";
import "src/SweepDust.sol";
import "src/UniswapV3.sol";

// for cheatcodes
interface USDT {
    function balanceOf(address) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);
}

contract SweepDustTest is Test {
    SweepDust sweeper;
    UniV3Provider uniswap;
    USDT usdt = USDT(0xdAC17F958D2ee523a2206206994597C13D831ec7);
    USDT chz = USDT(0x3506424F91fD33084466F402d5D97f05F8e3b4AF);
    USDT aave = USDT(0x7Fc66500c84A76Ad7e9c93437bFc5Ac33E2DDaE9);
    USDT link = USDT(0x514910771AF9Ca656af840dff83E8264EcF986CA);

    address[] tokens = [
        0x3506424F91fD33084466F402d5D97f05F8e3b4AF,
        0x7Fc66500c84A76Ad7e9c93437bFc5Ac33E2DDaE9,
        0x514910771AF9Ca656af840dff83E8264EcF986CA
    ];

    uint256[] amounts = [
        uint256(900000000000000000000000000),
        uint256(676728891474511811440000),
        uint256(43000000000000000000000000)
    ];

    function setUp() public {
        uniswap = new UniV3Provider(
            0xE592427A0AEce92De3Edee1F18E0157C05861564,
            0xd0A1E359811322d97991E03f863a0C30C2cF029C
        );
        sweeper = new SweepDust(address(uniswap));
    }

    address prankAddress = 0xF977814e90dA44bFA03b6295A0616a897441aceC;

    function testswapERC20() public {
        vm.startPrank(prankAddress);
        emit log_named_uint("USDT bal before", chz.balanceOf(prankAddress));
        chz.approve(address(uniswap), 24497828057911968162000000);
        uniswap.swapERC20(
            address(chz),
            address(usdt),
            2449782196816200,
            prankAddress,
            ""
        );
        emit log_named_uint("USDT bal after", chz.balanceOf(prankAddress));
    }

    function testsweepDust() public {
        vm.startPrank(prankAddress);
        emit log_named_uint("usdt bal before", usdt.balanceOf(prankAddress));
        emit log_named_uint("chz bal before", chz.balanceOf(prankAddress));
        emit log_named_uint("aave bal before", aave.balanceOf(prankAddress));
        emit log_named_uint("link bal before", link.balanceOf(prankAddress));
        chz.approve(address(uniswap), 900000000000000000000000000);
        aave.approve(address(uniswap), 676728891474511811440000);
        link.approve(address(uniswap), 43000000000000000000000000);
        sweeper.sweepDust(
            tokens,
            amounts,
            0xdAC17F958D2ee523a2206206994597C13D831ec7
        );
        emit log_named_uint("chz bal after", chz.balanceOf(prankAddress));
        emit log_named_uint("aave bal after", aave.balanceOf(prankAddress));
        emit log_named_uint("link bal after", link.balanceOf(prankAddress));
        emit log_named_uint("usdt bal after", usdt.balanceOf(prankAddress));
    }
}
