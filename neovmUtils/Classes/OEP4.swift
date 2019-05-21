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
        return hex.hexToAscii()
    }

    public func getSymbol() -> String {
        let hex = ontologyInvokeRead(endpoint: endpoint, contractHash: contractHash, method: "symbol", args: [])
        return hex.hexToAscii()
    }

    public func getDecimals() -> Int {
        return ontologyInvokeRead(endpoint: endpoint, contractHash: contractHash, method: "decimals", args: []).hexToDecimal()
    }

    public func getTotalSupply() -> Int {
        let hex = ontologyInvokeRead(endpoint: endpoint, contractHash: contractHash, method: "totalSupply", args: [])
        return hex.hexToDecimal()
    }

    public func getBalance(address: String) -> Int {
        let address = OntologyParameter(type: .Address, value: address)
        let hex = ontologyInvokeRead(endpoint: endpoint, contractHash: contractHash, method: "balanceOf", args: [address])
        return hex.hexToDecimal()
    }

    public func transfer(from: String, to: String, amount: Double, decimals: Int, gasPrice: Int = 500, gasLimit: Int = 20000, wallet: Wallet) -> String {
        return transfer(from: from, to: to, amount: amount, decimals: decimals, gasPrice: gasPrice, gasLimit: gasLimit, wif: wallet.wif)
    }

    public func transfer(from: String, to: String, amount: Double, decimals: Int, gasPrice: Int = 500, gasLimit: Int = 20000, wif: String) -> String {
        let fromAcct = OntologyParameter(type: .Address, value: from)
        let toAcct = OntologyParameter(type: .String, value: to)
        var type = OntologyParameterType.Integer
        if decimals == 8 {
            type = .Fixed8
        } else if decimals == 9 {
            type = .Fixed9
        }
        let spend = OntologyParameter(type: type, value: amount)
        return ontologyInvoke(endpoint: endpoint, contractHash: contractHash, method: "transfer", args: [fromAcct, toAcct, spend], gasPrice: gasPrice, gasLimit: gasLimit, wif: wif)
    }

    public func transferMulti(args: [[Any]], decimals: Int, gasPrice: Int = 500, gasLimit: Int = 20000, wallet: Wallet) -> String {
        return transferMulti(args: args, decimals: decimals, gasPrice: gasPrice, gasLimit: gasLimit, wif: wallet.wif)
    }

    public func transferMulti(args: [[Any]], decimals: Int, gasPrice: Int = 500, gasLimit: Int = 20000, wif: String) -> String {
        var params: [OntologyParameter] = []
        for arg in args {
            guard arg.count == 3 else {
                continue
            }

            let fromAcct = OntologyParameter(type: .Address, value: arg[0])
            let toAcct = OntologyParameter(type: .String, value: arg[1])
            var type = OntologyParameterType.Integer
            if decimals == 8 {
                type = .Fixed8
            } else if decimals == 9 {
                type = .Fixed9
            }
            let spend = OntologyParameter(type: type, value: arg[2])
            let array = OntologyParameter(type: .Array, value: [fromAcct, toAcct, spend])
            params.append(array)
        }

        return ontologyInvoke(endpoint: endpoint, contractHash: contractHash, method: "transferMulti", args: params, gasPrice: gasPrice, gasLimit: gasLimit, wif: wif)
    }
}
