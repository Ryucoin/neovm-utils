//
//  PackedList.swift
//  neovmUtils
//
//  Created by Wyatt Mufson on 6/10/19.
//  Copyright © 2020 Ryu Blockchain Technologies. All rights reserved.
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

    private func flatten(arr: [Any]) -> [Any] {
        var flattened: [Any] = []
        for item in arr {
            if let list = item as? [Any] {
                let flattenedList = flatten(arr: list)
                for i in flattenedList {
                    flattened.append(i)
                }
            } else {
                flattened.append(item)
            }
        }
        return flattened
    }

    public func flatten() -> [Any] {
        return flatten(arr: self.array)
    }
}
