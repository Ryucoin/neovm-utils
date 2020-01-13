//
//  NEOInvocation.swift
//  neovmUtils
//
//  Created by Wyatt Mufson on 6/11/19.
//  Copyright © 2020 Ryu Blockchain Technologies. All rights reserved.
//

import Foundation
import Neoutils

private func concatenatePayloadData(tx: [UInt8], signatureData: Data, publicKey: Data) -> Data {
    var payload = tx + [0x01]                         // signature number
    payload += [0x41]                                 // signature struct length
    payload += [0x40]                                 // signature data length
    payload += signatureData.bytes                    // signature
    payload += [0x23]                                 // contract data length
    payload += [0x21] + publicKey.bytes + [0xac]      // NeoSigned publicKey
    return Data(payload)
}

private func unsignedPayloadToTransactionId(_ unsignedPayload: Data) -> String {
    let firstHash = unsignedPayload.sha256
    let reversed: [UInt8] = firstHash.sha256.bytes.reversed()
    return reversed.fullHexString
}

private func getAttribute(signer: Wallet?) -> [UInt8] {
    var customAttributes: [TransactionAttritbute] = []
    let remark = String(format: "O3X%@", Date().timeIntervalSince1970.description)
    if let signer = signer {
        customAttributes.append(TransactionAttritbute(script: signer.address.hashFromAddress()))
    }
    customAttributes.append(TransactionAttritbute(remark: remark))

    var numberOfAttributes: UInt8 = 0x00
    var attributesPayload: [UInt8] = []
    for attribute in customAttributes where attribute.data != nil {
        attributesPayload += attribute.data!
        numberOfAttributes += 1
    }
    return  [numberOfAttributes] + attributesPayload
}

private func getLength(_ size: Int) -> [UInt8] {
    // TODO: Implement correctly
//    if size < OpCode.PUSHBYTES75.rawValue {
//        return toByteArrayWithoutTrailingZeros(size)
//    } else if size < 0x100 {
//        return [OpCode.PUSHDATA1.rawValue] + toByteArrayWithoutTrailingZeros(size)
//    } else if size < 0x10000 {
//        return [OpCode.PUSHDATA2.rawValue] + toByteArrayWithoutTrailingZeros(size)
//    } else {
//        return [OpCode.PUSHDATA4.rawValue] + toByteArrayWithoutTrailingZeros(size)
//    }
    return toByteArrayWithoutTrailingZeros(size)
}

public func buildScript(scriptHash: String, operation: String, args: [NVMParameter]) -> [UInt8] {
    let scriptBuilder = ScriptBuilder()
    scriptBuilder.pushTypedContractInvoke(scriptHash: scriptHash, operation: operation, args: args)

    let scriptBytes = scriptBuilder.rawBytes
    let lengthBytes =  getLength(scriptBytes.count)
    let script = lengthBytes + scriptBytes

    return script
}

private func buildPayload(script: [UInt8], scriptHash: String, operation: String, args: [NVMParameter], signer: Wallet) -> (String, Data) {
    let payloadPrefix = [0xd1, 0x00] + script
    let attributesPayload: [UInt8] =  getAttribute(signer: signer)
    var rawTransaction = payloadPrefix + attributesPayload

    let totalInputCount: UInt8 = 0
    let finalInputPayload = Data()
    let finalOutputCount: UInt8 = 0
    let finalOutputPayload = Data()

    rawTransaction += [totalInputCount] + finalInputPayload.bytes + [finalOutputCount] + finalOutputPayload.bytes

    let rawTransactionData = Data(rawTransaction)
    let txid = unsignedPayloadToTransactionId(rawTransactionData)

    let signatureData = signer.signData(data: rawTransactionData)
    let finalPayload = concatenatePayloadData(tx: rawTransaction, signatureData: signatureData!, publicKey: signer.publicKey)
    return (txid, finalPayload)
}

public func neoInvoke(endpoint: String = neoTestNet, contractHash: String, operation: String, args: [NVMParameter], signer: Wallet) -> String {
    let script = buildScript(scriptHash: contractHash, operation: operation, args: args)
    var (txid, payload) = buildPayload(script: script, scriptHash: contractHash, operation: operation, args: args, signer: signer)
    payload += contractHash.dataWithHexString()

    return neoSendRawTransaction(endpoint: endpoint, raw: payload) ? txid : ""
}

public func neoInvokeRead(endpoint: String = neoTestNet, contractHash: String, operation: String, args: [NVMParameter]) -> String {
    return neoInvokeFunction(endpoint: endpoint, scriptHash: contractHash, operation: operation, args: args)
}
