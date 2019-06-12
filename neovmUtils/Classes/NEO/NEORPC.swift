//
//  NEORPC.swift
//  neovmUtils
//
//  Created by Wyatt Mufson on 6/11/19.
//  Copyright © 2019 Ryu Blockchain Technologies. All rights reserved.
//

import Foundation

public func getBestNEONode(net: network) -> String {
    var bestNode = ""
    var bestCount = -1
    switch net {
    case .testNet:
        let nodes: [neoTestNodes] = [.polaris1, .polaris2, .polaris3, .polaris4]
        for node in nodes {
            let count = ontologyGetBlockCount(endpoint: node.rawValue)
            bestNode = node.rawValue
            if count > bestCount {
                bestNode = node.rawValue
                bestCount = count
            }
        }
        return bestNode
    case .mainNet:
        let nodes: [neoMainNodes] = [.seed1, .seed2, .seed3, .seed4]
        for node in nodes {
            let count = ontologyGetBlockCount(endpoint: node.rawValue)
            bestNode = node.rawValue
            if count > bestCount {
                bestNode = node.rawValue
                bestCount = count
            }
        }
        return bestNode
    }
}

public func formatNEOEndpoint(endpt: String) -> String {
    if endpt == neoTestNodes.bestNode.rawValue {
        return getBestNEONode(net: .testNet)
    } else if endpt == neoMainNodes.bestNode.rawValue {
        return getBestNEONode(net: .mainNet)
    }
    return endpt
}

public func neoSendRawTransaction(endpoint: String = neoTestNet, raw: Data) -> String {
    let node = formatNEOEndpoint(endpt: endpoint)
    return ""
}

public func neoInvokeScript(endpoint: String = neoTestNet, raw: Data) -> String {
    let node = formatNEOEndpoint(endpt: endpoint)
    return ""
}
