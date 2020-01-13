//
//  Ontology-AssetTests.swift
//  neovmUtils_Tests
//
//  Created by Wyatt Mufson on 10/2/19.
//  Copyright © 2020 Ryu Blockchain Technologies. All rights reserved.
//

import XCTest

class Ontology_AssetTests: XCTestCase {
    var exampleWallet: Wallet = newWallet()
    let fault = "[NeoVmService] vm execution encountered a state fault!"

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testOEP10() {
        let oep5 = OEP5Interface(contractHash: "cae215265a5e348bfd603b8db22893aa74b42417", testnet: false)
        let wallet = newWallet()
        let hash = "edf64937ca304ea8180fa92e2de36dc0a33cc712"
        XCTAssertTrue(oep5.approveContract(hash: hash, wallet: wallet).hasSuffix("no balance enough to cover gas cost 10000000"))
        XCTAssertTrue(oep5.unapproveContract(hash: hash, wallet: wallet).hasSuffix("no balance enough to cover gas cost 10000000"))
        XCTAssertEqual(oep5.isApproved(hash: hash, wallet: wallet), "00")
    }

    func testOEP4() {
        let oep4 = OEP4Interface(contractHash: "78b98deed62aa708eaf6de85843734ecdfb14c1b", testnet: false)
        let address = "ATrApQ3w4xLnc2yDkEDXw1zAk9Ue544Csz"

        XCTAssertEqual(oep4.getName(), "SEED")
        XCTAssertEqual(oep4.getSymbol(), "SEED")
        let decimals = Double(oep4.getDecimals())
        XCTAssertEqual(decimals, 6)
        let rawSupply = oep4.getTotalSupply()
        let actual = Int(Double(rawSupply) / pow(10, decimals))
        XCTAssertEqual(actual, 100000000000)
        XCTAssertEqual(oep4.getBalance(address: address), 0)

        let wallet = newWallet()
        let res = oep4.transfer(from: address, to: wallet.address, amount: 1, decimals: 8, wallet: wallet)
        XCTAssertTrue(res.hasSuffix("no balance enough to cover gas cost 10000000"))
        let resx = oep4.transfer(from: address, to: wallet.address, amount: 1, decimals: 9, wallet: wallet)
        XCTAssertTrue(resx.hasSuffix("no balance enough to cover gas cost 10000000"))
        let args: [Any] = [address, wallet.address, 1]
        let res2 = oep4.transferMulti(args: [args], decimals: 8, wallet: wallet)
        XCTAssertEqual(res2, fault)
        let args2: [Any] = [address, wallet.address, 1]
        let res3 = oep4.transferMulti(args: [args2], decimals: 9, wallet: wallet)
        XCTAssertEqual(res3, fault)
        let args3: [Any] = [address, wallet.address, 1, 5]
        let res4 = oep4.transferMulti(args: [args3], decimals: 9, wallet: wallet)
        XCTAssertNotEqual(res4, "")

        let args3b: [Any] = [wallet.address, address, 1, 5]
        let res4b = oep4.transferMulti(args: [args3b], decimals: 9, wallet: wallet)
        XCTAssertTrue(res4b.hasSuffix("no balance enough to cover gas cost 10000000"))

        let res5 = oep4.approve(owner: wallet.address, spender: address, amount: 1, decimals: 8, wallet: wallet)
        XCTAssertEqual(res5, fault)
        let res6 = oep4.approve(owner: wallet.address, spender: address, amount: 1, decimals: 9, wallet: wallet)
        XCTAssertEqual(res6, fault)

        let allowance = oep4.allowance(owner: wallet.address, spender: address)
        XCTAssertEqual(allowance, 0)

        let from = NVMParameter(type: .Address, value: address)
        let to = NVMParameter(type: .Address, value: wallet.address)
        let amount = NVMParameter(type: .Fixed8, value: 1.0)
        let res7 = oep4.customInvoke(operation: "transfer", args: [from, to, amount], wallet: wallet)
        XCTAssertNotEqual(res7, "")

        let decimals2 = oep4.customRead(operation: "decimals", args: []).hexToDecimal()
        XCTAssertEqual(decimals2, 6)

        let res8 = oep4.transferFrom(spender: address, from: wallet.address, to: address, amount: 1, decimals: 8, wallet: wallet)
        let res9 = oep4.transferFrom(spender: address, from: wallet.address, to: address, amount: 1, decimals: 9, wallet: wallet)
        XCTAssertTrue(res8.hasSuffix("no balance enough to cover gas cost 10000000"))
        XCTAssertTrue(res9.hasSuffix("no balance enough to cover gas cost 10000000"))
    }

    func testOEP5() {
        let oep5 = OEP5Interface(contractHash: "cae215265a5e348bfd603b8db22893aa74b42417", testnet: false)
        let wallet = newWallet()
        let address = wallet.address
        let tokenId = 87
        let state = OEP5State(address: address, tokenId: tokenId)
        let supply = oep5.getTotalSupply()

        let owner = oep5.getOwner(tokenId: tokenId)
        let ownerAddress = owner.scriptHashToAddress()

        XCTAssertEqual(oep5.getName(), "HyperDragons")
        XCTAssertEqual(oep5.getSymbol(), "HD")
        XCTAssertTrue(supply > 2969)
        XCTAssertEqual(oep5.getBalance(address: address), 0)
        XCTAssertEqual(owner, "654c9d8057fefb71a41954ec9b96d3af997119f9")
        XCTAssertEqual(ownerAddress, "AR1VgCAkzwqJKEA3K36g33HrBa3Yzd4Ssd")

        XCTAssertEqual(oep5.transfer(address: address, tokenId: tokenId, wallet: wallet), fault)
        XCTAssertEqual(oep5.transferMulti(args: [state], wallet: wallet), fault)
        XCTAssertEqual(oep5.transferMulti(args: [[address, tokenId]], wallet: wallet), fault)
        XCTAssertTrue(oep5.transferMulti(args: [[address, tokenId, "invalid"]], wallet: wallet).hasSuffix("no balance enough to cover gas cost 10000000"))

        XCTAssertEqual(oep5.approve(address: address, tokenId: tokenId, wallet: wallet), fault)
        XCTAssertTrue(oep5.clearApproved(tokenId: tokenId, wallet: wallet).hasSuffix("no balance enough to cover gas cost 10000000"))

        XCTAssertEqual(oep5.getApproved(tokenId: "A"), "00")
        XCTAssertEqual(oep5.getApproved(tokenId: 1.5), "00")

        XCTAssertEqual(oep5.getApproved(tokenId: tokenId), "00")
        XCTAssertEqual(oep5.tokensOf(address: address), "00")
        XCTAssertTrue(oep5.approvalForAll(owner: address, to: ownerAddress, approval: true, wallet: wallet).hasSuffix("no balance enough to cover gas cost 10000000"))
        XCTAssertTrue(oep5.approvalForAll(owner: address, to: ownerAddress, approval: false, wallet: wallet).hasSuffix("no balance enough to cover gas cost 10000000"))

        let hex = oep5.tokenMetadata(tokenId: tokenId)
        let parser = NVMParser()
        let raw = parser.deserialize(hex: hex)
        guard let metadata = raw as? [String: Any] else {
            XCTFail("Failed to cast metadata to dict")
            return
        }

        guard let image = metadata["image"] as? String else {
            XCTFail("Failed to cast image")
            return
        }

        guard let name = metadata["name"] as? String else {
            XCTFail("Failed to cast name")
            return
        }

        let imageURL = "https://hyd-go-res.alfakingdom.com/normal/W.svg"
        XCTAssertEqual(imageURL, image.hexToAscii())

        let tokenName = "dragon#W"
        XCTAssertEqual(tokenName, name.hexToAscii())
    }

    func testOEP5Big() {
        let oep5 = OEP5Interface(contractHash: "463cff118238915e974e0610a3422b32718329ce")
        let address = "AdKhP9DJkuXTiKPSpWKde3zcL8XVVsMTc8"
        let address2 = "ASvdG49hEJ9rbA247v9Moa1JSjKAiJZfEH"

        let raw1 = oep5.tokensOf(address: address)
        let dynamic1 = DynamicList(hex: raw1)
        let array1 = dynamic1.flatten()
        let actual1 = array1.count
        let calculated1 = dynamic1.items
        XCTAssertEqual(actual1, calculated1)

        let raw2 = oep5.tokensOf(address: address2)
        let dynamic2 = DynamicList(hex: raw2)
        let array2 = dynamic2.flatten()
        let actual2 = array2.count
        let calculated2 = dynamic2.items
        XCTAssertEqual(actual2, calculated2)

        XCTAssertTrue(actual1 > 1024)
        XCTAssertTrue(actual2 > 1024)
    }

    func testOEP8() {
        let oep8 = OEP8Interface(contractHash: "edf64937ca304ea8180fa92e2de36dc0a33cc712")
        let address = "AHDP1jtfMA1vMpy3Gy41vMfyVWQym4eTwu"
        let wallet = newWallet()
        let tokenId: Int = 1
        let state = OEP8State(from: address, to: wallet.address, tokenId: tokenId, amount: 1)

        XCTAssertEqual(oep8.getName(tokenId: tokenId), "redpumpkin")
        XCTAssertEqual(oep8.getSymbol(tokenId: tokenId), "REP")
        XCTAssertEqual(oep8.getTotalSupply(tokenId: tokenId), 200000)
        XCTAssertEqual(oep8.getBalance(address: address, tokenId: tokenId), 200000)

        XCTAssertEqual(oep8.transfer(from: address, to: wallet.address, tokenId: tokenId, amount: 1, wallet: wallet), fault)
        XCTAssertEqual(oep8.transferMulti(args: [state], wallet: wallet), fault)
        XCTAssertEqual(oep8.transferMulti(args: [[address, wallet.address, tokenId, 1]], wallet: wallet), fault)
        XCTAssertTrue(oep8.transferMulti(args: [[address, tokenId, "invalid"]], wallet: wallet).hasSuffix("no balance enough to cover gas cost 10000000"))

        XCTAssertEqual(oep8.approve(from: address, to: wallet.address, tokenId: tokenId, amount: 1, wallet: wallet), fault)
        XCTAssertEqual(oep8.transferFrom(spender: address, from: address, to: wallet.address, tokenId: tokenId, amount: 1, wallet: wallet), fault)
        XCTAssertEqual(oep8.getAllowance(owner: address, spender: wallet.address, tokenId: tokenId), 0)

        XCTAssertEqual(oep8.approveMulti(args: [state], wallet: wallet), fault)
        XCTAssertEqual(oep8.approveMulti(args: [[address, wallet.address, tokenId, 1]], wallet: wallet), fault)
        XCTAssertTrue(oep8.approveMulti(args: [[address, tokenId, "invalid"]], wallet: wallet).hasSuffix("no balance enough to cover gas cost 10000000"))

        XCTAssertEqual(oep8.transferFromMulti(args: [[address, address, wallet.address, tokenId, 1]], wallet: wallet), fault)
        XCTAssertTrue(oep8.transferFromMulti(args: [[address, address, wallet.address, tokenId]], wallet: wallet).hasSuffix("no balance enough to cover gas cost 10000000"))
    }

    func testOID() {
        let identity = createIdentity()
        let res = sendRegister(ident: identity, payerAcct: exampleWallet)
        let identity2 = createIdentity(password: "1234")
        let res2 = sendRegister(ident: identity2, password: "1234", payerAcct: exampleWallet)
        let res3 = sendRegister(ident: identity2, password: "12345", payerAcct: exampleWallet)
        XCTAssertNotEqual(res, "")
        XCTAssertNotEqual(res2, "")
        XCTAssertEqual(res3, "")
        let identity3 = createIdentity()
        identity3.wif = ""
        let res4 = sendRegister(ident: identity3, payerAcct: exampleWallet)
        XCTAssertEqual(res4, "")
        let res5 = sendRegister(ident: identity2, payerAcct: exampleWallet)
        XCTAssertEqual(res5, "")
        let unlocked = identity.unlock(password: "1234")
        XCTAssertFalse(unlocked)
        let identity4 = createIdentity()
        identity4.wif = ""
        let locked = identity4.lock(password: "1234")
        XCTAssertFalse(locked)
    }

    func testRES1() {
        let res1 = RES1Interface(contractHash: "a47222204212ef759df954f1e1b156528098153d")
        let wallet = newWallet()
        let address = "ARCeBHE161cR8Z4YUaxtDGEJbAmt53M24W"
        let tokenId = 1
        let rarity = "Common"
        let name = "Slimey"

        XCTAssertEqual(res1.getName(), "Ryu NFT Collectibles")
        XCTAssertEqual(res1.getSymbol(), "RNC")
        XCTAssertTrue(res1.getTotalSupply() > 1)
        XCTAssertTrue(res1.getBalance(address: address) > 1)

        XCTAssertEqual(res1.nameOf(tokenId: tokenId), name)
        XCTAssertEqual(res1.getRarity(tokenId: tokenId), rarity)
        XCTAssertEqual(res1.mint(tokenName: "Name", address: address, wallet: wallet), fault)

        let hex = res1.tokensOf(address: address)
        let dynamic = DynamicList(hex: hex)
        let tokens = dynamic.flatten()
        for token in tokens {
            XCTAssertEqual(res1.getOwner(tokenId: token).scriptHashToAddress(), address)
        }

        XCTAssertTrue(res1.getNameSupply(name: name) >= 1)
        XCTAssertTrue(res1.getRaritySupply(rarity: rarity) >= 1)
        XCTAssertTrue(res1.getRarityAndNameSupply(rarity: rarity, name: name) >= 1)

        let dna = res1.getDNA(tokenId: tokenId)
        XCTAssertTrue(dna.count == 120)

        let colorStruct1 = res1.getColor(tokenId: "A")
        let color1 = colorStruct1.color
        let alpha1 = colorStruct1.alpha

        let colorStructD = res1.getColor(tokenId: 65)
        let colorD = colorStructD.color
        let alphaD = colorStructD.alpha
        XCTAssertEqual(color1, colorD)
        XCTAssertEqual(alpha1, alphaD)
        XCTAssertEqual(color1, "8000ff")
        XCTAssertEqual(alpha1, "ff")

        let colorStruct2 = res1.getColor(tokenId: tokenId)
        let color2 = colorStruct2.color
        let alpha2 = colorStruct2.alpha
        XCTAssertEqual(color2, "ffffff")
        XCTAssertEqual(alpha2, "ff")

        let approvalForAllError = "RES1 Assets do not support approvalForAll"
        XCTAssertEqual(res1.approvalForAll(owner: address, to: address, approval: true, wif: wallet.wif), approvalForAllError)
        XCTAssertEqual(res1.approvalForAll(owner: address, to: address, approval: true, wallet: wallet), approvalForAllError)
        let tokenMetadataError = "RES1 Assets do not support tokenMetadata"
        XCTAssertEqual(res1.tokenMetadata(tokenId: tokenId), tokenMetadataError)

        let hexEmpty = res1.tokensOf(address: newWallet().address)
        XCTAssertEqual(hexEmpty, "")
        let dynamicEmpty = DynamicList(hex: hexEmpty)
        let tokensEmpty = dynamicEmpty.flatten()
        XCTAssertEqual(tokensEmpty.count, 0)
    }

    func testSendGetDDO() {
        let ontid = "did:ont:ATJEoWVjzTTuXRu5aRZWyoAP4kCeKSQCVi"
        guard let ddo = sendGetDDO(ontid: ontid) else {
            XCTFail()
            return
        }
        let pk = ddo.publicKeys
        let attr = ddo.attributes
        let recovery = ddo.recovery
        let formattedPk = pk.map { $0.getFull() }
        let formattedAttr = attr.map { $0.getFull() }
        XCTAssertEqual(formattedPk.count, 2)
        XCTAssertEqual(formattedAttr.count, 0)
        XCTAssertEqual(recovery, "")
        let identity = createIdentity(password: "1234")
        identity.ontid = "did:ont:AUh7JcTVhh5W26Ch9tpdJoD4vnJANzHBhH"
        guard let ddoR = sendGetDDO(ident: identity) else {
            XCTFail()
            return
        }
        let recoveryR = ddoR.recovery
        XCTAssertNotEqual(recoveryR, "")

        let ontidA = "did:ont:AdzkzvG9ekuAjFh589UmVrbtgbGmz1eNdU"
        guard let ddoA = sendGetDDO(ontid: ontidA) else {
            XCTFail()
            return
        }
        let pkA = ddoA.publicKeys
        let attrA = ddoA.attributes
        let recoveryA = ddoA.recovery
        let formattedPkA = pkA.map { $0.getFull() }
        let formattedAttrA = attrA.map { $0.getFull() }
        if formattedPkA.count == 1 {
            let formatedPublicKey = formattedPkA[0]
            XCTAssertEqual(formatedPublicKey["Curve"], "P256")
            XCTAssertEqual(formatedPublicKey["Type"], "ECDSA")
            XCTAssertEqual(formatedPublicKey["PubKeyId"], "did:ont:AdzkzvG9ekuAjFh589UmVrbtgbGmz1eNdU#keys-1")
            XCTAssertEqual(formatedPublicKey["Value"], "0314ef57dfcbff4b7fdb157d3eefeedc126fbec532579ee7c77a20a53f59d9d311")
        } else {
            XCTFail()
        }

        if formattedAttrA.count == 1 {
            let formatedAttributte = formattedAttrA[0]
            XCTAssertEqual(formatedAttributte["Type"], "string")
            XCTAssertEqual(formatedAttributte["Key"], "hello")
            XCTAssertEqual(formatedAttributte["Value"], "attribute")
        } else {
            XCTFail()
        }
        XCTAssertEqual(recoveryA, "")
    }

    func testSendGetDDOInvalid() {
        let ontid = "ATJEoWVjzTTuXRu5aRZWyoAP4kCeKSQCVi"
        let ddo = sendGetDDO(ontid: ontid)
        XCTAssertNil(ddo)
        let identity = createIdentity()
        identity.ontid = ontid
        let ddo2 = sendGetDDO(ident: identity)
        XCTAssertNil(ddo2)
    }
}
