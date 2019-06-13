//
//  NVMParameter.swift
//  neovmUtils
//
//  Created by Wyatt Mufson on 6/11/19.
//  Copyright © 2019 Ryu Blockchain Technologies. All rights reserved.
//

import Foundation

public enum NVMParameterType: String {
    case Address
    case String
    case Fixed8
    case Fixed9
    case Integer
    case Array
    case Bool       // Casts to Int
    case Boolean
    case ByteArray
    case Unknown
}

public class NVMParameter {
    public var type: NVMParameterType = .Unknown
    public var value: Any = ""

    public convenience init(type: NVMParameterType, value: Any) {
        self.init()
        if type == .Bool {
            self.type = .Integer
            let value = value as? Bool ?? false
            self.value = value ? 1 : 0
        } else {
            self.type = type
            self.value = value
        }
    }

    public func getIFArg() -> [String: Any] {
        switch self.type {
        case .Address:
            return ["type": "ByteArray", "value" : "\((self.value as? String ?? "").hashFromAddress())"]
        case .String, .Integer, .Boolean:
            return ["type": self.type.rawValue, "value" : "\(self.value)"]
        case .Fixed8:
            return ["type": "Integer", "value" : "\((self.value as? Int ?? 0) * 100000000)"]
        case .Fixed9:
            return ["type": "Integer", "value" : "\((self.value as? Int ?? 0) * 1000000000)"]
        case .Array:
            var values: [Any] = []
            let array = self.value as? [NVMParameter] ?? []
            for item in array {
                let x = item.getIFArg()
                values.append(x)
            }
            return ["type": self.type.rawValue, "value" : values]
        default:
            return [:]
        }
    }
}
