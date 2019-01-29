import XCTest
import Neoutils
import neovmUtils

class Tests: XCTestCase {
    
    var exampleWif = ""
    var exampleAddress = ""
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        if let w = newWallet() {
            exampleWif = w.wif()
            exampleAddress = w.address()
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

    func testGenerateWifHelper(){
        if let _ = generateFromWif(wif: exampleWif) {
            print("Created wallet")
        }
    }
}
