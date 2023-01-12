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

    uint256 p = 29;
    uint256 g = 2;

    function setUp() public {
        dkg = new DKG(p, g);
        elGamal = new ElGamal(p, g);
    }

    function testDKGFlow() public {
        uint256[] memory polynomial1 = dkg.generateRandomPolynomial(add1);
        dkg.computePublicValues(polynomial1, add1);

        uint256[] memory polynomial2 = dkg.generateRandomPolynomial(add2);
        dkg.computePublicValues(polynomial2, add2);

        assert(dkg.verifyPublicValues(polynomial2, add1) == true);
        assert(dkg.verifyPublicValues(polynomial1, add2) == true);

        dkg.generateSharedPublicKey();

        // // Ensure the contract public key is set
        assert(dkg.contractPublicKey() != 0);

        uint256 seed = elGamal.generateSeed();
        uint256 rn = elGamal.generateRandomNumberWithSeed(seed);
        uint256 msg1 = 14;
        uint256[] memory cipherText1 = elGamal.encrypt(
            msg1,
            dkg.contractPublicKey(),
            rn
        );
        uint256[] memory cipherText2 = elGamal.encrypt(
            6,
            dkg.contractPublicKey(),
            rn
        );
        uint256[][] memory cipherTexts = new uint256[][](2);
        cipherTexts[0] = cipherText1;
        cipherTexts[1] = cipherText2;

        uint256[] memory addedCipherText = elGamal.addEncryptedNumbers(
            cipherTexts
        );

        assert(msg1 == elGamal.decrypt(polynomial1[0], addedCipherText));
    }
}
