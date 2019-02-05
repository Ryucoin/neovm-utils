//
//  neovm.swift
//  Pods-neovmUtils_Tests
//
//  Created by Wyatt Mufson on 1/28/19.
//

import Foundation
import Neoutils

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

public func buildOntologyInvocationTransaction(contractHash: String, method: String, args: [OntologyParameter], gasPrice: Int, gasLimit: Int, wif: String, payer: String) -> String? {
    let params = convertParamArray(params: args)
    return buildOntologyInvocationTransactionHelper(contractHash: contractHash, method: method, args: params, gasPrice: gasPrice, gasLimit: gasLimit, wif: wif, payer: payer)
}

public func ontologyInvoke(endpoint: String = ontologyTestNodes.bestNode.rawValue, contractHash: String, method: String, args: [OntologyParameter], gasPrice: Int, gasLimit: Int, wif: String, payer: String) -> String? {
    let e = getEndpoint(def: endpoint)
    let params = convertParamArray(params: args)
    return ontologyInvokeHelper(endpoint: e, contractHash: contractHash, method: method, args: params, gasPrice: gasPrice, gasLimit: gasLimit, wif: wif, payer: payer)
}

public func newWallet() -> NeoutilsWallet? {
    let err = NSErrorPointer(nilLiteral: ())
    return NeoutilsNewWallet(err)
}

public func generateFromWIF(wif: String) -> NeoutilsWallet? {
    let err = NSErrorPointer(nilLiteral: ())
    return NeoutilsGenerateFromWIF(wif, err)
}

public func generateFromPrivateKey(privateKey: String) -> NeoutilsWallet? {
    let err = NSErrorPointer(nilLiteral: ())
    return NeoutilsGenerateFromPrivateKey(privateKey, err)
}

public func generateFromPrivateKey(privateKey: Data) -> NeoutilsWallet? {
    let err = NSErrorPointer(nilLiteral: ())
    return NeoutilsGenerateFromPrivateKey(privateKey.bytesToHex, err)
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

public extension NeoutilsWallet {
    public var privateKeyString: String? {
        return self.privateKey()?.bytesToHex
    }

    public var publicKeyString: String? {
        return self.publicKey()?.bytesToHex
    }
}

public func signMessage(message: String, wallet: NeoutilsWallet) -> String? {
    let error = NSErrorPointer(nilLiteral: ())
    let data = message.data(using: .utf8)
    if let privateKey = wallet.privateKeyString {
        if let sign_data = NeoutilsSign(data, privateKey, error) {
            return sign_data.bytesToHex
        }
    }
    return nil
}

public func encrypt(message: String, key: Data) -> String? {
    return NeoutilsEncrypt(key, message)
}

public func encrypt(message: String, key: String) -> String? {
    return NeoutilsEncrypt(key.hexToBytes, message)
}

public func decrypt(encrypted: String, key: Data) -> String? {
    return NeoutilsDecrypt(key, encrypted)
}

public func decrypt(encrypted: String, key: String) -> String? {
    return NeoutilsDecrypt(key.hexToBytes, encrypted)
}

public func computeSharedSecret(wallet: NeoutilsWallet, publicKey: Data) -> Data? {
    return wallet.computeSharedSecret(publicKey)
}

public func computeSharedSecret(wallet: NeoutilsWallet, publicKey: String) -> Data? {
    return wallet.computeSharedSecret(publicKey.hexToBytes)
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
