// SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

import { IERC20, SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import { MerkleProof } from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

contract MerkleAirdrop {
    error MerkleAirdrop__InvalidProof();
    error MerkleAirdrop__AlreadyClaimed();

    // some list of addressses
    // Allow someone in the list to claim the ERC20 tokens
    address[] claimers;
    bytes32 private immutable i_merkleRoot;
    IERC20 private immutable i_airdropToken;
    mapping(address claimer => bool claimed) private s_hasClaimed;

    event Claimed(address account, uint256 amount);

    constructor (bytes32 merkleRoot, IERC20 airdropToken) {
        i_merkleRoot = merkleRoot;
        i_airdropToken = airdropToken;
    }

    function claim(address account, uint256 amount, bytes32[] calldata merkleProof) external {
        if (s_hasClaimed[account]) {
            revert MerkleAirdrop__AlreadyClaimed();
        }
        // calculate using the account and the amount, the hash -> leaf node
        bytes32 leaf = keccak256(bytes.concat(keccak256(abi.encode(account, amount))));
        if(!MerkleProof.verify(merkleProof, i_merkleRoot, leaf)) {
            revert MerkleAirdrop__InvalidProof();
        }
        emit Claimed(account, amount);
        i_airdropToken.transfer(account, amount);
        // Prevent one user from claiming multiple times
        s_hasClaimed[account] = true;
    }
}