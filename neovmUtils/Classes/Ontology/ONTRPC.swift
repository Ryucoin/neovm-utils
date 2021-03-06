//
//  ONTRPC.swift
//  neovmUtils
//
//  Created by Wyatt Mufson on 2/15/19.
//  Copyright © 2020 Ryu Blockchain Technologies. All rights reserved.
//

import Foundation
import Neoutils

public func ontologyGetBlockCount(endpoint: String = ontologyTestNet) -> Int {
    let e = formatONTEndpoint(endpt: endpoint)
    let error = NSErrorPointer(nilLiteral: ())
    var count: Int = -1
    NeoutilsOntologyGetBlockCount(e, &count, error)
    return count
}

public func ontologyGetBalances(endpoint: String = ontologyTestNet, address: String) -> (Int, Double) {
    let e = formatONTEndpoint(endpt: endpoint)
    let error = NSErrorPointer(nilLiteral: ())
    let balances = NeoutilsOntologyGetBalance(e, address, error)
    let ont = Int(balances?.ont ?? "0") ?? 0
    var ong = Double(balances?.ong ?? "0") ?? 0
    ong = ong / 1000000000.0
    return (ont, ong)
}

public func ontologyGetSmartCodeEvent(endpoint: String = ontologyTestNet, txHash: String) -> NeoutilsSmartCodeEvent? {
    let e = formatONTEndpoint(endpt: endpoint)
    let error = NSErrorPointer(nilLiteral: ())
    let res = NeoutilsOntologyGetSmartCodeEvent(e, txHash, error)
    return res
}

public func ontologySendRawTransaction(endpoint: String = ontologyTestNet, raw: String) -> String {
    let e = formatONTEndpoint(endpt: endpoint)
    let error = NSErrorPointer(nilLiteral: ())
    let txId = NeoutilsOntologySendRawTransaction(e, raw, error)
    return txId
}

public func ontologySendPreExecRawTransaction(endpoint: String = ontologyTestNet, raw: String) -> String {
    let e = formatONTEndpoint(endpt: endpoint)
    let error = NSErrorPointer(nilLiteral: ())
    let response = NeoutilsOntologySendPreExecRawTransaction(e, raw, error)
    return response
}

public func ontologyGetStorage(endpoint: String = ontologyTestNet, scriptHash: String, key: String) -> String {
    let e = formatONTEndpoint(endpt: endpoint)
    let error = NSErrorPointer(nilLiteral: ())
    let item = NeoutilsOntologyGetStorage(e, scriptHash, key, error)
    return item
}

public func ontologyGetRawTransaction(endpoint: String = ontologyTestNet, txID: String) -> String {
    let e = formatONTEndpoint(endpt: endpoint)
    let error = NSErrorPointer(nilLiteral: ())
    let raw = NeoutilsOntologyGetRawTransaction(e, txID, error)
    return raw
}

public func ontologyGetBlockWithHash(endpoint: String = ontologyTestNet, hash: String) -> String {
    let e = formatONTEndpoint(endpt: endpoint)
    let error = NSErrorPointer(nilLiteral: ())
    let result = NeoutilsOntologyGetBlockWithHash(e, hash, error)
    return result
}

public func ontologyGetBlockWithHeight(endpoint: String = ontologyTestNet, height: Int) -> String {
    let e = formatONTEndpoint(endpt: endpoint)
    let error = NSErrorPointer(nilLiteral: ())
    let result = NeoutilsOntologyGetBlockWithHeight(e, height, error)
    return result
}

public enum OntAsset: String {
    case ONT
    case ONG
}

public func ontologyTransfer(endpoint: String = ontologyTestNet, gasPrice: Int = 500, gasLimit: Int = 20000, wif: String, asset: OntAsset, toAddress: String, amount: Double) -> String {
    let error = NSErrorPointer(nilLiteral: ())
    let e = formatONTEndpoint(endpt: endpoint)
    let txID = NeoutilsOntologyTransfer(e, gasPrice, gasLimit, wif, asset.rawValue, toAddress, amount, error)
    return txID
}

public func claimONG(endpoint: String = ontologyTestNet, gasPrice: Int = 500, gasLimit: Int = 20000, wif: String) -> String {
    let error = NSErrorPointer(nilLiteral: ())
    let e = formatONTEndpoint(endpt: endpoint)
    let txID = NeoutilsClaimONG(e, gasPrice, gasLimit, wif, error)
    return txID
}

public func getUnboundONG(endpoint: String = ontologyTestNet, address: String) -> String {
    let error = NSErrorPointer(nilLiteral: ())
    let e = formatONTEndpoint(endpt: endpoint)
    let res = NeoutilsOntologyGetUnboundONG(e, address, error)
    return res
}
