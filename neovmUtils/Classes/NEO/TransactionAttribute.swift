//
//  TransactionAttritbute.swift
//  NeoSwift
//
//  Created by Apisit Toompakdee on 9/12/17.
//  Copyright © 2017 drei. All rights reserved.
//

public class TransactionAttritbute {

    public let data: [UInt8]?

    public init(remark: String) {
        let byteArray: [UInt8] = Array(remark.utf8)
        let length = UInt8(byteArray.count)
        var attribute: [UInt8] = [0xf0, length]
        attribute += byteArray
        self.data = attribute
    }

    public init(script: String) {
        var attribute: [UInt8] = [0x20]
        attribute += script.dataWithHexString().bytes
        self.data = attribute
    }
}
