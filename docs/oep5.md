# OEP5 Interface

Implemented in [OEP5.swift](https://github.com/Ryucoin/neovm-utils/blob/master/neovmUtils/Classes/Asset%20Interfaces/OEP5.swift)

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
public class OEP5Interface: OEP10Interface
```

### Properties

``` swift
var contractHash: String = ""
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

Gets the total amount of tokens minted. Returns the decimal representation.

``` swift
func getTotalSupply() -> String
```

#### Get Balance

Gets the total balance of tokens for the given `address`. Returns the decimal representation.

``` swift
func getBalance(address: String) -> String
```

#### Get Owner

Gets the owner of the token with the token id `tokenId`.

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
func transferMulti(args: [[String]], wallet: Wallet) -> String {
```
or
``` swift
func transferMulti(args: [[String]], wif: String) -> String {
```

Can also call with an array of `OEP5State` objects, which contain an `address` and `tokenId`.

``` swift
func transferMulti(args: [OEP5State], wif: String) -> String {
```
or
``` swift
func transferMulti(args: [OEP5State], wif: String) -> String {
```
