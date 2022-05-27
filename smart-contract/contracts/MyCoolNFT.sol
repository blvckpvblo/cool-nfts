// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.1;

// We need some util functions for strings.
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "hardhat/console.sol";

import {Base64} from "./libraries/Base64.sol";

contract MyCoolNFT is ERC721URIStorage {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    uint256 TOTAL_MINT_COUNT = 50;
    uint256 TOTAL_NFT_MINTED = 0;

    string[] colors = ["blue", "black", "green", "red", "purple"];

    string baseSvg =
        "<svg xmlns='http://www.w3.org/2000/svg' preserveAspectRatio='xMinYMin meet' viewBox='0 0 350 350'><style>.base { fill: white; font-family: serif; font-size: 14px; }</style>";
    string secondSvg =
        "<text x='50%' y='50%' class='base' dominant-baseline='middle' text-anchor='middle'>";

    string[] firstWords = [
        "President",
        "Governor",
        "Mayor",
        "King",
        "Chairman",
        "General",
        "Lieutenant",
        "Officer",
        "Doctor",
        "Professor",
        "Admiral",
        "Director",
        "Cardinal",
        "Mufti",
        "Sheikh"
    ];
    string[] secondWords = [
        "Elon",
        "Bill",
        "Virgil",
        "Kanye",
        "Mark",
        "Jeff",
        "Steve",
        "Chamath",
        "Cristiano",
        "Lewis",
        "Jay",
        "Pharrell",
        "Jack",
        "Sam",
        "Ray"
    ];
    string[] thirdWords = [
        "Tomato",
        "Orange",
        "Banana",
        "Stawberry",
        "Grape",
        "Grapefruit",
        "Apple",
        "Pear",
        "Apricot",
        "Cherry",
        "Guava",
        "Lemon",
        "Cranberry",
        "Papaya",
        "Date"
    ];

    constructor() ERC721("CoolNFT", "CNFT") {
        console.log("This is my NFT contract. Whoa!");
    }

    function pickRandomFirstWord(uint256 tokenId)
        public
        view
        returns (string memory)
    {
        uint256 rand = random(
            string(abi.encodePacked("FIRST_WORD", Strings.toString(tokenId)))
        );
        rand = rand % firstWords.length;
        return firstWords[rand];
    }

    function pickRandomSecondWord(uint256 tokenId)
        public
        view
        returns (string memory)
    {
        uint256 rand = random(
            string(abi.encodePacked("SECOND_WORD", Strings.toString(tokenId)))
        );
        rand = rand % firstWords.length;
        return secondWords[rand];
    }

    function pickRandomThirdWord(uint256 tokenId)
        public
        view
        returns (string memory)
    {
        uint256 rand = random(
            string(abi.encodePacked("THIRD_WORD", Strings.toString(tokenId)))
        );
        rand = rand % firstWords.length;
        return thirdWords[rand];
    }

    function pickRandomColor(uint256 tokenId)
        public
        view
        returns (string memory)
    {
        uint256 rand = random(
            string(abi.encodePacked("COLORS", Strings.toString(tokenId)))
        );
        rand = rand % colors.length;
        return colors[rand];
    }

    event NewCoolNFTMinted(address sender, uint256 tokenId, uint256 totalNFTs);

    function random(string memory input) internal pure returns (uint256) {
        return uint256(keccak256(abi.encodePacked(input)));
    }

    function makeACoolNFT() public {
        // Get the current tokenId, this starts at 0.
        uint256 newItemId = _tokenIds.current();

        require(_tokenIds.current() < TOTAL_MINT_COUNT, "Mint over.");

        string memory first = pickRandomFirstWord(newItemId);
        string memory second = pickRandomSecondWord(newItemId);
        string memory third = pickRandomThirdWord(newItemId);
        string memory color = pickRandomColor(newItemId);
        string memory combineWord = string(
            abi.encodePacked(first, second, third)
        );

        string memory finalSvg = string(
            abi.encodePacked(baseSvg, "<rect width='100%' height='100%' fill='", color, "' />", secondSvg, combineWord, "</text></svg>")
        );

        string memory json = Base64.encode(
            bytes(
                string(
                    abi.encodePacked(
                        '{"name":"',
                        combineWord,
                        '", "description": "A highly acclaimed collection of squares.", "image": "data:image/svg+xml;base64,',
                        Base64.encode(bytes(finalSvg)),
                        '"}'
                    )
                )
            )
        );

        string memory finalTokenUri = string(
            abi.encodePacked("data:application/json;base64,", json)
        );

        console.log("\n--------------------");
        console.log(
            string(
                abi.encodePacked(
                    "https://nftpreview.0xdev.codes/?code=",
                    finalTokenUri
                )
            )
        );
        console.log("--------------------\n");

        // Actually mint the NFT to the sender using msg.sender.
        _safeMint(msg.sender, newItemId);

        // Set the NFTs data.
        _setTokenURI(newItemId, finalTokenUri);

        // Increment the counter for when the next NFT is minted.
        _tokenIds.increment();

        console.log(
            "An NFT w/ ID %s has been minted to %s",
            newItemId,
            msg.sender
        );

        TOTAL_NFT_MINTED += 1;

        emit NewCoolNFTMinted(msg.sender, newItemId, TOTAL_NFT_MINTED);
    }

    function getTotalNFTsMintedSoFar() public view returns (uint256) {
        console.log("%d minted so far.", TOTAL_NFT_MINTED);
        return TOTAL_NFT_MINTED;
    }
}
