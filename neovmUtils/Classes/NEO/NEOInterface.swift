//
//  NEOInterface.swift
//  neovmUtils
//
//  Created by Wyatt Mufson on 6/11/19.
//  Copyright © 2020 Ryu Blockchain Technologies. All rights reserved.
//

import UIKit

public final class NEOInterface: NSObject, BlockchainInterfaceProtocol {
    public static let shared = NEOInterface()
    public var testnetExecution: Bool = true
    
    public func invoke(contractHash: String, operation: String, args: [NVMParameter], wif: String, other: [String: Any]) -> String {
        guard let signer = walletFromWIF(wif: wif) else {
            return ""
        }

        return neoInvoke(endpoint: testnetExecution ? neoTestNet : neoMainNet, contractHash: contractHash, operation: operation, args: args, signer: signer)
    }
    
    public func read(contractHash: String, operation: String, args: [NVMParameter]) -> String {
        return neoInvokeRead(endpoint: testnetExecution ? neoTestNet : neoMainNet, contractHash: contractHash, operation: operation, args: args)
    }
}
