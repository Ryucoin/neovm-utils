//
//  Ontology-RPCTests.swift
//  neovmUtils_Tests
//
//  Created by Wyatt Mufson on 10/2/19.
//  Copyright © 2019 Ryu Blockchain Technologies. All rights reserved.
//

import XCTest

class Ontology_RPCTests: XCTestCase {
    var exampleWallet: Wallet = newWallet()

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testClaimONG() {
        let tx = claimONG(wif: exampleWallet.wif)
        print(tx)
    }

    func testGetBalances() {
        let address = "AFmseVrdL9f9oyCzZefL9tG6UbviEH9ugK"
        let (ont, ong) = ontologyGetBalances(address: address)
        XCTAssertTrue(ont > 0 && ong > 0)

        let (ontMain, ongMain) = ontologyGetBalances(endpoint: ontologyMainNet, address: address)
        XCTAssertTrue(ontMain > 0 && ongMain > 0)

        let (ontBad, ongBad) = ontologyGetBalances(address: "bad address")
        XCTAssertTrue(ontBad == 0 && ongBad == 0)
    }

    func testGetBlock() {
        let height = 100
        let block1 = ontologyGetBlockWithHeight(height: height)

        let hash = "b1d635982eebcd9c542993a32a1f3534a3de7cd53a5270f4beefde2ff1362444"
        let block2 = ontologyGetBlockWithHash(hash: hash)

        let expected = "00000000c7e3bccb342bfd71f8a691781e5b4bc1a0dccf7732abe32faa5be79c906cd7acceb720c67cfb944e47db5278fa6e27ff"

        XCTAssertEqual(block1, block2)

        let s1 = block1.starts(with: expected)
        let s2 = block2.starts(with: expected)

        XCTAssertTrue(s1)
        XCTAssertTrue(s2)
    }

    func testGetBlockCount() {
        let blockCount = ontologyGetBlockCount()
        print("Block count: \(blockCount)")
        XCTAssertNotEqual(blockCount, -1)
    }

    func testGetRawTransaction() {
        let txID = "ea82d1e85303e1d955231b7c863308ce9b580602d386f8aa9bd80bccc0b51b6e"
        let raw = ontologyGetRawTransaction(endpoint: ontologyMainNet, txID: txID)
        let unknown = "unknown transaction"
        XCTAssertNotEqual(raw, unknown)
    }

    func testGetSmartCodeEvent() {
        let txHash = "41ee265bf50952cd0445d0f612bf2574af523b741c9cc82617bd27c0f7404b14"
        guard let result = ontologyGetSmartCodeEvent(txHash: txHash) else {
            XCTFail()
            return
        }
        XCTAssertEqual(10852500, result.gasConsumed)
        XCTAssertEqual(1, result.state)
        XCTAssertEqual(txHash, result.txHash)
    }

    func testGetStorage() {
        let contractHash = "c168e0fb1a2bddcd385ad013c2c98358eca5d4dc"
        let result = ontologyGetStorage(scriptHash: contractHash, key: exampleWallet.address)
        print("Result for getStorage: \(result)")
    }

    func testGetUnboundONG() {
        let res = getUnboundONG(address: exampleWallet.address)
        XCTAssertEqual(res, "0")

        let res2 = getUnboundONG(address: "123")
        XCTAssertEqual(res2, "")
    }

    func testTransferONT() {
        let b = newWallet()
        let tx = ontologyTransfer(wif: exampleWallet.wif, asset: .ONT, toAddress: b.address, amount: 10)
        print(tx)
    }
}
