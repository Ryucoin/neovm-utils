//
//  BlockchainInterfaceProtocol.swift
//  neovmUtils
//
//  Created by Wyatt Mufson on 6/11/19.
//  Copyright © 2020 Ryu Blockchain Technologies. All rights reserved.
//

import Foundation

public protocol BlockchainInterfaceProtocol {
    var testnetExecution: Bool { get set }
    func invoke(contractHash: String, operation: String, args: [NVMParameter], wif: String, other: [String: Any]) -> String
    func read(contractHash: String, operation: String, args: [NVMParameter]) -> String
}

public let Ontology = OntologyInterface.shared
public let NEO = NEOInterface.shared
