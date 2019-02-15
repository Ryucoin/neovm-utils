//
//  Crypto.swift
//  neovmUtils_Tests
//
//  Created by Wyatt Mufson on 2/15/19.
//  Copyright © 2019 Ryu Blockchain Technologies. All rights reserved.
//

import Foundation
import TrezorCrypto

public class Mnemonic {
    public var value: String!
    public var seed: Data!

    convenience init(value: String, seed: Data) {
        self.init()
        self.value = value
        self.seed = seed
    }

    public func isValid() -> Bool {
        return mnemonic_check(value) != 0
    }
}

public func createMnemonic() -> Mnemonic {
    let raw = mnemonic_generate(128)!
    let mnemonic = String(cString: raw)
    var seed = Data(repeating: 0, count: 64)
    seed.withUnsafeMutableBytes { seedPtr in
        mnemonic_to_seed(mnemonic, "", seedPtr, nil)
    }
    let m = Mnemonic(value: mnemonic, seed: seed)
    return m
}
