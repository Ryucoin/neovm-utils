# neovmUtils

[![Build Status](https://travis-ci.com/Ryucoin/neovm-utils.svg?branch=master)](https://travis-ci.com/Ryucoin/neovm-utils)
[![codecov](https://codecov.io/gh/Ryucoin/neovm-utils/branch/master/graph/badge.svg)](https://codecov.io/gh/Ryucoin/neovm-utils)
[![Version](https://img.shields.io/cocoapods/v/neovmUtils.svg?style=flat)](https://cocoapods.org/pods/neovmUtils)
[![License](https://img.shields.io/cocoapods/l/neovmUtils.svg?style=flat)](https://cocoapods.org/pods/neovmUtils)
[![Platform](https://img.shields.io/cocoapods/p/neovmUtils.svg?style=flat)](https://cocoapods.org/pods/neovmUtils)

neovmUtils is a native iOS framework for interacting with the NEO and Ontology blockchains. It is a compiled version of the [neo-utils](https://github.com/O3Labs/neo-utils) project by O3 Labs written in Go.

## Installation

`neovmUtils` is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'neovmUtils'
```

## Usage

You must import the `neovmUtils` pod as well as the compiled `neo-utils` Go framework.

```
import neovmUtils
import Neoutils
```

**Note:** the functions imported by `Neoutils` are used slightly differently than their implementations in Go. Additionally, the functions supplied by `neovmUtils` further simplify the compiled code.

#### Example

`neo-utils` (Go implementation):

```
wif := "<SOME VALID WIF>"
account, err := neoutils.GenerateFromWIF(wif)
if err != nil {
  log.Printf("There was an error: %v", err)
}
```  

`Neoutils` (Compiled Swift):

```
let wif = "<SOME VALID WIF>"
let err = NSErrorPointer(nilLiteral: ())
let account = NeoutilsGenerateFromWIF(wif, err) // account is of type NeoutilsWallet?
if err != nil {
  print("There was an error: \(err!)")
}
```

`neovmUtils` (Swift Abstraction):

```
let wif = "<SOME VALID WIF>"
let account = walletFromWIF(wif: wif) // account is of type Wallet
```

The full implementation of the `neovmUtils` abstraction is available [here](https://github.com/Ryucoin/neovm-utils/blob/master/neovmUtils/Classes/neovm.swift). Not all of the functions and types made available by importing `Neoutils` are simplified by importing `neovmUtils`.

Documentation for the Go implementation is available [here](https://github.com/O3Labs/neo-utils/blob/master/neoutils/README.md).

## Authors

`neovmUtils` - Wyatt Mufson, wyatt@ryucoin.com

`neo-utils` - Apisit Toompakdee, apisit@o3.network

## License

`neovmUtils` is available under the [MIT license](./LICENSE).
