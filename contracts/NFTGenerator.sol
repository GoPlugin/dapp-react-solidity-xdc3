// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@goplugin/contracts/src/v0.8/PluginClient.sol";

contract NFTGenerator is PluginClient,ERC721, Ownable {
    constructor(address _pli) ERC721("MyNFT", "MTK") {
        setPluginToken(_pli);
    }

    function safeMint(address to, uint256 tokenId) public onlyOwner {
        _safeMint(to, tokenId);
    }
}
