# QR View

Implemented in [QRView.swift](https://github.com/Ryucoin/neovm-utils/blob/master/neovmUtils/Classes/QRView.swift)

- [QRView Class](#qrview-class)
- [Properties](#properties)
- [Methods](#methods)
  - [generate](#generate)

### Wallet Class

The `QRView` class is used to display QR codes for a given code.

``` swift
public class QRView: UIView
```

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
