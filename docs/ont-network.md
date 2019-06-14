# Ontology Network

Implemented in [ONTNetwork.swift](https://github.com/Ryucoin/neovm-utils/blob/master/neovmUtils/Classes/Ontology/ONTNetwork.swift)

- [Functions](#functions)
  - [getEndpoint](#get-endpoint)
  - [getBestNode](#get-best-node)
- [Nodes](#nodes)

### Functions

#### Format ONT Endpoint

Gets the endpoint for a given url

``` swift
formatONTEndpoint(endpt: String) -> String
```

#### Get Best Ontology Node

Gets the best node for a given `network`

``` swift
getBestOntologyNode(net:network) -> String
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
