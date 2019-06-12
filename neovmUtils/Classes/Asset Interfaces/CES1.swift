//
//  CES1.swift
//  neovmUtils
//
//  Created by Wyatt Mufson on 6/10/19.
//  Copyright © 2019 Ryu Blockchain Technologies. All rights reserved.
//

import UIKit

public final class CES1Interface: OEP5Interface {

    public func nameOf(tokenId: Any) -> String {
        let token = strOrIntToParam(arg: tokenId)
        let hex = interface.read(contractHash: contractHash, operation: "nameOf", args: [token])
        return hex.hexToAscii()
    }

    public func getRarity(tokenId: Any) -> String {
        let token = strOrIntToParam(arg: tokenId)
        let hex = interface.read(contractHash: contractHash, operation: "getRarity", args: [token])
        return hex.hexToAscii()
    }

    public func getDNA(tokenId: Any) -> String {
        let token = strOrIntToParam(arg: tokenId)
        let hex = interface.read(contractHash: contractHash, operation: "getDNA", args: [token])
        return hex
    }

    public func getColor(tokenId: Any) -> TokenColor {
        let dna = getDNA(tokenId: tokenId)
        if dna.count < 8 {
            return TokenColor(color: "", alpha: "")
        }
        let color = String(dna[0..<6])
        let alpha = String(dna[6..<8])
        return TokenColor(color: color, alpha: alpha)
    }

    public func getRaritySupply(rarity: String) -> Int {
        let param = OntologyParameter(type: .String, value: rarity)
        let hex = interface.read(contractHash: contractHash, operation: "getRaritySupply", args: [param])
        return hex.hexToDecimal()
    }

    public func getNameSupply(name: String) -> Int {
        let param = OntologyParameter(type: .String, value: name)
        let hex = interface.read(contractHash: contractHash, operation: "getNameSupply", args: [param])
        return hex.hexToDecimal()
    }

    public func getRarityAndNameSupply(rarity: String, name: String) -> Int {
        let rparam = OntologyParameter(type: .String, value: rarity)
        let nparam = OntologyParameter(type: .String, value: name)
        let hex = interface.read(contractHash: contractHash, operation: "getRarityAndNameSupply", args: [nparam, rparam])
        return hex.hexToDecimal()
    }

    public func mint(tokenName: String, address: String, gasPrice: Int = 500, gasLimit: Int = 20000, wallet: Wallet) -> String {
        return mint(tokenName: tokenName, address: address, gasPrice: gasPrice, gasLimit: gasLimit, wif: wallet.wif)
    }

    public func mint(tokenName: String, address: String, gasPrice: Int = 500, gasLimit: Int = 20000, wif: String) -> String {
        let name = OntologyParameter(type: .String, value: tokenName)
        let receiver = OntologyParameter(type: .Address, value: address)
        let other: [String: Any] = ["gasPrice": gasPrice, "gasLimit": gasLimit]
        return interface.invoke(contractHash: contractHash, operation: "mint", args: [name, receiver], wif: wif, other: other)
    }

    override public func approvalForAll(owner: String, to: String, approval: Bool, gasPrice: Int = 500, gasLimit: Int = 20000, wallet: Wallet) -> String {
        return "CES1 Assets do not support approvalForAll"
    }

    override public func approvalForAll(owner: String, to: String, approval: Bool, gasPrice: Int = 500, gasLimit: Int = 20000, wif: String) -> String {
        return "CES1 Assets do not support approvalForAll"
    }

    override public func tokenMetadata(tokenId: Any) -> String {
        return "CES1 Assets do not support tokenMetadata"
    }
}

public struct TokenColor {
    public let color: String
    public let alpha: String

    public init(color: String, alpha: String) {
        self.color = color
        self.alpha = alpha
    }
}
