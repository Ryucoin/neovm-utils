//
//  OEP5.swift
//  neovmUtils
//
//  Created by Wyatt Mufson on 5/8/19.
//  Copyright © 2019 Ryu Blockchain Technologies. All rights reserved.
//

import Foundation

public class OEP5Interface: OEP10Interface {

    public func getName() -> String {
        let hex = ontologyInvokeRead(endpoint: endpoint, contractHash: contractHash, method: "name", args: [])
        return hex.hexToAscii()
    }

    public func getSymbol() -> String {
        let hex = ontologyInvokeRead(endpoint: endpoint, contractHash: contractHash, method: "symbol", args: [])
        return hex.hexToAscii()
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

    public func getOwner(tokenId: Any) -> String {
        let token = strOrIntToParam(arg: tokenId)
        let hex = ontologyInvokeRead(endpoint: endpoint, contractHash: contractHash, method: "ownerOf", args: [token])
        return hex
    }

    public func transfer(address: String, tokenId: Any, gasPrice: Int = 500, gasLimit: Int = 20000, wallet: Wallet) -> String {
        return transfer(address: address, tokenId: tokenId, gasPrice: gasPrice, gasLimit: gasLimit, wif: wallet.wif)
    }

    public func transfer(address: String, tokenId: Any, gasPrice: Int = 500, gasLimit: Int = 20000, wif: String) -> String {
        let receiver = OntologyParameter(type: .Address, value: address)
        let token = strOrIntToParam(arg: tokenId)
        return ontologyInvoke(endpoint: endpoint, contractHash: contractHash, method: "transfer", args: [receiver, token], gasPrice: gasPrice, gasLimit: gasLimit, wif: wif)
    }

    public func transferMulti(args: [OEP5State], gasPrice: Int = 500, gasLimit: Int = 20000, wallet: Wallet) -> String {
        return transferMulti(args: args, gasPrice: gasPrice, gasLimit: gasLimit, wif: wallet.wif)
    }

    public func transferMulti(args: [OEP5State], gasPrice: Int = 500, gasLimit: Int = 20000, wif: String) -> String {
        var params: [[Any]] = []
        for arg in args {
            let array = arg.getParam()
            params.append(array)
        }

        return transferMulti(args: params, gasPrice: gasPrice, gasLimit: gasLimit, wif: wif)
    }

    public func transferMulti(args: [[Any]], gasPrice: Int = 500, gasLimit: Int = 20000, wallet: Wallet) -> String {
        return transferMulti(args: args, gasPrice: gasPrice, gasLimit: gasLimit, wif: wallet.wif)
    }

    public func transferMulti(args: [[Any]], gasPrice: Int = 500, gasLimit: Int = 20000, wif: String) -> String {
        var params: [OntologyParameter] = []
        for arg in args {
            guard arg.count == 2 else {
                continue
            }

            let receiver = OntologyParameter(type: .Address, value: arg[0] as? String ?? "")
            let token = strOrIntToParam(arg: arg[1])
            let array = OntologyParameter(type: .Array, value: [receiver, token])
            params.append(array)
        }

        return ontologyInvoke(endpoint: endpoint, contractHash: contractHash, method: "transferMulti", args: params, gasPrice: gasPrice, gasLimit: gasLimit, wif: wif)
    }

    public func approve(address: String, tokenId: Any, gasPrice: Int = 500, gasLimit: Int = 20000, wallet: Wallet) -> String {
        return approve(address: address, tokenId: tokenId, gasPrice: gasPrice, gasLimit: gasLimit, wif: wallet.wif)
    }

    public func approve(address: String, tokenId: Any, gasPrice: Int = 500, gasLimit: Int = 20000, wif: String) -> String {
        let toAcct = OntologyParameter(type: .Address, value: address)
        let token = strOrIntToParam(arg: tokenId)
        let params = [toAcct, token]
        return ontologyInvoke(endpoint: endpoint, contractHash: contractHash, method: "approve", args: params, gasPrice: gasPrice, gasLimit: gasLimit, wif: wif)
    }

    public func allowance(tokenId: Any) -> String {
        let token = strOrIntToParam(arg: tokenId)
        let hex = ontologyInvokeRead(endpoint: endpoint, contractHash: contractHash, method: "allowance", args: [token])
        return hex
    }

    // OEP 5.1

    public func clearApproved(tokenId: Any, gasPrice: Int = 500, gasLimit: Int = 20000, wallet: Wallet) -> String {
        return clearApproved(tokenId: tokenId, gasPrice: gasPrice, gasLimit: gasLimit, wif: wallet.wif)
    }

    public func clearApproved(tokenId: Any, gasPrice: Int = 500, gasLimit: Int = 20000, wif: String) -> String {
        let token = strOrIntToParam(arg: tokenId)
        let params = [token]
        return ontologyInvoke(endpoint: endpoint, contractHash: contractHash, method: "clearApproved", args: params, gasPrice: gasPrice, gasLimit: gasLimit, wif: wif)
    }

    public func approvalForAll(owner: String, to: String, approval: Bool, gasPrice: Int = 500, gasLimit: Int = 20000, wallet: Wallet) -> String {
        return approvalForAll(owner: owner, to: to, approval: approval, gasPrice: gasPrice, gasLimit: gasLimit, wif: wallet.wif)
    }

    public func approvalForAll(owner: String, to: String, approval: Bool, gasPrice: Int = 500, gasLimit: Int = 20000, wif: String) -> String {
        let fromAcct = OntologyParameter(type: .Address, value: owner)
        let toAcct = OntologyParameter(type: .Address, value: to)
        let token = OntologyParameter(type: .Bool, value: approval)
        let params = [fromAcct, toAcct, token]
        return ontologyInvoke(endpoint: endpoint, contractHash: contractHash, method: "approvalForAll", args: params, gasPrice: gasPrice, gasLimit: gasLimit, wif: wif)
    }

    public func tokensOf(address: String) -> String {
        let owner = OntologyParameter(type: .Address, value: address)
        let hex = ontologyInvokeRead(endpoint: endpoint, contractHash: contractHash, method: "tokensOf", args: [owner])
        return hex
    }

    public func tokenMetadata(tokenId: Any) -> String {
        let token = strOrIntToParam(arg: tokenId)
        let hex = ontologyInvokeRead(endpoint: endpoint, contractHash: contractHash, method: "tokenMetadata", args: [token])
        return hex
    }
}