# Ontology Transactions

- [Parameters](#parameters)
- [Functions](#functions)
  - [createOntParam](#create-parameter)
  - [buildOntologyInvocationTransaction](#build-invocation-transaction)
  - [ontologyInvoke](#invoke)

### Parameters

``` swift
public struct OntologyParameter {
  public var type : OntologyParameterType = .Unknown
  public var value : Any = ""
}
```

#### Types

``` swift
public enum OntologyParameterType: String {
  case Address
  case String
  case Fixed8
  case Fixed9
  case Integer
  case Array
  case Unknown
}
```

### Functions

#### Create Parameter

Create an `OntologyParameter` for a given type and value

``` swift
createOntParam(type:OntologyParameterType, value:Any) -> OntologyParameter
```

#### Build Invocation Transaction

Builds a raw transaction

``` swift
buildOntologyInvocationTransaction(contractHash: String, method: String, args: [OntologyParameter], gasPrice: Int = 0, gasLimit: Int = 0, wif: String, payer: String = "") -> String?
```

#### Invoke

Invokes a transaction

``` swift
ontologyInvoke(endpoint: String = ontologyTestNodes.bestNode.rawValue, contractHash: String, method: String, args: [OntologyParameter], gasPrice: Int = 0, gasLimit: Int = 0, wif: String, payer: String = "") -> String?
```
