// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "./UniswapV3.sol";

//Transfer multiple tokens to this contract
//Swap those tokens for required/stable/native token
contract SweepDust is Ownable, ReentrancyGuard {
    using SafeERC20 for IERC20;

    UniV3Provider public dex;

    event sweep(address[] tokensList, uint256[] amount, address requiredToken);

    constructor(address _dex) {
        dex = UniV3Provider(_dex);
    }

    function sweepDust(
        address[] memory tokensList,
        uint256[] memory amount,
        address requiredToken
    ) external nonReentrant {
        uint256 leng = tokensList.length;
        for (uint256 i; i < leng; ) {
            IERC20(tokensList[i]).safeTransferFrom(
                msg.sender,
                address(this),
                amount[i]
            );
            dex.swapERC20(tokensList[i], requiredToken, amount[i], "");
            unchecked {
                ++i;
            }
        }
        emit sweep(tokensList, amount, requiredToken);
    }
}
