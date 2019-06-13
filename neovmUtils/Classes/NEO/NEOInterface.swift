//
//  NEOInterface.swift
//  neovmUtils
//
//  Created by Wyatt Mufson on 6/11/19.
//  Copyright © 2019 Ryu Blockchain Technologies. All rights reserved.
//

import UIKit

public final class NEOInterface: NSObject, BlockchainInterfaceProtocol {
    public static let shared = NEOInterface()
    public var testnetExecution: Bool = true
    
    public func invoke(contractHash: String, operation: String, args: [Any], wif: String, other: [String : Any]) -> String {
        guard let params = args as? [NVMParameter] else {
            return ""
        }

        guard let signer = walletFromWIF(wif: wif) else {
            return ""
        }

        return neoInvoke(contractHash: contractHash, operation: operation, args: params, signer: signer)
    }
    
    public func read(contractHash: String, operation: String, args: [Any]) -> String {
        guard let params = args as? [NVMParameter] else {
            return ""
        }

        return neoInvokeRead(contractHash: contractHash, operation: operation, args: params)
    }
}