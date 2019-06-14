# OEP10 Interface

Implemented in [OEP10.swift](https://github.com/Ryucoin/neovm-utils/blob/master/neovmUtils/Classes/Asset%20Interfaces/OEP10.swift)

- [OEP10 Class](#oep10-class)
- [Properties](#properties)
- [Methods](#methods)
  - [approveContract](#approve-contract)
  - [unapproveContract](#unapprove-contract)
  - [isApproved](#is-approved)

### OEP10 Class

The `OEP10Interface` class is used to interact with [OEP10](https://github.com/ontio/OEPs/pull/48) compliant smart contacts.

``` swift
public class OEP10Interface: OEPAssetInterface
```

### Properties

``` swift
var contractHash: String = ""
```

### Methods

#### Approve Contract

Approves a contract for the OEP10 contract.

``` swift
approveContract(hash: String, wallet: Wallet, gasPrice: Int = 500, gasLimit: Int = 20000) -> String
```

#### Unapprove Contract

Unapproves a contract for the OEP10 contract.

``` swift
unapproveContract(hash: String, wallet: Wallet, gasPrice: Int = 500, gasLimit: Int = 20000) -> String
```

#### Is Approved

Gets whether the given contract is approved for the OEP10 contract.

``` swift
isApproved(hash: String, wallet: Wallet) -> String
```
