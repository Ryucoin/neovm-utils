# NEO Transactions

Implemented in [NEOInvocation.swift](https://github.com/Ryucoin/neovm-utils/blob/master/neovmUtils/Classes/NEO/NEOInvocation.swift)

- [Functions](#functions)
  - [buildScript](#build-script)
  - [neoInvoke](#invoke)
  - [neoInvokeRead](#read)

### Functions

#### Build Script

Builds a transaction script

``` swift
buildScript(scriptHash: String, operation: String, args: [NVMParameter]) -> [UInt8]
```

#### Invoke

Invokes a transaction

``` swift
neoInvoke(endpoint: String = neoTestNet, contractHash: String, operation: String, args: [NVMParameter], signer: Wallet) -> String
```

#### Read

Pre-executes a transaction

``` swift
neoInvokeRead(endpoint: String = neoTestNet, contractHash: String, operation: String, args: [NVMParameter]) -> String
```
