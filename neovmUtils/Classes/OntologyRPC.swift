//
//  OntologyRPC.swift
//  neovmUtils_Tests
//
//  Created by Wyatt Mufson on 2/15/19.
//  Copyright © 2019 Ryu Blockchain Technologies. All rights reserved.
//

import Foundation
import Neoutils

public enum ontologyTestNodes: String {
    case polaris1 = "http://polaris1.ont.io:20336"
    case polaris2 = "http://polaris2.ont.io:20336"
    case polaris3 = "http://polaris3.ont.io:20336"
    case polaris4 = "http://polaris4.ont.io:20336"
    case bestNode = "testNetBestNode"
}

public enum ontologyMainNodes: String {
    case seed1 = "seed1.ont.io:20338"
    case seed2 = "seed2.ont.io:20338"
    case seed3 = "seed3.ont.io:20338"
    case seed4 = "seed4.ont.io:20338"
    case seed5 = "seed5.ont.io:20338"
    case bestNode = "mainNetBestNode"
}

public enum network {
    case mainNet
    case testNet
}

public func getBestNode(net:network) -> String {
    var bestNode = ""
    var bestCount = 0
    if net == .testNet {
        let count1 = ontologyGetBlockCount(endpoint: ontologyTestNodes.polaris1.rawValue)
        bestNode = ontologyTestNodes.polaris1.rawValue
        bestCount = count1
        let count2 = ontologyGetBlockCount(endpoint: ontologyTestNodes.polaris2.rawValue)
        if count2 > bestCount {
            bestNode = ontologyTestNodes.polaris2.rawValue
            bestCount = count2
        }
        let count3 = ontologyGetBlockCount(endpoint: ontologyTestNodes.polaris3.rawValue)
        if count3 > bestCount {
            bestNode = ontologyTestNodes.polaris3.rawValue
            bestCount = count3
        }
        let count4 = ontologyGetBlockCount(endpoint: ontologyTestNodes.polaris4.rawValue)
        if count4 > bestCount {
            bestNode = ontologyTestNodes.polaris4.rawValue
            bestCount = count4
        }
        return bestNode
    } else if net == .mainNet {
        let count1 = ontologyGetBlockCount(endpoint: ontologyMainNodes.seed1.rawValue)
        bestNode = ontologyMainNodes.seed1.rawValue
        bestCount = count1
        let count2 = ontologyGetBlockCount(endpoint: ontologyMainNodes.seed2.rawValue)
        if count2 > bestCount {
            bestNode = ontologyMainNodes.seed2.rawValue
            bestCount = count2
        }
        let count3 = ontologyGetBlockCount(endpoint: ontologyMainNodes.seed3.rawValue)
        if count3 > bestCount {
            bestNode = ontologyMainNodes.seed3.rawValue
            bestCount = count3
        }
        let count4 = ontologyGetBlockCount(endpoint: ontologyMainNodes.seed4.rawValue)
        if count4 > bestCount {
            bestNode = ontologyMainNodes.seed4.rawValue
            bestCount = count4
        }
        let count5 = ontologyGetBlockCount(endpoint: ontologyMainNodes.seed5.rawValue)
        if count5 > bestCount {
            bestNode = ontologyMainNodes.seed5.rawValue
            bestCount = count5
        }
        return bestNode
    }
    return ""
}

public func getEndpoint(def:String) -> String {
    if def == ontologyTestNodes.bestNode.rawValue {
        return getBestNode(net: .testNet)
    } else if def == ontologyMainNodes.bestNode.rawValue {
        return getBestNode(net: .mainNet)
    }
    return def
}

public func ontologyGetBlockCount(endpoint: String = ontologyTestNodes.bestNode.rawValue) -> Int {
    let e = getEndpoint(def: endpoint)
    let error = NSErrorPointer(nilLiteral: ())
    var count : Int = 0
    NeoutilsOntologyGetBlockCount(e, &count, error)
    if error != nil {
        return -1
    }
    return count
}

public func ontologyGetBalances(endpoint: String = ontologyTestNodes.bestNode.rawValue, address: String) -> (Int, Double) {
    let e = getEndpoint(def: endpoint)
    let error = NSErrorPointer(nilLiteral: ())
    let balances = NeoutilsOntologyGetBalance(e, address, error)
    let ont = Int(balances?.ont() ?? "0") ?? 0
    var ong = Double(balances?.ong() ?? "0") ?? 0
    ong = ong / 1000000000.0
    return (ont, ong)
}

public func ontologySendRawTransaction(endpoint: String = ontologyTestNodes.bestNode.rawValue, raw: String) -> String {
    let e = getEndpoint(def: endpoint)
    let error = NSErrorPointer(nilLiteral: ())
    let txId = NeoutilsOntologySendRawTransaction(e, raw, error)
    return txId ?? ""
}

public func ontologyGetStorage(endpoint: String = ontologyTestNodes.bestNode.rawValue, scriptHash: String, key: String) -> String {
    let e = getEndpoint(def: endpoint)
    let error = NSErrorPointer(nilLiteral: ())
    let item = NeoutilsOntologyGetStorage(e, scriptHash, key, error)
    return item ?? ""
}

public func ontologyGetRawTransaction(endpoint: String = ontologyTestNodes.bestNode.rawValue, txID: String) -> String {
    let e = getEndpoint(def: endpoint)
    let error = NSErrorPointer(nilLiteral: ())
    let raw = NeoutilsOntologyGetRawTransaction(e, txID, error)
    return raw ?? ""
}

public func ontologyGetBlockWithHash(endpoint: String = ontologyTestNodes.bestNode.rawValue, hash: String) -> String {
    let e = getEndpoint(def: endpoint)
    let error = NSErrorPointer(nilLiteral: ())
    let result = NeoutilsOntologyGetBlockWithHash(e, hash, error)
    return result ?? ""
}

public func ontologyGetBlockWithHeight(endpoint: String = ontologyTestNodes.bestNode.rawValue, height: Int) -> String {
    let e = getEndpoint(def: endpoint)
    let error = NSErrorPointer(nilLiteral: ())
    let result = NeoutilsOntologyGetBlockWithHeight(e, height, error)
    return result ?? ""
}

public enum OntAsset: String {
    case ONT
    case ONG
}

public func sendOntologyTransfer(endpoint: String = ontologyTestNodes.bestNode.rawValue, gasPrice: Int = 500, gasLimit: Int = 20000, wif: String, asset: OntAsset, toAddress: String, amount: Double) -> String {
    let error = NSErrorPointer(nilLiteral: ())
    let txID = NeoutilsOntologyTransfer(endpoint, gasPrice, gasLimit, wif, asset.rawValue, toAddress, amount, error)
    return txID ?? ""
}

public func claimONG(endpoint: String = ontologyTestNodes.bestNode.rawValue, gasPrice: Int = 500, gasLimit: Int = 20000, wif: String) -> String {
    let error = NSErrorPointer(nilLiteral: ())
    let txID = NeoutilsClaimONG(endpoint, gasPrice, gasLimit, wif, error)
    return txID ?? ""
}
