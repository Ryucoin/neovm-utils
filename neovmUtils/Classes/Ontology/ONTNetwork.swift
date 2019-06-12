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

public enum network {
    case mainNet
    case testNet
}
