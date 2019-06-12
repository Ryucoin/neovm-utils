//
//  BlockchainInterfaceProtocol.swift
//  neovmUtils
//
//  Created by Wyatt Mufson on 6/11/19.
//  Copyright © 2019 Ryu Blockchain Technologies. All rights reserved.
//

import Foundation

protocol BlockchainInterfaceProtocol {
    var testnetExecution: Bool { get set }
    func invoke(contractHash: String, operation: String, args: [Any], wallet: Wallet, other: [String: Any]) -> String
    func read(contractHash: String, operation: String, args: [Any]) -> String
}
