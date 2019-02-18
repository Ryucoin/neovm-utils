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

public final class HDKeyPair {
    var node: HDNode
    
    init(node: HDNode) {
        self.node = node
    }
    
    public var privateKeyHex: String {
        return self.privateKey.bytesToHex!
    }
    
    public var publicKeyHex: String {
        return self.publicKey.bytesToHex!
    }
    
    public var privateKey: Data {
        return Data(bytes: withUnsafeBytes(of: &node.private_key) { ptr in
            return ptr.map({ $0 })
        })
    }
    
    public var publicKey: Data {
        var key = Data(repeating: 0, count: 65)
        privateKey.withUnsafeBytes { ptr in
            key.withUnsafeMutableBytes { keyPtr in
                ecdsa_get_public_key65(node.curve.pointee.params, ptr, keyPtr)
            }
        }
        return key
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

public func mnemonicFromPhrase(phrase: String) -> Mnemonic {
    var seed = Data(repeating: 0, count: 512 / 8)
    seed.withUnsafeMutableBytes { seedPtr in
        mnemonic_to_seed(phrase, "", seedPtr, nil)
    }
    let m = Mnemonic(value: phrase, seed: seed)
    return m
}

public func createHDKeyPair(mnemonic:Mnemonic) -> HDKeyPair {
    var node = HDNode()
    _ = mnemonic.seed.withUnsafeBytes { dataPtr in
        hdnode_from_seed(dataPtr, Int32(mnemonic.seed.count), "secp256k1", &node)
    }
    
    let keyPair = HDKeyPair(node: node)
    return keyPair
}
