// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

contract DKG {
    // Number of players in the contract
    uint256 playerCount = 2;
    // Mapping of player addresses to their public values
    mapping(address => uint256[]) public playerPublicValues;
    // Array of player addresses
    address[] public playerAddresses;
    // Event emitted when a player is detected as malicious
    event CheatDetected(address);
    // Shared public key for the players
    uint256 public contractPublicKey;
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

    function generateRandomPolynomial(address myAddress)
        public
        returns (uint256[] memory)
    {
        // Get the number of players
        uint256 k = playerCount;

        // Generate a random secret value si
        uint256 si = uint256(
            keccak256(abi.encodePacked(block.timestamp, myAddress))
        ) % (10);

        // Initialize an empty polynomial for the player
        uint256[] memory polynomial = new uint256[](k + 1);

        // Set the first coefficient of the polynomial to si
        polynomial[0] = si;

        // Generate random coefficients for the remaining k terms of the polynomial
        for (uint256 i = 1; i < k; i++) {
            polynomial[i] =
                uint256(keccak256(abi.encodePacked(block.timestamp, i))) %
                (10);
        }

        playerAddresses.push(myAddress);

        return polynomial;
    }

    function computePublicValues(
        uint256[] calldata polynomial,
        address myAddress
    ) public returns (uint256[] memory) {
        // Get the number of players
        uint256 k = playerCount;

        // Initialize an empty array for the public values
        uint256[] memory publicValues = new uint256[](k);

        // Compute the public values
        for (uint256 j = 0; j < k; j++) {
            publicValues[j] = (g**polynomial[j]) % p;
        }

        // Store the public values for the player
        playerPublicValues[myAddress] = publicValues;
        return publicValues;
    }

    function verifyPublicValues(
        uint256[] calldata polynomial,
        address myAddress
    ) public {
        // Get the number of players
        uint256 k = playerCount;

        // Initialize an array to store the computed public values
        uint256[] memory computedPublicValues = new uint256[](k);

        // Verify the public values for the player
        for (uint256 i = 0; i < playerAddresses.length; i++) {
            if (playerAddresses[i] == myAddress) {
                continue;
            }
            // Get the public values for player i
            uint256[] memory publicValues = playerPublicValues[
                playerAddresses[i]
            ];

            // Compute the public values for player i's polynomial
            for (uint256 j = 0; j < k; j++) {
                computedPublicValues[j] = (publicValues[j]**polynomial[i]) % p;
            }
            // Check if the computed public values match the received public values
            if (
                keccak256(abi.encodePacked(computedPublicValues)) !=
                keccak256(abi.encodePacked(publicValues))
            ) {
                // Invalid public values, the player is considered malicious
                emit CheatDetected(playerAddresses[i]);
            }
        }
    }

    function generateSharedPublicKey() public {
        // Get the number of players
        uint256 k = playerCount;

        // Initialize the shared public key
        uint256 sharedPublicKey = 1;

        // Calculate the shared public key
        for (uint256 i = 0; i < playerAddresses.length; i++) {
            // Get the public values for player i
            uint256[] memory publicValues = playerPublicValues[
                playerAddresses[i]
            ];

            // Calculate the shared public key
            for (uint256 j = 0; j < k; j++) {
                sharedPublicKey = (sharedPublicKey * publicValues[j]) % p;
            }
        }
        // Store the shared public key
        contractPublicKey = sharedPublicKey;
    }
}
