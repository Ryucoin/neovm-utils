# Wallet

- [Properties](#properties)
- [Methods](#methods)
  - [signMessage](#sign-message)
  - [verifySignature](#sign-message)
  - [computeSharedSecret](#compute-shared-secret)
  - [privateEncrypt](#private-encrypt)
  - [privateDecrypt](#private-decrypt)
  - [sharedEncrypt](#shared-encrypt)
  - [sharedDecrypt](#shared-decrypt)
  - [exportQR](#export-qr)

### Properties:

``` swift
var address : String!
var wif : String!
var privateKey : Data!
var publicKey : Data!
var privateKeyString : String!
var publicKeyString : String!
var neoPrivateKey : Data
```

### Methods:

#### Sign Message

``` swift
signMessage(message: String) -> String?
```

#### Verify Signature

``` swift
verifySignature(signature: String, message: String) -> Bool
```

#### Compute Shared Secret

``` swift
computeSharedSecret(publicKey: Data) -> Data?
```
and
``` swift
computeSharedSecret(publicKey: String) -> Data?
```

#### Private Encrypt

``` swift
privateEncrypt(message: String) -> String
```

#### Private Decrypt

``` swift
privateDecrypt(encrypted: String) -> String
```

#### Shared Encrypt

``` swift
sharedEncrypt(message: String, publicKey: Data) -> String
```

#### Shared Decrypt

``` swift
sharedDecrypt(encrypted: String, publicKey: Data) -> String
```

#### Export QR

``` swift
exportQR(key: KeyType, frame: CGRect = CGRect(x: 0, y: 0, width: 230, height: 230), passphrase: String = "") -> QRView
```
