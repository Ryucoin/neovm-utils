import XCTest
import Neoutils

class Tests: XCTestCase {
    var exampleWallet : Wallet = newWallet()

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

    func testBuildJoinTransaction() {
        let contractHash = "6b21a978e40e681c8439e2fb9cb39424920bf3e1"
        let gid = "G1"
        let mid = "M1"
        let entry = 10.0
        let max : Int = 1

        let target = OntologyParameter(type: .Address, value: exampleWallet.address)
        let gameId = OntologyParameter(type: .String, value: gid)
        let matchId = OntologyParameter(type: .String, value: mid)
        let fee = OntologyParameter(type: .Fixed8, value: entry)
        let mx = OntologyParameter(type: .Integer, value: max)

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
            let data =  try JSONSerialization.data(withJSONObject: argDict, options: .prettyPrinted)
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
        let args: [OntologyParameter] = [OntologyParameter(type: .Address, value: exampleWallet.address), OntologyParameter(type: .String, value: "Hello!")]
        let gasPrice = 500
        let gasLimit = 20000

        let res = buildOntologyInvocationTransaction(contractHash: contractHash, method: method, args: args, gasPrice: gasPrice, gasLimit: gasLimit, wif: exampleWallet.wif, payer: exampleWallet.address)
        XCTAssertNotEqual("", res)
        
        let res2 = buildOntologyInvocationTransaction(contractHash: contractHash, method: method, args: args, gasPrice: gasPrice, gasLimit: gasLimit, wif: exampleWallet.wif, payer: exampleWallet.address)
        XCTAssertNotEqual("", res2)

        let res3 = buildOntologyInvocationTransaction(contractHash: contractHash, method: method, args: args, gasPrice: gasPrice, gasLimit: gasLimit, wif: "123")
        XCTAssertEqual("", res3)
    }

    func testBuildOntologyInvocationHelperFail() {
        let contractHash = "c168e0fb1a2bddcd385ad013c2c98358eca5d4dc"
        let method = "put"

        let badStr = String(
            bytes: [0xD8, 0x00] as [UInt8],
            encoding: String.Encoding.utf16BigEndian)!

        let args: [OntologyParameter] = [OntologyParameter(type: .Address, value: exampleWallet.address), OntologyParameter(type: .String, value: badStr)]
        let gasPrice = 500
        let gasLimit = 20000

        let res = buildOntologyInvocationTransaction(contractHash: contractHash, method: method, args: args, gasPrice: gasPrice, gasLimit: gasLimit, wif: exampleWallet.wif, payer: exampleWallet.address)
        XCTAssertEqual("", res)
    }

    func testClaimONG() {
        let tx = claimONG(wif: exampleWallet.wif)
        print(tx)
    }

    func testComparePrivateKeys() {
        for _ in 0..<5 {
            let wallet = newWallet()
            let ont = wallet.privateKey.count
            let neo = wallet.neoPrivateKey.count
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
        let neo = exampleWallet.neoPrivateKey

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

        guard let n = neo.bytesToHex else {
            XCTFail()
            return
        }

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

    func testEncryptDecrypt() {
        let original = "Hello, world"
        guard let wallet = walletFromPrivateKey(privateKey: exampleWallet.privateKey) else {
            XCTFail()
            return
        }

        let encrypted = wallet.privateEncrypt(message: original)
        let decrypted = wallet.privateDecrypt(encrypted: encrypted)
        let encryptedString = wallet.privateEncrypt(message: original)
        let decryptedString = wallet.privateDecrypt(encrypted: encryptedString)

        XCTAssert(original == decrypted)
        XCTAssert(original == decryptedString)
    }

    func testGetBalances() {
        let address = "AFmseVrdL9f9oyCzZefL9tG6UbviEH9ugK"
        let (ont, ong) = ontologyGetBalances(address: address)
        XCTAssertTrue(ont > 0 && ong > 0)

        let (ontMain, ongMain) = ontologyGetBalances(endpoint: ontologyMainNodes.bestNode.rawValue, address: address)
        XCTAssertTrue(ontMain > 0 && ongMain > 0)
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
        let raw = ontologyGetRawTransaction(endpoint: ontologyMainNodes.bestNode.rawValue, txID: txID)
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

    func testNEP2() {
        let password = "12345678"
        guard let e = newEncryptedKey(wif: exampleWallet.wif, password: password) else {
            XCTFail()
            return
        }
        guard let w = wifFromEncryptedKey(encrypted: e, password: password) else {
            XCTFail()
            return
        }
        XCTAssertTrue(w == exampleWallet.wif)
    }

    func testOEP4() {
        let oep4 = OEP4Interface(contractHash: "25277b421a58cfc2ef5836767e54eb7abdd31afd", endpoint: ontologyTestNodes.bestNode.rawValue)
        let address = "ATrApQ3w4xLnc2yDkEDXw1zAk9Ue544Csz"

        XCTAssertEqual(oep4.getName(), "LUCKY")
        XCTAssertEqual(oep4.getSymbol(), "LCY")
        XCTAssertEqual(oep4.getDecimals(), "09")
        XCTAssertEqual(oep4.getTotalSupply(), "0000e8890423c78a00")
        XCTAssertEqual(oep4.getBalance(address: address), "")
    }

    func testOEP8() {
        let oep8 = OEP8Interface(contractHash: "edf64937ca304ea8180fa92e2de36dc0a33cc712")
        let address = "AHDP1jtfMA1vMpy3Gy41vMfyVWQym4eTwu"

        XCTAssertEqual(oep8.getName(tokenId: 1), "redpumpkin")
        XCTAssertEqual(oep8.getSymbol(tokenId: 1), "REP")
        XCTAssertEqual(oep8.getTotalSupply(tokenId: 1), "400d03")
        XCTAssertEqual(oep8.getBalance(address: address, tokenId: 1), "400d03")
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
    }

    func testOntologyInvocation() {
        let contractHash = "c168e0fb1a2bddcd385ad013c2c98358eca5d4dc"
        let method = "put"
        let argDict : [[String:Any]] = [["T":"Address", "V":exampleWallet.address], ["T":"String", "V":"Hello!"]]

        do {
            let data =  try JSONSerialization.data(withJSONObject: argDict, options: .prettyPrinted)
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
        let args: [OntologyParameter] = [OntologyParameter(type: .Address, value: exampleWallet.address), OntologyParameter(type: .String, value: "Hello!")]
        let gasPrice = 500
        let gasLimit = 20000

        let res = ontologyInvoke(contractHash: contractHash, method: method, args: args, gasPrice: gasPrice, gasLimit: gasLimit, wif: exampleWallet.wif, payer: exampleWallet.address)
        XCTAssertNotEqual("", res)

        let res2 = ontologyInvoke(contractHash: contractHash, method: method, args: args, gasPrice: gasPrice, gasLimit: gasLimit, wif: exampleWallet.wif)
        XCTAssertNotEqual("", res2)

        let res3 = ontologyInvoke(contractHash: contractHash, method: method, args: args, gasPrice: gasPrice, gasLimit: gasLimit, wif: "123")
        XCTAssertEqual("", res3)
    }

    func testOntologyInvocationHelperFail() {
        let contractHash = "c168e0fb1a2bddcd385ad013c2c98358eca5d4dc"
        let method = "put"

        let badStr = String(
            bytes: [0xD8, 0x00] as [UInt8],
            encoding: String.Encoding.utf16BigEndian)!

        let args: [OntologyParameter] = [OntologyParameter(type: .Address, value: exampleWallet.address), OntologyParameter(type: .String, value: badStr)]
        let gasPrice = 500
        let gasLimit = 20000

        let res = ontologyInvoke(contractHash: contractHash, method: method, args: args, gasPrice: gasPrice, gasLimit: gasLimit, wif: exampleWallet.wif, payer: exampleWallet.address)
        XCTAssertEqual("", res)
    }

    func testOntologyInvocationRead() {
        let contractHash = "a29564a30043d50620e4c6be61eda834d0acc48b"

        let methods: [String] = ["getTotal", "getCirculation", "getLocked"]
        for method in methods {
            let res = ontologyInvokeRead(contractHash: contractHash, method: method, args: [])
            XCTAssertNotEqual(res, "")
            print(res)
        }
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
        XCTAssertEqual(q2.code, exampleWallet.neoPrivateKey.bytesToHex!)
        XCTAssertEqual(q3.code, newEncryptedKey(wif: exampleWallet.wif, password: passphrase) ?? "")
        XCTAssertEqual(q4.code, exampleWallet.wif)
        XCTAssertEqual(q5.code, exampleWallet.address)
        XCTAssertEqual(q6.code, exampleWallet.publicKeyString)
        q1.layoutSubviews()
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
        let args: [OntologyParameter] = [OntologyParameter(type: .Address, value: exampleWallet.address), OntologyParameter(type: .String, value: "Hello!")]
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
        let verified = wallet.verifySignature(pubKey: exampleWallet.publicKey, signature: signature, message: message)
        XCTAssertTrue(verified)
        let notVerified = wallet.verifySignature(pubKey: exampleWallet.publicKey, signature: signature, message: "\(message)1")
        XCTAssertFalse(notVerified)
    }

    func testTransferONT() {
        let b = newWallet()
        let tx = ontologyTransfer(wif: exampleWallet.wif, asset: .ONT, toAddress: b.address, amount: 10)
        print(tx)
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
}
