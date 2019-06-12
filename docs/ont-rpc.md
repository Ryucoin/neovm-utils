# Ontology RPC

Implemented in [OntologyRPC.swift](https://github.com/Ryucoin/neovm-utils/blob/master/neovmUtils/Classes/Ontology/OntologyRPC.swift)

- [Functions](#functions)
  - [ontologyGetBlockCount](#get-block-count)
  - [ontologyGetBalances](#get-balances)
  - [ontologyGetSmartCodeEvent](#get-smart-code-event)
  - [ontologySendRawTransaction](#send-raw-transaction)
  - [ontologyGetStorage](#get-storage)
  - [ontologyGetRawTransaction](#get-raw-transaction)
  - [ontologyGetBlockWithHash](#get-block-with-hash)
  - [ontologyGetBlockWithHeight](#get-block-with-height)
  - [ontologyTransfer](#transfer)
  - [claimONG](#claim-ong)
  - [getUnboundONG](#get-unbound-ong)
- [Helpers](#helpers)
  - [getEndpoint](#get-endpoint)
  - [getBestNode](#get-best-node)
  - [OntAsset](#ont-asset)
- [Nodes](#nodes)

### Functions

#### Get Block Count

Gets the current block count

``` swift
ontologyGetBlockCount(endpoint: String = testNet) -> Int
```

#### Get Balances

Gets the ONT and ONG balances for an address.

``` swift
ontologyGetBalances(endpoint: String = testNet, address: String) -> (Int, Double)
```

#### Get Smart Code Event

Gets the smart code event for a given transaction hash

``` swift
ontologyGetSmartCodeEvent(endpoint: String = testNet, txHash: String) -> NeoutilsSmartCodeEvent?
```

#### Send Raw Transaction

Sends a raw transaction

``` swift
ontologySendRawTransaction(endpoint: String = testNet, raw: String) -> String
```

#### Get Storage

Gets a value out of storage for a key for a given smart contract

``` swift
ontologyGetStorage(endpoint: String = testNet, scriptHash: String, key: String) -> String
```

#### Get Raw Transaction

Gets the raw transaction for a transaction id

``` swift
ontologyGetRawTransaction(endpoint: String = testNet, txID: String) -> String
```

#### Get Block With Hash

Gets the block for a given hash

``` swift
ontologyGetBlockWithHash(endpoint: String = testNet, hash: String) -> String
```

#### Get Block With Height

Gets the block for a given height

``` swift
ontologyGetBlockWithHeight(endpoint: String = testNet, height: Int) -> String
```

#### Transfer

Transfers an `OntAsset` to an address

``` swift
ontologyTransfer(endpoint: String = testNet, gasPrice: Int = 500, gasLimit: Int = 20000, wif: String, asset: OntAsset, toAddress: String, amount: Double) -> String
```


#### Claim ONG

Claims ONG for an address

``` swift
claimONG(endpoint: String = testNet, gasPrice: Int = 500, gasLimit: Int = 20000, wif: String) -> String
```


#### Get Unbound ONG

Gets the unbound ONG for an address

``` swift
getUnboundONG(endpoint: String = testNet, address: String) -> String
```

### Helpers

#### Get Endpoint

Gets the endpoint for a given url

``` swift
formatEndpoint(endpt:String) -> String
```

#### Get Best Node

Gets the best node for a given `network`

``` swift
getBestNode(net:network) -> String
```

#### Ont Asset

``` swift
public enum OntAsset: String {
  case ONT
  case ONG
}
```

### Nodes

``` swift
public enum ontologyTestNodes: String {
  case polaris1 = "http://polaris1.ont.io:20336"
  case polaris2 = "http://polaris2.ont.io:20336"
  case polaris3 = "http://polaris3.ont.io:20336"
  case polaris4 = "http://polaris4.ont.io:20336"
  case bestNode = "testNetBestNode"
}

public enum ontologyMainNodes: String {
  case seed1 = "seed1.ont.io:20338"
  case seed2 = "seed2.ont.io:20338"
  case seed3 = "seed3.ont.io:20338"
  case seed4 = "seed4.ont.io:20338"
  case seed5 = "seed5.ont.io:20338"
  case bestNode = "mainNetBestNode"
}

public enum network {
  case mainNet
  case testNet
}
```
