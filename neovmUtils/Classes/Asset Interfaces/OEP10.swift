//
//  OEP10.swift
//  neovmUtils
//
//  Created by Wyatt Mufson on 5/26/19.
//  Copyright © 2019 Ryu Blockchain Technologies. All rights reserved.
//

import Foundation

public class OEP10Interface: OEPAssetInterface {

    public func approveContract(hash: String, wallet: Wallet, gasPrice: Int = 500, gasLimit: Int = 20000) -> String {
        let cHash = NVMParameter(type: .String, value: hash)
        let params = [cHash]
        let other: [String: Any] = ["gasPrice": gasPrice, "gasLimit": gasLimit]
        return interface.invoke(contractHash: contractHash, operation: "approveContract", args: params, wif: wallet.wif, other: other)
    }

    public func unapproveContract(hash: String, wallet: Wallet, gasPrice: Int = 500, gasLimit: Int = 20000) -> String {
        let cHash = NVMParameter(type: .String, value: hash)
        let params = [cHash]
        let other: [String: Any] = ["gasPrice": gasPrice, "gasLimit": gasLimit]
        return interface.invoke(contractHash: contractHash, operation: "unapproveContract", args: params, wif: wallet.wif, other: other)
    }

    public func isApproved(hash: String, wallet: Wallet) -> String {
        let cHash = NVMParameter(type: .String, value: hash)
        let params = [cHash]
        let hex = interface.read(contractHash: contractHash, operation: "isApproved", args: params)
        return hex
    }
}
