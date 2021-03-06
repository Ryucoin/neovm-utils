//
//  ScriptBuilder.swift
//  NeoSwift
//
//  Created by Andrei Terentiev on 10/28/17.
//  Copyright © 2017 drei. All rights reserved.
//

import Foundation

public class ScriptBuilder {
    private(set) public var rawBytes = [UInt8]()

    public init() {
        rawBytes = []
    }

    private func pushOPCode(_ op: OpCode) {
        rawBytes.append(op.rawValue)
    }

    private func pushBool(_ boolValue: Bool) {
        pushOPCode(boolValue ? .PUSH1 : .PUSH0)
    }

    private func pushInt(_ intValue: Int) {
        switch intValue {
        case -1:
            pushOPCode(.PUSHM1)
        case 0:
            pushOPCode(.PUSH0)
        case 1..<16:
            let rawValue = OpCode.PUSH1.rawValue + UInt8(intValue) - 1
            rawBytes.append(rawValue)
        default:
            let intBytes = toByteArray(intValue)
            pushHexString(intBytes.fullHexString)
        }
    }

    private func pushHexString(_ stringValue: String) {
        let stringBytes = stringValue.dataWithHexString().bytes
        let size = stringBytes.count
        if size < OpCode.PUSHBYTES75.rawValue {
            // Don't push OpCode
        } else if size < 0x100 {
            pushOPCode(.PUSHDATA1)
        } else if size < 0x10000 {
            pushOPCode(.PUSHDATA2)
        } else {
            pushOPCode(.PUSHDATA4)
        }
        rawBytes += toByteArrayWithoutTrailingZeros(stringBytes.count)
        rawBytes += stringBytes
    }

    private func pushTypedArray(_ arrayValue: [NVMParameter]) {
        for elem in arrayValue {
            pushTypedData(elem)
        }
        pushInt(arrayValue.count)
        pushOPCode(.PACK)
    }

    public func pushTypedData(_ data: NVMParameter) {
        let type = data.type.rawValue.lowercased()
        if type == "string" || type == "hash160" {
            pushHexString((data.value as? String ?? "").toHexString())
        } else if type == "address" {
            pushHexString((data.value as? String ?? "").hashFromAddress())
        } else if type == "boolean" {
            pushBool(data.value as? Bool ?? false)
        } else if type == "integer" {
            pushInt(data.value as? Int ?? 0)
        } else if type == "fixed8" {
            pushInt(Int(data.value as? Double ?? 0) * 100000000)
        } else if type == "fixed9" {
            pushInt(Int(data.value as? Double ?? 0) * 1000000000)
        } else if type == "bytearray" {
            pushHexString(data.value as? String ?? "")
        } else if type == "array" {
            let array = data.value as? [NVMParameter] ?? []
            pushTypedArray(array)
        }
    }

    public func pushTypedContractInvoke(scriptHash: String, operation: String, args: [NVMParameter]) {
        if scriptHash.count != 40 {
            print("Attempting to invoke invalid contract")
            return
        }

        if (!args.isEmpty) {
            pushTypedArray(args.reversed())
        } else {
            pushBool(false)
        }

        let hex = operation.unicodeScalars.filter { $0.isASCII }.map { String(format: "%X", $0.value) }.joined()
        pushHexString(hex)

        pushOPCode(.APPCALL)
        let toAppendBytes = scriptHash.dataWithHexString().bytes.reversed()
        rawBytes += toAppendBytes
    }
}
