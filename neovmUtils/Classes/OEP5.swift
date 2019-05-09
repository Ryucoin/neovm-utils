//
//  OEP5.swift
//  neovmUtils
//
//  Created by Wyatt Mufson on 5/8/19.
//  Copyright © 2019 Ryu Blockchain Technologies. All rights reserved.
//

import Foundation

public class OEP5Interface: NSObject {

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

    public func getTotalSupply() -> String {
        return ontologyInvokeRead(endpoint: endpoint, contractHash: contractHash, method: "totalSupply", args: [])
    }

    public func getBalance(address: String) -> String {
        let address = OntologyParameter(type: .Address, value: address)
        return ontologyInvokeRead(endpoint: endpoint, contractHash: contractHash, method: "balanceOf", args: [address])
    }

    public func getOwner(tokenId: String) -> String {
        let token = OntologyParameter(type: .String, value: tokenId)
        return ontologyInvokeRead(endpoint: endpoint, contractHash: contractHash, method: "ownerOf", args: [token])
    }

    public func getTokenName(tokenId: String) -> String {
        let token = OntologyParameter(type: .String, value: tokenId)
        return ontologyInvokeRead(endpoint: endpoint, contractHash: contractHash, method: "nameOf", args: [token])
    }

    public func transfer(address: String, tokenId: String, gasPrice: Int = 500, gasLimit: Int = 20000, wallet: Wallet) -> String {
        return transfer(address: address, tokenId: tokenId, gasPrice: gasPrice, gasLimit: gasLimit, wif: wallet.wif)
    }

    public func transfer(address: String, tokenId: String, gasPrice: Int = 500, gasLimit: Int = 20000, wif: String) -> String {
        let receiver = OntologyParameter(type: .Address, value: address)
        let token = OntologyParameter(type: .String, value: tokenId)
        return ontologyInvoke(endpoint: endpoint, contractHash: contractHash, method: "transfer", args: [receiver, token], gasPrice: gasPrice, gasLimit: gasLimit, wif: wif)
    }

    public func transferMulti(args: [State], gasPrice: Int = 500, gasLimit: Int = 20000, wallet: Wallet) -> String {
        return transferMulti(args: args, gasPrice: gasPrice, gasLimit: gasLimit, wif: wallet.wif)
    }

    public func transferMulti(args: [State], gasPrice: Int = 500, gasLimit: Int = 20000, wif: String) -> String {
        var params: [[String]] = []
        for arg in args {
            let array = arg.getParam()
            params.append(array)
        }

        return transferMulti(args: params, gasPrice: gasPrice, gasLimit: gasLimit, wif: wif)
    }

    public func transferMulti(args: [[String]], gasPrice: Int = 500, gasLimit: Int = 20000, wallet: Wallet) -> String {
        return transferMulti(args: args, gasPrice: gasPrice, gasLimit: gasLimit, wif: wallet.wif)
    }

    public func transferMulti(args: [[String]], gasPrice: Int = 500, gasLimit: Int = 20000, wif: String) -> String {
        var params: [OntologyParameter] = []
        for arg in args {
            guard arg.count == 2 else {
                continue
            }

            let receiver = OntologyParameter(type: .Address, value: arg[0])
            let token = OntologyParameter(type: .String, value: arg[1])
            let array = OntologyParameter(type: .Array, value: [receiver, token])
            params.append(array)
        }

        return ontologyInvoke(endpoint: endpoint, contractHash: contractHash, method: "transferMulti", args: params, gasPrice: gasPrice, gasLimit: gasLimit, wif: wif)
    }

    public func mint(tokenName: String, address: String, gasPrice: Int = 500, gasLimit: Int = 20000, wallet: Wallet) -> String {
        return mint(tokenName: tokenName, address: address, gasPrice: gasPrice, gasLimit: gasLimit, wif: wallet.wif)
    }

    public func mint(tokenName: String, address: String, gasPrice: Int = 500, gasLimit: Int = 20000, wif: String) -> String {
        let name = OntologyParameter(type: .String, value: tokenName)
        let receiver = OntologyParameter(type: .Address, value: address)
        return ontologyInvoke(endpoint: endpoint, contractHash: contractHash, method: "mint", args: [name, receiver], gasPrice: gasPrice, gasLimit: gasLimit, wif: wif)
    }
}
