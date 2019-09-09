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

public struct StackItem: Codable, Equatable {
    public var type: String
    public var value: Any

    public init(type: String, value: Any) {
        self.type = type
        self.value = value
    }

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

    public static func == (lhs: StackItem, rhs: StackItem) -> Bool {
        let typeMatch: Bool = lhs.type == rhs.type
        var valueMatch: Bool = false
        if let lstr = lhs.value as? String, let rstr = rhs.value as? String {
            valueMatch = lstr == rstr
        } else if let lstr = lhs.value as? Int, let rstr = rhs.value as? Int {
            valueMatch = lstr == rstr
        } else if let lstr = lhs.value as? Bool, let rstr = rhs.value as? Bool {
            valueMatch = lstr == rstr
        } else if let lstr = lhs.value as? [StackItem], let rstr = rhs.value as? [StackItem] {
            valueMatch = lstr == rstr
        }
        return typeMatch && valueMatch
    }
}

private let emptyResult = InvokeScriptResult(gas_consumed: "0", script: "", stack: [], state: "")
private let emptyResponse = InvokeScriptResponse(jsonrpc: "0", id: 0, result: emptyResult)

private func rpc(dispatchQueue: DispatchQueue?, node: String, params: Any) -> Promise<InvokeScriptResponse?> {
    let params: [String: Any] = [
        "jsonrpc": "2.0",
        "id": 2,
        "method": "invokescript",
        "params": params
    ]

    return Promise<InvokeScriptResponse?>(dispatchQueue: dispatchQueue) { fulfill, _ in
        networkUtils.post(node, params, 3, headers: ["Content-Type": "application/json-rpc"]).then { data in
            let json = try? JSONDecoder().decode(InvokeScriptResponse.self, from: data)
            fulfill(json)
        }.catch { (error) in
            print("Network error with rpc: \((error as! NetworkError).localizedDescription)")
            fulfill(nil)
        }
    }
}

private func invokeScript(dispatchQueue: DispatchQueue?, node: String, data: Data) -> Promise<InvokeScriptResponse?> {
    return rpc(dispatchQueue: dispatchQueue, node: node, params: [data.fullHexString])
}

private func invokeScript(dispatchQueue: DispatchQueue?, node: String, avm: String) -> Promise<InvokeScriptResponse?> {
    return rpc(dispatchQueue: dispatchQueue, node: node, params: [avm])
}

public func neoInvokeScript(dispatchQueueA: DispatchQueue? = nil, dispatchQueueB: DispatchQueue? = nil, endpoint: String = neoTestNet, raw: Data) -> InvokeScriptResponse {
    var result: InvokeScriptResponse = emptyResponse
    if let node = try? await(formatNEOEndpoint(dispatchQueue: dispatchQueueA, endpt: endpoint)) {
        if let dict = try? await(invokeScript(dispatchQueue: dispatchQueueB, node: node, data: raw)) {
            result = dict
        }
    }
    return result
}

public func neoInvokeScript(dispatchQueueA: DispatchQueue? = nil, dispatchQueueB: DispatchQueue? = nil, endpoint: String = neoTestNet, avm: String) -> InvokeScriptResponse {
    var result: InvokeScriptResponse = emptyResponse
    if let node = try? await(formatNEOEndpoint(dispatchQueue: dispatchQueueA, endpt: endpoint)) {
        if let dict = try? await(invokeScript(dispatchQueue: dispatchQueueB, node: node, avm: avm)) {
            result = dict
        }
    }
    return result
}

public func neoInvokeScriptAsync(dispatchQueueA: DispatchQueue? = nil, dispatchQueueB: DispatchQueue? = nil, endpoint: String = neoTestNet, avm: String, timeout: Int = 7000) -> Promise<InvokeScriptResponse> {
    let timeoutException = NSError(domain: "Timeout exception", code: -1, userInfo: [:])
    return Promise<InvokeScriptResponse> { fulfill, reject in
        formatNEOEndpoint(dispatchQueue: dispatchQueueA, endpt: endpoint).then { (node) in
            if let node = node {
                invokeScript(dispatchQueue: dispatchQueueB, node: node, avm: avm).then { (response) in
                    fulfill(response ?? emptyResponse)
                }

                DispatchQueue.global().asyncAfter(deadline: .now() + .milliseconds(timeout)) {
                    reject(timeoutException)
                }
            } else {
                reject(timeoutException)
            }
        }
    }
}
