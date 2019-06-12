//
//  ONTNetwork.swift
//  neovmUtils
//
//  Created by Wyatt Mufson on 6/11/19.
//  Copyright © 2019 Ryu Blockchain Technologies. All rights reserved.
//

import Foundation

public enum ontologyTestNodes: String {
    case polaris1 = "http://polaris1.ont.io:20336"
    case polaris2 = "http://polaris2.ont.io:20336"
    case polaris3 = "http://polaris3.ont.io:20336"
    case polaris4 = "http://polaris4.ont.io:20336"
    case bestNode = "testNetBestNode"
}

public enum ontologyMainNodes: String {
    case seed1 = "http://dappnode1.ont.io:20336"
    case seed2 = "http://dappnode2.ont.io:20336"
    case seed3 = "http://dappnode3.ont.io:20336"
    case seed4 = "http://dappnode4.ont.io:20336"
    case bestNode = "mainNetBestNode"
}

public var ontologyTestNet = ontologyTestNodes.bestNode.rawValue
public var ontologyMainNet = ontologyMainNodes.bestNode.rawValue
public let solochainNode = "http://127.0.0.1:20336"

public enum network: String {
    case mainNet
    case testNet
}

public func getBestOntologyNode(net: network) -> String {
    var bestNode = ""
    var bestCount = -1
    switch net {
    case .testNet:
        let nodes: [ontologyTestNodes] = [.polaris1, .polaris2, .polaris3, .polaris4]
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
        let nodes: [ontologyMainNodes] = [.seed1, .seed2, .seed3, .seed4]
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

public func formatONTEndpoint(endpt: String) -> String {
    if endpt == ontologyTestNodes.bestNode.rawValue {
        return getBestOntologyNode(net: .testNet)
    } else if endpt == ontologyMainNodes.bestNode.rawValue {
        return getBestOntologyNode(net: .mainNet)
    }
    return endpt
}
