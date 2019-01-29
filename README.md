# neovmUtils

[![Build Status](https://travis-ci.com/Ryucoin/neovm-utils.svg?branch=master)](https://travis-ci.com/Ryucoin/neovm-utils)
[![codecov](https://codecov.io/gh/Ryucoin/neovm-utils/branch/master/graph/badge.svg)](https://codecov.io/gh/Ryucoin/neovm-utils)
[![Version](https://img.shields.io/cocoapods/v/neovmUtils.svg?style=flat)](https://cocoapods.org/pods/neovmUtils)
[![License](https://img.shields.io/cocoapods/l/neovmUtils.svg?style=flat)](https://cocoapods.org/pods/neovmUtils)
[![Platform](https://img.shields.io/cocoapods/p/neovmUtils.svg?style=flat)](https://cocoapods.org/pods/neovmUtils)

neovmUtils is a native iOS framework for interacting with the NEO and Ontology blockchains. It is a compiled version of the [neo-utils](https://github.com/O3Labs/neo-utils) project by O3 Labs written in Go.

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Installation

`neovmUtils` is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'neovmUtils'
```

## Usage

You can import the compiled `neo-utils` Go library as well as the `neovmUtils` helper functions built on-top written in Swift.

```
import Neoutils
import neovmUtils
```

**Note:** the functions imported by `Neoutils` are used slightly differently than their implementations in Go. Additionally, there are functions supplied by `neovmUtils` that further simplify the compiled code.

`neo-utils` (Go implementation):

```
wif := "<SOME VALID WIF>"
account, err = neoutils.GenerateFromWIF(wif)
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
let account = generateFromWIF(wif: wif) // account is of type NeoutilsWallet?
```

The full implementation of the `neovmUtils` abstraction is available [here](https://github.com/Ryucoin/neovm-utils/blob/master/neovmUtils/Classes/neovm.swift). Not all of the functions and types made available by importing `Neoutils` are simplified by importing `neovmUtils`.

Documentation for the Go implementation is available [here](https://github.com/O3Labs/neo-utils/blob/master/neoutils/README.md).

## Authors

`neo-utils` - Apisit Toompakdee, apisit@o3.network

`neovmUtils` - Wyatt Mufson, wyatt@ryucoin.com

## License

`neovmUtils` is available under the [MIT license](./LICENSE).
