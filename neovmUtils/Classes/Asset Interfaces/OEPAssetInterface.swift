//
//  OEPAssetInterface.swift
//  neovmUtils
//
//  Created by Wyatt Mufson on 5/26/19.
//  Copyright © 2019 Ryu Blockchain Technologies. All rights reserved.
//

import Foundation

public class OEPAssetInterface: AssetInterface {

    public func customInvoke(operation: String, args: [OntologyParameter], gasPrice: Int = 500, gasLimit: Int = 20000, wallet: Wallet, payer: String = "") -> String {
        return customInvoke(operation: operation, args: args, gasPrice: gasPrice, gasLimit: gasLimit, wif: wallet.wif, payer: payer)
    }

    public func customInvoke(operation: String, args: [OntologyParameter], gasPrice: Int = 500, gasLimit: Int = 20000, wif: String, payer: String = "") -> String {
        let other: [String: Any] = ["gasPrice": gasPrice, "gasLimit": gasLimit, "payer": payer]
        return interface.invoke(contractHash: contractHash, operation: operation, args: args, wif: wif, other: other)
    }

    public func customRead(operation: String, args: [OntologyParameter]) -> String {
        return interface.read(contractHash: contractHash, operation: operation, args: args)
    }

    public func strOrIntToParam(arg: Any) -> OntologyParameter {
        if let string = arg as? String {
            return OntologyParameter(type: .String, value: string)
        } else if let int = arg as? Int {
            return OntologyParameter(type: .Integer, value: int)
        } else {
            return OntologyParameter(type: .String, value: "")
        }
    }
}
