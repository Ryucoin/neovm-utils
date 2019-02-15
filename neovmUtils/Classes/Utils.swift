//
//  Utils.swift
//  neovmUtils_Tests
//
//  Created by Wyatt Mufson on 2/15/19.
//  Copyright © 2019 Ryu Blockchain Technologies. All rights reserved.
//

import Foundation
import Neoutils

public extension Data {
    public var bytesToHex: String? {
        return NeoutilsBytesToHex(self)
    }
}

public extension String {
    public var hexToBytes: Data? {
        return NeoutilsHexTobytes(self)
    }
    
    public var isValidAddress: Bool {
        return NeoutilsValidateNEOAddress(self)
    }
}
