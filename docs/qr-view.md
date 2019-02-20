# QR View

Implemented in [QRView.swift](https://github.com/Ryucoin/neovm-utils/blob/master/neovmUtils/Classes/QRView.swift)

- [Properties](#properties)
- [Methods](#methods)
  - [generate](#generate)

### Properties:

``` swift
var imageView: UIImageView
var code: String
```

### Methods:

#### Generate

Generates the QR view for a given code

``` swift
generate(code: String, foregroundColor: UIColor = .black, backgroundColor: UIColor = .white)
```
