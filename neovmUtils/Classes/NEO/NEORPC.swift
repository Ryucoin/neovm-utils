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
    case invokeScript = "invokescript"
}

private func sendJSONRPC(node: String, rpcMethod: RPCMethod, data: Data) -> Promise<[String: Any]?> {
    let params: [String: Any] = [
        "jsonrpc": "2.0",
        "id": 2,
        "method": rpcMethod.rawValue,
        "params": [data.fullHexString]
    ]

    return Promise<[String: Any]?> { fulfill, _ in
        networkUtils.post(node, params, 3, "application/json-rpc").then ({ data in
            guard let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
                print("Invalid data from sendJSONRPC")
                fulfill(nil)
                return
            }

            fulfill(json)
        }).catch({ error in
            if let error = error as? NetworkError {
                print("Network error with sendJSONRPC: \(error.localizedDescription)")
            }
            fulfill(nil)
        })
    }
}

private func getReadResult(dict: [String: Any]) -> String {
    guard let result = dict["result"] as? [String: Any] else {
        return ""
    }

    guard let state = result["state"] as? String else {
        return ""
    }

    return state
}

private func getWriteResult(dict: [String: Any]) -> Bool {
    guard let result = dict["result"] as? Int else {
        return false
    }

    return result == 1
}

public func neoSendRawTransaction(endpoint: String = neoTestNet, raw: Data) -> Bool {
    var result = false
    DispatchQueue.promises = .global()
    if let node = try? await(formatNEOEndpoint(endpt: endpoint)) {
        if let dict = try? await(sendJSONRPC(node: node, rpcMethod: .sendRawTransaction, data: raw)) {
            result = getWriteResult(dict: dict)
        }
    }
    return result
}

public func neoInvokeScript(endpoint: String = neoTestNet, raw: Data) -> String {
    var result = ""
    DispatchQueue.promises = .global()
    if let node = try? await(formatNEOEndpoint(endpt: endpoint)) {
        if let dict = try? await(sendJSONRPC(node: node, rpcMethod: .invokeScript, data: raw)) {
            result = getReadResult(dict: dict)
        }
    }
    return result
}
