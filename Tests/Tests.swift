import XCTest
import Neoutils

class Tests: XCTestCase {
    var exampleWallet : Wallet!

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        if let w = newWallet() {
            exampleWallet = w
        }
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testBuildJoinTransaction() {
        let contractHash = "6b21a978e40e681c8439e2fb9cb39424920bf3e1"
        let gid = "G1"
        let mid = "M1"
        let entry = 10.0
        let max : Int = 1

        let target = createOntParam(type: .Address, value: exampleWallet.address)
        let gameId = createOntParam(type: .String, value: gid)
        let matchId = createOntParam(type: .String, value: mid)
        let fee = createOntParam(type: .Fixed8, value: entry)
        let mx = createOntParam(type: .Integer, value: max)

        let args = [target, gameId, matchId, fee, mx]

        let method = "join"

        let gasPrice = 500
        let gasLimit = 20000

        guard let tx = buildOntologyInvocationTransaction(contractHash: contractHash, method: method, args: args, gasPrice: gasPrice, gasLimit: gasLimit, wif: exampleWallet.wif, payer: exampleWallet.address) else {
            print("Failed to build the transaction")
            return
        }

        print(tx)
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
        let args : [OntologyParameter] = [createOntParam(type: .Address, value: exampleWallet.address), createOntParam(type: .String, value: "Hello!")]
        let gasPrice = 500
        let gasLimit = 20000

        let res = buildOntologyInvocationTransaction(contractHash: contractHash, method: method, args: args, gasPrice: gasPrice, gasLimit: gasLimit, wif: exampleWallet.wif, payer: exampleWallet.address)
        XCTAssertNotNil(res)
        
        let res2 = buildOntologyInvocationTransaction(contractHash: contractHash, method: method, args: args, gasPrice: gasPrice, gasLimit: gasLimit, wif: exampleWallet.wif, payer: exampleWallet.address)
        XCTAssertNotNil(res2)

        let res3 = buildOntologyInvocationTransaction(contractHash: contractHash, method: method, args: args, gasPrice: gasPrice, gasLimit: gasLimit, wif: "123")
        XCTAssertNil(res3)
    }

    func testClaimONG() {
        let tx = claimONG(wif: exampleWallet.wif)
        print(tx)
    }

    func testComparePrivateKeys() {
        for _ in 0..<5 {
            guard let wallet = newWallet() else {
                XCTFail()
                return
            }
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

        guard let ont = exampleWallet.privateKey else {
            XCTFail()
            return
        }
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
        let (ont, ong) = ontologyGetBalances(address: "AcNZnTKFx1cA53H7DHcU9T6ErdVMzTrwSq")
        print("Ont: \(ont), Ong: \(ong)")
        let none = ont == 0 && ong == 0
        XCTAssertFalse(none)

        let (ontMain, ongMain) = ontologyGetBalances(endpoint: ontologyMainNodes.bestNode.rawValue, address: "AcNZnTKFx1cA53H7DHcU9T6ErdVMzTrwSq")
        print("Ont: \(ont), Ong: \(ong)")
        let noneMain = ontMain == 0 && ongMain == 0
        XCTAssertTrue(noneMain)
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
        let txID = "f4250dab094c38d8265acc15c366dc508d2e14bf5699e12d9df26577ed74d657"
        let raw = ontologyGetRawTransaction(endpoint: ontologyMainNodes.bestNode.rawValue, txID: txID)
        let unknown = "unknown transaction"
        XCTAssertNotEqual(raw, unknown)
    }

    func testGetStorage() {
        let contractHash = "c168e0fb1a2bddcd385ad013c2c98358eca5d4dc"
        let result = ontologyGetStorage(scriptHash: contractHash, key: exampleWallet.address)
        print("Result for getStorage: \(result)")
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
            print("Response: \(res ?? "ERROR")")
        } catch let error {
            XCTFail("Failed to cast JSON: \(error)")
        }
    }

    func testOntologyInvocationHelper() {
        let contractHash = "c168e0fb1a2bddcd385ad013c2c98358eca5d4dc"
        let method = "put"
        let args : [OntologyParameter] = [createOntParam(type: .Address, value: exampleWallet.address), createOntParam(type: .String, value: "Hello!")]
        let gasPrice = 500
        let gasLimit = 20000

        let res = ontologyInvoke(contractHash: contractHash, method: method, args: args, gasPrice: gasPrice, gasLimit: gasLimit, wif: exampleWallet.wif)
        XCTAssertNotNil(res)
        print("Response: \(res ?? "ERROR")")
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
    }

    func testSendRawTransaction() {
        let contractHash = "c168e0fb1a2bddcd385ad013c2c98358eca5d4dc"
        let method = "put"
        let args : [OntologyParameter] = [createOntParam(type: .Address, value: exampleWallet.address), createOntParam(type: .String, value: "Hello!")]
        let gasPrice = 500
        let gasLimit = 20000

        guard let res = buildOntologyInvocationTransaction(contractHash: contractHash, method: method, args: args, gasPrice: gasPrice, gasLimit: gasLimit, wif: exampleWallet.wif, payer: exampleWallet.address) else {
            XCTFail()
            return
        }

        let txId = ontologySendRawTransaction(raw: res)
        print(txId)
    }

    func testSharedSecret() {
        guard let a = walletFromPrivateKey(privateKey: exampleWallet.privateKey) else {
            XCTFail()
            return
        }

        guard let b = newWallet() else {
            XCTFail()
            return
        }

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
        // TODO: - Verify still not working
        let verified = wallet.verifySignature(signature: signature, message: message)
        XCTAssertTrue(verified)
    }

    func testTransferONT() {
        guard let b = newWallet() else {
            XCTFail()
            return
        }
        let tx = sendOntologyTransfer(wif: exampleWallet.wif, asset: .ONT, toAddress: b.address, amount: 10)
        print(tx)
    }

    func testWalletFromPK() {
        let wallet = walletFromPrivateKey(privateKey: exampleWallet.privateKey)

        guard let strPrivateKey = wallet?.privateKeyString else {
            XCTFail()
            return
        }

        let _ = walletFromPrivateKey(privateKey: strPrivateKey)
    }

    func testWalletFromWIF() {
        let _ = walletFromWIF(wif: exampleWallet.wif)
    }
}
