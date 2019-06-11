import XCTest
import Neoutils

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

    func testBadOntKey() {
        let privateKeyStr = exampleWallet.privateKeyString
        let modified = privateKeyStr.dropFirst()
        let newPKS = "B\(modified)"
        guard let newPK = newPKS.hexToBytes else {
            XCTFail()
            return
        }

        print(privateKeyStr)
        print(newPKS)
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

    func testCES1() {
        let ces1 = CES1Interface(contractHash: "a47222204212ef759df954f1e1b156528098153d")
        let wallet = newWallet()
        let address = "ARCeBHE161cR8Z4YUaxtDGEJbAmt53M24W"
        let tokenId = 1
        let rarity = "Common"
        let name = "Slimey"

        XCTAssertEqual(ces1.getName(), "Ryu NFT Collectibles")
        XCTAssertEqual(ces1.getSymbol(), "RNC")
        XCTAssertTrue(ces1.getTotalSupply() > 1)
        XCTAssertTrue(ces1.getBalance(address: address) > 1)

        XCTAssertEqual(ces1.nameOf(tokenId: tokenId), name)
        XCTAssertEqual(ces1.getRarity(tokenId: tokenId), rarity)
        XCTAssertEqual(ces1.mint(tokenName: "Name", address: address, wallet: wallet), fault)

        let hex = ces1.tokensOf(address: address)
        let dynamic = DynamicList(hex: hex)
        let tokens = dynamic.flatten()
        for token in tokens {
            XCTAssertEqual(ces1.getOwner(tokenId: token).scriptHashToAddress(), address)
        }

        XCTAssertTrue(ces1.getNameSupply(name: name) >= 1)
        XCTAssertTrue(ces1.getRaritySupply(rarity: rarity) >= 1)
        XCTAssertTrue(ces1.getRarityAndNameSupply(rarity: rarity, name: name) >= 1)

        let dna = ces1.getDNA(tokenId: tokenId)
        XCTAssertTrue(dna.count == 120)
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

        let (ontMain, ongMain) = ontologyGetBalances(endpoint: mainNet, address: address)
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
        let raw = ontologyGetRawTransaction(endpoint: mainNet, txID: txID)
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

    func testLockedWallet() {
        let a = newWallet()
        let originalData = a.toData()
        let locked = a.lock(password: "123")
        XCTAssertTrue(locked)
        let second = a.lock(password: "456")
        XCTAssertFalse(second)
        let sig = a.signMessage(message: "Hello, world!")
        XCTAssertNil(sig)
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

    func testOEP10() {
        let oep5 = OEP5Interface(contractHash: "cae215265a5e348bfd603b8db22893aa74b42417", endpoint: mainNet)
        let wallet = newWallet()
        let hash = "edf64937ca304ea8180fa92e2de36dc0a33cc712"
        XCTAssertTrue(oep5.approveContract(hash: hash, wallet: wallet).hasSuffix("no balance enough to cover gas cost 10000000"))
        XCTAssertTrue(oep5.unapproveContract(hash: hash, wallet: wallet).hasSuffix("no balance enough to cover gas cost 10000000"))
        XCTAssertEqual(oep5.isApproved(hash: hash, wallet: wallet), "00")
    }

    func testOEP4() {
        let oep4 = OEP4Interface(contractHash: "78b98deed62aa708eaf6de85843734ecdfb14c1b", endpoint: mainNet)
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

        let from = OntologyParameter(type: .Address, value: address)
        let to = OntologyParameter(type: .Address, value: wallet.address)
        let amount = OntologyParameter(type: .Fixed8, value: 1.0)
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
        let oep5 = OEP5Interface(contractHash: "cae215265a5e348bfd603b8db22893aa74b42417", endpoint: mainNet)
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

        XCTAssertEqual(oep5.allowance(tokenId: "A"), "00")
        XCTAssertEqual(oep5.allowance(tokenId: 1.5), "00")

        XCTAssertEqual(oep5.allowance(tokenId: tokenId), "00")
        XCTAssertEqual(oep5.tokensOf(address: address), "00")
        XCTAssertTrue(oep5.approvalForAll(owner: address, to: ownerAddress, approval: true, wallet: wallet).hasSuffix("no balance enough to cover gas cost 10000000"))
        XCTAssertTrue(oep5.approvalForAll(owner: address, to: ownerAddress, approval: false, wallet: wallet).hasSuffix("no balance enough to cover gas cost 10000000"))
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
            let num = res.hexToDecimal()
            XCTAssertGreaterThan(num, 0)
            print(num)
        }
    }

    func testOntologyParameterArrayFail() {
        let param = OntologyParameter(type: .Array, value: 5)
        let args: [OntologyParameter] = [param]
        let res = ontologyInvokeRead(contractHash: "a29564a30043d50620e4c6be61eda834d0acc48b", method: "getTotal", args: args)
        let num = res.hexToDecimal()
        XCTAssertGreaterThan(num, 0)
        print(num)
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
