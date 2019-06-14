# Ontology Identity

Implemented in [ONTIdentity.swift](https://github.com/Ryucoin/neovm-utils/blob/master/neovmUtils/Classes/Ontology/ONTIdentity.swift)

The Ontology DID Protocol is further defined here in the [official documentation](https://github.com/ontio/ontology-DID). The Swift implementation is based off the [Java SDK's implementation](https://github.com/ontio/ontology-java-sdk/blob/master/docs/en/identity_claim.md) and the [TS SDK's implementation](https://github.com/ontio/ontology-ts-sdk/blob/master/docs/en/identity_claim.md).

- [Classes](#classes)
  - [Identity](#identity)
  - [DDO Attribute](#ddo-attribute)
  - [PublicKeyWithId](#public-key-with-id)
  - [OntidDescriptionObject (DDO)](#ontid-description-object)
- [Functions](#functions)
  - [createIdentity](#create-identity)
  - [sendRegister](#send-register)
  - [sendGetDDO](#send-get-ddo)

### Classes

#### Identity

The `Identity` class stores information for a given Ontology DID.

``` swift
public class Identity {
  public var label: String = ""
  public var ontid: String = ""
  public var publicKey: String = ""
  public var privatKey: String = ""
  public var wif: String = ""
  public var enc: String = ""
  public var hasPassword: Bool = false
}
```

#### DDO Attribute

A `DDOAttribute` is used to store key/value pairs of information on an Ontology DID.

``` swift
public class DDOAttribute {
  private var key: String = ""
  private var type: String = ""
  private var value: String = ""
}
```

##### DDO Getters

``` swift
getKey() -> String
getType() -> String
getValue() -> String
getFull() -> [String: String]
```

#### Public Key With Id

A `PublicKeyWithId` is used to store an Ontology DID's public key.

``` swift
public class PublicKeyWithId {
  private var id: Int = 0
  private var pk: String = ""
  private var ontid: String = ""
  private var type: String = ""
  private var curve: String = ""
}
```

##### PK Getters

``` swift
getValue() -> String
getId() -> String
getType() -> String
getCurve() -> String
getFull() -> [String: String]
```

#### Ontid Description Object

A `OntidDescriptionObject` is used to store all of the information for an Ontology DID.

``` swift
public class OntidDescriptionObject {
  public var ontid: String = ""
  public var publicKeys: [PublicKeyWithId] = []
  public var attributes: [DDOAttribute] = []
  public var recovery: String = ""
}
```

### Functions

#### Create Identity

Create an `Identity` with an optional label and password

``` swift
createIdentity(label: String = "", password: String = "") -> Identity
```

#### Send Register

Registers an `Identity`

``` swift
sendRegister(endpoint: String = testNet, ident: Identity, password: String = "", payerAcct: Wallet, gasLimit: Int = 20000, gasPrice: Int = 500) -> String
```

#### Send Get DDO

Gets a `OntidDescriptionObject?` for a given ontid or `Identity`

``` swift
sendGetDDO(endpoint: String = testNet, ontid: String) -> OntidDescriptionObject?
```
and
``` swift
sendGetDDO(endpoint: String = testNet, ident: Identity) -> OntidDescriptionObject?
```
