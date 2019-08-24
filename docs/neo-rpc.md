# NEO RPC

Implemented in [NEORPC.swift](https://github.com/Ryucoin/neovm-utils/blob/master/neovmUtils/Classes/NEO/NEORPC.swift)

- [Functions](#functions)
  - [neoSendRawTransaction](#send-raw-transaction)
  - [neoInvokeScript](#invoke-script)
  - [neoInvokeFunction](#invoke-function)

### Functions

#### Send Raw Transaction

Sends a raw transaction. Returns whether it succeeded.

``` swift
neoSendRawTransaction(endpoint: String = neoTestNet, raw: Data) -> Bool
```

#### Invoke Script

Invokes a given script. Returns a result JSON

``` swift
neoInvokeScript(endpoint: String = neoTestNet, raw: Data) -> [String: Any]
```
or
``` swift
neoInvokeScript(endpoint: String = neoTestNet, avm: String) -> [String: Any]
```

#### Invoke Function

Invokes a function in read-only. Returns the hex result

``` swift
neoInvokeFunction(endpoint: String = neoTestNet, scriptHash: String, operation: String, args: [NVMParameter]) -> String
```
