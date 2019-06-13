//
//  NEOInvocation.swift
//  neovmUtils
//
//  Created by Wyatt Mufson on 6/11/19.
//  Copyright © 2019 Ryu Blockchain Technologies. All rights reserved.
//

import Foundation
import Neoutils

private func concatenatePayloadData(txData: Data, signatureData: Data, publicKey: Data) -> Data {
    var payload = txData.bytes + [0x01]               // signature number
    payload += [0x41]                                 // signature struct length
    payload += [0x40]                                 // signature data length
    payload += signatureData.bytes                    // signature
    payload += [0x23]                                 // contract data length
    payload += [0x21] + publicKey.bytes + [0xac]      // NeoSigned publicKey
    return Data(payload)
}

private func unsignedPayloadToTransactionId(_ unsignedPayload: Data) -> String {
    let unsignedPayloadString = unsignedPayload.fullHexString
    let firstHash = unsignedPayloadString.dataWithHexString().sha256.fullHexString
    let reversed: [UInt8] = firstHash.dataWithHexString().sha256.bytes.reversed()
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

private func buildScript(scriptHash: String, operation: String, args: [NVMParameter]) -> String {
    let scriptBuilder = ScriptBuilder()
    scriptBuilder.pushTypedContractInvoke(scriptHash: scriptHash, operation: operation, args: args)
    let script = scriptBuilder.rawBytes
    let scriptBytes = [UInt8(script.count)] + script
    return scriptBytes.fullHexString
}

private func buildPayload(script: String, scriptHash: String, operation: String, args: [NVMParameter], signer: Wallet? = nil) -> (String, Data) {
    let payloadPrefix = [0xd1, 0x00] + script.dataWithHexString().bytes
    let attributesPayload: [UInt8] =  getAttribute(signer: signer)
    var rawTransaction = payloadPrefix + attributesPayload

    let totalInputCount: UInt8 = 0
    let finalInputPayload = Data()
    let finalOutputCount: UInt8 = 0
    let finalOutputPayload = Data()

    rawTransaction += [totalInputCount] + finalInputPayload.bytes + [finalOutputCount] + finalOutputPayload.bytes

    let rawTransactionData = Data(rawTransaction)
    let txid = unsignedPayloadToTransactionId(rawTransactionData)

    if let signer = signer {
        let signatureData = signer.signData(data: rawTransactionData)
        let finalPayload = concatenatePayloadData(txData: rawTransactionData, signatureData: signatureData!, publicKey: signer.publicKey)
        return (txid, finalPayload)
    }
    return (txid, rawTransactionData)
}

public func neoInvoke(endpoint: String = neoTestNet, contractHash: String, operation: String, args: [NVMParameter], signer: Wallet) -> String {
    let script = buildScript(scriptHash: contractHash, operation: operation, args: args)
    var (txid, payload) = buildPayload(script: script, scriptHash: contractHash, operation: operation, args: args, signer: signer)
    payload += contractHash.dataWithHexString().bytes
    if neoSendRawTransaction(endpoint: endpoint, raw: payload) {
        return txid
    }
    return ""
}

public func neoInvokeRead(endpoint: String = neoTestNet, contractHash: String, operation: String, args: [NVMParameter]) -> String {
    return neoInvokeScript(endpoint: endpoint, scriptHash: contractHash, operation: operation, args: args)
}
