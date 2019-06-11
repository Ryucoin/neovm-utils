//
//  CES1.swift
//  neovmUtils_Tests
//
//  Created by Wyatt Mufson on 6/10/19.
//  Copyright © 2019 Ryu Blockchain Technologies. All rights reserved.
//

import UIKit

public final class CES1Interface: OEP5Interface {

    public func nameOf(tokenId: Any) -> String {
        let token = strOrIntToParam(arg: tokenId)
        let hex = ontologyInvokeRead(endpoint: endpoint, contractHash: contractHash, method: "nameOf", args: [token])
        return hex.hexToAscii()
    }

    public func getRarity(tokenId: Any) -> String {
        let token = strOrIntToParam(arg: tokenId)
        let hex = ontologyInvokeRead(endpoint: endpoint, contractHash: contractHash, method: "getRarity", args: [token])
        return hex.hexToAscii()
    }

    public func getDNA(tokenId: Any) -> String {
        let token = strOrIntToParam(arg: tokenId)
        let hex = ontologyInvokeRead(endpoint: endpoint, contractHash: contractHash, method: "getDNA", args: [token])
        return hex.hexToAscii()
    }

    public func getRaritySupply(tokenId: Any) -> Int {
        let token = strOrIntToParam(arg: tokenId)
        let hex = ontologyInvokeRead(endpoint: endpoint, contractHash: contractHash, method: "getRaritySupply", args: [token])
        return hex.hexToDecimal()
    }

    public func getNameSupply(tokenId: Any) -> Int {
        let token = strOrIntToParam(arg: tokenId)
        let hex = ontologyInvokeRead(endpoint: endpoint, contractHash: contractHash, method: "getNameSupply", args: [token])
        return hex.hexToDecimal()
    }

    public func getRarityAndNameSupply(tokenId: Any) -> Int {
        let token = strOrIntToParam(arg: tokenId)
        let hex = ontologyInvokeRead(endpoint: endpoint, contractHash: contractHash, method: "getRarityAndNameSupply", args: [token])
        return hex.hexToDecimal()
    }

    public func mint(tokenName: String, address: String, gasPrice: Int = 500, gasLimit: Int = 20000, wallet: Wallet) -> String {
        return mint(tokenName: tokenName, address: address, gasPrice: gasPrice, gasLimit: gasLimit, wif: wallet.wif)
    }

    public func mint(tokenName: String, address: String, gasPrice: Int = 500, gasLimit: Int = 20000, wif: String) -> String {
        let name = OntologyParameter(type: .String, value: tokenName)
        let receiver = OntologyParameter(type: .Address, value: address)
        return ontologyInvoke(endpoint: endpoint, contractHash: contractHash, method: "mint", args: [name, receiver], gasPrice: gasPrice, gasLimit: gasLimit, wif: wif)
    }

    @available(*, unavailable, message:"CES1 Assets do not support approvalForAll")
    override public func approvalForAll(owner: String, to: String, approval: Bool, gasPrice: Int = 500, gasLimit: Int = 20000, wallet: Wallet) -> String {
        return ""
    }

    @available(*, unavailable, message: "CES1 Assets do not support approvalForAll")
    override public func approvalForAll(owner: String, to: String, approval: Bool, gasPrice: Int = 500, gasLimit: Int = 20000, wif: String) -> String {
        return ""
    }

    @available(*, unavailable, message: "CES1 Assets do not support tokenMetadata")
    override public func tokenMetadata(tokenId: Any) -> String {
        return ""
    }
}
