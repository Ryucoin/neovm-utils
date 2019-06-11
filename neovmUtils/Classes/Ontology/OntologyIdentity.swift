//
//  OntologyIdentity.swift
//  neovmUtils
//
//  Created by Wyatt Mufson on 2/21/19.
//  Copyright © 2019 Ryu Blockchain Technologies. All rights reserved.
//

import Foundation
import Neoutils

public class Identity: Codable {
    public var label: String = ""
    public var ontid: String = ""
    public var publicKey: String = ""
    public var privateKey: String = ""
    public var wif: String = ""
    public var locked: Bool = false
    public var key: String = ""
    public var isDefault: Bool = false
    public let algorithm = "ECDSA"
    public let parameters: [String: String] = ["curve": "P-256"]

    fileprivate convenience init(label: String = "", password: String? = nil, ontid: String, publicKey: String, privateKey: String, wif: String) {
        self.init()
        self.label = label
        self.ontid = ontid
        self.publicKey = publicKey
        self.privateKey = privateKey
        self.wif = wif
        self.locked = false
        if let password = password {
            _ = lock(password: password)
        }
    }

    public func lock(password: String) -> Bool {
        if locked {
            return false
        }

        guard let enc = newEncryptedKey(wif: self.wif, password: password) else {
            return false
        }

        self.key = enc
        self.locked = true
        self.wif = ""
        self.privateKey = ""
        return true
    }

    public func unlock(password: String) -> Bool {
        if !locked {
            return false
        }

        let wifTry = wifFromEncryptedKey(encrypted: self.key, password: password)
        guard let wal = walletFromWIF(wif: wifTry) else {
            return false
        }

        self.key = ""
        self.locked = false
        self.wif = wal.wif
        self.privateKey = wal.privateKeyString
        return true
    }
}

public func createIdentity(label: String = "", password: String? = nil) -> Identity {
    let account = newAccount()
    let ontid = "did:ont:\(account.address)"
    let publicKey = account.publicKeyString
    let privateKey = account.privateKeyString
    let wif = account.wif
    return Identity(label: label, password: password, ontid: ontid, publicKey: publicKey, privateKey: privateKey, wif: wif)
}

public func sendRegister(endpoint: String = testNet, ident: Identity, password: String? = nil, payerAcct: Account, gasLimit: Int = 20000, gasPrice: Int = 500) -> String {
    var wif = ident.wif
    if ident.locked {
        if let password = password {
            _ = ident.unlock(password: password)
            wif = ident.wif
            _ = ident.lock(password: password)
        } else {
            return ""
        }
    }

    let err = NSErrorPointer(nilLiteral: ())
    let raw = NeoutilsOntologyMakeRegister(gasPrice, gasLimit, wif, payerAcct.wif, err)
    let e = getEndpoint(def: endpoint)
    let response = ontologySendRawTransaction(endpoint: e, raw: raw)
    return response
}

public class DDOAttribute {
    private var key: String = ""
    private var type: String = ""
    private var value: String = ""

    fileprivate convenience init(key: String, type: String, value: String) {
        self.init()
        self.key = key
        self.type = type
        self.value = value
    }

    public func getKey() -> String {
        return key
    }

    public func getType() -> String {
        return type
    }

    public func getValue() -> String {
        return value
    }

    public func getFull() -> [String: String] {
        var full: [String: String] = [:]
        full["Key"] = getKey()
        full["Type"] = getType()
        full["Value"] = getValue()
        return full
    }
}

private func parseDDOAttribute(hex: String) -> [DDOAttribute] {
    var attributes: [DDOAttribute] = []
    var index = 0
    let count = hex.count
    while index < count {
        let keyLength = hex[index..<index + 2]
        let keyVal = Int(UInt8(keyLength, radix: 16)! * 2)
        let keyUpper = index + 2 + keyVal
        let keyData = String(hex[index + 2..<keyUpper])
        let key = keyData.hexToAscii()

        let typeLength = hex[keyUpper..<keyUpper + 2]
        let typeVal = Int(UInt8(typeLength, radix: 16)! * 2)
        let typeUpper = keyUpper + 2 + typeVal
        let typeData = String(hex[keyUpper + 2..<typeUpper])
        let type = typeData.hexToAscii()

        let valueLength = hex[typeUpper..<typeUpper + 2]
        let valueVal = Int(UInt8(valueLength, radix: 16)! * 2)
        let valueUpper = typeUpper + 2 + valueVal
        let valueData = String(hex[typeUpper + 2..<valueUpper])
        let value = valueData.hexToAscii()

        let attr = DDOAttribute(key: key, type: type, value: value)
        attributes.append(attr)
        index = valueUpper
    }
    return attributes
}

public class PublicKeyWithId {
    private var id: Int = 0
    private var pk: String = ""
    private var ontid: String = ""
    private var type: String = ""
    private var curve: String = ""

    fileprivate convenience init(id: Int, pk: String, ontid: String) {
        self.init()
        self.id = id
        self.pk = pk
        self.ontid = ontid
        self.type = "ECDSA"
        self.curve = "P256"
    }

    public func getValue() -> String {
        return pk
    }

    public func getId() -> String {
        return "\(ontid)#keys-\(id)"
    }

    public func getType() -> String {
        return type
    }

    public func getCurve() -> String {
        return curve
    }

    public func getFull() -> [String: String] {
        var full: [String: String] = [:]
        full["Type"] = getType()
        full["Curve"] = getCurve()
        full["Value"] = getValue()
        full["PubKeyId"] = getId()
        return full
    }
}

private func parsePublicKeys(hex: String, ontid: String) -> [PublicKeyWithId] {
    var publicKeys: [PublicKeyWithId] = []
    var index = 0
    let count = hex.count
    while index < count {
        let original = UInt32(hex[index..<index+8], radix: 16)!
        let str = UInt32(littleEndian: original)
        let reversed = String(format:"%08X", str.bigEndian)
        let i = Int(reversed)!

        let length = hex[index+8..<index+10]
        let val = Int(UInt8(length, radix: 16)! * 2)
        let data = String(hex[index+10..<index+10+val])
        let pk = PublicKeyWithId(id: i, pk: data, ontid: ontid)
        publicKeys.append(pk)
        index += (10 + val)
    }
    return publicKeys
}

public class OntidDescriptionObject {
    public var ontid: String = ""
    public var publicKeys: [PublicKeyWithId] = []
    public var attributes: [DDOAttribute] = []
    public var recovery: String = ""

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

    let publicKeys = parsePublicKeys(hex: pk, ontid: ontid)
    let attributes = parseDDOAttribute(hex: attr)
    return OntidDescriptionObject(ontid: ontid, publicKeys: publicKeys, attributes: attributes, recovery: recovery)
}

public func sendGetDDO(endpoint: String = testNet, ontid: String) -> OntidDescriptionObject? {
    let err = NSErrorPointer(nilLiteral: ())
    let raw = NeoutilsOntologyBuildGetDDO(ontid, err)
    let response = ontologySendPreExecRawTransaction(endpoint: endpoint, raw: raw)
    if response == "" {
        return nil
    }
    return parseDDO(ontid: ontid, hex: response)
}

public func sendGetDDO(endpoint: String = testNet, ident: Identity) -> OntidDescriptionObject? {
    let err = NSErrorPointer(nilLiteral: ())
    let raw = NeoutilsOntologyBuildGetDDO(ident.ontid, err)
    let response = ontologySendPreExecRawTransaction(endpoint: endpoint, raw: raw)
    if response == "" {
        return nil
    }
    return parseDDO(ontid: ident.ontid, hex: response)
}
