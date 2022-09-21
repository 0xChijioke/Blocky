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
    address blockToken;
    uint256 regenTime = 60;



    struct CharacterAttributes {
        uint256 characterIndex;
        string name;
        string imageURI;
        uint256 hp;
        uint256 maxHp;
        uint256[] attacks;
        uint256[] specialAttacks;
        uint256 lastRegenTime;
    }

    struct AttackType {
        uint256 attackIndex;
        string attackName;
        uint256 attackDamage;
        string attackImage;
    }

    struct SpecialAttackType {
        uint256 price;
        uint256 specialAttackIndex;
        string specialAttackName;
        uint256 specialAttackDamage;
        string specialAttackImage;
    }

    AttackType[] allAttacks;
    SpecialAttackType[] allSpecialAttacks;

    struct MadBots {
        string name;
        string imageURI;
        uint256 hp;
        uint256 maxHp;
        uint256 attackDamage;
    }

    MadBots public madBots;

    CharacterAttributes[] defaultCharacters;

    mapping(uint256 => CharacterAttributes) public nftHolderAttributes;
    mapping(address => uint256) public nftHolders;


     event CharacterNFTMinted(
        address sender,
        uint256 tokenId,
        uint256 characterIndex
    );
    event AttackComplete(uint256 newBotHp, uint256 newPlayerHp);
    event RegenCompleted(uint256 newHp);


    constructor(
        string[] memory characterName,
        string[] memory characterImageURI,
        uint256[] memory characterMaxHp,
        uint256[][] memory characterAttacks,
        string memory botName,
        string memory botImageURI,
        uint256 botHp,
        uint256 botAttackDamage,
        address blockTokenAddress
    ) ERC721("Hero", "HERO") {
        blockToken = blockTokenAddress;
        for (uint256 i = 0; i < characterName.length; i++) {
            CharacterAttributes memory charAttribute;
            charAttribute.characterIndex = i;
            charAttribute.name = characterName[i];
            charAttribute.imageURI = characterImageURI[i];
            charAttribute.hp = characterMaxHp[i];
            charAttribute.maxHp = characterMaxHp[i];
            charAttribute.attacks = characterAttacks[i];
            defaultCharacters.push(charAttribute);
        }
        _tokenIds.increment();
        madBots = MadBots({
            name: botName,
            imageURI: botImageURI,
            hp: botHp,
            maxHp: botHp,
            attackDamage: botAttackDamage
        });
    }


        function addAttacks(
        // All the attacks for each character
        string[] memory attackNames,
        string[] memory attackImages,
        uint256[] memory attackDamages,
        uint256[] memory attackIndexes
    ) public onlyOwner {
        for (uint256 j = 0; j < attackIndexes.length; j++) {
            allAttacks.push(
                AttackType(
                    attackIndexes[j],
                    attackNames[j],
                    attackDamages[j],
                    attackImages[j]
                )
            );
        }
    }

    function addSpecialAttacks(
        // All the special attacks for each character
        string[] memory specialAttackNames,
        string[] memory specialAttackImages,
        uint256[] memory specialAttackDamages,
        uint256[] memory specialAttackPrices,
        uint256[] memory specialAttackIndexes
    ) public onlyOwner {
        for (uint256 j = 0; j < specialAttackIndexes.length; j++) {
            allSpecialAttacks.push(
                SpecialAttackType(
                    specialAttackPrices[j],
                    specialAttackIndexes[j],
                    specialAttackNames[j],
                    specialAttackDamages[j],
                    specialAttackImages[j]
                )
            );
        }
    }


 function mintCharacterNFT(uint256 _characterIndex) external payable {
        require(
            _characterIndex < defaultCharacters.length,
            "Character index out of bounds"
        );
        require(
            IERC20(blockToken).allowance(msg.sender, address(this)) >= 10 ether,
            "Please approve the required token transfer before minting"
        );
        IERC20(blockToken).transferFrom(msg.sender, address(this), 10 ether);
        uint256 newItemId = _tokenIds.current();
        _safeMint(msg.sender, newItemId);
        nftHolderAttributes[newItemId] = CharacterAttributes({
            characterIndex: _characterIndex,
            name: defaultCharacters[_characterIndex].name,
            imageURI: defaultCharacters[_characterIndex].imageURI,
            hp: defaultCharacters[_characterIndex].hp,
            maxHp: defaultCharacters[_characterIndex].maxHp,
            attacks: defaultCharacters[_characterIndex].attacks,
            specialAttacks: defaultCharacters[_characterIndex].specialAttacks,
            lastRegenTime: block.timestamp
        });
        nftHolders[msg.sender] = newItemId;
        _tokenIds.increment();
        emit CharacterNFTMinted(msg.sender, newItemId, _characterIndex);
    }



    function claimHealth() external {
            require(
                nftHolders[msg.sender] != 0,
                "You don't have a character to claim health"
            );
            require(
                IERC20(blockToken).allowance(msg.sender, address(this)) >= 0.1 ether,
                "Please approve the required token transfer before minting"
            );
            IERC20(blockToken).transferFrom(msg.sender, address(this), 0.1 ether);
            uint256 tokenId = nftHolders[msg.sender];
            CharacterAttributes memory character = nftHolderAttributes[tokenId];
            uint256 currentTime = block.timestamp;
            uint256 timeSinceLastRegen = currentTime - character.lastRegenTime;

            if (timeSinceLastRegen > regenTime) {
                uint256 newHp = character.hp + timeSinceLastRegen.div(60);
                if (newHp > character.maxHp) {
                    newHp = character.maxHp;
                }
                character.hp = newHp;
                character.lastRegenTime = currentTime;
                nftHolderAttributes[tokenId] = character;
                emit RegenCompleted(newHp);
            }
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