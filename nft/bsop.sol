// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import '../contracts/extensions/ERC721AQueryable.sol';
import '../contracts/ERC721A.sol';
contract BSOP is  ERC721A, ERC721AQueryable {
    
    mapping(address => bool) members;

    constructor() ERC721A('BSOP', 'BSOP') {
        members[msg.sender] = true;
    }

    function mint(uint256 quantity) external payable {
        // `_mint`'s second argument now takes in a `quantity`, not a `tokenId`.
        require(members[msg.sender]);
        _mint(msg.sender, quantity);
    }

    function addMember(address newMember) external {
        require(members[msg.sender]);
        members[newMember] = true;
    }

    function removeMember(address member) external {
        require(members[msg.sender]);
        delete members[member];
    }

    string private _baseTokenURI;

    function _baseURI() internal view virtual override returns (string memory) {
        return _baseTokenURI;
    }

    function setBaseURI(string calldata baseURI) external {
        require(members[msg.sender]);
        _baseTokenURI = baseURI;
    }
   function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256){
        uint256 numMintedSoFar = _nextTokenId();
        uint256 tokenIdsIdx;
        address currOwnershipAddr;
        if (index >= balanceOf(owner)) revert();
        // Counter overflow is impossible as the loop breaks when
        // uint256 i is equal to another uint256 numMintedSoFar.
        unchecked {
            for (uint256 i; i < numMintedSoFar; i++) {
                TokenOwnership memory ownership = explicitOwnershipOf(i);
                if (ownership.burned) {
                    continue;
                }
                if (ownership.addr != address(0)) {
                    currOwnershipAddr = ownership.addr;
                }
                if (currOwnershipAddr == owner) {
                    if (tokenIdsIdx == index) {
                        return i;
                    }
                    tokenIdsIdx++;
                }
            }
        }
        return 0;
    }
    function tokenByIndex(uint256 index) external view returns (uint256){
        uint256 numMintedSoFar = _nextTokenId();
        uint256 tokenIdsIdx;

        // Counter overflow is impossible as the loop breaks when
        // uint256 i is equal to another uint256 numMintedSoFar.
        unchecked {
            for (uint256 i; i < numMintedSoFar; i++) {
                TokenOwnership memory ownership = explicitOwnershipOf(i);
                if (!ownership.burned) {
                    if (tokenIdsIdx == index) {
                        return i;
                    }
                    tokenIdsIdx++;
                }
            }
        }
        revert();
    }


    
}
