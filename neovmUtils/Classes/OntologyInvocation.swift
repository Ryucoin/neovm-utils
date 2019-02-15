//
//  OntologyInvocation.swift
//  neovmUtils_Tests
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
