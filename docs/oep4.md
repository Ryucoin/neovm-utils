# OEP4 Interface

Implemented in [OEP4.swift](https://github.com/Ryucoin/neovm-utils/blob/master/neovmUtils/Classes/OEP4.swift)

- [OEP4 Class](#oep4-class)
- [Properties](#properties)
- [Methods](#methods)
  - [getName](#get-name)
  - [getSymbol](#get-symbol)
  - [getDecimals](#get-decimals)
  - [getTotalSupply](#get-total-supply)
  - [getBalance](#get-balance)

### OEP4 Class

The `OEP4Interface` class is used to interact with [OEP4](https://github.com/ontio/OEPs/blob/master/OEPS/OEP-4.mediawiki) compliant smart contacts.

``` swift
public class OEP4Interface: NSObject
```

### Properties

``` swift
var contractHash: String = ""
var endpoint: String = ""
```

### Methods

#### Get Name

Gets the name of the given `OEP4` token.

``` swift
func getName() -> String
```

#### Get Symbol

Gets the symbol for the given `OEP4` token.

``` swift
func getSymbol() -> String
```

#### Get Decimals

Gets the amount of decimals for the given `OEP4` token. Returns the hex representation.

``` swift
func getDecimals() -> String
```

#### Get Total Supply

Gets the total supply for the given `OEP4` token. Returns the hex representation.

``` swift
func getTotalSupply() -> String
```

#### Get Balance

Gets the balance for the given `address` of the given `OEP4` token. Returns the hex representation.

``` swift
func getBalance(address: String) -> String
```
