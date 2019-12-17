//
//  OEP4.swift
//  neovmUtils
//
//  Created by Wyatt Mufson on 3/15/19.
//  Copyright © 2019 Ryu Blockchain Technologies. All rights reserved.
//

import Foundation

public class OEP4Interface: OEP10Interface {

    public func getName() -> String {
        let hex = interface.read(contractHash: contractHash, operation: "name", args: [])
        return hex.hexToAscii()
    }

    public func getSymbol() -> String {
        let hex = interface.read(contractHash: contractHash, operation: "symbol", args: [])
        return hex.hexToAscii()
    }

    public func getDecimals() -> Int {
        let hex = interface.read(contractHash: contractHash, operation: "decimals", args: [])
        return hex.hexToDecimal()
    }

    public func getTotalSupply() -> Int {
        let hex = interface.read(contractHash: contractHash, operation: "totalSupply", args: [])
        return hex.hexToDecimal()
    }

    public func getBalance(address: String) -> Int {
        let address = NVMParameter(type: .Address, value: address)
        let hex = interface.read(contractHash: contractHash, operation: "balanceOf", args: [address])
        return hex.hexToDecimal()
    }

    public func transfer(from: String, to: String, amount: Double, decimals: Int, gasPrice: Int = 500, gasLimit: Int = 20000, wallet: Wallet, payer: String = "") -> String {
        return transfer(from: from, to: to, amount: amount, decimals: decimals, gasPrice: gasPrice, gasLimit: gasLimit, wif: wallet.wif, payer: payer)
    }

    public func transfer(from: String, to: String, amount: Double, decimals: Int, gasPrice: Int = 500, gasLimit: Int = 20000, wif: String, payer: String = "") -> String {
        let fromAcct = NVMParameter(type: .Address, value: from)
        let toAcct = NVMParameter(type: .Address, value: to)
        var type = NVMParameterType.Integer
        var sending = amount
        if decimals == 8 {
            type = .Fixed8
        } else if decimals == 9 {
            type = .Fixed9
        } else {
            sending *= pow(10.0, Double(decimals))
        }
        let spend = NVMParameter(type: type, value: amount)
        let other: [String: Any] = ["gasPrice": gasPrice, "gasLimit": gasLimit, "payer": payer]
        return interface.invoke(contractHash: contractHash, operation: "transfer", args: [fromAcct, toAcct, spend], wif: wif, other: other)
    }

    public func transferFrom(spender: String, from: String, to: String, amount: Double, decimals: Int, gasPrice: Int = 500, gasLimit: Int = 20000, wallet: Wallet, payer: String = "") -> String {
        return transferFrom(spender: spender, from: from, to: to, amount: amount, decimals: decimals, gasPrice: gasPrice, gasLimit: gasLimit, wif: wallet.wif, payer: payer)
    }

    public func transferFrom(spender: String, from: String, to: String, amount: Double, decimals: Int, gasPrice: Int = 500, gasLimit: Int = 20000, wif: String, payer: String = "") -> String {
        let spenderAcct = NVMParameter(type: .Address, value: spender)
        let fromAcct = NVMParameter(type: .Address, value: from)
        let toAcct = NVMParameter(type: .Address, value: to)
        var type = NVMParameterType.Integer
        if decimals == 8 {
            type = .Fixed8
        } else if decimals == 9 {
            type = .Fixed9
        }
        let spend = NVMParameter(type: type, value: amount)
        let other: [String: Any] = ["gasPrice": gasPrice, "gasLimit": gasLimit, "payer": payer]
        return interface.invoke(contractHash: contractHash, operation: "transferFrom", args: [spenderAcct, fromAcct, toAcct, spend], wif: wif, other: other)
    }

    public func transferMulti(args: [[Any]], decimals: Int, gasPrice: Int = 500, gasLimit: Int = 20000, wallet: Wallet, payer: String = "") -> String {
        return transferMulti(args: args, decimals: decimals, gasPrice: gasPrice, gasLimit: gasLimit, wif: wallet.wif, payer: payer)
    }

    public func transferMulti(args: [[Any]], decimals: Int, gasPrice: Int = 500, gasLimit: Int = 20000, wif: String, payer: String = "") -> String {
        var params: [NVMParameter] = []
        for arg in args {
            guard arg.count == 3 else {
                continue
            }

            let fromAcct = NVMParameter(type: .Address, value: arg[0])
            let toAcct = NVMParameter(type: .Address, value: arg[1])
            var type = NVMParameterType.Integer
            if decimals == 8 {
                type = .Fixed8
            } else if decimals == 9 {
                type = .Fixed9
            }
            let spend = NVMParameter(type: type, value: arg[2])
            let array = NVMParameter(type: .Array, value: [fromAcct, toAcct, spend])
            params.append(array)
        }
        let other: [String: Any] = ["gasPrice": gasPrice, "gasLimit": gasLimit, "payer": payer]
        return interface.invoke(contractHash: contractHash, operation: "transferMulti", args: params, wif: wif, other: other)
    }

    public func approve(owner: String, spender: String, amount: Double, decimals: Int, gasPrice: Int = 500, gasLimit: Int = 20000, wallet: Wallet, payer: String = "") -> String {
        return approve(owner: owner, spender: spender, amount: amount, decimals: decimals, gasPrice: gasPrice, gasLimit: gasLimit, wif: wallet.wif, payer: payer)
    }

    public func approve(owner: String, spender: String, amount: Double, decimals: Int, gasPrice: Int = 500, gasLimit: Int = 20000, wif: String, payer: String = "") -> String {
        let ownerAcct = NVMParameter(type: .Address, value: owner)
        let spenderAcct = NVMParameter(type: .String, value: spender)
        var type = NVMParameterType.Integer
        if decimals == 8 {
            type = .Fixed8
        } else if decimals == 9 {
            type = .Fixed9
        }
        let spend = NVMParameter(type: type, value: amount)
        let other: [String: Any] = ["gasPrice": gasPrice, "gasLimit": gasLimit, "payer": payer]
        return interface.invoke(contractHash: contractHash, operation: "approve", args: [ownerAcct, spenderAcct, spend], wif: wif, other: other)
    }

    public func allowance(owner: String, spender: String) -> Int {
        let ownerAcct = NVMParameter(type: .Address, value: owner)
        let spenderAcct = NVMParameter(type: .String, value: spender)
        let hex = interface.read(contractHash: contractHash, operation: "allowance", args: [ownerAcct, spenderAcct])
        return hex.hexToDecimal()
    }
}
