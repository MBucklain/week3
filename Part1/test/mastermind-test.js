//[assignment] write your own unit test to show that your Mastermind variation circuit is working as expected
const chai = require("chai");
const path = require("path");

const wasm_tester = require("circom_tester").wasm;

const F1Field = require("ffjavascript").F1Field;
const Scalar = require("ffjavascript").Scalar;
exports.p = Scalar.fromString("21888242871839275222246405745257275088548364400416034343698204186575808495617");
const Fr = new F1Field(exports.p);
const assert = chai.assert;
const { buildPoseidonOpt } = require("circomlibjs");


describe("Pico Fermi Bagels", function () {
    this.timeout(100000000);

    let Poseidon;
    before(async ()=>{
        Poseidon = await buildPoseidonOpt();
    });

    it("Pico Fermi Bagels", async () => {
        const circuit = await wasm_tester("contracts/circuits/MastermindVariation.circom");
        await circuit.loadConstraints();
        const hash = Poseidon.F.toObject(await Poseidon([7,1,2,3]));

        const INPUT = {
            "pubGuessA":1,
            "pubGuessB":2,
            "pubGuessC":3,
            "pubNumHit":3,
            "pubNumBlow":0,
            "pubSolnHash":hash,
            "privSolnA":1,
            "privSolnB":2,
            "privSolnC":3,
            "privSalt":7,
        }

         const witness = await circuit.calculateWitness(INPUT, true);
        
        assert(Fr.eq(Fr.e(witness[0]),Fr.e(1)));
        assert(Fr.eq(Fr.e(witness[1]),Fr.e(hash)));
    });
});