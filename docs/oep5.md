# OEP5 Interface

Implemented in [OEP5.swift](https://github.com/Ryucoin/neovm-utils/blob/master/neovmUtils/Classes/OEP5.swift)

- [OEP5 Class](#oep5-class)
- [Properties](#properties)
- [Methods](#methods)
  - [getName](#get-name)
  - [getSymbol](#get-symbol)
  - [getTotalSupply](#get-total-supply)
  - [getBalance](#get-balance)
  - [getOwner](#get-owner)
  - [getTokenName](#get-token-name)
  - [transfer](#transfer)
  - [transferMulti](#transfer-multi)
  - [mint](#mint)


### OEP5 Class

The `OEP5Interface` class is used to interact with [OEP5](https://github.com/ontio/OEPs/blob/master/OEPS/OEP-5.mediawiki) compliant smart contacts.

``` swift
public class OEP5Interface: NSObject
```

### Properties

``` swift
var contractHash: String = ""
var endpoint: String = ""
```

### Methods

#### Get Name

Gets the name of the given `OEP5` token.

``` swift
func getName() -> String
```

#### Get Symbol

Gets the symbol for the given `OEP5` token.

``` swift
func getSymbol() -> String
```

#### Get Total Supply

Gets the total amount of tokens minted. Returns the hex representation.

``` swift
func getTotalSupply() -> String
```

#### Get Balance

Gets the total balance of tokens for the given `address`. Returns the hex representation.

``` swift
func getBalance(address: String) -> String
```

#### Get Owner

Gets the owner of the token with the token id `tokenId`. Returns the hex representation.

``` swift
func getOwner(tokenId: String) -> String
```

#### Get Token Name

Gets the name of the token with the token id `tokenId`.

``` swift
func getTokenName(tokenId: String) -> String
```

#### Transfer

Transfers the token with token id `tokenId` to the given `address`. Requires either a `wallet` or `wif` to sign the transaction. Returns the transaction hash.

``` swift
func transfer(address: String, tokenId: String, wallet: Wallet) -> String
```
or
``` swift
func transfer(address: String, tokenId: String, wif: String) -> String
```

#### Transfer Multi

Transfers the multiple tokens at once. Takes an array of type `[address, tokenId]` that transfers the token with token id `tokenId` to `address`. Requires either a `wallet` or `wif` to sign the transaction. Returns the transaction hash.

``` swift
func transferMulti(args: [String], wallet: Wallet) -> String {
```
or
``` swift
func transferMulti(args: [String], wif: String) -> String {
```

#### Mint

Mints a token with name `tokenName` and sends it to `address`. Requires either a `wallet` or `wif` to sign the transaction. Returns the transaction hash.

``` swift
func mint(tokenName: String, address: String, wallet: Wallet) -> String
```
or
``` swift
func mint(tokenName: String, address: String, wif: String) -> String
```
