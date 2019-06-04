//
//  OEP10.swift
//  neovmUtils_Tests
//
//  Created by Wyatt Mufson on 5/26/19.
//  Copyright © 2019 Ryu Blockchain Technologies. All rights reserved.
//

import Foundation

public class OEP10Interface: OEPAssetInterface {

    public func approveContract(hash: String, wallet: Wallet, gasPrice: Int = 500, gasLimit: Int = 20000) -> String {
        let cHash = OntologyParameter(type: .String, value: hash)
        let params = [cHash]
        return ontologyInvoke(endpoint: endpoint, contractHash: contractHash, method: "approveContract", args: params, gasPrice: gasPrice, gasLimit: gasLimit, wif: wallet.wif)
    }

    public func unapproveContract(hash: String, wallet: Wallet, gasPrice: Int = 500, gasLimit: Int = 20000) -> String {
        let cHash = OntologyParameter(type: .String, value: hash)
        let params = [cHash]
        return ontologyInvoke(endpoint: endpoint, contractHash: contractHash, method: "unapproveContract", args: params, gasPrice: gasPrice, gasLimit: gasLimit, wif: wallet.wif)
    }

    public func isApproved(hash: String, wallet: Wallet) -> String {
        let cHash = OntologyParameter(type: .String, value: hash)
        let params = [cHash]
        let hex = ontologyInvokeRead(endpoint: endpoint, contractHash: contractHash, method: "isApproved", args: params)
        return hex
    }
}
