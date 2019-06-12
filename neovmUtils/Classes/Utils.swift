//
//  Utils.swift
//  neovmUtils
//
//  Created by Wyatt Mufson on 2/15/19.
//  Copyright © 2019 Ryu Blockchain Technologies. All rights reserved.
//

import Foundation
import Neoutils

public extension Data {
    var bytesToHex: String {
        return NeoutilsBytesToHex(self)
    }

    var bytes: [UInt8] {
        return [UInt8](self)
    }
}

public extension String {
    var hexToBytes: Data? {
        return NeoutilsHexTobytes(self)
    }

    var isValidAddress: Bool {
        return NeoutilsValidateNEOAddress(self)
    }

    subscript(value: CountableRange<Int>) -> Substring {
        get {
            return self[index(at: value.lowerBound)..<index(at: value.upperBound)]
        }
    }

    func index(at offset: Int) -> String.Index {
        return index(startIndex, offsetBy: offset)
    }

    func hexToAscii() -> String {
        let regex = try! NSRegularExpression(pattern: "(0x)?([0-9A-Fa-f]{2})", options: .caseInsensitive)
        let textNS = self as NSString
        let matchesArray = regex.matches(in: textNS as String, options: [], range: NSMakeRange(0, textNS.length))
        let characters = matchesArray.map {
            Character(UnicodeScalar(UInt32(textNS.substring(with: $0.range(at: 2)), radix: 16)!)!)
        }
        return String(characters)
    }

    func hexToDecimal() -> Int {
        var formatted = self
        let length = self.count
        if length <= 16 {
            let difference = 16 - length
            for _ in 0..<difference {
                formatted.append("0")
            }
        } else {
            return 0
        }

        let value = UInt64(formatted, radix: 16) ?? 0
        let z = value.byteSwapped
        let final = UInt64(bitPattern: Int64(z))
        return Int(final)
    }

    func scriptHashToAddress() -> String {
        let length = self.count
        var newStr = ""
        let startIndex = self.startIndex
        for i in 0..<length / 2 {
            let index = length - 2 * (i + 1)
            let start = self.index(startIndex, offsetBy: index)
            let end = self.index(startIndex, offsetBy: index + 2)
            let range = start..<end
            let piece = self[range]
            newStr += piece
        }
        return NeoutilsScriptHashToNEOAddress(newStr)
    }

    func dataWithHexString() -> Data {
        var hex = self
        var data = Data()
        while hex.count > 0 {
            let c: String = String(hex[0..<2])
            hex = String(hex[2..<hex.count])
            var ch: UInt32 = 0
            Scanner(string: c).scanHexInt32(&ch)
            var char = UInt8(ch)
            data.append(&char, count: 1)
        }
        return data
    }
}

public extension Array where Element == UInt8 {
    var hexString: String {
        return self.map { return String(format: "%x", $0) }.joined()
    }

    var fullHexString: String {
        return self.map { return String(format: "%02x", $0) }.joined()
    }

    mutating func removeTrailingZeros() {
        for i in (0..<self.endIndex).reversed() {
            guard self[i] == 0 else {
                break
            }
            self.remove(at: i)
        }
    }
}

public func toByteArray<T>(_ value: T) -> [UInt8] {
    var value = value
    return withUnsafeBytes(of: &value) { Array($0) }
}

public func toByteArrayWithoutTrailingZeros<T>(_ value: T) -> [UInt8] {
    var value = value
    var arr = withUnsafeBytes(of: &value) { Array($0) }
    arr.removeTrailingZeros()
    return arr
}
