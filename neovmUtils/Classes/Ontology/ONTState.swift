//
//  ONTState.swift
//  neovmUtils
//
//  Created by Wyatt Mufson on 6/11/19.
//  Copyright © 2020 Ryu Blockchain Technologies. All rights reserved.
//

import Foundation

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
