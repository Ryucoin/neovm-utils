//
//  NEOInvokeScript.swift
//  neovmUtils
//
//  Created by Wyatt Mufson on 8/24/19.
//  Copyright © 2019 Ryu Blockchain Technologies. All rights reserved.
//

import Foundation
import NetworkUtils
import SwiftPromises

public struct InvokeScriptResponse: Codable {
    public var jsonrpc: String
    public var id: Int
    public var result: InvokeScriptResult
}

public struct InvokeScriptResult: Codable {
    public var gas_consumed: String
    public var script: String
    public var stack: [StackItem]
    public var state: String
}

public struct StackItem: Codable {
    public var type: String
    public var value: Any

    private enum CodingKeys: String, CodingKey {
        case typeKey = "type"
        case valueKey = "value"
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        if type == "Array" {
            try container.encode(value as? [StackItem], forKey: .valueKey)
        } else if type == "ByteArray" || type == "String" {
            try container.encode(value as? String, forKey: .valueKey)
        } else if type == "Integer" || type == "Int" {
            try container.encode(value as? Int, forKey: .valueKey)
        } else {
            try container.encode(value as? Bool, forKey: .valueKey)
        }
        try container.encode(type, forKey: .typeKey)
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.type = try container.decode(String.self, forKey: .typeKey)
        if type == "Array" {
            self.value = try container.decode([StackItem].self, forKey: .valueKey)
        } else if type == "ByteArray" {
            self.value = try container.decode(String.self, forKey: .valueKey)
        } else if type == "String" {
            self.value = try container.decode(String.self, forKey: .valueKey)
        } else if type == "Integer" {
            self.value = try container.decode(Int.self, forKey: .valueKey)
        } else {
            self.value = try container.decode(Bool.self, forKey: .valueKey)
        }
    }
}

private let emptyResult = InvokeScriptResult(gas_consumed: "0", script: "", stack: [], state: "")
private let emptyResponse = InvokeScriptResponse(jsonrpc: "0", id: 0, result: emptyResult)

private func rpc(node: String, params: Any) -> Promise<InvokeScriptResponse?> {
    let params: [String: Any] = [
        "jsonrpc": "2.0",
        "id": 2,
        "method": "invokescript",
        "params": params
    ]

    return Promise<InvokeScriptResponse?>(dispatchQueue: .global(qos: .userInitiated)) { fulfill, _ in
        networkUtils.post(node, params, 3, "application/json-rpc").then { data in
            let json = try? JSONDecoder().decode(InvokeScriptResponse.self, from: data)
            fulfill(json)
        }.catch { (error) in
            print("Network error with rpc: \((error as! NetworkError).localizedDescription)")
            fulfill(nil)
        }
    }
}

private func invokeScript(node: String, data: Data) -> Promise<InvokeScriptResponse?> {
    return rpc(node: node, params: [data.fullHexString])
}

private func invokeScript(node: String, avm: String) -> Promise<InvokeScriptResponse?> {
    return rpc(node: node, params: [avm])
}

public func neoInvokeScript(endpoint: String = neoTestNet, raw: Data) -> InvokeScriptResponse {
    var result: InvokeScriptResponse = emptyResponse
    if let node = try? await(formatNEOEndpoint(endpt: endpoint)) {
        if let dict = try? await(invokeScript(node: node, data: raw)) {
            result = dict
        }
    }
    return result
}

public func neoInvokeScript(endpoint: String = neoTestNet, avm: String) -> InvokeScriptResponse {
    var result: InvokeScriptResponse = emptyResponse
    if let node = try? await(formatNEOEndpoint(endpt: endpoint)) {
        if let dict = try? await(invokeScript(node: node, avm: avm)) {
            result = dict
        }
    }
    return result
}
