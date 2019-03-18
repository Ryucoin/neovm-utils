# Mnemonic

Implemented in [Crypto.swift](https://github.com/Ryucoin/neovm-utils/blob/master/neovmUtils/Classes/Crypto.swift)

- [Mnemonic Class](#mnemonic-class)
- [Properties](#properties)
- [Methods](#methods)
  - [isValid](#is-valid)
- [Helpers](#helpers)
  - [createMnemonic](#create-mnemonic)
  - [mnemonicFromPhrase](#mnemonic-from-phrase)
  - [privateKeyFromMnemonic](#privatekey-from-mnemonic)


### Mnemonic Class

The `Mnemonic` class is used to generate 12 word mnemonic phrases. These can be used to seed the creation of wallets.

``` swift
public class Mnemonic
```

### Properties:

``` swift
var value: String!
var seed: Data!
```

### Methods:

#### Is Valid

Checks whether `value` is a valid mnemonic phrase

``` swift
isValid() -> Bool
```

### Helpers

#### Create Mnemonic

Creates a new `Mnemonic`

``` swift
createMnemonic() -> Mnemonic
```

#### Mnemonic From Phrase

Creates a new `Mnemonic` from a given phrase

``` swift
mnemonicFromPhrase(phrase: String) -> Mnemonic
```

#### PrivateKey From Mnemonic

Creates a private key from a given `Mnemonic`

``` swift
privateKeyFromMnemonic(mnemonic:Mnemonic) -> Data
```
