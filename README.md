# neovmUtils

[![Build Status](https://travis-ci.com/Ryucoin/neovm-utils.svg?branch=master)](https://travis-ci.com/Ryucoin/neovm-utils)
[![codecov](https://codecov.io/gh/Ryucoin/neovm-utils/branch/master/graph/badge.svg)](https://codecov.io/gh/Ryucoin/neovm-utils)
[![Version](https://img.shields.io/cocoapods/v/neovmUtils.svg?style=flat)](https://cocoapods.org/pods/neovmUtils)
[![License](https://img.shields.io/cocoapods/l/neovmUtils.svg?style=flat)](https://cocoapods.org/pods/neovmUtils)
[![Platform](https://img.shields.io/cocoapods/p/neovmUtils.svg?style=flat)](https://cocoapods.org/pods/neovmUtils)

- [Overview](#overview)
- [Installation](#installation)
- [Usage](#usage)
- [Authors](#authors)
- [License](#license)

## Overview

`neovmUtils` is a native iOS framework for interacting with the NEO and Ontology blockchains. It includes a compiled version of the [neo-utils](https://github.com/O3Labs/neo-utils) project by O3 Labs written in Go.

`neovmUtils` also implements BIP39 mnemonic phrases to generate wallets using an iOS wrapper of the [Trezor Crypto library](https://github.com/Ryucoin/trezor-crypto-ios).

Documentation for the Go implementation is available [here](https://github.com/O3Labs/neo-utils/blob/master/neoutils/README.md).

## Installation

`neovmUtils` is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'neovmUtils'
```

And import it into your project with:

```
import neovmUtils
```

## Usage

`neovmUtils` offers:
- [NEO/ONT Wallet](docs/wallet.md)
- [ONT RPC Methods](docs/ont-rpc.md)
- [ONT Transactions](docs/ont-trans.md)
- [QR View](docs/qr-view.md)
- [Mnemonic Creation](docs/mnemonic.md)

#### Improvements

The compiled `neo-utils` sdk is a little complicated to use, so a lot of it has been improved in native Swift.

For example, wallet creation can be done like the following:

`import Neoutils` (Compiled Swift):

``` swift
let wif = "<SOME VALID WIF>"
let err = NSErrorPointer(nilLiteral: ())
let account = NeoutilsGenerateFromWIF(wif, err) // account is of type NeoutilsWallet?
if err != nil {
  print("There was an error: \(err!)")
}
```

Or it can be done like this:

`import neovmUtils` (Swift Abstraction):

``` swift
let wif = "<SOME VALID WIF>"
let account = walletFromWIF(wif: wif) // account is of type Wallet?
```

## Authors

`neovmUtils` - Wyatt Mufson from Ryu Coin, wyatt@ryucoin.com

`neo-utils` - Apisit Toompakdee from O3 Labs, apisit@o3.network

## License

`neovmUtils` is available under the [MIT license](./LICENSE).
