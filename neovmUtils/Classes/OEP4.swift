//
//  OEP4.swift
//  neovmUtils
//
//  Created by Wyatt Mufson on 3/15/19.
//  Copyright © 2019 Ryu Blockchain Technologies. All rights reserved.
//

import Foundation

public class OEP4Interface: NSObject {

    private var contractHash: String = ""
    private var endpoint: String = ""

    public convenience init(contractHash: String, endpoint: String = ontologyTestNodes.bestNode.rawValue) {
        self.init()
        self.contractHash = contractHash
        self.endpoint = endpoint
    }

    public func getName() -> String {
        let hex = ontologyInvokeRead(endpoint: endpoint, contractHash: contractHash, method: "name", args: [])
        return hexToAscii(text: hex)
    }

    public func getSymbol() -> String {
        let hex = ontologyInvokeRead(endpoint: endpoint, contractHash: contractHash, method: "symbol", args: [])
        return hexToAscii(text: hex)
    }

    public func getDecimals() -> String {
        return ontologyInvokeRead(endpoint: endpoint, contractHash: contractHash, method: "decimals", args: [])
    }

    public func getTotalSupply() -> String {
        return ontologyInvokeRead(endpoint: endpoint, contractHash: contractHash, method: "totalSupply", args: [])
    }

    public func getBalance(address: String) -> String {
        let address = OntologyParameter(type: .Address, value: address)
        return ontologyInvokeRead(endpoint: endpoint, contractHash: contractHash, method: "balanceOf", args: [address])
    }
}
