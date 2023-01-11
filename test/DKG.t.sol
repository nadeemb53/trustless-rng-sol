// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "../lib/forge-std/src/Test.sol";
import "../src/DKG.sol";
import "../src/ElGamal.sol";

contract DKGTest is Test {
    DKG public dkg;
    ElGamal public elGamal;
    // 64-bit
    uint256 p = 15524864159439314293;
    // 16-bit
    uint256 q = 50753;

    function setUp() public {
        dkg = new DKG(p, q);
        elGamal = new ElGamal(p, q);
    }

    function test1() public {
        uint256[] memory m;
        uint256 si;
        (si, m) = dkg.generateRandomPolynomial();
        dkg.computePublicValues(m);
        address addr = dkg.playerAddresses(0);
        uint256[] memory publicValues = dkg.playerPublicValues[addr];
    }
}
