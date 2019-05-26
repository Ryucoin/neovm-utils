//
//  OEPAssetInterface.swift
//  neovmUtils_Tests
//
//  Created by Wyatt Mufson on 5/26/19.
//  Copyright © 2019 Ryu Blockchain Technologies. All rights reserved.
//

import Foundation

public class OEPAssetInterface: NSObject {
    internal var contractHash: String = ""
    internal var endpoint: String = ""

    public convenience init(contractHash: String, endpoint: String = ontologyTestNodes.bestNode.rawValue) {
        self.init()
        self.contractHash = contractHash
        self.endpoint = endpoint
    }

    public func customInvoke(operation: String, args: [OntologyParameter], gasPrice: Int = 500, gasLimit: Int = 20000, wallet: Wallet, payer: String = "") -> String {
        return customInvoke(operation: operation, args: args, gasPrice: gasPrice, gasLimit: gasLimit, wif: wallet.wif, payer: payer)
    }

    public func customInvoke(operation: String, args: [OntologyParameter], gasPrice: Int = 500, gasLimit: Int = 20000, wif: String, payer: String = "") -> String {
        return ontologyInvoke(endpoint: endpoint, contractHash: contractHash, method: operation, args: args, gasPrice: gasPrice, gasLimit: gasLimit, wif: wif, payer: payer)
    }

    public func customRead(operation: String, args: [OntologyParameter]) -> String {
        return ontologyInvokeRead(endpoint: endpoint, contractHash: contractHash, method: operation, args: args)
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
