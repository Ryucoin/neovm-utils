# NEO Network

Implemented in [NEONetwork.swift](https://github.com/Ryucoin/neovm-utils/blob/master/neovmUtils/Classes/NEO/NEONetwork.swift)

- [Functions](#functions)
  - [getEndpoint](#get-endpoint)
  - [getBestNode](#get-best-node)
- [Nodes](#nodes)

### Functions

#### Format NEO Endpoint

Gets the endpoint for a given url, returns a Promise

``` swift
formatNEOEndpoint(endpt: String) -> Promise<String?>
```

#### Get Best NEO Node

Gets the best node for a given `network`, returns a Promise

``` swift
getBestNEONode(net: network) -> Promise<String?>
```

### Nodes

Unlike with Ontology, the NEO network management is done asynchronously. The best node is calculated through the O3 API.
