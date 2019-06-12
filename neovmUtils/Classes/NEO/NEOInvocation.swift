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

private func buildScript(scriptHash: String, operation: String, args: [NVMParameter], signer: Wallet? = nil) -> Data {
    let scriptBuilder = ScriptBuilder()
    scriptBuilder.pushTypedContractInvoke(scriptHash: scriptHash, operation: operation, args: args)
    let script = scriptBuilder.rawBytes
    let scriptBytes = [UInt8(script.count)] + script
    let scriptHexstring = scriptBytes.fullHexString
    let rawTransaction = [0xd1, 0x00] + scriptHexstring.dataWithHexString().bytes
    let rawTransactionData = Data(rawTransaction)
    if let signer = signer {
        let signatureData = signer.signData(data: rawTransactionData)
        let finalPayload = concatenatePayloadData(txData: rawTransactionData, signatureData: signatureData!, publicKey: signer.publicKey)
        return finalPayload
    }
    return rawTransactionData
}

public func neoInvoke(endpoint: String = neoTestNet, contractHash: String, operation: String, args: [NVMParameter], signer: Wallet) -> String {
    var payload = buildScript(scriptHash: contractHash, operation: operation, args: args, signer: signer)
    payload += contractHash.dataWithHexString().bytes
    return neoSendRawTransaction(raw: payload)
}

public func neoInvokeRead(endpoint: String = neoTestNet, contractHash: String, operation: String, args: [NVMParameter]) -> String {
    var payload = buildScript(scriptHash: contractHash, operation: operation, args: args)
    payload += contractHash.dataWithHexString().bytes
    return neoInvokeScript(raw: payload)
}
