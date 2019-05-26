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
}
