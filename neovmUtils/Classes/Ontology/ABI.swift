//
//  ABI.swift
//  neovmUtils
//
//  Created by Wyatt Mufson on 6/11/19.
//  Copyright © 2019 Ryu Blockchain Technologies. All rights reserved.
//

import Foundation

public enum OntologyParameterType: String {
    case Address
    case String
    case Fixed8
    case Fixed9
    case Integer
    case Array
    case Bool
    case Unknown
}

public class OntologyParameter {
    public var type: OntologyParameterType = .Unknown
    public var value: Any = ""

    public convenience init(type: OntologyParameterType, value: Any) {
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

public class OEP5State {
    private var address: String = ""
    private var tokenId: Any = ""

    public convenience init(address: String, tokenId: Any) {
        self.init()
        self.address = address
        self.tokenId = tokenId
    }

    public func getParam() -> [Any] {
        let array = [address, tokenId]
        return array
    }
}

public class OEP8State {
    private var from: String = ""
    private var to: String = ""
    private var tokenId: Any = ""
    private var amount: Int = 0

    public convenience init(from: String, to: String, tokenId: Any, amount: Int) {
        self.init()
        self.from = from
        self.to = to
        self.tokenId = tokenId
        self.amount = amount
    }

    public func getParam() -> [Any] {
        let array = [from, to, tokenId, amount]
        return array
    }
}
