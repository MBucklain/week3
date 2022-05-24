

// [assignment] implement a variation of mastermind from https://en.wikipedia.org/wiki/Mastermind_(board_game)#Variation as a circuit
pragma circom 2.0.0;

include "../../node_modules/circomlib/circuits/comparators.circom";
include "../../node_modules/circomlib/circuits/bitify.circom";
include "../../node_modules/circomlib/circuits/poseidon.circom";

template MastermindVariation() {//HIt & Blow converted into Pico Fermi Bagels 
    // Public inputs
    signal input pubGuessA;
    signal input pubGuessB;
    signal input pubGuessC;
    //signal input pubGuessD;
    signal input pubNumHit;
    signal input pubNumBlow;
    signal input pubSolnHash;

    // Private inputs
    signal input privSolnA;
    signal input privSolnB;
    signal input privSolnC;
    //signal input privSolnD;
    signal input privSalt;

    // Output
    signal output solnHashOut;

    var guess[3] = [pubGuessA, pubGuessB, pubGuessC];
    var soln[3] =  [privSolnA, privSolnB, privSolnC];
    var j = 0;
    var k = 0;
    component lessThan[8];
    component equalGuess[6];
    component equalSoln[6];
    var equalIdx = 0;

    // Create a constraint that the solution and guess digits are all less than 10.
    for (j=0; j<3; j++) {
        lessThan[j] = LessThan(4);
        lessThan[j].in[0] <== guess[j];
        lessThan[j].in[1] <== 10;
        lessThan[j].out === 1;
        lessThan[j+3] = LessThan(4);
        lessThan[j+3].in[0] <== soln[j];
        lessThan[j+3].in[1] <== 10;
        lessThan[j+3].out === 1;
        for (k=j+1; k<3; k++) {
            // Create a constraint that the solution and guess digits are unique. no duplication.
            equalGuess[equalIdx] = IsEqual();
            equalGuess[equalIdx].in[0] <== guess[j];
            equalGuess[equalIdx].in[1] <== guess[k];
            equalGuess[equalIdx].out === 0;
            equalSoln[equalIdx] = IsEqual();
            equalSoln[equalIdx].in[0] <== soln[j];
            equalSoln[equalIdx].in[1] <== soln[k];
            equalSoln[equalIdx].out === 0;
            equalIdx += 1;
        }
    }

    // Count Pico Fermi
    var hit = 0;
    var blow = 0;
    component equalHB[16];

    for (j=0; j<3; j++) {
        //j =0
        for (k=0; k<3; k++) {//k = 0
            equalHB[3*j+k] = IsEqual();
            //equalHB[0] = IsEqual();
            equalHB[3*j+k].in[0] <== soln[j];
            //equalHB[0].in[0] <== soln[0] = privSolnA;
            equalHB[3*j+k].in[1] <== guess[k];
            //equalHB[0].in[1] <== guess[0] = pubGuessA;
            blow += equalHB[3*j+k].out;
            // 1 = blow += equalHB[0].out;
            if (j == k) {//true
                hit += equalHB[3*j+k].out;//+1
                blow -= equalHB[3*j+k].out;//-1
            }
        }
    }

    // Create a constraint around the number of hit
    component equalHit = IsEqual();
    equalHit.in[0] <== pubNumHit;
    equalHit.in[1] <== hit;
    equalHit.out === 1;
    
    // Create a constraint around the number of blow
    component equalBlow = IsEqual();
    equalBlow.in[0] <== pubNumBlow;
    equalBlow.in[1] <== blow;
    equalBlow.out === 1;

    // Verify that the hash of the private solution matches pubSolnHash
    component poseidon = Poseidon(4);
    poseidon.inputs[0] <== privSalt;
    poseidon.inputs[1] <== privSolnA;
    poseidon.inputs[2] <== privSolnB;
    poseidon.inputs[3] <== privSolnC;
 

    solnHashOut <== poseidon.out;
    pubSolnHash === solnHashOut;
 }

 component main {public [pubGuessA, pubGuessB, pubGuessC, pubNumHit, pubNumBlow, pubSolnHash]} = MastermindVariation();