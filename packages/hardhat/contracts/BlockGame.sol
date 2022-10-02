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
        string imageURI;
        uint256 hp;
        uint256 attackDamage;
    }

    MadBots public madBots;

    CharacterAttributes[] defaultCharacters;

    mapping(uint256 => CharacterAttributes) public nftHolderAttributes;
    mapping(address => uint256) public nftHolders;


     event CharacterNFTMinted(
        address sender,
        uint256 tokenId
    );
    event AttackComplete(uint256 newBotHp, uint256 newPlayerHp);
    event RegenCompleted(uint256 newHp);


     constructor(
        string memory characterName,
        string memory characterImageURI,
        uint256 characterMaxHp,
        uint256[] memory characterAttacks,
        string memory botImageURI,
        uint256 botHp,
        uint256 botAttackDamage,
        address blockTokenAddress
    ) ERC721("Heroes", "HERO") {
        blockToken = blockTokenAddress;
            CharacterAttributes memory charAttribute;
            charAttribute.name = characterName;
            charAttribute.imageURI = characterImageURI;
            charAttribute.hp = characterMaxHp;
            charAttribute.maxHp = characterMaxHp;
            charAttribute.attacks = characterAttacks;
            defaultCharacters.push(charAttribute);
        
        _tokenIds.increment();
        madBots = MadBots({
            imageURI: botImageURI,
            hp: botHp,
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
        
     function mintCharacterNFT() external payable {
        
        // require(
        //     IERC20(blockToken).allowance(msg.sender, address(this)) >= 10 ether,
        //     "Please approve the required token transfer before minting"
        // );
        // IERC20(blockToken).transferFrom(msg.sender, address(this), 10 ether);
        uint256 newItemId = _tokenIds.current();
        _safeMint(msg.sender, newItemId);
        nftHolderAttributes[newItemId] = CharacterAttributes({
            name: defaultCharacters[0].name,
            imageURI: defaultCharacters[0].imageURI,
            hp: defaultCharacters[0].hp,
            maxHp: defaultCharacters[0].maxHp,
            attacks: defaultCharacters[0].attacks,
            specialAttacks: defaultCharacters[0].specialAttacks,
            lastRegenTime: block.timestamp
        });
        nftHolders[msg.sender] = newItemId;
        _tokenIds.increment();
        emit CharacterNFTMinted(msg.sender, newItemId);
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

    function attackBot(uint256 attackIndex) public {
        uint256 nftTokenIdOfPlayer = nftHolders[msg.sender];
        CharacterAttributes storage player = nftHolderAttributes[
            nftTokenIdOfPlayer
        ];
        require(player.hp > 0, "Error: character must have HP to attack bots.");
        require(madBots.hp > 0, "Error: bot is already dead");
        uint256 attackDamage = 0;
        for (uint256 i = 0; i < player.attacks.length; i++) {
            if (attackIndex == player.attacks[i]) {
                attackDamage = allAttacks[attackIndex].attackDamage;
            }
        }
        require(attackDamage > 0, "Error: attack must have damage.");
        if (madBots.hp < attackDamage) {
            madBots.hp = 0;
        } else {
            madBots.hp = madBots.hp - attackDamage;
        }

        if (player.hp < madBots.attackDamage) {
            player.hp = 0;
        } else {
            player.hp = player.hp - madBots.attackDamage;
        }
        emit AttackComplete(madBots.hp, player.hp);
    }

    function buySpecialAttack(uint256 specialAttackIndex) public payable {
        uint256 nftTokenIdOfPlayer = nftHolders[msg.sender];
        require(
            nftTokenIdOfPlayer > 0,
            "Error: must have NFT to buy special attack."
        );

        CharacterAttributes storage player = nftHolderAttributes[
            nftTokenIdOfPlayer
        ];
        require(
            IERC20(blockToken).allowance(msg.sender, address(this)) >=
                allSpecialAttacks[specialAttackIndex].price,
            "Error: user must provide enough token to buy special attack."
        );
        IERC20(blockToken).transferFrom(
            msg.sender,
            address(this),
            allSpecialAttacks[specialAttackIndex].price
        );
        player.specialAttacks.push(specialAttackIndex);
        emit AttackComplete(madBots.hp, player.hp);
    }


    function checkIfUserHasNFT()
        public
        view
        returns (CharacterAttributes memory)
    {
        uint256 userNftTokenId = nftHolders[msg.sender];
        if (userNftTokenId > 0) {
            return nftHolderAttributes[userNftTokenId];
        } else {
            CharacterAttributes memory emptyStruct;
            return emptyStruct;
        }
    }

    function getAllDefaultCharacters()
        public
        view
        returns (CharacterAttributes[] memory)
    {
        return defaultCharacters;
    }

    function getAllAttacks() public view returns (AttackType[] memory) {
        return allAttacks;
    }

    function getAllSpecialAttacks()
        public
        view
        returns (SpecialAttackType[] memory)
    {
        return allSpecialAttacks;
    }


    function getMadBots() public view returns (MadBots memory) {
        return madBots;
    }


    function tokenURI(uint256 _tokenId)
        public
        view
        override
        returns (string memory)
    {
        CharacterAttributes memory charAttributes = nftHolderAttributes[
            _tokenId
        ];
        string memory strHp = Strings.toString(charAttributes.hp);
        string memory strMaxHp = Strings.toString(charAttributes.maxHp);

        string memory specialAttacksStr = "";
        string memory attacksStr = "";

        for (uint256 i = 0; i < charAttributes.specialAttacks.length; i++) {
            uint256 index = charAttributes.specialAttacks[i];
            specialAttacksStr = string(
                abi.encodePacked(
                    specialAttacksStr,
                    ', {"trait_type": "Special Attack - ',
                    allSpecialAttacks[index].specialAttackName,
                    '", "value": ',
                    Strings.toString(
                        allSpecialAttacks[index].specialAttackDamage
                    ),
                    '"}'
                )
            );
        }

        for (uint256 i = 0; i < charAttributes.attacks.length; i++) {
            uint256 index = charAttributes.attacks[i];
            attacksStr = string(
                abi.encodePacked(
                    attacksStr,
                    ', {"trait_type": "',
                    allAttacks[index].attackName,
                    '", "value": ',
                    Strings.toString(allAttacks[index].attackDamage),
                    "}"
                )
            );
        }

        string memory json = Base64.encode(
            bytes(
                string(
                    abi.encodePacked(
                        '{"name": "',
                        charAttributes.name,
                        " -- NFT #: ",
                        Strings.toString(_tokenId),
                        '", "description": "This is an NFT that lets people play in the Blocky NFT Game!", "image": "',
                        charAttributes.imageURI,
                        '", "attributes": [{"trait_type": "Health Points", "value": ',
                        strHp,
                        ', "max_value": ',
                        strMaxHp,
                        "}",
                        specialAttacksStr,
                        attacksStr,
                        "]}"
                    )
                )
            )
        );

        string memory output = string(
            abi.encodePacked("data:application/json;base64,", json)
        );
        return output;
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