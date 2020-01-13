//
//  AssetInterface.swift
//  neovmUtils
//
//  Created by Wyatt Mufson on 6/11/19.
//  Copyright © 2020 Ryu Blockchain Technologies. All rights reserved.
//

import Foundation

public class AssetInterface: NSObject {
    internal var contractHash: String = ""
    internal var interface: BlockchainInterfaceProtocol = Ontology

    public convenience init(contractHash: String, testnet: Bool = true, interface: BlockchainInterfaceProtocol = Ontology) {
        self.init()
        self.contractHash = contractHash
        self.interface = interface
        self.interface.testnetExecution = testnet
    }
}
