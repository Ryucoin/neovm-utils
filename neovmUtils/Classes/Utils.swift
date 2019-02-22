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

    subscript(value: CountableClosedRange<Int>) -> Substring {
        get {
            return self[index(at: value.lowerBound)...index(at: value.upperBound)]
        }
    }

    subscript(value: CountableRange<Int>) -> Substring {
        get {
            return self[index(at: value.lowerBound)..<index(at: value.upperBound)]
        }
    }

    subscript(value: PartialRangeUpTo<Int>) -> Substring {
        get {
            return self[..<index(at: value.upperBound)]
        }
    }

    subscript(value: PartialRangeThrough<Int>) -> Substring {
        get {
            return self[...index(at: value.upperBound)]
        }
    }

    subscript(value: PartialRangeFrom<Int>) -> Substring {
        get {
            return self[index(at: value.lowerBound)...]
        }
    }

    func index(at offset: Int) -> String.Index {
        return index(startIndex, offsetBy: offset)
    }
}
