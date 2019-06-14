//
//  NEORPC.swift
//  neovmUtils
//
//  Created by Wyatt Mufson on 6/11/19.
//  Copyright © 2019 Ryu Blockchain Technologies. All rights reserved.
//

import Foundation
import Promises
import NetworkUtils

private enum RPCMethod: String {
    case sendRawTransaction = "sendrawtransaction"
    case invokeFunction = "invokefunction"
    case invokeScript = "invokescript"
}

private func rpc(node: String, method: RPCMethod, params: Any) -> Promise<[String: Any]?> {
    let params: [String: Any] = [
        "jsonrpc": "2.0",
        "id": 2,
        "method": method.rawValue,
        "params": params
    ]

    return Promise<[String: Any]?> { fulfill, _ in
        networkUtils.post(node, params, 3, "application/json-rpc").then ({ data in
            guard let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
                fulfill(nil)
                return
            }
            fulfill(json)
        }).catch({ error in
            print("Network error with sendJSONRPC: \((error as! NetworkError).localizedDescription)")
            fulfill(nil)
        })
    }
}

private func sendRawTransaction(node: String, data: Data) -> Promise<[String: Any]?> {
    return rpc(node: node, method: .sendRawTransaction, params: [data.fullHexString])
}

private func invokeScript(node: String, data: Data) -> Promise<[String: Any]?> {
    return rpc(node: node, method: .invokeScript, params: [data.fullHexString])
}

private func invokeFunction(node: String, args: [Any]) -> Promise<[String: Any]?> {
    return rpc(node: node, method: .invokeFunction, params: args)
}

struct Stack: Codable {
    let type: String
    let value: String
}

private func getReadResult(dict: [String: Any]) -> String {
    guard let result = dict["result"] as? [String: Any],
        let stackObj = result["stack"] as? [Any],
        let data = try? JSONSerialization.data(withJSONObject: stackObj, options: .prettyPrinted),
        let stackArray = try? JSONDecoder().decode([Stack].self, from: data),
        stackArray.count >= 1 else {
            return ""
    }

    let first = stackArray[0].value
    return first
}

private func getWriteResult(dict: [String: Any]) -> Bool {
    let result = dict["result"] as? Int ?? 0
    return result == 1
}

public func neoSendRawTransaction(endpoint: String = neoTestNet, raw: Data) -> Bool {
    var result = false
    DispatchQueue.promises = .global()
    if let node = try? await(formatNEOEndpoint(endpt: endpoint)) {
        if let dict = try? await(sendRawTransaction(node: node, data: raw)) {
            result = getWriteResult(dict: dict)
        }
    }
    return result
}

public func neoInvokeScript(endpoint: String = neoTestNet, raw: Data) -> [String: Any] {
    var result: [String: Any] = [:]
    DispatchQueue.promises = .global()
    if let node = try? await(formatNEOEndpoint(endpt: endpoint)) {
        if let dict = try? await(invokeScript(node: node, data: raw)) {
            result = dict
        }
    }
    return result
}

public func neoInvokeFunction(endpoint: String = neoTestNet, scriptHash: String, operation: String, args: [NVMParameter]) -> String {
    var result = ""
    DispatchQueue.promises = .global()
    if let node = try? await(formatNEOEndpoint(endpt: endpoint)) {
        var params: [Any] = [scriptHash, operation]
        var arguments: [Any] = []
        for arg in args {
            let param = arg.getIFArg()
            arguments.append(param)
        }
        params.append(arguments)
        if let dict = try? await(invokeFunction(node: node, args: params)) {
            result = getReadResult(dict: dict)
        }
    }
    return result
}
