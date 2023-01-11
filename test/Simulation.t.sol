// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "../lib/forge-std/src/Test.sol";
import "../lib/forge-std/src/console.sol";
import "../src/DKG.sol";
import "../src/ElGamal.sol";

contract Simulation is Test {
    DKG public dkg;
    ElGamal public elGamal;
    address add1 = 0x5FbDB2315678afecb367f032d93F642f64180aa3;
    address add2 = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;

    // 64-bit
    uint256 p = 15524864159439314293;
    // 16-bit
    uint256 q = 50753;

    function setUp() public {
        dkg = new DKG(p, q);
        elGamal = new ElGamal(p, q);
    }

    function testCorrectPublicValues() public {
        uint256[] memory polynomial1 = dkg.generateRandomPolynomial(add1);
        dkg.computePublicValues(polynomial1, add1);

        uint256[] memory polynomial2 = dkg.generateRandomPolynomial(add2);
        dkg.computePublicValues(polynomial2, add2);

        dkg.playerAddresses(0);
        dkg.playerAddresses(1);

        // dkg.verifyPublicValues(polynomial2, add1);

        dkg.generateSharedPublicKey();

        // // Ensure the contract public key is set
        assert(dkg.contractPublicKey() != 0);
    }
}