# Ontology Transactions

Implemented in [ONTInvocation.swift](https://github.com/Ryucoin/neovm-utils/blob/master/neovmUtils/Classes/Ontology/ONTInvocation.swift)

- [Functions](#functions)
  - [buildOntologyInvocationTransaction](#build-invocation-transaction)
  - [ontologyInvoke](#invoke)
  - [ontologyInvokeRead](#read)

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
