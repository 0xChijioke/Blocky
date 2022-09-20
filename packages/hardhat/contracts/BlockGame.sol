pragma solidity >=0.8.0 <0.9.0;
//SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "base64-sol/base64.sol";
import "hardhat/console.sol";

contract BlockGame is ERC721, ReentrancyGuard, Ownable {

    using Counters for Counters.Counter;
    using SafeMath for uint256;

    Counters.Counter private _tokenIds;
    address epicToken;
    uint256 regenTime = 60;

    function mint(uint id)
    external
    {
        
    }

    
    /********************
    Utility Stuff Starts
    *********************/

    function getRandomNumber() public view returns (uint )
    {
        bytes32 res = getRandom();
        uint256 num = uint256(res);
        return num;
    }

    function getRandom() private view returns (bytes32 addr) {
        assembly {
            let freemem := mload(0x40)
            let start_addr := add(freemem, 0)
            if iszero(staticcall(gas(), 0x18, 0, 0, start_addr, 32)) {
                invalid()
            }
            addr := mload(freemem)
        }
    }


    /********************
    Utility Stuff Ends
    *********************/
}