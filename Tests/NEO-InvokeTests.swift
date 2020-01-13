//
//  NEO-InvokeTests.swift
//  neovmUtils_Tests
//
//  Created by Wyatt Mufson on 10/2/19.
//  Copyright © 2020 Ryu Blockchain Technologies. All rights reserved.
//

import XCTest
import SwiftPromises

class NEO_InvokeTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testBadNEORPC() {
        let bad = "http://badurlasdasd.com"
        let result = neoInvokeScript(endpoint: bad, raw: Data())
        XCTAssertTrue(result.result.stack.count == 0)

        let expectation = XCTestExpectation(description: "Test bad node")
        getBestNEONode(api: bad, net: .mainNet).then { (result) in
            XCTAssertEqual("http://seed1.ngd.network:10332", result)
            getBestNEONode(api: bad, net: .testNet).then { (result2) in
                XCTAssertEqual("http://seed1.ngd.network:20332", result2)
                expectation.fulfill()
            }
        }
        self.wait(for: [expectation], timeout: 10)
    }

    func testNEOInvocations() {
        let contractHash = "849d095d07950b9e56d0c895ec48ec5100cfdff1"

        let bestNode = try? await(getBestNEONode(net: .testNet))
        if bestNode == nil {
            XCTFail()
            return
        }

        let asset = OEPAssetInterface(contractHash: contractHash, testnet: true, interface: NEO)
        let result = asset.customRead(operation: "name", args: []).hexToAscii()
        let name = "TrinityToken"
        XCTAssertEqual(name, result)

        let address = "AUxBn8n37YpYwkVKVg5rSP6W2BwrJZjU5t"
        let owner = NVMParameter(type: .Address, value: address)
        let result2 = asset.customRead(operation: "balanceOf", args: [owner]).hexToDecimal()
        XCTAssertTrue(result2 > 0)

        let wallet = newWallet()
        let txid = asset.customInvoke(operation: "name", args: [], wif: wallet.wif)
        XCTAssertNotEqual(txid, "")

        let toAddress = wallet.address
        let to = NVMParameter(type: .Address, value: toAddress)
        let amount = NVMParameter(type: .Fixed8, value: 24)
        let txid2 = asset.customInvoke(operation: "transfer", args: [owner, to, amount], wif: wallet.wif)
        XCTAssertNotEqual(txid2, "")

        let amount2 = NVMParameter(type: .Fixed9, value: 2.4)
        let txid3 = asset.customInvoke(operation: "transfer", args: [owner, to, amount2], wif: wallet.wif)
        XCTAssertNotEqual(txid3, "")

        let amount3 = NVMParameter(type: .Integer, value: 2400000000)
        let txid4 = asset.customInvoke(operation: "transfer", args: [owner, to, amount3], wif: wallet.wif)
        XCTAssertNotEqual(txid4, "")

        let result3 = asset.customRead(operation: "transfer", args: [owner, to, amount])
        let result4 = asset.customRead(operation: "transfer", args: [owner, to, amount2])
        let result5 = asset.customRead(operation: "transfer", args: [owner, to, amount3])
        XCTAssertEqual(result3, "")
        XCTAssertEqual(result4, "")
        XCTAssertEqual(result5, "")

        let res1 = RES1Interface(contractHash: contractHash, testnet: false, interface: NEO)
        let args: [Any] = [address, 1]
        let ctxid = res1.transferMulti(args: [args], wif: wallet.wif)
        XCTAssertNotEqual(ctxid, "")

        let arrayParam = NVMParameter(type: .Array, value: [to, amount])
        let cresult = res1.customRead(operation: "transferMulti", args: [arrayParam])
        XCTAssertEqual(cresult, "")

        let unknown = NVMParameter(type: .Unknown, value: "")
        let unknownDict = unknown.getIFArg()
        XCTAssertEqual(unknownDict.keys.count, 0)

        let str = NVMParameter(type: .String, value: "00000000000000000000000000000000000000000000000000000000000000000000000000000000")
        let boolean = NVMParameter(type: .Boolean, value: true)
        let bytearray = NVMParameter(type: .ByteArray, value: "262bec084432")
        let negative = NVMParameter(type: .Integer, value: -1)
        let array = NVMParameter(type: .Array, value: [])
        let ctxid2 = res1.customInvoke(operation: "operation", args: [array, str, boolean, arrayParam, bytearray, negative], wif: wallet.wif)
        XCTAssertNotEqual(ctxid2, "")

        let script2 = buildScript(scriptHash: contractHash, operation: "name", args: [])
        let invokeresult2 = neoInvokeScript(raw: Data(script2))
        XCTAssertTrue(invokeresult2.result.stack.count >= 1)

        let badWif = wallet.wif + "XXXX"
        let res = res1.customInvoke(operation: "operation", args: [], wif: badWif)
        XCTAssertEqual(res, "")
    }

    func testNEOInvokeScript() {
        let script = "59c56b09656e756d657261746500c176c97c679105582f17e28f4c10b444c568b842442dde681e6a00527ac4006a51527ac400c176c96a52527ac461616a00c368134e656f2e456e756d657261746f722e4e6578746434006a51c3559f642c006a52c36a00c368124e656f2e4974657261746f722e56616c756561c86a51c351936a51527ac462b6ff6161616a52c36c7566"
        let res = neoInvokeScript(avm: script)
        let topStack = res.result.stack
        XCTAssertEqual(topStack.count, 1)
        XCTAssertEqual(topStack[0].type, "Array")
        guard let stack = topStack[0].value as? [StackItem] else {
            XCTFail()
            return
        }

        let count = stack.count
        XCTAssertEqual(count, 5)
        for i in 0..<count {
            let item = stack[i]
            XCTAssertEqual(item.type, "ByteArray")
            var value = "76616c75652035"
            if i == 0 {
                value = "76616c75652031"
            } else if i == 1 {
                value = "76616c75652032"
            } else if i == 2 {
                value = "76616c75652033"
            } else if i == 3 {
                value = "76616c75652034"
            }
            XCTAssertEqual(item.value as? String, value)
        }
    }

    func testNEOInvokeScript2() {
        let script = "5dc56b14322631399103e714acc7decc2dceda1fb2fcc83c6a00527ac408746f6b656e734f666a00c351c176c97ce101020309116fc6a03067f580e82ecffff0c93a885d836a51527ac4006a52527ac400c176c96a53527ac402e8036a54527ac4006a54c3956a55527ac461616a51c368134e656f2e456e756d657261746f722e4e6578746441006a52c36a54c39f6437006a52c36a55c3a2641f006a53c36a51c368124e656f2e4974657261746f722e56616c756561c8616a52c351936a52527ac462a9ff6161616a53c36c7566"
        let res = neoInvokeScript(avm: script)
        let stack = res.result.stack
        guard let items = stack[0].value as? [StackItem] else {
            XCTFail()
            return
        }

        guard let item = items[0].value as? String else {
            XCTFail()
            return
        }

        let address = "ALM3BjfC1iYJ6rCS9vejqSWnikk5rDJQXQ"
        XCTAssertEqual(address, item.scriptHashToAddress())

        let res1Interface = RES1Interface(contractHash: "835d883ac9f0ffcf2ee880f56730a0c66f110903", testnet: true, interface: NEO)

        let supply = res1Interface.getTotalSupply()
        print("Supply: \(supply)")
        XCTAssertTrue(supply > 0)

        let balance = res1Interface.getBalance(address: "ALM3BjfC1iYJ6rCS9vejqSWnikk5rDJQXQ")
        print("Balance: \(balance)")
        XCTAssertTrue(balance > 0)

        let addressParam = NVMParameter(type: .Address, value: "ALM3BjfC1iYJ6rCS9vejqSWnikk5rDJQXQ")
        let bhex = NEO.read(contractHash: "835d883ac9f0ffcf2ee880f56730a0c66f110903", operation: "balanceOf", args: [addressParam])
        print("Balance hex: \(bhex)")

        let id = NVMParameter(type: .Integer, value: 1)
        let params = res1Interface.customRead(operation: "properties", args: [id])
        let parser = NVMParser()
        guard let des = parser.deserialize(hex: params) as? [String: Any],
            let ownerHex = des["Owner"] as? String,
            let rarityHex = des["Rarity"] as? String,
            let DNA = des["DNA"] as? String,
            let nameHex = des["Name"] as? String else {
            XCTFail()
            return
        }

        let expected = "Abxfqq6n12QgkLRXR6ohS89rTPvNvtmtbR"
        let owner = ownerHex.scriptHashToAddress()
        XCTAssertEqual(expected, owner)

        let rarity = rarityHex.hexToAscii()
        XCTAssertEqual("Common", rarity)

        let dna = "ffffffff3bde2ebb8cd2b7e3d1600ad631c385a5d7cce23c7785459a9c12cfdc04c74584d787ac3d23772132c18524bc7ab28dec4219b8fc5b425f70"
        XCTAssertEqual(DNA, dna)

        let slimey = "Slimey"
        let name = nameHex.hexToAscii()
        XCTAssertEqual(name, slimey)
    }

    func testNEOInvokeScriptEncoding() {
        let int: StackItem = StackItem(type: "Integer", value: 1)
        let boolean: StackItem = StackItem(type: "Bool", value: true)
        let bytearray: StackItem = StackItem(type: "ByteArray", value: "ffffff00")
        let string: StackItem = StackItem(type: "String", value: "Hello!")
        let a: StackItem = StackItem(type: "Array", value: [])

        let arrayItems: [StackItem] = [a, int, boolean, bytearray, string]
        let array: StackItem = StackItem(type: "Array", value: arrayItems)
        let stack: [StackItem] = [array]
        let result = InvokeScriptResult(gas_consumed: "1.036", script: "ABCDEFGHIJKLMNOPQRTSTUVWXYZ", stack: stack, state: "HALT")
        let invokeScriptResponse = InvokeScriptResponse(jsonrpc: "2.0", id: 2, result: result)

        guard let encoded = try? JSONEncoder().encode(invokeScriptResponse) else {
            XCTFail()
            return
        }

        guard let decoded = try? JSONDecoder().decode(InvokeScriptResponse.self, from: encoded) else {
            XCTFail()
            return
        }

        XCTAssertEqual(decoded.jsonrpc, invokeScriptResponse.jsonrpc)
        XCTAssertEqual(decoded.id, invokeScriptResponse.id)
        XCTAssertEqual(decoded.result.gas_consumed, invokeScriptResponse.result.gas_consumed)
        XCTAssertEqual(decoded.result.script, invokeScriptResponse.result.script)
        XCTAssertEqual(decoded.result.state, invokeScriptResponse.result.state)

        guard decoded.result.stack.count == 1,
            let arr = decoded.result.stack[0].value as? [StackItem] else {
            XCTFail()
            return
        }

        for item in arr {
            XCTAssertTrue(arrayItems.contains(item))
        }
    }

    func testNEOInvokeScriptAsync() {
        let exp = expectation(description: "Neo invoke script async")
        let script = "59c56b09656e756d657261746500c176c97c679105582f17e28f4c10b444c568b842442dde681e6a00527ac4006a51527ac400c176c96a52527ac461616a00c368134e656f2e456e756d657261746f722e4e6578746434006a51c3559f642c006a52c36a00c368124e656f2e4974657261746f722e56616c756561c86a51c351936a51527ac462b6ff6161616a52c36c7566"

        neoInvokeScriptAsync(avm: script).then { (res) in
            let topStack = res.result.stack
            XCTAssertEqual(topStack.count, 1)
            XCTAssertEqual(topStack[0].type, "Array")
            guard let stack = topStack[0].value as? [StackItem] else {
                XCTFail()
                return
            }

            let count = stack.count
            XCTAssertEqual(count, 5)
            for i in 0..<count {
                let item = stack[i]
                XCTAssertEqual(item.type, "ByteArray")
                var value = "76616c75652035"
                if i == 0 {
                    value = "76616c75652031"
                } else if i == 1 {
                    value = "76616c75652032"
                } else if i == 2 {
                    value = "76616c75652033"
                } else if i == 3 {
                    value = "76616c75652034"
                }
                XCTAssertEqual(item.value as? String, value)
            }
            exp.fulfill()
        }.catch { _ in
            XCTFail()
            exp.fulfill()
        }

        wait(for: [exp], timeout: 35)
    }
}
