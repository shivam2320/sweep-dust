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

    /// @notice This function is responsible for swapping multiple tokens into a single token
    /// @dev Explain to a developer any extra details
    /// @param tokensList List of ERC20 tokenAddresses to swap
    /// @param amount Amount of tokens to swap
    /// @param requiredToken
    function sweepDust(
        address[] memory tokensList,
        uint256[] memory amount,
        address requiredToken
    ) external nonReentrant {
        _swapForERC20(tokensList, amount, requiredToken);
        emit sweep(tokensList, amount, requiredToken);
    }

    function _swapForERC20(
        address[] memory tokensList,
        uint256[] memory amount,
        address requiredToken
    ) internal {
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
    }
}
