//
//  NEONetwork.swift
//  neovmUtils
//
//  Created by Wyatt Mufson on 6/11/19.
//  Copyright © 2019 Ryu Blockchain Technologies. All rights reserved.
//

import Foundation

public enum neoTestNodes: String {
    case polaris1 = "http://polaris1.ont.io:20336"
    case polaris2 = "http://polaris2.ont.io:20336"
    case polaris3 = "http://polaris3.ont.io:20336"
    case polaris4 = "http://polaris4.ont.io:20336"
    case bestNode = "testNetBestNode"
}

public enum neoMainNodes: String {
    case seed1 = "http://dappnode1.ont.io:20336"
    case seed2 = "http://dappnode2.ont.io:20336"
    case seed3 = "http://dappnode3.ont.io:20336"
    case seed4 = "http://dappnode4.ont.io:20336"
    case bestNode = "mainNetBestNode"
}

public var neoTestNet = neoTestNodes.bestNode.rawValue
public var neoMainNet = neoMainNodes.bestNode.rawValue
