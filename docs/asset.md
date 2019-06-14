# Asset Interface

Implemented in [AssetInterface.swift](https://github.com/Ryucoin/neovm-utils/blob/master/neovmUtils/Classes/Asset%20Interfaces/AssetInterface.swift)

- [AssetInterface Class](#assetinterface-class)
  - [Properties](#properties)

### AssetInterface Class

The `AssetInterface` class is used to connect the interfaces with a given blockchain. The `AssetInterface` class can connect to any interface following the `BlockchainInterfaceProtocol`.

``` swift
public class AssetInterface: NSObject
```

### Properties

``` swift
var contractHash: String = ""
var interface: BlockchainInterfaceProtocol = Ontology
```
