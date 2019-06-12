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
}
