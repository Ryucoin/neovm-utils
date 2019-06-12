//
//  OntologyInvocation.swift
//  neovmUtils
//
//  Created by Wyatt Mufson on 2/15/19.
//  Copyright © 2019 Ryu Blockchain Technologies. All rights reserved.
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
    case Bool
    case Unknown
}

public class OntologyParameter {
    public var type: OntologyParameterType = .Unknown
    public var value: Any = ""

    public convenience init(type: OntologyParameterType, value: Any) {
        self.init()
        if type == .Bool {
            self.type = .Integer
            let value = value as? Bool ?? false
            self.value = value ? 1 : 0
        } else {
            self.type = type
            self.value = value
        }
    }
}

public class OEP5State {
    private var address: String = ""
    private var tokenId: Any = ""

    public convenience init(address: String, tokenId: Any) {
        self.init()
        self.address = address
        self.tokenId = tokenId
    }

    public func getParam() -> [Any] {
        let array = [address, tokenId]
        return array
    }
}

public class OEP8State {
    private var from: String = ""
    private var to: String = ""
    private var tokenId: Any = ""
    private var amount: Int = 0

    public convenience init(from: String, to: String, tokenId: Any, amount: Int) {
        self.init()
        self.from = from
        self.to = to
        self.tokenId = tokenId
        self.amount = amount
    }

    public func getParam() -> [Any] {
        let array = [from, to, tokenId, amount]
        return array
    }
}

private func convertParamArray(params: [OntologyParameter]) -> [String: [[String: Any]]] {
    var args: [[String: Any]] = []
    for i in 0..<params.count {
        let item = params[i]
        if item.type == .Array {
            guard let arr = item.value as? [OntologyParameter] else {
                continue
            }

            let dict = convertParamArray(params: arr)
            var str: String = ""
            if let data = try? JSONSerialization.data(withJSONObject: dict) {
                str = String(data: data, encoding: .utf8) ?? ""
            }

            let arg: [String: Any] = ["type": item.type.rawValue, "value": str]
            args.append(arg)
        } else {
            let type = item.type.rawValue
            let value = item.value
            let arg: [String: Any] = ["type": type, "value": value]
            args.append(arg)
        }
    }
    return ["array": args]
}

private func buildOntologyInvocationTransactionHelper(contractHash: String, method: String, args: [String: [[String: Any]]], gasPrice: Int, gasLimit: Int, wif: String, payer: String) -> String {
    do {
        let data = try JSONSerialization.data(withJSONObject: args)
        let params = String(data: data, encoding: .utf8)
        let err = NSErrorPointer(nilLiteral: ())
        let res = NeoutilsBuildOntologyInvocationTransaction(contractHash, method, params, gasPrice, gasLimit, wif, payer, err)
        return res
    } catch {
        return ""
    }
}

private func ontologyInvokeHelper(endpoint: String, contractHash: String, method: String, args: [String: [[String: Any]]], gasPrice: Int, gasLimit: Int, wif: String, payer: String) -> String {
    do {
        let data = try JSONSerialization.data(withJSONObject: args)
        let args = String(data: data, encoding: .utf8)
        let err = NSErrorPointer(nilLiteral: ())
        let res = NeoutilsOntologyInvoke(endpoint, contractHash, method, args, gasPrice, gasLimit, wif, payer, err)
        return res
    } catch {
        return ""
    }
}

public func buildOntologyInvocationTransaction(contractHash: String, method: String, args: [OntologyParameter], gasPrice: Int = 0, gasLimit: Int = 0, wif: String, payer: String = "") -> String {
    let params = convertParamArray(params: args)
    let p = payer == "" ? addressFromWif(wif: wif) ?? "" : payer
    return buildOntologyInvocationTransactionHelper(contractHash: contractHash, method: method, args: params, gasPrice: gasPrice, gasLimit: gasLimit, wif: wif, payer: p)
}

public func ontologyInvoke(endpoint: String = ontologyTestNet, contractHash: String, method: String, args: [OntologyParameter], gasPrice: Int = 0, gasLimit: Int = 0, wif: String, payer: String = "") -> String {
    let e = getEndpoint(def: endpoint)
    let params = convertParamArray(params: args)
    let p = payer == "" ? addressFromWif(wif: wif) ?? "" : payer
    return ontologyInvokeHelper(endpoint: e, contractHash: contractHash, method: method, args: params, gasPrice: gasPrice, gasLimit: gasLimit, wif: wif, payer: p)
}

public func ontologyInvokeRead(endpoint: String = ontologyTestNet, contractHash: String, method: String, args: [OntologyParameter]) -> String {
    let wallet = newWallet()
    let raw = buildOntologyInvocationTransaction(contractHash: contractHash, method: method, args: args, gasPrice: 500, gasLimit: 20000, wif: wallet.wif, payer: wallet.address)
    let res = ontologySendPreExecRawTransaction(endpoint: endpoint, raw: raw)
    return res
}
