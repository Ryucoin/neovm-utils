//
//  Crypto.swift
//  neovmUtils_Tests
//
//  Created by Wyatt Mufson on 2/15/19.
//  Copyright © 2019 Ryu Blockchain Technologies. All rights reserved.
//

import Foundation
import RyuCrypto

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

    var seed = [UInt8](repeating: 0, count: 64)
    mnemonic_to_seed(mnemonic, "", &seed, nil)

    let m = Mnemonic(value: mnemonic, seed: Data(seed))
    return m
}

public func mnemonicFromPhrase(phrase: String) -> Mnemonic {
    var seed = [UInt8](repeating: 0, count: 64)
    mnemonic_to_seed(phrase, "", &seed, nil)

    let m = Mnemonic(value: phrase, seed: Data(seed))
    return m
}

public func privateKeyFromMnemonic(mnemonic:Mnemonic) -> Data {
    var node = HDNode()
    var data = [UInt8](repeating: 0, count: mnemonic.seed.count)
    hdnode_from_seed(&data, Int32(mnemonic.seed.count), "secp256k1", &node)

    return Data(withUnsafeBytes(of: &node.private_key) { ptr in
        return ptr.map({ $0 })
    })
}
