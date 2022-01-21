// SPDX-License-Identifier: AGPL-3.0

pragma solidity ^0.8.11;

import {SingleNFT} from "./SingleNFT.sol";
import {ClonesWithCallData} from "./lib/ClonesWithCallData.sol";

/// @title SingleNFTFactory
/// @author https://twitter.com/devan_non https://github.com/devanonon
/// @notice Factory for deploying ERC721 contracts cheaply
/// @dev Based on https://github.com/ZeframLou/vested-erc20
/// and inspiried by this thread: https://twitter.com/alcuadrado/status/1484333520071708672
contract SingleNFTFactory {
    /// -----------------------------------------------------------------------
    /// Library usage
    /// -----------------------------------------------------------------------

    using ClonesWithCallData for address;

    /// -----------------------------------------------------------------------
    /// Immutable parameters
    /// -----------------------------------------------------------------------

    /// @notice The ERC721 used as the template for all clones created
    SingleNFT public immutable implementation;

    constructor(SingleNFT implementation_) {
        implementation = implementation_;
    }

    /// @notice Creates a SingleNFT contract
    /// @dev Uses a modified minimal proxy contract that stores immutable parameters in code and
    /// passes them in through calldata. See ClonesWithCallData. Make 96 byte token URI
    /// @param _name The name of the ERC721 token
    /// @param _symbol The symbol of the ERC721 token
    /// @param _URI1 First part of the URI, requires client to split up URI for gas savings
    /// @param _URI2 Second part of the URI, requires client to split up URI for gas savings
    /// @param _URI3 Third part of the URI, requires client to split up URI for gas savings
    /// @return erc721 The created SingleNFT contract
    function createERC721(
        bytes32 _name,
        bytes32 _symbol,
        bytes32 _URI1,
        bytes32 _URI2,
        bytes32 _URI3
    ) external returns (SingleNFT erc721) {
        bytes memory ptr = new bytes(256);
        assembly {
            mstore(add(ptr, 0x20), _name)
            mstore(add(ptr, 0x40), _symbol)
            mstore(add(ptr, 0x60), _URI1)
            mstore(add(ptr, 0x80), _URI2)
            mstore(add(ptr, 0x100), _URI3)
        }

        erc721 = SingleNFT(address(implementation).cloneWithCallDataProvision(ptr));
        erc721.mint(msg.sender);
    }
}