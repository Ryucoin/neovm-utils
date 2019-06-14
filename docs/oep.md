# General OEP Asset Interface

Implemented in [OEPAssetInterface.swift](https://github.com/Ryucoin/neovm-utils/blob/master/neovmUtils/Classes/Asset%20Interfaces/OEPAssetInterface.swift)

- [OEPAssetInterface Class](#oepassetinterface-class)
  - [Properties](#properties)
  - [Methods](#methods)
    - [Custom Invoke](#custom-invoke)
    - [Custom Read](#custom-invoke-read)

### OEPAssetInterface Class

The `OEPAssetInterface` class is used to interact with all OEP assets. It includes `customInvoke` and `customRead` to call non-standard functions on the given asset.

``` swift
public class OEPAssetInterface: AssetInterface
```

### Properties

``` swift
var contractHash: String = ""
```

### Methods

#### Custom Invoke

Invokes a non-standard method

``` swift
customInvoke(operation: String, args: [NVMParameter], gasPrice: Int = 500, gasLimit: Int = 20000, wallet: Wallet, payer: String = "") -> String
```
or
``` swift
customInvoke(operation: String, args: [NVMParameter], gasPrice: Int = 500, gasLimit: Int = 20000, wif: String, payer: String = "") -> String
```

#### Custom Read

Invokes a non-standard method in read-only

``` swift
customRead(operation: String, args: [NVMParameter]) -> String
```
