import XCTest
import Neoutils
import SwiftPromises

class Tests: XCTestCase {
    var exampleWallet : Wallet = newWallet()
    let fault = "[NeoVmService] vm execution encountered a state fault!"

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testAddressFromPublicKey() {
        XCTAssertEqual(exampleWallet.address, addressFromPublicKey(publicKey: exampleWallet.publicKeyString))
        XCTAssertEqual("", addressFromPublicKey(publicKey: "1234"))
        XCTAssertEqual("", addressFromPublicKey(publicKey: ""))
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

    func testBadOntKey() {
        let privateKeyStr = exampleWallet.privateKeyString
        let modified = privateKeyStr.dropFirst()
        let newPKS = "B\(modified)"
        guard let newPK = newPKS.hexToBytes else {
            XCTFail()
            return
        }
        let nWallet = walletFromPrivateKey(privateKey: newPK)
        XCTAssertNil(nWallet)
    }

    func testBadWif() {
        let wif = exampleWallet.wif
        let modified = wif.dropFirst()
        let newWif = "B\(modified)"
        let nWallet = walletFromWIF(wif: newWif)
        XCTAssertNil(nWallet)
    }

    func testBase58() {
        let address = newWallet().address
        let bad = address + "a"
        let hash = address.hashFromAddress()
        let badHash = bad.hashFromAddress()
        XCTAssertNotEqual("", hash)
        XCTAssertEqual("", badHash)
        XCTAssertEqual("", "BA".hashFromAddress())
        XCTAssertEqual("", "BAX".hashFromAddress())
        XCTAssertEqual("", "BADA".hashFromAddress())
        XCTAssertEqual("", "BA0102".hashFromAddress())
        XCTAssertEqual("", "BA234234234".hashFromAddress())
        XCTAssertEqual("", "a12312B123123123A".hashFromAddress())
        XCTAssertEqual("", "a12312B123123123Aa12312B123123123A".hashFromAddress())
        XCTAssertEqual("", "123242345235".hashFromAddress())
        XCTAssertEqual("", "DASDASDASDADA".hashFromAddress())
        XCTAssertEqual("", "EASEAESASEASEASE".hashFromAddress())
        XCTAssertEqual("", "D\(address)".hashFromAddress())
        XCTAssertEqual("", "1\(address)".hashFromAddress())
    }

    func testBuildJoinTransaction() {
        let contractHash = "6b21a978e40e681c8439e2fb9cb39424920bf3e1"
        let gid = "G1"
        let mid = "M1"
        let entry = 10.0
        let max : Int = 1

        let target = NVMParameter(type: .Address, value: exampleWallet.address)
        let gameId = NVMParameter(type: .String, value: gid)
        let matchId = NVMParameter(type: .String, value: mid)
        let fee = NVMParameter(type: .Fixed8, value: entry)
        let mx = NVMParameter(type: .Integer, value: max)

        let args = [target, gameId, matchId, fee, mx]

        let method = "join"

        let gasPrice = 500
        let gasLimit = 20000

        let tx = buildOntologyInvocationTransaction(contractHash: contractHash, method: method, args: args, gasPrice: gasPrice, gasLimit: gasLimit, wif: exampleWallet.wif, payer: exampleWallet.address)
        XCTAssertNotEqual(tx, "")
    }

    func testBuildOntologyInvocation() {
        let contractHash = "c168e0fb1a2bddcd385ad013c2c98358eca5d4dc"
        let method = "put"
        let argDict : [[String:Any]] = [["T":"Address", "V":exampleWallet.address], ["T":"String", "V":"Hello!"]]

        do {
            let data = try JSONSerialization.data(withJSONObject: argDict, options: .prettyPrinted)
            let args = String(data: data, encoding: String.Encoding.utf8)
            let gasPrice = 500
            let gasLimit = 20000
            let wif = exampleWallet.wif
            let err = NSErrorPointer(nilLiteral: ())
            let res = NeoutilsBuildOntologyInvocationTransaction(contractHash, method, args, gasPrice, gasLimit, wif, exampleWallet.address, err)
            XCTAssertNil(err)
            XCTAssertNotNil(res)
        } catch let error {
            XCTFail("Failed to cast JSON: \(error)")
        }
    }

    func testBuildOntologyInvocationHelper() {
        let contractHash = "c168e0fb1a2bddcd385ad013c2c98358eca5d4dc"
        let method = "put"
        let args: [NVMParameter] = [NVMParameter(type: .Address, value: exampleWallet.address), NVMParameter(type: .String, value: "Hello!")]
        let gasPrice = 500
        let gasLimit = 20000

        let res = buildOntologyInvocationTransaction(contractHash: contractHash, method: method, args: args, gasPrice: gasPrice, gasLimit: gasLimit, wif: exampleWallet.wif, payer: exampleWallet.address)
        XCTAssertNotEqual("", res)
        
        let res2 = buildOntologyInvocationTransaction(contractHash: contractHash, method: method, args: args, gasPrice: gasPrice, gasLimit: gasLimit, wif: exampleWallet.wif, payer: exampleWallet.address)
        XCTAssertNotEqual("", res2)

        let res3 = buildOntologyInvocationTransaction(contractHash: contractHash, method: method, args: args, gasPrice: gasPrice, gasLimit: gasLimit, wif: "123")
        XCTAssertEqual("", res3)
    }

    func testClaimONG() {
        let tx = claimONG(wif: exampleWallet.wif)
        print(tx)
    }

    func testComparePrivateKeys() {
        for _ in 0..<5 {
            let wallet = newWallet()
            let ont = wallet.privateKey.count
            guard let neo = wallet.neoPrivateKey?.count else {
                XCTFail()
                return
            }

            if (neo > ont) {
                XCTFail()
                return
            }
        }
    }

    func testCompareWallet() {
        guard let a = walletFromWIF(wif: exampleWallet.wif) else {
            XCTFail()
            return
        }

        let ont = exampleWallet.privateKey
        guard let neo = exampleWallet.neoPrivateKey else {
            XCTFail()
            return
        }

        guard let b = walletFromPrivateKey(privateKey: ont) else {
            XCTFail()
            return
        }

        guard let c = walletFromPrivateKey(privateKey: neo) else {
            XCTFail()
            return
        }

        guard let d = walletFromPrivateKey(privateKey: exampleWallet.privateKeyString) else {
            XCTFail()
            return
        }

        let n = neo.bytesToHex
        guard let e = walletFromPrivateKey(privateKey: n) else {
            XCTFail()
            return
        }

        let a1 = a.address
        let a2 = b.address
        let a3 = c.address
        let a4 = d.address
        let a5 = e.address

        XCTAssert(a1 == a2)
        XCTAssert(a1 == a3)
        XCTAssert(a1 == a4)
        XCTAssert(a1 == a5)
        XCTAssertNotNil(a1)
        XCTAssertNotNil(a2)
        XCTAssertNotNil(a3)
        XCTAssertNotNil(a4)
        XCTAssertNotNil(a5)
    }

    func testCreateMnemonic() {
        let mnemonic = createMnemonic()
        guard let phrase = mnemonic.value else {
            XCTFail()
            return
        }
        print(phrase)
        XCTAssertTrue(mnemonic.isValid())
    }

    func testData() {
        let a = newWallet()
        let b = a

        guard let d_a = a.toData() else {
            XCTFail()
            return
        }

        guard let d_b = b.toData() else {
            XCTFail()
            return
        }

        XCTAssertEqual(d_a, d_b)
        do {
            let w = try JSONDecoder().decode(Wallet.self, from: d_a)
            XCTAssertTrue(same(a: a, b: w))
        } catch {
            XCTFail()
        }
    }

    func testEncryptDecrypt() {
        let original = "Hello, world"
        guard let wallet = walletFromPrivateKey(privateKey: exampleWallet.privateKey) else {
            XCTFail()
            return
        }

        guard let encrypted = wallet.privateEncrypt(message: original) else {
            XCTFail()
            return
        }

        let decrypted = wallet.privateDecrypt(encrypted: encrypted)
        guard let encryptedString = wallet.privateEncrypt(message: original) else {
            XCTFail()
            return
        }

        let decryptedString = wallet.privateDecrypt(encrypted: encryptedString)

        XCTAssert(original == decrypted)
        XCTAssert(original == decryptedString)
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

    func testHexFail() {
        let string = "ABCDEFGHIJKLMNOPQRSTUV"
        XCTAssertEqual(string.hexToDecimal(), 0)
    }

    func testInvalidKeys() {
        let p = "NOT A VALID PRIVATE KEY"
        let w = "NOT A VALID WIF"
        let data = Data()

        let a = walletFromPrivateKey(privateKey: p)
        let b = walletFromWIF(wif: w)
        let c = walletFromPrivateKey(privateKey: data)
        let addr = addressFromWif(wif: w)

        XCTAssertNil(a)
        XCTAssertNil(b)
        XCTAssertNil(c)
        XCTAssertNil(addr)
    }

    func testIsValidAddress() {
        XCTAssertTrue(exampleWallet.address.isValidAddress)
    }

    func testLockedWallet() {
        let a = newWallet()
        let originalData = a.toData()
        let locked = a.lock(password: "123")
        XCTAssertTrue(locked)
        let second = a.lock(password: "456")
        XCTAssertFalse(second)
        let sig = a.signMessage(message: "Hello, world!")
        XCTAssertNil(sig)
        let signed = a.signData(data: originalData ?? Data())
        XCTAssertNil(signed)
        let publicKey = newWallet().publicKey
        let publicKeyString = newWallet().publicKeyString
        let shared = a.computeSharedSecret(publicKey: publicKey)
        XCTAssertNil(shared)
        let sharedString = a.computeSharedSecret(publicKey: publicKeyString)
        XCTAssertNil(sharedString)
        let enc = a.privateEncrypt(message: "XXX")
        XCTAssertNil(enc)
        let dec = a.privateDecrypt(encrypted: "XXX")
        XCTAssertNil(dec)
        let lockedData = a.toData()
        XCTAssertNotEqual(originalData, lockedData)
        let unlocked1 = a.unlock(password: "1234")
        XCTAssertFalse(unlocked1)
        let unlocked2 = a.unlock(password: "123")
        XCTAssertTrue(unlocked2)
        let unlocked3 = a.unlock(password: "123")
        XCTAssertFalse(unlocked3)
    }

    func testLocking() {
        let wallet = newWallet()
        let wif = wallet.wif
        let password = "password"

        XCTAssertEqual(wif, wallet.wif)
        XCTAssertFalse(wallet.locked)
        let locked = wallet.lock(password: password)
        XCTAssertTrue(locked)
        XCTAssertNotEqual(wif, wallet.wif)
        XCTAssertEqual("", wallet.wif)
        XCTAssertTrue(wallet.locked)

        guard let data = try? JSONEncoder().encode(wallet) else {
            XCTFail()
            return
        }

        do {
            let w = try JSONDecoder().decode(Wallet.self, from: data)
            XCTAssertNotEqual(wif, w.wif)
            XCTAssertEqual("", w.wif)
            XCTAssertTrue(w.locked)
            XCTAssertTrue(same(a: wallet, b: w))

            let unlocked = w.unlock(password: password)
            XCTAssertTrue(unlocked)
            XCTAssertEqual(wif, w.wif)
            XCTAssertNotEqual("", w.wif)
            XCTAssertFalse(w.locked)
            XCTAssertFalse(same(a: wallet, b: w))

            let unlocked2 = wallet.unlock(password: password)
            XCTAssertTrue(unlocked2)
            XCTAssertEqual(wif, wallet.wif)
            XCTAssertNotEqual("", wallet.wif)
            XCTAssertFalse(wallet.locked)
            XCTAssertTrue(same(a: wallet, b: w))
        } catch {
            XCTFail("\(error)")
        }
    }

    func testLockingIncorrectly() {
        let a = newAccount()
        a.wif = ""
        let locked = a.lock(password: "123")
        XCTAssertFalse(locked)
    }

    func testMnemonic() {
        let m = createMnemonic()
        guard let w = walletFromMnemonicPhrase(mnemonic: m.value!) else {
            XCTFail()
            return
        }
        XCTAssertTrue(m.isValid())

        let p1 = privateKeyFromMnemonic(mnemonic: m)
        let p2 = w.neoPrivateKey
        XCTAssertEqual(p1, p2)

        guard let w2 = walletFromPrivateKey(privateKey: p1) else {
            XCTFail()
            return
        }
        XCTAssertEqual(w.wif, w2.wif)
    }

    func testMnemonicPair() {
        let pair = newWalletMnemonicPair()
        let wallet = pair.0
        let mnemonic = pair.1

        XCTAssertTrue(mnemonic.isValid())
        XCTAssertEqual(mnemonic.seed, mnemonicFromPhrase(phrase: mnemonic.value).seed)
        guard let w = walletFromMnemonicPhrase(mnemonic: mnemonic.value) else {
            XCTFail()
            return
        }
        XCTAssertEqual(wallet.address, w.address)
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

    func testNEP2() {
        let password = "12345678"
        guard let e = newEncryptedKey(wif: exampleWallet.wif, password: password) else {
            XCTFail()
            return
        }

        let w = wifFromEncryptedKey(encrypted: e, password: password)
        XCTAssertTrue(w == exampleWallet.wif)
    }

    func testNewWallet() {
        let label = "Hello there!"
        let password = "12345"
        let wallet = newWallet(label: label, password: password)
        XCTAssertTrue(wallet.locked)
        XCTAssertEqual(wallet.wif, "")
        XCTAssertEqual(wallet.label, label)
        let unlocked = wallet.unlock(password: password)
        XCTAssertTrue(unlocked)
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
        XCTAssertEqual(res, fault)
        let resx = oep4.transfer(from: address, to: wallet.address, amount: 1, decimals: 9, wallet: wallet)
        XCTAssertEqual(resx, fault)
        let args: [Any] = [address, wallet.address, 1]
        let res2 = oep4.transferMulti(args: [args], decimals: 8, wallet: wallet)
        XCTAssertEqual(res2, fault)
        let args2: [Any] = [address, wallet.address, 1]
        let res3 = oep4.transferMulti(args: [args2], decimals: 9, wallet: wallet)
        XCTAssertEqual(res3, fault)
        let args3: [Any] = [address, wallet.address, 1, 5]
        let res4 = oep4.transferMulti(args: [args3], decimals: 9, wallet: wallet)
        XCTAssertNotEqual(res4, "")

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
        XCTAssertEqual(res8, fault)
        XCTAssertEqual(res9, fault)
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

    func testOntMonitor() {
        let exp = expectation(description: "Ont monitor")
        let monitor = OntMonitor.shared
        let blockHeight = monitor.blockHeight
        XCTAssertEqual(blockHeight, 0)

        func finish(_ monitor: OntMonitor, _ num: Int, _ exp: XCTestExpectation) {
            print("Found new height #\(num): \(monitor.blockHeight)")
            print("TPS: \(monitor.tps)")
            print("Block time: \(monitor.blockTime)")
            print("Since last block: \(monitor.sinceLastBlock)")
            print("Status: \(monitor.currentState.name)")
            exp.fulfill()
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            let blockHeight2 = monitor.blockHeight
            if blockHeight == blockHeight2 {
                DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                    let blockHeight3 = monitor.blockHeight
                    if blockHeight == blockHeight3 {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                            let blockHeight4 = monitor.blockHeight
                            if blockHeight == blockHeight4 {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                                    let blockHeight5 = monitor.blockHeight
                                    if blockHeight == blockHeight5 {
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                                            let blockHeight6 = monitor.blockHeight
                                            if blockHeight == blockHeight6 {
                                                XCTFail("No block in 30 seconds")
                                            } else {
                                                finish(monitor, 6, exp)
                                            }
                                        }
                                    } else {
                                        finish(monitor, 5, exp)
                                    }
                                }
                            } else {
                                finish(monitor, 4, exp)
                            }
                        }
                    } else {
                        finish(monitor, 3, exp)
                    }
                }
            } else {
                finish(monitor, 2, exp)
            }
        }
        wait(for: [exp], timeout: 35)
    }

    func testOntologyInvocation() {
        let contractHash = "c168e0fb1a2bddcd385ad013c2c98358eca5d4dc"
        let method = "put"
        let argDict : [[String:Any]] = [["T":"Address", "V":exampleWallet.address], ["T":"String", "V":"Hello!"]]

        do {
            let data = try JSONSerialization.data(withJSONObject: argDict, options: .prettyPrinted)
            let args = String(data: data, encoding: String.Encoding.utf8)
            let gasPrice = 500
            let gasLimit = 20000
            let endpoint = "http://polaris2.ont.io:20336"
            let wif = exampleWallet.wif
            let err = NSErrorPointer(nilLiteral: ())
            let res = NeoutilsOntologyInvoke(endpoint, contractHash, method, args, gasPrice, gasLimit, wif, exampleWallet.address, err)
            XCTAssertNil(err)
            XCTAssertNotNil(res)
            print("Response: \(res)")
        } catch let error {
            XCTFail("Failed to cast JSON: \(error)")
        }
    }

    func testOntologyInvocationHelper() {
        let contractHash = "c168e0fb1a2bddcd385ad013c2c98358eca5d4dc"
        let method = "put"
        let args: [NVMParameter] = [NVMParameter(type: .Address, value: exampleWallet.address), NVMParameter(type: .String, value: "Hello!")]
        let gasPrice = 500
        let gasLimit = 20000

        let res = ontologyInvoke(contractHash: contractHash, method: method, args: args, gasPrice: gasPrice, gasLimit: gasLimit, wif: exampleWallet.wif, payer: exampleWallet.address)
        XCTAssertNotEqual("", res)

        let res2 = ontologyInvoke(contractHash: contractHash, method: method, args: args, gasPrice: gasPrice, gasLimit: gasLimit, wif: exampleWallet.wif)
        XCTAssertNotEqual("", res2)

        let res3 = ontologyInvoke(contractHash: contractHash, method: method, args: args, gasPrice: gasPrice, gasLimit: gasLimit, wif: "123")
        XCTAssertEqual("", res3)
    }

    func testOntologyInvocationRead() {
        let contractHash = "a29564a30043d50620e4c6be61eda834d0acc48b"

        let methods: [String] = ["getTotal", "getCirculation", "getLocked"]
        for method in methods {
            let res = ontologyInvokeRead(contractHash: contractHash, method: method, args: [])
            let num = res.hexToDecimal()
            XCTAssertGreaterThan(num, 0)
            print(num)
        }
    }

    func testOntologyWallet() {
        let wallet = OntologyWallet(name: "My Wallet")
        let account = newAccount()
        let account2 = newAccount()
        XCTAssertNotEqual(account.address, account2.address)

        XCTAssertEqual(wallet.accounts.count, 0)
        wallet.addAccount(acc: account)
        XCTAssertEqual(wallet.accounts.count, 1)
        wallet.setDefaultAccountAddress(acc: account)
        XCTAssertEqual(wallet.accounts.count, 1)
        wallet.setDefaultAccountAddress(acc: account2)
        XCTAssertEqual(wallet.accounts.count, 2)

        let ident = createIdentity()
        let ident2 = createIdentity()
        XCTAssertNotEqual(ident.ontid, ident2.ontid)

        XCTAssertEqual(wallet.identities.count, 0)
        wallet.addIdentity(ident: ident)
        XCTAssertEqual(wallet.identities.count, 1)
        wallet.setDefaultOntId(ident: ident)
        XCTAssertEqual(wallet.identities.count, 1)
        wallet.setDefaultOntId(ident: ident2)
        XCTAssertEqual(wallet.identities.count, 2)

        wallet.removeIdenitity(ident: ident2)
        XCTAssertEqual(wallet.identities.count, 1)
        XCTAssertEqual(wallet.defaultOntid, "")

        wallet.removeAccount(acc: account2)
        XCTAssertEqual(wallet.accounts.count, 1)
        XCTAssertEqual(wallet.defaultAccountAddress, "")
    }

    func testPublicKeyFrom() {
        guard let p1 = publicKeyFromWif(wif: exampleWallet.wif) else {
            XCTFail()
            return
        }

        guard let p2 = publicKeyFromPrivateKey(privateKey: exampleWallet.privateKeyString) else {
            XCTFail()
            return
        }

        XCTAssertEqual(p1, p2)
        let p3 = publicKeyFromWif(wif: "123")
        let p4 = publicKeyFromPrivateKey(privateKey: "123")
        XCTAssertNil(p3)
        XCTAssertNil(p4)
    }

    func testQRGenerator() {
        let passphrase = "Hello, world!"
        let q1 = exampleWallet.exportQR(key: .PrivateKey)
        let q2 = exampleWallet.exportQR(key: .NEOPrivateKey)
        let q3 = exampleWallet.exportQR(key: .NEP2, passphrase: passphrase)
        let q4 = exampleWallet.exportQR(key: .WIF)
        let q5 = exampleWallet.exportQR(key: .Address)
        let q6 = exampleWallet.exportQR(key: .PublicKey)
        XCTAssertEqual(q1.code, exampleWallet.privateKeyString)
        XCTAssertEqual(q2.code, exampleWallet.neoPrivateKey?.bytesToHex)
        XCTAssertEqual(q3.code, newEncryptedKey(wif: exampleWallet.wif, password: passphrase) ?? "")
        XCTAssertEqual(q4.code, exampleWallet.wif)
        XCTAssertEqual(q5.code, exampleWallet.address)
        XCTAssertEqual(q6.code, exampleWallet.publicKeyString)
        q1.layoutSubviews()
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

    func testSendRawTransaction() {
        let contractHash = "c168e0fb1a2bddcd385ad013c2c98358eca5d4dc"
        let method = "put"
        let args: [NVMParameter] = [NVMParameter(type: .Address, value: exampleWallet.address), NVMParameter(type: .String, value: "Hello!")]
        let gasPrice = 500
        let gasLimit = 20000

        let res = buildOntologyInvocationTransaction(contractHash: contractHash, method: method, args: args, gasPrice: gasPrice, gasLimit: gasLimit, wif: exampleWallet.wif, payer: exampleWallet.address)
        let txId = ontologySendRawTransaction(raw: res)
        XCTAssertNotEqual("", res)
        XCTAssertNotEqual("", txId)
    }

    func testSharedSecret() {
        guard let a = walletFromPrivateKey(privateKey: exampleWallet.privateKey) else {
            XCTFail()
            return
        }

        let b = newWallet()

        guard let shared = b.computeSharedSecret(publicKey: a.publicKey) else {
            XCTFail()
            return
        }

        guard let shared2 = b.computeSharedSecret(publicKey: a.publicKeyString) else {
            XCTFail()
            return
        }

        XCTAssertEqual(shared, shared2)

        let original = "Hello, world"
        let encrypted = a.sharedEncrypt(message: original, publicKey: b.publicKey)
        let decrypted = a.sharedDecrypt(encrypted: encrypted, publicKey: b.publicKey)
        XCTAssertEqual(original, decrypted)
    }

    func testSign() {
        guard let wallet = walletFromPrivateKey(privateKey: exampleWallet.privateKey) else {
            XCTFail()
            return
        }

        let message = "Hello, world"
        guard let signature = wallet.signMessage(message: message) else {
            XCTFail()
            return
        }
        XCTAssertNotNil(signature)
        let verified = wallet.verifySignature(signature: signature, message: message)
        XCTAssertTrue(verified)
        let notVerified = wallet.verifySignature(signature: signature, message: "\(message)1")
        XCTAssertFalse(notVerified)
    }

    func testTransferONT() {
        let b = newWallet()
        let tx = ontologyTransfer(wif: exampleWallet.wif, asset: .ONT, toAddress: b.address, amount: 10)
        print(tx)
    }

    func testUtils() {
        let str = "abc"
        let d = str.dataWithHexString()
        XCTAssertEqual(d.count, 0)
    }

    func testWalletFromPK() {
        let wallet = walletFromPrivateKey(privateKey: exampleWallet.privateKey)
        XCTAssertNotNil(wallet)
        let w = walletFromPrivateKey(privateKey: exampleWallet.privateKeyString)
        XCTAssertNotNil(w)
        let str = "123456789012345678901234567890"
        let data = str.data(using: .utf8)!
        let a = walletFromPrivateKey(privateKey: data)
        XCTAssertNil(a)
    }

    func testWalletFromWIF() {
        let _ = walletFromWIF(wif: exampleWallet.wif)
    }

    func testWif() {
        let str = "ABCDEFGHIJKLMNOPQRTSTUVWXYZ"
        let w1 = wifFromEncryptedKey(encrypted: str, password: "123")
        let wif = newWallet().wif
        guard let encrypted = newEncryptedKey(wif: wif, password: "123") else {
            XCTFail()
            return
        }
        let w2 = wifFromEncryptedKey(encrypted: encrypted, password: "456")
        let none = ""
        XCTAssertEqual(none, w1)
        XCTAssertEqual(none, w2)
        let enc2 = newEncryptedKey(wif: "", password: "")
        XCTAssertNil(enc2)
    }
}
