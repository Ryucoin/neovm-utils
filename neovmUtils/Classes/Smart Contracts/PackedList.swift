//
//  PackedList.swift
//  neovmUtils
//
//  Created by Wyatt Mufson on 6/10/19.
//  Copyright © 2019 Ryu Blockchain Technologies. All rights reserved.
//

import Foundation

public final class PackedList: NSObject {
    public var items: Int = 0
    public var array: [Any] = []

    public init(dict: [String: Any]) {
        if let itm = dict["items"] as? Int {
            self.items = itm
        }

        if let array = dict["array"] as? [Any] {
            self.array = array
        }
    }
}
