//
//  Scripts+ParamsTests.swift
//  neovmUtils_Tests
//
//  Created by Wyatt Mufson on 10/2/19.
//  Copyright © 2019 Ryu Blockchain Technologies. All rights reserved.
//

import XCTest

class Scripts_ParamsTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testHexFail() {
        let string = "ABCDEFGHIJKLMNOPQRSTUV"
        XCTAssertEqual(string.hexToDecimal(), 0)
    }

    func testNEOScriptBuilderBadHash() {
        let sb = ScriptBuilder()
        let sh = "12345"
        sb.pushTypedContractInvoke(scriptHash: sh, operation: "name", args: [])
        XCTAssertTrue(sb.rawBytes.count == 0)
    }

    func testNEOScriptBuilderLargeSize() {
        let sb = ScriptBuilder()
        let sh = "a47222204212ef759df954f1e1b156528098153d"
        let arg = NVMParameter(type: .String, value: "ABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZ")
        sb.pushTypedContractInvoke(scriptHash: sh, operation: "n", args: [arg])
        XCTAssertTrue(sb.rawBytes.count > 0)
    }

    func testNVMParameterArrayFail() {
        let param = NVMParameter(type: .Array, value: 5)
        let args: [NVMParameter] = [param]
        let res = ontologyInvokeRead(contractHash: "a29564a30043d50620e4c6be61eda834d0acc48b", method: "getTotal", args: args)
        let num = res.hexToDecimal()
        XCTAssertGreaterThan(num, 0)
        print(num)
    }

    func testNVMParser() {
        let parser = NVMParser()
        let hex1 = "0101"
        guard let bool = parser.deserialize(hex: hex1) as? Bool else {
            XCTFail()
            return
        }

        XCTAssertEqual(bool, true)
        parser.resetParser()

        let hex2 = "0100"
        guard let bool2 = parser.deserialize(hex: hex2) as? Bool else {
            XCTFail()
            return
        }

        XCTAssertEqual(bool2, false)
        parser.resetParser()

        let hex3 = "8100"
        guard let arr = parser.deserialize(hex: hex3) as? [Any] else {
            XCTFail()
            return
        }

        XCTAssertEqual(arr.count, 0)
        parser.resetParser()

        guard let empty = parser.deserialize(hex: "03") as? String else {
            XCTFail()
            return
        }

        XCTAssertEqual(empty, "")
    }

    func testNVMParserIntsEightBytes() {
        let parser = NVMParser()
        let arrayByte = "80"
        let nextByte = "ff"
        let lengthBytes = "0100000000000000"
        let baByte = "00"
        let lvar = "01"
        let itemByte = "DE"
        let varBytes = "\(lvar)\(itemByte)"

        let hex = "\(arrayByte)\(nextByte)\(lengthBytes)\(baByte)\(varBytes)"
        guard let arr = parser.deserialize(hex: hex) as? [String],
            arr.count == 1 else {
                XCTFail()
                return
        }

        let item = arr[0]
        XCTAssertEqual(item, itemByte)
    }

    func testNVMParserIntsFourBytes() {
        let parser = NVMParser()
        let arrayByte = "80"
        let nextByte = "fe"
        let lengthBytes = "01000000"
        let baByte = "00"
        let lvar = "01"
        let itemByte = "CE"
        let varBytes = "\(lvar)\(itemByte)"

        let hex = "\(arrayByte)\(nextByte)\(lengthBytes)\(baByte)\(varBytes)"
        guard let arr = parser.deserialize(hex: hex) as? [String],
            arr.count == 1 else {
            XCTFail()
            return
        }

        let item = arr[0]
        XCTAssertEqual(item, itemByte)
    }
}
