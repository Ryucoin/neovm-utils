# Ontology Wallet

Implemented in [OntologyWallet.swift](https://github.com/Ryucoin/neovm-utils/blob/master/neovmUtils/Classes/Ontology/OntologyWallet.swift)

Follows the specifications outlined in the [Ontology Developer Documentation](https://dev-docs.ont.io/#/docs-en/SDKs/01-wallet-file-specification).

- [Account Class](#account)
- [Ontology Wallet Class](#ontology-wallet-class)
- [Properties](#properties)
- [Methods](#methods)
  - [Add Identity](#add-identity)
  - [Add Account](#add-account)
  - [Remove Identity](#remove-identity)
  - [Remove Account](#remove-account)
  - [Set Default OntId](#set-default-ontid)
  - [Set Default Address](#set-default-address)
- [Helpers](#helpers)
  - [New Account](#new-account)

### Account Class

The `Account` class is a type-alias of the `Wallet` class, following the Ontology naming convention. `Account` and `Wallet` can be used interchangeably.

### Ontology Wallet Class

The `OntologyWallet` class is used to manage a list of `Account` and `Identity` objects.

``` swift
public final class OntologyWallet
```

### Properties:

``` swift
var name: String
let version: String
var scrypt: [String: Int]
var defaultOntid: String
var defaultAccountAddress: String
var createTime: String
var identities: [Identity]
var accounts: [Account]
```

### Methods:

#### Add Identity

Adds an `Identity` to the array `identities`.

``` swift
addIdentity(ident: Identity)
```

#### Add Account

Adds an `Account` to the array `accounts`.

``` swift
addAccount(acc: Account)
```

#### Remove Identity

Removes an `Identity` from the array `identities`.

``` swift
removeIdentity(ident: Identity)
```

#### Remove Account

Removes an `Account` from the array `accounts`.

``` swift
removeAccount(acc: Account)
```

#### Set Default OntId

Sets the `defaultOntid`.

``` swift
setDefaultOntId(ident: Identity)
```

#### Set Default Address

Sets the `defaultAccountAddress`.

``` swift
setDefaultAccountAddress(acc: Account)
```

### Helpers:

#### New Account

Creates a new `Account`. Same as calling `newWallet`.

``` swift
newAccount() -> Account
```
