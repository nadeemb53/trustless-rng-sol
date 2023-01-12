// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "./utils/ECDSA.sol";

contract ElGamal {
    // The large prime number p
    uint256 private p;
    // The generator g
    uint256 private g;
    using ECDSA for bytes32;

    //constructor of the contract
    constructor(uint256 _p, uint256 _g) {
        // Set the value of p
        p = _p;

        // Set the value of g
        g = _g;
    }

    function generateSeed() public view returns (uint256 seed) {
        uint256 rand1 = uint256(
            keccak256(abi.encodePacked(block.timestamp, msg.sender))
        );
        uint256 rand2 = uint256(
            keccak256(abi.encodePacked(block.timestamp, msg.sender, rand1))
        );
        seed = (rand1 + rand2) % (p - 1);
    }

    function generateRandomNumberWithSeed(uint256 seed)
        public
        view
        returns (uint256)
    {
        return
            uint256(
                keccak256(abi.encodePacked(block.timestamp, msg.sender, seed))
            ) % (10);
    }

    function verifySeed(
        bytes32 seedHash,
        bytes calldata signature,
        address user
    ) public pure returns (bool) {
        return user == ECDSA.recover(seedHash, signature);
    }

    function encrypt(
        uint256 message,
        uint256 publicKey,
        uint256 randomNumber
    ) public view returns (uint256[] memory) {
        // Compute the ciphertext
        uint256[] memory ciphertext = new uint256[](2);
        ciphertext[0] = (g**randomNumber) % p;
        ciphertext[1] = (message * (publicKey**randomNumber)) % p;

        return ciphertext;
    }

    function addEncryptedNumbers(uint256[][] memory numbers)
        public
        view
        returns (uint256[] memory)
    {
        // Initialize the sum of the encrypted numbers
        uint256[] memory sum = new uint256[](2);
        sum[0] = 1;
        sum[1] = 0;

        // Add all the encrypted numbers to the sum
        for (uint256 i = 0; i < numbers.length; i += 2) {
            sum[0] = (sum[0] * numbers[i][0]) % p;
            sum[1] = (sum[1] + numbers[i + 1][1]) % p;
        }

        return sum;
    }

    function decrypt(uint256 privateKey, uint256[] memory ciphertext)
        public
        view
        returns (uint256)
    {
        // Decrypt the ciphertext
        return (ciphertext[1] * (ciphertext[0]**(p - 1 - privateKey))) % p;
    }
}
