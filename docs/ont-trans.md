# Ontology Transactions

Implemented in [OntologyInvocation.swift](https://github.com/Ryucoin/neovm-utils/blob/master/neovmUtils/Classes/Ontology/OntologyInvocation.swift)

- [Parameters](#parameters)
- [Functions](#functions)
  - [buildOntologyInvocationTransaction](#build-invocation-transaction)
  - [ontologyInvoke](#invoke)
  - [ontologyInvokeRead](#read)

### Parameters

``` swift
public class NVMParameter {
  public var type: NVMParameterType = .Unknown
  public var value: Any = ""

  public convenience init(type: NVMParameterType, value: Any) {
    self.init()
    self.type = type
    self.value = value
  }
}
```

#### Types

``` swift
public enum NVMParameterType: String {
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

#### Build Invocation Transaction

Builds a raw transaction

``` swift
buildOntologyInvocationTransaction(contractHash: String, method: String, args: [NVMParameter], gasPrice: Int = 0, gasLimit: Int = 0, wif: String, payer: String = "") -> String?
```

#### Invoke

Invokes a transaction

``` swift
ontologyInvoke(endpoint: String = testNet, contractHash: String, method: String, args: [NVMParameter], gasPrice: Int = 0, gasLimit: Int = 0, wif: String, payer: String = "") -> String?
```

#### Read

Pre-executes a transaction

``` swift
ontologyInvokeRead(endpoint: String = testNet, contractHash: String, method: String, args: [NVMParameter]) -> String?
```
