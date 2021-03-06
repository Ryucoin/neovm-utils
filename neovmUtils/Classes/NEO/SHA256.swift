//
//  SHA256.swift
//  NeoSwift
//
//  Created by Luís Silva on 13/09/17.
//  Copyright © 2017 drei. All rights reserved.
//

import Foundation
import CommonCrypto

public extension Data {
    var sha256: Data {
        let bytes = [UInt8](self)
        return Data(bytes.sha256)
    }
}

public extension Array where Element == UInt8 {
    var sha256: [UInt8] {
        let bytes = self

        let mutablePointer = UnsafeMutablePointer<UInt8>.allocate(capacity: Int(CC_SHA256_DIGEST_LENGTH))

        CC_SHA256(bytes, CC_LONG(bytes.count), mutablePointer)

        let mutableBufferPointer = UnsafeMutableBufferPointer<UInt8>.init(start: mutablePointer, count: Int(CC_SHA256_DIGEST_LENGTH))
        let sha256Data = Data(buffer: mutableBufferPointer)

        mutablePointer.deallocate()

        return sha256Data.bytes
    }
}
