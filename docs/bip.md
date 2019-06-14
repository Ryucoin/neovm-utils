# BlockchainInterfaceProtocol

Implemented in [BlockchainInterfaceProtocol.swift](https://github.com/Ryucoin/neovm-utils/blob/master/neovmUtils/Classes/BlockchainInterfaceProtocol.swift)

- [Overview](#overview)
- [Properties](#properties)
- [Methods](#methods)
- [Singletons](#singletons)

### Overview

The `BlockchainInterfaceProtocol` declares two methods and one property. Any class that follows this protocol can be plugged into any of the classes inheriting from the `AssetInterface`. This allows for different assert standards to be used regardless of chain.

### Properties

``` swift
var testnetExecution: Bool { get set }
```

### Methods

``` swift
invoke(contractHash: String, operation: String, args: [NVMParameter], wif: String, other: [String: Any]) -> String
read(contractHash: String, operation: String, args: [NVMParameter]) -> String
```

### Singletons

There are currently two singletons that can be used. `Ontology` and `NEO`. They are instances of the `OntologyInterface` and `NEOInterface` classes. Each one implements `invoke` and `read` using the technologies implemented in their respective RPC, invocation and network management files.
