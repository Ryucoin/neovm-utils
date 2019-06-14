//
//  NVMParser.swift
//  neovmUtils
//
//  Created by Wyatt Mufson on 6/10/19.
//  Copyright © 2019 Ryu Blockchain Technologies. All rights reserved.
//

import UIKit

public class NVMParser: NSObject {
    enum VMType: String {
        case ByteArray = "00"
        case Bool = "01"
        case Int = "02"
        case Array = "80"
        case Struct = "81"
        case Dict = "82"
    }

    private var index = 0

    private func readByte(hex: String) -> String {
        let byte = String(hex[self.index..<self.index+2])
        self.index += 2
        return byte
    }

    private func readBytes(hex: String, count: Int) -> String {
        var bytes = ""
        for _ in 0..<count {
            let nByte = readByte(hex: hex)
            bytes += nByte
        }
        return bytes
    }

    private func readVarBytes(hex: String) -> String {
        let count = readInt(hex: hex)
        return readBytes(hex: hex, count: count)
    }

    private func readInt(hex: String) -> Int {
        let byte = readByte(hex: hex)
        let num = byte.hexToDecimal()
        return num
    }

    public func deserialize(hex: String) -> Any {
        let byte = readByte(hex: hex)
        if byte == VMType.ByteArray.rawValue {
            let bytes = readVarBytes(hex: hex)
            return bytes
        } else if byte == VMType.Bool.rawValue {
            let nextByte = readByte(hex: hex)
            if nextByte == "00" {
                return false
            }

            return true
        } else if byte == VMType.Int.rawValue {
            let bytes = readVarBytes(hex: hex)
            return bytes.hexToDecimal()
        } else if byte == VMType.Array.rawValue || byte == VMType.Struct.rawValue {
            let count = readInt(hex: hex)
            var list: [Any] = []
            for _ in 0..<count {
                let item = deserialize(hex: hex)
                list.append(item)
            }

            if byte == VMType.Struct.rawValue {
                return [list]
            }

            return list
        } else if byte == VMType.Dict.rawValue {
            let count = readInt(hex: hex)
            var dict: [String: Any] = [:]
            for _ in 0..<count {
                let key = (deserialize(hex: hex) as? String)?.hexToAscii() ?? "Bad key"
                let value = deserialize(hex: hex)
                dict[key] = value
            }
            return dict
        } else {
            return ""
        }
    }

    public func resetParser() {
        self.index = 0
    }
}
