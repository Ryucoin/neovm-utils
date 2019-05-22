# Utils

Implemented in [Utils.swift](https://github.com/Ryucoin/neovm-utils/blob/master/neovmUtils/Classes/Utils.swift)

- [String Extensions](#string-extensions)
  - [Is Valid Address](#is-valid-address)
  - [Hex to ASCII](#hex-to-ascii)
  - [Hex to Decimal](#hex-to-decimal)

### String Extensions

#### Is Valid Address

Checks to see if a string is a valid wallet address.

``` swift
isValidAddress: Bool
```

#### Hex to ASCII

Converts a hexstring returned from the blockchain to normal ASCII characters.

``` swift
hexToAscii() -> String
```

#### Hex to Decimal

Converts a hexstring returned from the blockchain to a normal decimal number. Note that it's limited to strings that are 16 characters long.

``` swift
hexToDecimal() -> Int
```
