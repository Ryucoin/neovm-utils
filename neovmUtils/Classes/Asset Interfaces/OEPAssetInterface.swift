//
//  OEPAssetInterface.swift
//  neovmUtils
//
//  Created by Wyatt Mufson on 5/26/19.
//  Copyright © 2019 Ryu Blockchain Technologies. All rights reserved.
//

import Foundation

public class OEPAssetInterface: AssetInterface {

    public func customInvoke(operation: String, args: [NVMParameter], gasPrice: Int = 500, gasLimit: Int = 20000, wallet: Wallet, payer: String = "") -> String {
        return customInvoke(operation: operation, args: args, gasPrice: gasPrice, gasLimit: gasLimit, wif: wallet.wif, payer: payer)
    }

    public func customInvoke(operation: String, args: [NVMParameter], gasPrice: Int = 500, gasLimit: Int = 20000, wif: String, payer: String = "") -> String {
        let other: [String: Any] = ["gasPrice": gasPrice, "gasLimit": gasLimit, "payer": payer]
        return interface.invoke(contractHash: contractHash, operation: operation, args: args, wif: wif, other: other)
    }

    public func customRead(operation: String, args: [NVMParameter]) -> String {
        return interface.read(contractHash: contractHash, operation: operation, args: args)
    }

    public func strOrIntToParam(arg: Any) -> NVMParameter {
        if let string = arg as? String {
            return NVMParameter(type: .String, value: string)
        } else if let int = arg as? Int {
            return NVMParameter(type: .Integer, value: int)
        } else {
            return NVMParameter(type: .String, value: "")
        }
    }
}
