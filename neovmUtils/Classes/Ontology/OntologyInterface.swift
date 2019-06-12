//
//  OntologyInterface.swift
//  neovmUtils
//
//  Created by Wyatt Mufson on 6/11/19.
//  Copyright © 2019 Ryu Blockchain Technologies. All rights reserved.
//

import UIKit

public final class OntologyInterface: NSObject, BlockchainInterfaceProtocol {
    static let shared = OntologyInterface()
    public var testnetExecution: Bool = true

    func invoke(contractHash: String, operation: String, args: [Any], wallet: Wallet, other: [String : Any]) -> String {
        guard let params = args as? [OntologyParameter] else {
            return ""
        }

        let gasPrice = other["gasPrice"] as? Int ?? 500
        let gasLimit = other["gasLimit"] as? Int ?? 20000
        let payer = other["payer"] as? String ?? ""

        return ontologyInvoke(endpoint: testnetExecution ? ontologyTestNet : ontologyMainNet, contractHash: contractHash, method: operation, args: params, gasPrice: gasPrice, gasLimit: gasLimit, wif: wallet.wif, payer: payer)
    }

    func read(contractHash: String, operation: String, args: [Any]) -> String {
        guard let params = args as? [OntologyParameter] else {
            return ""
        }

        return ontologyInvokeRead(endpoint: testnetExecution ? ontologyTestNet : ontologyMainNet, contractHash: contractHash, method: operation, args: params)
    }
}
