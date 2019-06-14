//
//  NEONetwork.swift
//  neovmUtils
//
//  Created by Wyatt Mufson on 6/11/19.
//  Copyright © 2019 Ryu Blockchain Technologies. All rights reserved.
//

import Foundation
import Promises
import NetworkUtils

public var neoTestNet = "testNetBestNode"
public var neoMainNet = "mainNetBestNode"

public struct o3Response: Codable {
    var result: o3Result
    var code: Int
}

public struct o3Result: Codable {
    var data: o3Data
}

public struct o3Data: Codable {
    var neo: o3Chain
    var ontology: o3Chain
}

public struct o3Chain: Codable {
    var blockCount: Int
    var best: String
    var nodes: [String]
}

public let o3api = "https://platform.o3.network/api/v1/nodes"

public func getBestNEONode(api: String = o3api, net: network) -> Promise<String?> {
    return Promise<String?> { fulfill, _ in
        var apiUrl = api
        if net == .testNet {
            apiUrl += "?network=test"
        }

        networkUtils.get(apiUrl).then { data in
            let json = try? JSONDecoder().decode(o3Response.self, from: data)
            fulfill(json?.result.data.neo.best)
        }.catch { (error) in
            print("Network error with getBestNEONode: \((error as! NetworkError).localizedDescription)")
            fulfill(nil)
        }
    }
}

public func formatNEOEndpoint(endpt: String) -> Promise<String?> {
    return Promise<String?> { fulfill, _ in
        if endpt == neoTestNet {
            getBestNEONode(net: .testNet).then { node in
                fulfill(node)
            }
        } else if endpt == neoMainNet {
            getBestNEONode(net: .mainNet).then { node in
                fulfill(node)
            }
        } else {
            fulfill(endpt)
        }
    }
}
