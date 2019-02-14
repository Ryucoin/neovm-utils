import XCTest
import Neoutils

class Tests: XCTestCase {

    var exampleWif : String!
    var exampleAddress : String!
    var examplePrivateKey : Data!
    var examplePublicKey : Data!

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        if let w = newWallet() {
            exampleWif = w.wif
            exampleAddress = w.address
            examplePrivateKey = w.privateKey
            examplePublicKey = w.publicKey
        }
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testExample() {
        // This is an example of a functional test case.
        XCTAssert(true, "Pass")
    }

    func testBuildOntologyInvocation(){
        let contractHash = "c168e0fb1a2bddcd385ad013c2c98358eca5d4dc"
        let method = "put"
        let argDict : [[String:Any]] = [["T":"Address", "V":exampleAddress], ["T":"String", "V":"Hello!"]]

        do {
            let data =  try JSONSerialization.data(withJSONObject: argDict, options: .prettyPrinted)
            let args = String(data: data, encoding: String.Encoding.utf8)
            let gasPrice = 500
            let gasLimit = 20000
            let wif = exampleWif
            let err = NSErrorPointer(nilLiteral: ())
            let res = NeoutilsBuildOntologyInvocationTransaction(contractHash, method, args, gasPrice, gasLimit, wif, exampleAddress, err)
            XCTAssertNil(err)
            XCTAssertNotNil(res)
            print("Response: \(res ?? "ERROR")")
        } catch let error {
            XCTFail("Failed to cast JSON: \(error)")
        }
    }

    func testOntologyInvocation(){
        let contractHash = "c168e0fb1a2bddcd385ad013c2c98358eca5d4dc"
        let method = "put"
        let argDict : [[String:Any]] = [["T":"Address", "V":exampleAddress], ["T":"String", "V":"Hello!"]]

        do {
            let data =  try JSONSerialization.data(withJSONObject: argDict, options: .prettyPrinted)
            let args = String(data: data, encoding: String.Encoding.utf8)
            let gasPrice = 500
            let gasLimit = 20000
            let endpoint = "http://polaris2.ont.io:20336"
            let wif = exampleWif
            let err = NSErrorPointer(nilLiteral: ())
            let res = NeoutilsOntologyInvoke(endpoint, contractHash, method, args, gasPrice, gasLimit, wif, exampleAddress, err)
            XCTAssertNil(err)
            XCTAssertNotNil(res)
            print("Response: \(res ?? "ERROR")")
        } catch let error {
            XCTFail("Failed to cast JSON: \(error)")
        }
    }

    func testBuildOntologyInvocationHelper(){
        let contractHash = "c168e0fb1a2bddcd385ad013c2c98358eca5d4dc"
        let method = "put"
        let args : [OntologyParameter] = [createOntParam(type: .Address, value: exampleAddress), createOntParam(type: .String, value: "Hello!")]
        let gasPrice = 500
        let gasLimit = 20000

        let res = buildOntologyInvocationTransaction(contractHash: contractHash, method: method, args: args, gasPrice: gasPrice, gasLimit: gasLimit, wif: exampleWif, payer: exampleAddress)
        XCTAssertNotNil(res)
        print("Response: \(res ?? "ERROR")")
    }

    func testOntologyInvocationHelper(){
        let contractHash = "c168e0fb1a2bddcd385ad013c2c98358eca5d4dc"
        let method = "put"
        let args : [OntologyParameter] = [createOntParam(type: .Address, value: exampleAddress), createOntParam(type: .String, value: "Hello!")]
        let gasPrice = 500
        let gasLimit = 20000
        
        let res = ontologyInvoke(contractHash: contractHash, method: method, args: args, gasPrice: gasPrice, gasLimit: gasLimit, wif: exampleWif)
        XCTAssertNotNil(res)
        print("Response: \(res ?? "ERROR")")
    }

    func testwalletFromWIF(){
        let _ = walletFromWIF(wif: exampleWif)
    }

    func testwalletFromPK(){
        let wallet = walletFromONTPrivateKey(privateKey: examplePrivateKey)

        guard let strPrivateKey = wallet?.privateKeyString else {
            XCTFail()
            return
        }

        let _ = walletFromONTPrivateKey(privateKey: strPrivateKey)
    }

    func testSign(){
        guard let wallet = walletFromONTPrivateKey(privateKey: examplePrivateKey) else {
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

    func testEncryptDecrypt(){
        let original = "Hello, world"
        guard let wallet = walletFromONTPrivateKey(privateKey: examplePrivateKey) else {
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

    func testSharedSecret(){
        guard let a = walletFromONTPrivateKey(privateKey: examplePrivateKey) else {
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

    func testIsValidAddress(){
        XCTAssertTrue(exampleAddress.isValidAddress)
    }

    func testGetBlockCount(){
        let blockCount = ontologyGetBlockCount()
        print("Block count: \(blockCount)")
        XCTAssertNotEqual(blockCount, -1)
    }

    func testGetBalances(){
        let (ont, ong) = ontologyGetBalances(address: "AcNZnTKFx1cA53H7DHcU9T6ErdVMzTrwSq")
        print("Ont: \(ont), Ong: \(ong)")
        let none = ont == 0 && ong == 0
        XCTAssertFalse(none)

        let (ontMain, ongMain) = ontologyGetBalances(endpoint: ontologyMainNodes.bestNode.rawValue, address: "AcNZnTKFx1cA53H7DHcU9T6ErdVMzTrwSq")
        print("Ont: \(ont), Ong: \(ong)")
        let noneMain = ontMain == 0 && ongMain == 0
        XCTAssertTrue(noneMain)
    }

    func testSendRawTransaction() {
        let contractHash = "c168e0fb1a2bddcd385ad013c2c98358eca5d4dc"
        let method = "put"
        let args : [OntologyParameter] = [createOntParam(type: .Address, value: exampleAddress), createOntParam(type: .String, value: "Hello!")]
        let gasPrice = 500
        let gasLimit = 20000

        guard let res = buildOntologyInvocationTransaction(contractHash: contractHash, method: method, args: args, gasPrice: gasPrice, gasLimit: gasLimit, wif: exampleWif, payer: exampleAddress) else {
            XCTFail()
            return
        }

        let txId = ontologySendRawTransaction(raw: res)
        print(txId)
    }

    func testGetStorage() {
        let contractHash = "c168e0fb1a2bddcd385ad013c2c98358eca5d4dc"
        let result = ontologyGetStorage(scriptHash: contractHash, key: exampleAddress)
        print("Result for getStorage: \(result)")
    }

    func testGetRawTransaction() {
        let txID = "f4250dab094c38d8265acc15c366dc508d2e14bf5699e12d9df26577ed74d657"
        let raw = ontologyGetRawTransaction(endpoint: ontologyMainNodes.bestNode.rawValue, txID: txID)
        let unknown = "unknown transaction"
        XCTAssertNotEqual(raw, unknown)
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
    
    func testBuildJoinTransaction() {
        let contractHash = "6b21a978e40e681c8439e2fb9cb39424920bf3e1"
        let gid = "G1"
        let mid = "M1"
        let entry = 10.0
        let max : Int = 1
        
        let target = createOntParam(type: .Address, value: exampleAddress)
        let gameId = createOntParam(type: .String, value: gid)
        let matchId = createOntParam(type: .String, value: mid)
        let fee = createOntParam(type: .Fixed8, value: entry)
        let mx = createOntParam(type: .Integer, value: max)

        let args = [target, gameId, matchId, fee, mx]

        let method = "join"

        let gasPrice = 500
        let gasLimit = 20000

        guard let tx = buildOntologyInvocationTransaction(contractHash: contractHash, method: method, args: args, gasPrice: gasPrice, gasLimit: gasLimit, wif: exampleWif, payer: exampleAddress) else {
            print("Failed to build the transaction")
            return
        }

        print(tx)
        XCTAssertNotEqual(tx, "")
    }

    func testNEP2() {
        let password = "12345678"
        guard let e = newEncryptedKey(wif: exampleWif, password: password) else {
            XCTFail()
            return
        }
        guard let w = wifFromEncryptedKey(encrypted: e, password: password) else {
            XCTFail()
            return
        }
        XCTAssertTrue(w == exampleWif)
    }

    func testTransferONT() {
        guard let b = newWallet() else {
            XCTFail()
            return
        }
        guard let tx = sendOntologyTransfer(wif: exampleWif, asset: .ONT, toAddress: b.address, amount: 10) else {
            return
        }
        print(tx)
    }

    func testClaimONG() {
        guard let tx = claimONG(wif: exampleWif) else {
            return
        }
        print(tx)
    }
}
