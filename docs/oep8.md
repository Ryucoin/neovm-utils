# OEP8 Interface

Implemented in [OEP8.swift](https://github.com/Ryucoin/neovm-utils/blob/master/neovmUtils/Classes/OEP8.swift)

- [OEP8 Class](#oep8-class)
- [Properties](#properties)
- [Methods](#methods)
  - [getName](#get-name)
  - [getSymbol](#get-symbol)
  - [getTotalSupply](#get-total-supply)
  - [getBalance](#get-balance)

### OEP8 Class

The `OEP8Interface` class is used to interact with [OEP8](https://github.com/ontio/OEPs/blob/master/OEPS/OEP-8.mediawiki) compliant smart contacts.

``` swift
public class OEP8Interface: NSObject
```

### Properties

``` swift
var contractHash: String = ""
var endpoint: String = ""
```

### Methods

#### Get Name

Gets the name of the given `OEP8` token with a `tokenId`.

``` swift
func getName(tokenId: Int) -> String?
```

#### Get Symbol

Gets the symbol for the given `OEP8` token with a `tokenId`.

``` swift
func getSymbol(tokenId: Int) -> String?
```

#### Get Total Supply

Gets the total supply for the given `OEP8` token with a `tokenId`. Returns the hex representation.

``` swift
func getTotalSupply(tokenId: Int) -> String?
```

#### Get Balance

Gets the balance for the given `address` of the given `OEP8` token with a `tokenId`. Returns the hex representation.

``` swift
func getBalance(address: String, tokenId: Int) -> String?
```
