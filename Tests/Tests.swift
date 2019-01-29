import XCTest
import Neoutils

class Tests: XCTestCase {
    
    var exampleWif = ""
    var exampleAddress = ""
    var examplePrivateKey = Data()
    var examplePublicKey = Data()
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        if let w = newWallet() {
            exampleWif = w.wif()
            exampleAddress = w.address()
            examplePrivateKey = w.privateKey()
            examplePublicKey = w.publicKey()
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
            let res = NeoutilsBuildOntologyInvocationTransaction(contractHash, method, args, gasPrice, gasLimit, wif, err)
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
            let res = NeoutilsOntologyInvoke(endpoint, contractHash, method, args, gasPrice, gasLimit, wif, err)
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
        let wif = exampleWif
        
        let res = buildOntologyInvocationTransaction(contractHash: contractHash, method: method, args: args, gasPrice: gasPrice, gasLimit: gasLimit, wif: wif)
        XCTAssertNotNil(res)
        print("Response: \(res ?? "ERROR")")
    }
    
    func testOntologyInvocationHelper(){
        let contractHash = "c168e0fb1a2bddcd385ad013c2c98358eca5d4dc"
        let method = "put"
        let args : [OntologyParameter] = [createOntParam(type: .Address, value: exampleAddress), createOntParam(type: .String, value: "Hello!")]
        let gasPrice = 500
        let gasLimit = 20000
        let wif = exampleWif
        
        let res = ontologyInvoke(contractHash: contractHash, method: method, args: args, gasPrice: gasPrice, gasLimit: gasLimit, wif: wif)
        XCTAssertNotNil(res)
        print("Response: \(res ?? "ERROR")")
    }

    func testGenerateFromWIF(){
        guard let _ = generateFromWIF(wif: exampleWif) else {
            XCTFail()
            return
        }
    }
    
    func testGenerateFromPK(){
        guard let wallet = generateFromPrivateKey(privateKey: examplePrivateKey) else {
            XCTFail()
            return
        }
        
        guard let strPrivateKey = wallet.privateKeyString else {
            XCTFail()
            return
        }
        
        guard let _ = generateFromPrivateKey(privateKey: strPrivateKey) else {
            XCTFail()
            return
        }
    }
    
    func testSign(){
        guard let wallet = generateFromPrivateKey(privateKey: examplePrivateKey) else {
            XCTFail()
            return
        }
        
        let message = "Hello, world"
        let signature = signMessage(message: message, wallet: wallet)
        XCTAssertNotNil(signature)
    }
    
    func testEncryptDecrypt(){
        let original = "Hello, world"
        guard let encrypted = encrypt(message: original, key: examplePrivateKey) else {
            XCTFail()
            return
        }
        
        guard let decrypted = decrypt(encrypted: encrypted, key: examplePrivateKey) else {
            XCTFail()
            return
        }
        
        XCTAssert(original == decrypted)
        
        guard let wallet = generateFromPrivateKey(privateKey: examplePrivateKey) else {
            XCTFail()
            return
        }
        
        guard let strPrivateKey = wallet.privateKeyString else {
            XCTFail()
            return
        }
        
        guard let encryptedString = encrypt(message: original, key: strPrivateKey) else {
            XCTFail()
            return
        }
        
        guard let decryptedString = decrypt(encrypted: encryptedString, key: strPrivateKey) else {
            XCTFail()
            return
        }
     
        XCTAssert(original == decryptedString)
    }
    
}
