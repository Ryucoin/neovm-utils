# NVMParameter

Implemented in [NVMParameter.swift](https://github.com/Ryucoin/neovm-utils/blob/master/neovmUtils/Classes/Smart%20Contracts/NVMParameter.swift)

- [Parameters](#parameters)
  - [Types](#types)

### Parameters

``` swift
public class NVMParameter {
  public var type: NVMParameterType = .Unknown
  public var value: Any = ""

  public convenience init(type: NVMParameterType, value: Any) {
    self.init()
    if type == .Bool {
      self.type = .Integer
      let value = value as? Bool ?? false
      self.value = value ? 1 : 0
    } else {
      self.type = type
      self.value = value
    }
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
  case Bool
  case Boolean
  case ByteArray
  case Unknown
}
```
