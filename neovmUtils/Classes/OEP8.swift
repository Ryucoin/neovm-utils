//
//  OEP8.swift
//  neovmUtils
//
//  Created by Wyatt Mufson on 3/15/19.
//  Copyright © 2019 Ryu Blockchain Technologies. All rights reserved.
//

import Foundation

public class OEP8Interface: OEP10Interface {

    public func getName(tokenId: Any) -> String {
        let token = strOrIntToParam(arg: tokenId)
        let hex = ontologyInvokeRead(endpoint: endpoint, contractHash: contractHash, method: "name", args: [token])
        return hex.hexToAscii()
    }

    public func getSymbol(tokenId: Any) -> String {
        let token = strOrIntToParam(arg: tokenId)
        let hex =  ontologyInvokeRead(endpoint: endpoint, contractHash: contractHash, method: "symbol", args: [token])
        return hex.hexToAscii()
    }

    public func getTotalSupply(tokenId: Any) -> Int {
        let token = strOrIntToParam(arg: tokenId)
        let hex = ontologyInvokeRead(endpoint: endpoint, contractHash: contractHash, method: "totalSupply", args: [token])
        return hex.hexToDecimal()
    }

    public func getBalance(address: String, tokenId: Any) -> Int {
        let address = OntologyParameter(type: .Address, value: address)
        let token = strOrIntToParam(arg: tokenId)
        let hex = ontologyInvokeRead(endpoint: endpoint, contractHash: contractHash, method: "balanceOf", args: [address, token])
        return hex.hexToDecimal()
    }

    public func transfer(from: String, to: String, tokenId: Any, amount: Int, gasPrice: Int = 500, gasLimit: Int = 20000, wallet: Wallet) -> String {
        return transfer(from: from, to: to, tokenId: tokenId, amount: amount, gasPrice: gasPrice, gasLimit: gasLimit, wif: wallet.wif)
    }

    public func transfer(from: String, to: String, tokenId: Any, amount: Int, gasPrice: Int = 500, gasLimit: Int = 20000, wif: String) -> String {
        let fromAcct = OntologyParameter(type: .Address, value: from)
        let toAcct = OntologyParameter(type: .Address, value: to)
        let token = strOrIntToParam(arg: tokenId)
        let sending = OntologyParameter(type: .Integer, value: amount)
        return ontologyInvoke(endpoint: endpoint, contractHash: contractHash, method: "transfer", args: [fromAcct, toAcct, token, sending], gasPrice: gasPrice, gasLimit: gasLimit, wif: wif)
    }

    public func transferMulti(args: [OEP8State], gasPrice: Int = 500, gasLimit: Int = 20000, wallet: Wallet) -> String {
        return transferMulti(args: args, gasPrice: gasPrice, gasLimit: gasLimit, wif: wallet.wif)
    }

    public func transferMulti(args: [OEP8State], gasPrice: Int = 500, gasLimit: Int = 20000, wif: String) -> String {
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
            guard arg.count == 4 else {
                continue
            }

            let fromAcct = OntologyParameter(type: .Address, value: arg[0] as! String)
            let toAcct = OntologyParameter(type: .Address, value: arg[1] as! String)
            let token = strOrIntToParam(arg: arg[2])
            let spending = OntologyParameter(type: .Address, value: arg[3] as! Int)
            let array = OntologyParameter(type: .Array, value: [fromAcct, toAcct, token, spending])
            params.append(array)
        }

        return ontologyInvoke(endpoint: endpoint, contractHash: contractHash, method: "transferMulti", args: params, gasPrice: gasPrice, gasLimit: gasLimit, wif: wif)
    }

    public func approve(from: String, to: String, tokenId: Any, amount: Int, gasPrice: Int = 500, gasLimit: Int = 20000, wallet: Wallet) -> String {
        return approve(from: from, to: to, tokenId: tokenId, amount: amount, gasPrice: gasPrice, gasLimit: gasLimit, wif: wallet.wif)
    }

    public func approve(from: String, to: String, tokenId: Any, amount: Int, gasPrice: Int = 500, gasLimit: Int = 20000, wif: String) -> String {
        let fromAcct = OntologyParameter(type: .Address, value: from)
        let toAcct = OntologyParameter(type: .Address, value: to)
        let token = strOrIntToParam(arg: tokenId)
        let sending = OntologyParameter(type: .Integer, value: amount)
        let params = [fromAcct, toAcct, token, sending]
        return ontologyInvoke(endpoint: endpoint, contractHash: contractHash, method: "approve", args: params, gasPrice: gasPrice, gasLimit: gasLimit, wif: wif)
    }

    public func transferFrom(spender: String, from: String, to: String, tokenId: Any, amount: Int, gasPrice: Int = 500, gasLimit: Int = 20000, wallet: Wallet) -> String {
        return transferFrom(spender: spender, from: from, to: to, tokenId: tokenId, amount: amount, gasPrice: gasPrice, gasLimit: gasLimit, wif: wallet.wif)
    }

    public func transferFrom(spender: String, from: String, to: String, tokenId: Any, amount: Int, gasPrice: Int = 500, gasLimit: Int = 20000, wif: String) -> String {
        let spenderAcct = OntologyParameter(type: .Address, value: spender)
        let fromAcct = OntologyParameter(type: .Address, value: from)
        let toAcct = OntologyParameter(type: .Address, value: to)
        let token = strOrIntToParam(arg: tokenId)
        let sending = OntologyParameter(type: .Integer, value: amount)
        return ontologyInvoke(endpoint: endpoint, contractHash: contractHash, method: "transferFrom", args: [spenderAcct, fromAcct, toAcct, token, sending], gasPrice: gasPrice, gasLimit: gasLimit, wif: wif)
    }

    public func getAllowance(owner: String, spender: String, tokenId: Any) -> String {
        let ownerAcct = OntologyParameter(type: .Address, value: owner)
        let spenderAcct = OntologyParameter(type: .Address, value: spender)
        let token = strOrIntToParam(arg: tokenId)
        let hex =  ontologyInvokeRead(endpoint: endpoint, contractHash: contractHash, method: "allowance", args: [ownerAcct, spenderAcct, token])
        return hex.hexToAscii()
    }

    public func approveMulti(args: [OEP8State], gasPrice: Int = 500, gasLimit: Int = 20000, wallet: Wallet) -> String {
        return approveMulti(args: args, gasPrice: gasPrice, gasLimit: gasLimit, wif: wallet.wif)
    }

    public func approveMulti(args: [OEP8State], gasPrice: Int = 500, gasLimit: Int = 20000, wif: String) -> String {
        var params: [[Any]] = []
        for arg in args {
            let array = arg.getParam()
            params.append(array)
        }

        return approveMulti(args: params, gasPrice: gasPrice, gasLimit: gasLimit, wif: wif)
    }

    public func approveMulti(args: [[Any]], gasPrice: Int = 500, gasLimit: Int = 20000, wallet: Wallet) -> String {
        return approveMulti(args: args, gasPrice: gasPrice, gasLimit: gasLimit, wif: wallet.wif)
    }

    public func approveMulti(args: [[Any]], gasPrice: Int = 500, gasLimit: Int = 20000, wif: String) -> String {
        var params: [OntologyParameter] = []
        for arg in args {
            guard arg.count == 4 else {
                continue
            }

            let fromAcct = OntologyParameter(type: .Address, value: arg[0] as! String)
            let toAcct = OntologyParameter(type: .Address, value: arg[1] as! String)
            let token = strOrIntToParam(arg: arg[2])
            let spending = OntologyParameter(type: .Address, value: arg[3] as! Int)
            let array = OntologyParameter(type: .Array, value: [fromAcct, toAcct, token, spending])
            params.append(array)
        }

        return ontologyInvoke(endpoint: endpoint, contractHash: contractHash, method: "approveMulti", args: params, gasPrice: gasPrice, gasLimit: gasLimit, wif: wif)
    }

    public func transferFromMulti(args: [[Any]], gasPrice: Int = 500, gasLimit: Int = 20000, wallet: Wallet) -> String {
        return transferFromMulti(args: args, gasPrice: gasPrice, gasLimit: gasLimit, wif: wallet.wif)
    }

    public func transferFromMulti(args: [[Any]], gasPrice: Int = 500, gasLimit: Int = 20000, wif: String) -> String {
        var params: [OntologyParameter] = []
        for arg in args {
            guard arg.count == 5 else {
                continue
            }

            let spenderAcct = OntologyParameter(type: .Address, value: arg[0] as! String)
            let fromAcct = OntologyParameter(type: .Address, value: arg[1] as! String)
            let toAcct = OntologyParameter(type: .Address, value: arg[2] as! String)
            let token = strOrIntToParam(arg: arg[3])
            let spending = OntologyParameter(type: .Integer, value: arg[4] as! Int)
            let array = OntologyParameter(type: .Array, value: [spenderAcct, fromAcct, toAcct, token, spending])
            params.append(array)
        }

        return ontologyInvoke(endpoint: endpoint, contractHash: contractHash, method: "approveMulti", args: params, gasPrice: gasPrice, gasLimit: gasLimit, wif: wif)
    }
}
