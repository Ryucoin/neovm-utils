# neovmUtils

[![Build Status](https://travis-ci.com/Ryucoin/neovm-utils.svg?branch=master)](https://travis-ci.com/Ryucoin/neovm-utils)
[![codecov](https://codecov.io/gh/Ryucoin/neovm-utils/branch/master/graph/badge.svg)](https://codecov.io/gh/Ryucoin/neovm-utils)
[![Version](https://img.shields.io/cocoapods/v/neovmUtils.svg?style=flat)](https://cocoapods.org/pods/neovmUtils)
[![License](https://img.shields.io/cocoapods/l/neovmUtils.svg?style=flat)](https://cocoapods.org/pods/neovmUtils)
[![Platform](https://img.shields.io/cocoapods/p/neovmUtils.svg?style=flat)](https://cocoapods.org/pods/neovmUtils)

- [Overview](#overview)
- [Installation](#installation)
- [Usage](#usage)
- [Contributing](#contributing)
- [License](#license)

## Overview

`neovmUtils` is a native iOS framework for interacting with the Ontology and NEO blockchains. It includes a compiled version of the [neo-utils](https://github.com/O3Labs/neo-utils) project by O3 Labs written in Go.

`neovmUtils` also implements BIP39 mnemonic phrases to generate wallets using an iOS wrapper of the [Trezor Crypto library](https://github.com/Ryucoin/trezor-crypto-ios).

It allows users to interact with numerous classes of digital assets on Ontology, such as native ONT/ONG and OEP4/5/8/10 assets.

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

**Note:** `neovmUtils` requires iOS 12.0 or higher. Bitcode must also be disabled.

An example `Podfile` would look like this:

```
use_frameworks!
platform :ios, '12.0'

target :'My_App' do
  pod 'neovmUtils'
end
```

## Usage

`neovmUtils` offers:
- [NEO/ONT Wallet](docs/wallet.md)
- [Ontology Wallet](docs/ont-wallet.md)
- [OntMonitor](docs/monitor.md)
- [ONT Identity](docs/ontid.md)
- [ONT RPC Methods](docs/ont-rpc.md)
- [ONT Transactions](docs/ont-trans.md)
- [QR View](docs/qr-view.md)
- [Mnemonic Creation](docs/mnemonic.md)
- [OEP4 Interface](docs/oep4.md)
- [OEP5 Interface](docs/oep5.md)
- [OEP8 Interface](docs/oep8.md)
- [Utils](docs/utils.md)
- [Compiled neo-utils golang](#golang)

### golang

The full `neo-utils` golang SDK is available for use with this pod. Simply import it with `import Neoutils`.

Documentation for the Go implementation is available [here](https://github.com/O3Labs/neo-utils/blob/master/neoutils/README.md).

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

## Contributing

We welcome contributors to `neovmUtils`. Before beginning, please take a look at our [contributing guidelines](./CONTRIBUTING.md).

It follows the [ontio-community sdk specifications doc](https://github.com/ontio-community/specifications/blob/master/sdk_dev_standard/en/ontology-sdk-dev.md) for its Ontology integration.

The compiled headers created by gomobile should be wrapped in NS_ASSUME_NONNULL macros until this is resolved by gomobile (https://stackoverflow.com/a/36164132/3830876).

#### Primary Authors

`neovmUtils` - [Wyatt Mufson](mailto:wyatt@towerbuilders.org) from Ryu Games

`neo-utils` - [Apisit Toompakdee](mailto:apisit@o3.network) from O3 Labs

## License

`neovmUtils` is available under the [MIT license](./LICENSE).
