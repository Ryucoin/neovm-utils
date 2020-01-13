//
//  DynamicList.swift
//  neovmUtils
//
//  Created by Wyatt Mufson on 6/10/19.
//  Copyright © 2020 Ryu Blockchain Technologies. All rights reserved.
//

import Foundation

public final class DynamicList: NSObject {
    public var items: Int = 0
    public var packed: [PackedList] = []

    public init(hex: String) {
        if hex.count < 2 {
            return
        }

        let parser = NVMParser()
        if let parsed = parser.deserialize(hex: hex) as? [String: Any] {
            if let itm = parsed["items"] as? Int {
                self.items = itm
            }

            if let packedArray = parsed["packed"] as? [[String: Any]] {
                for dict in packedArray {
                    let packedList = PackedList(dict: dict)
                    packed.append(packedList)
                }
            }
        }
    }

    public func flatten() -> [Any] {
        var result: [Any] = []
        for p in packed {
            for item in p.flatten() {
                result.append(item)
            }
        }
        return result
    }
}
