//
//  OntologyIdentity.swift
//  neovmUtils_Tests
//
//  Created by Wyatt Mufson on 2/21/19.
//  Copyright © 2019 Ryu Blockchain Technologies. All rights reserved.
//

import Foundation
import Neoutils

public class Identity {
    public var label: String = ""
    public var ontid: String = ""
    public var publicKey: String = ""
    public var privatKey: String = ""
    public var wif: String = ""
    public var enc: String = ""
    public var hasPassword: Bool = false

    fileprivate convenience init(label: String = "", ontid: String, publicKey: String, privateKey: String, wif: String, enc: String) {
        self.init()
        self.label = label
        self.ontid = ontid
        self.publicKey = publicKey
        self.privatKey = privateKey
        self.wif = wif
        self.enc = enc
        self.hasPassword = enc != ""
    }
}

public func createIdentity(label: String = "", password: String = "") -> Identity {
    let account = newWallet()
    let ontid = "did:ont:\(account.address!)"
    let publicKey = account.publicKeyString!
    var privateKey = account.privateKeyString!
    var wif = account.wif!
    var enc = ""
    if password != "" {
        enc = newEncryptedKey(wif: wif, password: password)!
        privateKey = ""
        wif = ""
    }
    return Identity(label: label, ontid: ontid, publicKey: publicKey, privateKey: privateKey, wif: wif, enc: enc)
}

public func sendRegister(endpoint: String = ontologyTestNodes.bestNode.rawValue, ident: Identity, password: String = "", payerAcct: Wallet, gasLimit: Int = 20000, gasPrice: Int = 500) -> String {
    var wif = ""
    if ident.hasPassword {
        guard let w = wifFromEncryptedKey(encrypted: ident.enc, password: password) else {
            return ""
        }
        wif = w
    } else {
        wif = ident.wif
    }

    let err = NSErrorPointer(nilLiteral: ())
    guard let raw = NeoutilsOntologyMakeRegister(gasPrice, gasLimit, wif, payerAcct.wif!, err) else {
        return ""
    }
    let e = getEndpoint(def: endpoint)
    let response = ontologySendRawTransaction(endpoint: e, raw: raw)
    return response
}

public func sendGetDDO(endpoint: String = ontologyTestNodes.bestNode.rawValue, ontid: String) -> String {
    let err = NSErrorPointer(nilLiteral: ())
    guard let raw = NeoutilsOntologyBuildGetDDO(ontid, err) else {
        return ""
    }
    let response = ontologySendPreExecRawTransaction(endpoint: endpoint, raw: raw)
    return response
}

public func sendGetDDO(endpoint: String = ontologyTestNodes.bestNode.rawValue, ident: Identity) -> String {
    let err = NSErrorPointer(nilLiteral: ())
    guard let raw = NeoutilsOntologyBuildGetDDO(ident.ontid, err) else {
        return ""
    }
    let response = ontologySendPreExecRawTransaction(endpoint: endpoint, raw: raw)
    return response
}
