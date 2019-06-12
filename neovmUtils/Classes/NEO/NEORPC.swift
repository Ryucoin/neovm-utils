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
