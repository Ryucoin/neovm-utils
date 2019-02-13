//
//  neovm.swift
//  Pods-neovmUtils_Tests
//
//  Created by Wyatt Mufson on 1/28/19.
//

import Foundation
import Neoutils
import CommonCrypto

public enum OntologyParameterType: String {
    case Address
    case String
    case Fixed8
    case Fixed9
    case Integer
    case Array
    case Unknown
}

public struct OntologyParameter {
    public var type : OntologyParameterType = .Unknown
    public var value : Any = ""
}

public func createOntParam(type:OntologyParameterType, value:Any) -> OntologyParameter {
    return OntologyParameter(type: type, value: value)
}

private func convertParamArray(params: [OntologyParameter]) -> [String: [[String:Any]]] {
    var args : [[String:Any]] = []
    for i in 0..<params.count {
        let item = params[i]
        let type = item.type.rawValue
        let value = item.value
        let arg : [String:Any] = ["type": type, "value": value]
        args.append(arg)
    }
    return ["array": args]
}

private func buildOntologyInvocationTransactionHelper(contractHash: String, method: String, args: [String: [[String:Any]]], gasPrice: Int, gasLimit: Int, wif: String, payer: String) -> String? {
    do {
        let data =  try JSONSerialization.data(withJSONObject: args)
        let params = String(data: data, encoding: String.Encoding.utf8)
        let err = NSErrorPointer(nilLiteral: ())
        let res = NeoutilsBuildOntologyInvocationTransaction(contractHash, method, params, gasPrice, gasLimit, wif, payer, err)
        return res
    } catch {
        return nil
    }
}

private func ontologyInvokeHelper(endpoint: String, contractHash: String, method: String, args: [String: [[String:Any]]], gasPrice: Int, gasLimit: Int, wif: String, payer: String) -> String? {
    do {
        let data =  try JSONSerialization.data(withJSONObject: args)
        let args = String(data: data, encoding: String.Encoding.utf8)
        let err = NSErrorPointer(nilLiteral: ())
        let res = NeoutilsOntologyInvoke(endpoint, contractHash, method, args, gasPrice, gasLimit, wif, payer, err)
        return res
    } catch {
        return nil
    }
}

private func addressFromWif(wif: String) -> String? {
    guard let wallet = walletFromWIF(wif: wif) else {
        return nil
    }
    return wallet.address
}

public func buildOntologyInvocationTransaction(contractHash: String, method: String, args: [OntologyParameter], gasPrice: Int = 0, gasLimit: Int = 0, wif: String, payer: String = "") -> String? {
    let params = convertParamArray(params: args)
    let p = payer == "" ? addressFromWif(wif: wif) ?? "" : payer
    return buildOntologyInvocationTransactionHelper(contractHash: contractHash, method: method, args: params, gasPrice: gasPrice, gasLimit: gasLimit, wif: wif, payer: p)
}

public func ontologyInvoke(endpoint: String = ontologyTestNodes.bestNode.rawValue, contractHash: String, method: String, args: [OntologyParameter], gasPrice: Int = 0, gasLimit: Int = 0, wif: String, payer: String = "") -> String? {
    let e = getEndpoint(def: endpoint)
    let params = convertParamArray(params: args)
    let p = payer == "" ? addressFromWif(wif: wif) ?? "" : payer
    return ontologyInvokeHelper(endpoint: e, contractHash: contractHash, method: method, args: params, gasPrice: gasPrice, gasLimit: gasLimit, wif: wif, payer: p)
}

public extension Data {
    public var bytesToHex: String? {
        return NeoutilsBytesToHex(self)
    }
}

public extension String {
    public var hexToBytes: Data? {
        return NeoutilsHexTobytes(self)
    }

    public var isValidAddress: Bool {
        return NeoutilsValidateNEOAddress(self)
    }
}

public func encrypt(message: String, key: Data) -> String {
    return NeoutilsEncrypt(key, message)
}

public func encrypt(message: String, key: String) -> String {
    return NeoutilsEncrypt(key.hexToBytes, message)
}

public func decrypt(encrypted: String, key: Data) -> String {
    return NeoutilsDecrypt(key, encrypted)
}

public func decrypt(encrypted: String, key: String) -> String {
    return NeoutilsDecrypt(key.hexToBytes, encrypted)
}

// Ontology RPC

public enum ontologyTestNodes: String {
    case polaris1 = "http://polaris1.ont.io:20336"
    case polaris2 = "http://polaris2.ont.io:20336"
    case polaris3 = "http://polaris3.ont.io:20336"
    case polaris4 = "http://polaris4.ont.io:20336"
    case bestNode = "testNetBestNode"
}

public enum ontologyMainNodes: String {
    case seed1 = "seed1.ont.io:20338"
    case seed2 = "seed2.ont.io:20338"
    case seed3 = "seed3.ont.io:20338"
    case seed4 = "seed4.ont.io:20338"
    case seed5 = "seed5.ont.io:20338"
    case bestNode = "mainNetBestNode"
}

public enum network {
    case mainNet
    case testNet
}

public func getBestNode(net:network) -> String {
    var bestNode = ""
    var bestCount = 0
    if net == .testNet {
        let count1 = ontologyGetBlockCount(endpoint: ontologyTestNodes.polaris1.rawValue)
        bestNode = ontologyTestNodes.polaris1.rawValue
        bestCount = count1
        let count2 = ontologyGetBlockCount(endpoint: ontologyTestNodes.polaris2.rawValue)
        if count2 > bestCount {
            bestNode = ontologyTestNodes.polaris2.rawValue
            bestCount = count2
        }
        let count3 = ontologyGetBlockCount(endpoint: ontologyTestNodes.polaris3.rawValue)
        if count3 > bestCount {
            bestNode = ontologyTestNodes.polaris3.rawValue
            bestCount = count3
        }
        let count4 = ontologyGetBlockCount(endpoint: ontologyTestNodes.polaris4.rawValue)
        if count4 > bestCount {
            bestNode = ontologyTestNodes.polaris4.rawValue
            bestCount = count4
        }
        return bestNode
    } else if net == .mainNet {
        let count1 = ontologyGetBlockCount(endpoint: ontologyMainNodes.seed1.rawValue)
        bestNode = ontologyMainNodes.seed1.rawValue
        bestCount = count1
        let count2 = ontologyGetBlockCount(endpoint: ontologyMainNodes.seed2.rawValue)
        if count2 > bestCount {
            bestNode = ontologyMainNodes.seed2.rawValue
            bestCount = count2
        }
        let count3 = ontologyGetBlockCount(endpoint: ontologyMainNodes.seed3.rawValue)
        if count3 > bestCount {
            bestNode = ontologyMainNodes.seed3.rawValue
            bestCount = count3
        }
        let count4 = ontologyGetBlockCount(endpoint: ontologyMainNodes.seed4.rawValue)
        if count4 > bestCount {
            bestNode = ontologyMainNodes.seed4.rawValue
            bestCount = count4
        }
        let count5 = ontologyGetBlockCount(endpoint: ontologyMainNodes.seed5.rawValue)
        if count5 > bestCount {
            bestNode = ontologyMainNodes.seed5.rawValue
            bestCount = count5
        }
        return bestNode
    }
    return ""
}

private func getEndpoint(def:String) -> String {
    if def == ontologyTestNodes.bestNode.rawValue {
        return getBestNode(net: .testNet)
    } else if def == ontologyMainNodes.bestNode.rawValue {
        return getBestNode(net: .mainNet)
    }
    return def
}

public func ontologyGetBlockCount(endpoint: String = ontologyTestNodes.bestNode.rawValue) -> Int {
    let e = getEndpoint(def: endpoint)
    let error = NSErrorPointer(nilLiteral: ())
    var count : Int = 0
    NeoutilsOntologyGetBlockCount(e, &count, error)
    if error != nil {
        return -1
    }
    return count
}

public func ontologyGetBalances(endpoint: String = ontologyTestNodes.bestNode.rawValue, address: String) -> (Int, Double) {
    let e = getEndpoint(def: endpoint)
    let error = NSErrorPointer(nilLiteral: ())
    let balances = NeoutilsOntologyGetBalance(e, address, error)
    let ont = Int(balances?.ont() ?? "0") ?? 0
    var ong = Double(balances?.ong() ?? "0") ?? 0
    ong = ong / 1000000000.0
    return (ont, ong)
}

public func ontologySendRawTransaction(endpoint: String = ontologyTestNodes.bestNode.rawValue, raw: String) -> String {
    let e = getEndpoint(def: endpoint)
    let error = NSErrorPointer(nilLiteral: ())
    let txId = NeoutilsOntologySendRawTransaction(e, raw, error)
    return txId ?? ""
}

public func ontologyGetStorage(endpoint: String = ontologyTestNodes.bestNode.rawValue, scriptHash: String, key: String) -> String {
    let e = getEndpoint(def: endpoint)
    let error = NSErrorPointer(nilLiteral: ())
    let item = NeoutilsOntologyGetStorage(e, scriptHash, key, error)
    return item ?? ""
}

public func ontologyGetRawTransaction(endpoint: String = ontologyTestNodes.bestNode.rawValue, txID: String) -> String {
    let e = getEndpoint(def: endpoint)
    let error = NSErrorPointer(nilLiteral: ())
    let raw = NeoutilsOntologyGetRawTransaction(e, txID, error)
    return raw ?? ""
}

public func ontologyGetBlockWithHash(endpoint: String = ontologyTestNodes.bestNode.rawValue, hash: String) -> String {
    let e = getEndpoint(def: endpoint)
    let error = NSErrorPointer(nilLiteral: ())
    let result = NeoutilsOntologyGetBlockWithHash(e, hash, error)
    return result ?? ""
}

public func ontologyGetBlockWithHeight(endpoint: String = ontologyTestNodes.bestNode.rawValue, height: Int) -> String {
    let e = getEndpoint(def: endpoint)
    let error = NSErrorPointer(nilLiteral: ())
    let result = NeoutilsOntologyGetBlockWithHeight(e, height, error)
    return result ?? ""
}

public class Wallet {
    public var address : String!
    public var wif : String!
    public var privateKey : Data!
    public var publicKey : Data!
    public var privateKeyString : String!
    public var publicKeyString : String!

    convenience init(address: String, wif: String, privateKey: Data, publicKey: Data) {
        self.init()
        self.address = address
        self.wif = wif
        self.privateKey = privateKey
        self.publicKey = publicKey
        self.privateKeyString = privateKey.bytesToHex
        self.publicKeyString = publicKey.bytesToHex
    }

    private func neoWallet() -> NeoutilsWallet? {
        let err = NSErrorPointer(nilLiteral: ())
        guard let neoWallet = NeoutilsGenerateFromWIF(wif, err) else {
            print("Failed to create neotuils wallet")
            return nil
        }
        return neoWallet
    }

    public func signMessage(message: String) -> String? {
        let error = NSErrorPointer(nilLiteral: ())
        guard let data = message.data(using: .utf8) else {
            return nil
        }
        return NeoutilsSign(data, privateKeyString, error).bytesToHex
    }

    // TODO: - Fix
    public func verifySignature(signature: String, message: String) -> Bool {
        guard let data = message.data(using: .utf8) else {
            return false
        }
        return NeoutilsVerify(publicKey, signature.hexToBytes, data)
    }

    public func computeSharedSecret(publicKey: Data) -> Data? {
        return neoWallet()?.computeSharedSecret(publicKey)
    }

    public func computeSharedSecret(publicKey: String) -> Data? {
        return neoWallet()?.computeSharedSecret(publicKey.hexToBytes)
    }
}

private func walletFromOntAccount(ontAccount: NeoutilsONTAccount) -> Wallet? {
    guard let a = ontAccount.address() else {
        print("Failed to get address from new ont account")
        return nil
    }
    guard let wif = ontAccount.wif() else {
        print("Failed to get wif from new ont account")
        return nil
    }
    guard let prK = ontAccount.privateKey() else {
        print("Failed to get private key from new ont account")
        return nil
    }
    guard let pbK = ontAccount.publicKey() else {
        print("Failed to get public key from new ont account")
        return nil
    }
    let w = Wallet(address: a, wif: wif, privateKey: prK, publicKey: pbK)
    return w
}

public func newWallet() -> Wallet? {
    guard let ontAccount = NeoutilsONTCreateAccount() else {
        print("Failed to generate new ont account")
        return nil
    }
    let wallet = walletFromOntAccount(ontAccount: ontAccount)
    return wallet
}

public func walletFromWIF(wif: String) -> Wallet? {
    guard let ontAccount = NeoutilsONTAccountFromWIF(wif) else {
        print("Failed to generate new ont account")
        return nil
    }
    let wallet = walletFromOntAccount(ontAccount: ontAccount)
    return wallet
}

public func walletFromPrivateKey(privateKey: String) -> Wallet? {
    guard let ontAccount = NeoutilsONTAccountFromPrivateKey(privateKey.hexToBytes) else {
        print("Failed to generate new ont account")
        return nil
    }
    let wallet = walletFromOntAccount(ontAccount: ontAccount)
    return wallet
}

public func walletFromPrivateKey(privateKey: Data) -> Wallet? {
    guard let ontAccount = NeoutilsONTAccountFromPrivateKey(privateKey) else {
        print("Failed to generate new ont account")
        return nil
    }
    let wallet = walletFromOntAccount(ontAccount: ontAccount)
    return wallet
}

public func newEncryptedKey(wif: String, password: String) -> String? {
    let error = NSErrorPointer(nilLiteral: ())
    let nep2 = NeoutilsNEP2Encrypt(wif, password, error)
    return nep2?.encryptedKey()
}

public func wifFromEncryptedKey(encrypted: String, password: String) -> String? {
    let error = NSErrorPointer(nilLiteral: ())
    let wif = NeoutilsNEP2Decrypt(encrypted, password, error)
    return wif
}

public enum OntAsset: String {
    case ONT
    case ONG
}

public func sendOntologyTransfer(endpoint: String = ontologyTestNodes.bestNode.rawValue, gasPrice: Int = 500, gasLimit: Int = 20000, wif: String, asset: OntAsset, toAddress: String, amount: Double) -> String? {
    let error = NSErrorPointer(nilLiteral: ())
    let txID = NeoutilsOntologyTransfer(endpoint, gasPrice, gasLimit, wif, asset.rawValue, toAddress, amount, error)
    if error != nil {
        print("There was an error transferring \(amount) \(asset.rawValue)")
        return nil
    }
    return txID
}

public func claimONG(endpoint: String = ontologyTestNodes.bestNode.rawValue, gasPrice: Int = 500, gasLimit: Int = 20000, wif: String) -> String? {
    let error = NSErrorPointer(nilLiteral: ())
    let txID = NeoutilsClaimONG(endpoint, gasPrice, gasLimit, wif, error)
    if error != nil {
        print("There was an error claiming ONG")
        return nil
    }
    return txID
}
