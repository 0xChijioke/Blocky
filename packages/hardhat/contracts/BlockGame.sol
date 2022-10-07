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
        uint256 characterIndex;
        string imageURI;
        uint256 hp;
        uint256 maxHp;
        uint256 lastRegenTime;
    }


    struct MadBots {
        string name;
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
        // All the characters attributes
        string[] memory characterName,
        string[] memory characterImageURI,
        uint256[] memory characterMaxHp,
        // All the boss attributes
        string memory bossName,
        string memory bossImageURI,
        uint256 bossHp,
        uint256 madbotsAttackDamage,
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

            defaultCharacters.push(charAttribute);
            CharacterAttributes memory c = defaultCharacters[i];
            console.log(
                "Done initializing %s w/ HP %s, img %s",
                c.name,
                c.hp,
                c.imageURI
            );
        }
        _tokenIds.increment();
        madBots = MadBots({
            name: bossName,
            imageURI: bossImageURI,
            hp: bossHp,
            attackDamage: madbotsAttackDamage
        });
        console.log(
            "Done initializing boss %s w/ HP %s, img %s",
            madBots.name,
            madBots.hp,
            madBots.imageURI
        );
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
            characterIndex: defaultCharacters[0].characterIndex,
            imageURI: defaultCharacters[0].imageURI,
            hp: defaultCharacters[0].hp,
            maxHp: defaultCharacters[0].maxHp,
            lastRegenTime: block.timestamp
        });
        nftHolders[msg.sender] = newItemId;
        _tokenIds.increment();
        emit CharacterNFTMinted(msg.sender, newItemId);
         console.log(
            nftHolders[msg.sender],
            newItemId
        );
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

    function attackBot() public {
        uint256 nftTokenIdOfPlayer = nftHolders[msg.sender];
        CharacterAttributes storage player = nftHolderAttributes[
            nftTokenIdOfPlayer
        ];
        require(player.hp > 0, "Error: character must have HP to attack bots.");
        require(madBots.hp > 0, "Error: bot is already dead");
        uint256 attackDamage = 0;
       
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

}