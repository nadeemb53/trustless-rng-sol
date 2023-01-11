// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

contract ElGamal {
    // The large prime number p
    uint256 private p;
    // The generator g
    uint256 private g;

    //constructor of the contract
    constructor(uint256 _p, uint256 _g) {
        // Set the value of p
        p = _p;

        // Set the value of g
        g = _g;
    }

    function generateSeed() public view returns (uint256) {
        return
            uint256(keccak256(abi.encodePacked(block.timestamp, msg.sender))); // TODO: make this more random
    }

    function verifySeed() public view returns (bool) {
        // TODO: ecrecover precompile - check if the seed is correct
    }

    function encrypt(
        uint256 message,
        uint256 publicKey,
        uint256 randomNumber
    ) public view returns (uint256[] memory) {
        // Compute the ciphertext
        uint256[] memory ciphertext;
        ciphertext[0] = (g**randomNumber) % p;
        ciphertext[1] = (message * (publicKey**randomNumber)) % p;

        return ciphertext;
    }

    function addEncryptedNumbers(uint256[] memory numbers)
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
            sum[0] = (sum[0] * numbers[i]) % p;
            sum[1] = (sum[1] + numbers[i + 1]) % p;
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
