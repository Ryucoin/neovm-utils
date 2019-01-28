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

private func convertParamArray(params: [OntologyParameter]) -> [[String:Any]] {
    var args : [[String:Any]] = []
    for i in 0..<params.count {
        let item = params[i]
        let type = item.type.rawValue
        let value = item.value
        let arg : [String:Any] = ["T": type, "V": value]
        args.append(arg)
    }
    return args
}

private func buildOntologyInvocationTransactionHelper(contractHash: String, method: String, args: [[String:Any]], gasPrice: Int, gasLimit: Int, wif: String) -> String? {
    do {
        let data =  try JSONSerialization.data(withJSONObject: args, options: .prettyPrinted)
        let params = String(data: data, encoding: String.Encoding.utf8)
        let err = NSErrorPointer(nilLiteral: ())
        let res = NeoutilsBuildOntologyInvocationTransaction(contractHash, method, params, gasPrice, gasLimit, wif, err)
        return res
    } catch {
        return nil
    }
}

private func ontologyInvokeHelper(endpoint: String, contractHash: String, method: String, args: [[String:Any]], gasPrice: Int, gasLimit: Int, wif: String) -> String? {
    do {
        let data =  try JSONSerialization.data(withJSONObject: args, options: .prettyPrinted)
        let args = String(data: data, encoding: String.Encoding.utf8)
        let err = NSErrorPointer(nilLiteral: ())
        let res = NeoutilsOntologyInvoke(endpoint, contractHash, method, args, gasPrice, gasLimit, wif, err)
        return res
    } catch {
        return nil
    }
}

public func buildOntologyInvocationTransaction(contractHash: String, method: String, args: [OntologyParameter], gasPrice: Int, gasLimit: Int, wif: String) -> String? {
    let params = convertParamArray(params: args)
    return buildOntologyInvocationTransactionHelper(contractHash: contractHash, method: method, args: params, gasPrice: gasPrice, gasLimit: gasLimit, wif: wif)
}

public func ontologyInvoke(endpoint: String = "http://polaris2.ont.io:20336", contractHash: String, method: String, args: [OntologyParameter], gasPrice: Int, gasLimit: Int, wif: String) -> String? {
    let params = convertParamArray(params: args)
    return ontologyInvokeHelper(endpoint: endpoint, contractHash: contractHash, method: method, args: params, gasPrice: gasPrice, gasLimit: gasLimit, wif: wif)
}
