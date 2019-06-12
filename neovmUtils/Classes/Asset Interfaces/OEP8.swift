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
        let hex = interface.read(contractHash: contractHash, operation: "name", args: [token])
        return hex.hexToAscii()
    }

    public func getSymbol(tokenId: Any) -> String {
        let token = strOrIntToParam(arg: tokenId)
        let hex =  interface.read(contractHash: contractHash, operation: "symbol", args: [token])
        return hex.hexToAscii()
    }

    public func getTotalSupply(tokenId: Any) -> Int {
        let token = strOrIntToParam(arg: tokenId)
        let hex = interface.read(contractHash: contractHash, operation: "totalSupply", args: [token])
        return hex.hexToDecimal()
    }

    public func getBalance(address: String, tokenId: Any) -> Int {
        let address = OntologyParameter(type: .Address, value: address)
        let token = strOrIntToParam(arg: tokenId)
        let hex = interface.read(contractHash: contractHash, operation: "balanceOf", args: [address, token])
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
        let other: [String: Any] = ["gasPrice": gasPrice, "gasLimit": gasLimit]
        return interface.invoke(contractHash: contractHash, operation: "transfer", args: [fromAcct, toAcct, token, sending], wif: wif, other: other)
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

            let fromAcct = OntologyParameter(type: .Address, value: arg[0] as? String ?? "")
            let toAcct = OntologyParameter(type: .Address, value: arg[1] as? String ?? "")
            let token = strOrIntToParam(arg: arg[2])
            let spending = OntologyParameter(type: .Integer, value: arg[3] as? Int ?? 0)
            let array = OntologyParameter(type: .Array, value: [fromAcct, toAcct, token, spending])
            params.append(array)
        }
        let other: [String: Any] = ["gasPrice": gasPrice, "gasLimit": gasLimit]
        return interface.invoke(contractHash: contractHash, operation: "transferMulti", args: params, wif: wif, other: other)
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
        let other: [String: Any] = ["gasPrice": gasPrice, "gasLimit": gasLimit]
        return interface.invoke(contractHash: contractHash, operation: "approve", args: params, wif: wif, other: other)
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
        let other: [String: Any] = ["gasPrice": gasPrice, "gasLimit": gasLimit]
        return interface.invoke(contractHash: contractHash, operation: "transferFrom", args: [spenderAcct, fromAcct, toAcct, token, sending], wif: wif, other: other)
    }

    public func getAllowance(owner: String, spender: String, tokenId: Any) -> Int {
        let ownerAcct = OntologyParameter(type: .Address, value: owner)
        let spenderAcct = OntologyParameter(type: .Address, value: spender)
        let token = strOrIntToParam(arg: tokenId)
        let hex =  interface.read(contractHash: contractHash, operation: "allowance", args: [ownerAcct, spenderAcct, token])
        return hex.hexToDecimal()
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

            let fromAcct = OntologyParameter(type: .Address, value: arg[0] as? String ?? "")
            let toAcct = OntologyParameter(type: .Address, value: arg[1] as? String ?? "")
            let token = strOrIntToParam(arg: arg[2])
            let spending = OntologyParameter(type: .Integer, value: arg[3] as? Int ?? 0)
            let array = OntologyParameter(type: .Array, value: [fromAcct, toAcct, token, spending])
            params.append(array)
        }
        let other: [String: Any] = ["gasPrice": gasPrice, "gasLimit": gasLimit]
        return interface.invoke(contractHash: contractHash, operation: "approveMulti", args: params, wif: wif, other: other)
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

            let spenderAcct = OntologyParameter(type: .Address, value: arg[0] as? String ?? "")
            let fromAcct = OntologyParameter(type: .Address, value: arg[1] as? String ?? "")
            let toAcct = OntologyParameter(type: .Address, value: arg[2] as? String ?? "")
            let token = strOrIntToParam(arg: arg[3])
            let spending = OntologyParameter(type: .Integer, value: arg[4] as? Int ?? 0)
            let array = OntologyParameter(type: .Array, value: [spenderAcct, fromAcct, toAcct, token, spending])
            params.append(array)
        }
        let other: [String: Any] = ["gasPrice": gasPrice, "gasLimit": gasLimit]
        return interface.invoke(contractHash: contractHash, operation: "approveMulti", args: params, wif: wif, other: other)
    }
}
