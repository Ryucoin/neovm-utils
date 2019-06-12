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

public func getBestNEONode(net: network) -> Promise<String?> {
    return Promise<String?> { fulfill, _ in
        var o3api = "https://platform.o3.network/api/v1/nodes"
        if net == .testNet {
            o3api += "?network=test"
        }

        networkUtils.get(o3api).then({ data in
            do {
                guard let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
                    print("Invalid data from o3api")
                    fulfill(nil)
                    return
                }

                guard let result = json["result"] as? [String: [String: Any]] else {
                    print("Failed to get result from o3api")
                    fulfill(nil)
                    return
                }

                guard let neo = result["neo"] else {
                    print("Failed to get neo nodes from o3api")
                    fulfill(nil)
                    return
                }

                guard let best = neo["best"] as? String else {
                    print("Failed to get best node from o3api")
                    fulfill(nil)
                    return
                }

                fulfill(best)
            } catch {
                print("Error in do-try block for getBestNEONode")
                fulfill(nil)
            }
        }).catch({ (error) in
            if let error = error as? NetworkError {
                print("Network error with o3api: \(error.localizedDescription)")
            }
            fulfill(nil)
        })
    }
}

public func formatNEOEndpoint(endpt: String) -> String? {
    var node: String? = endpt
    DispatchQueue.global().sync {
        if endpt == neoTestNet {
            node = try? await(getBestNEONode(net: .testNet))
        } else if endpt == neoMainNet {
            node = try? await(getBestNEONode(net: .mainNet))
        }
    }
    return node
}
