//
//  OEP8.swift
//  neovmUtils
//
//  Created by Wyatt Mufson on 3/15/19.
//  Copyright © 2019 Ryu Blockchain Technologies. All rights reserved.
//

import Foundation

public class OEP8Interface: NSObject {

    private var contractHash: String = ""
    private var endpoint: String = ""

    public convenience init(contractHash: String, endpoint: String = ontologyTestNodes.bestNode.rawValue) {
        self.init()
        self.contractHash = contractHash
        self.endpoint = endpoint
    }

    public func getName(tokenId: Int) -> String {
        let tokenId = OntologyParameter(type: .Integer, value: tokenId)
        let hex = ontologyInvokeRead(endpoint: endpoint, contractHash: contractHash, method: "name", args: [tokenId])
        return hex.hexToAscii()
    }

    public func getSymbol(tokenId: Int) -> String {
        let tokenId = OntologyParameter(type: .Integer, value: tokenId)
        let hex =  ontologyInvokeRead(endpoint: endpoint, contractHash: contractHash, method: "symbol", args: [tokenId])
        return hex.hexToAscii()
    }

    public func getTotalSupply(tokenId: Int) -> Int {
        let tokenId = OntologyParameter(type: .Integer, value: tokenId)
        let hex = ontologyInvokeRead(endpoint: endpoint, contractHash: contractHash, method: "totalSupply", args: [tokenId])
        return hex.hexToDecimal()
    }

    public func getBalance(address: String, tokenId: Int) -> Int {
        let address = OntologyParameter(type: .Address, value: address)
        let tokenId = OntologyParameter(type: .Integer, value: tokenId)
        let hex = ontologyInvokeRead(endpoint: endpoint, contractHash: contractHash, method: "balanceOf", args: [address, tokenId])
        return hex.hexToDecimal()
    }
}
