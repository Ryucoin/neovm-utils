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

public class DDOAttribute {
    var key: String = ""
    var type: String = ""
    var value: String = ""

    fileprivate convenience init(key: String, type: String, value: String) {
        self.init()
        self.key = key
        self.type = type
        self.value = value
    }
}

private func parseDDOAttribute(hex: String) -> [DDOAttribute] {
    let attributes: [DDOAttribute] = []
    return attributes
}

public class PublicKeyWithId {
    var id: Int = 0
    var pk: Data = Data()

    fileprivate convenience init(id: Int, pk: Data) {
        self.init()
        self.id = id
        self.pk = pk
    }
}

private func parsePublicKeys(hex: String) -> [PublicKeyWithId] {
    let publicKeys: [PublicKeyWithId] = []
    return publicKeys
}

public class OntidDescriptionObject {
    var ontid: String = ""
    var publicKeys: [PublicKeyWithId] = []
    var attributes: [DDOAttribute] = []
    var recovery: String = ""

    fileprivate convenience init(ontid: String, publicKeys: [PublicKeyWithId], attributes: [DDOAttribute], recovery: String) {
        self.init()
        self.ontid = ontid
        self.publicKeys = publicKeys
        self.attributes = attributes
        self.recovery = recovery
    }
}

private func parseDDO(ontid: String, hex: String) -> OntidDescriptionObject {
    let step = 2
    let pkLen = hex[0..<step]
    let pkValue = UInt8(pkLen, radix: 16)! * 2
    let pkUpper = step + Int(pkValue)
    let pk = String(hex[step..<pkUpper])

    let attrLen = hex[pkUpper..<pkUpper + step]
    let attrValue = UInt8(attrLen, radix: 16)! * 2
    let attrUpper = pkUpper + step + Int(attrValue)
    let attr = String(hex[pkUpper + step..<attrUpper])

    let recoveryLen = hex[attrUpper..<attrUpper + step]
    let recoveryValue = UInt8(recoveryLen, radix: 16)! * 2
    let recoveryUpper = attrUpper + step + Int(recoveryValue)
    let recovery = String(hex[attrUpper + step..<recoveryUpper])

    let publicKeys = parsePublicKeys(hex: pk)
    let attributes = parseDDOAttribute(hex: attr)
    return OntidDescriptionObject(ontid: ontid, publicKeys: publicKeys, attributes: attributes, recovery: recovery)
}

public func sendGetDDO(endpoint: String = ontologyTestNodes.bestNode.rawValue, ontid: String) -> OntidDescriptionObject? {
    let err = NSErrorPointer(nilLiteral: ())
    guard let raw = NeoutilsOntologyBuildGetDDO(ontid, err) else {
        return nil
    }
    let response = ontologySendPreExecRawTransaction(endpoint: endpoint, raw: raw)
    return parseDDO(ontid: ontid, hex: response)
}

public func sendGetDDO(endpoint: String = ontologyTestNodes.bestNode.rawValue, ident: Identity) -> OntidDescriptionObject? {
    let err = NSErrorPointer(nilLiteral: ())
    guard let raw = NeoutilsOntologyBuildGetDDO(ident.ontid, err) else {
        return nil
    }
    let response = ontologySendPreExecRawTransaction(endpoint: endpoint, raw: raw)
    return parseDDO(ontid: ident.ontid, hex: response)
}
