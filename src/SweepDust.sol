// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "./UniswapV3.sol";

/// @title SweepDust
/// @notice Allows users to swap small balance tokens into a single token

contract SweepDust is Ownable, ReentrancyGuard {
    using SafeERC20 for IERC20;

    /// @notice UniswapV3 implementation address
    UniV3Provider public dex;

    address private constant NATIVE_TOKEN_ADDRESS =
        address(0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE);

    /// @notice Events
    event Sweep(address[] tokensList, uint256[] amount, address requiredToken);

    constructor(address _dex) {
        dex = UniV3Provider(_dex);
    }

    /// @notice This function is responsible for swapping multiple tokens into a single token
    /// @dev This contract uses UniswapV3 for swapping
    /// @param tokensList List of ERC20 tokenAddresses to swap
    /// @param amount Amount of tokens to swap
    /// @param requiredToken Address of required ERC20 token
    function sweepDust(
        address[] memory tokensList,
        uint256[] memory amount,
        address requiredToken,
        address receiver
    ) external nonReentrant {
        require(requiredToken != address(0), "zero-check");

        uint256 amountOut = _sweep(tokensList, amount, requiredToken);

        IERC20(requiredToken).safeTransfer(receiver, amountOut);

        emit Sweep(tokensList, amount, requiredToken);
    }

    function _sweep(
        address[] memory tokensList,
        uint256[] memory amount,
        address requiredToken
    ) internal returns (uint256 amountOut) {
        uint256 leng = tokensList.length;

        for (uint8 i; i < leng; ) {
            uint256 _amountOut = dex.swapERC20(
                tokensList[i],
                requiredToken,
                amount[i],
                msg.sender
            );
            amountOut += _amountOut;

            unchecked {
                ++i;
            }
        }
        return amountOut;
    }

    /**
	// @notice function responsible to rescue funds if any
	// @param  tokenAddr address of token
	 */
    function rescueFunds(address tokenAddr) external onlyOwner nonReentrant {
        if (tokenAddr == NATIVE_TOKEN_ADDRESS) {
            uint256 balance = address(this).balance;
            payable(msg.sender).transfer(balance);
        } else {
            uint256 balance = IERC20(tokenAddr).balanceOf(address(this));
            IERC20(tokenAddr).transferFrom(address(this), msg.sender, balance);
        }
    }
}
