# Wallet

Implemented in [Wallet.swift](https://github.com/Ryucoin/neovm-utils/blob/master/neovmUtils/Classes/Wallet.swift)

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
- [Helpers](#helpers)
  - [keyType](#key-type)
  - [newWallet](#new-wallet)
  - [newWalletMnemonicPair](#new-wallet-mnemonic-pair)
  - [walletFromWIF](#wallet-from-wif)
  - [walletFromPrivateKey](#wallet-from-privatekey)
  - [newEncryptedKey](#new-encryptedkey)
  - [wifFromEncryptedKey](#wif-from-encryptedkey)
  - [addressFromWif](#address-from-wif)
  - [publicKeyFromWif](#publickey-from-wif)
  - [publicKeyFromPrivateKey](#PublicKey-from-privatekey)
  - [walletFromMnemonicPhrase](#wallet-from-mnemonic-phrase)

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

Signs a message using ECDSA encryption

``` swift
signMessage(message: String) -> String?
```

#### Verify Signature

Verifies a signature for a given public key using ECDSA

``` swift
verifySignature(pubKey: Data, signature: String, message: String) -> Bool
```

#### Compute Shared Secret

Creates a shared secret with another public key using ECDH

``` swift
computeSharedSecret(publicKey: Data) -> Data?
```
and
``` swift
computeSharedSecret(publicKey: String) -> Data?
```

#### Private Encrypt

Encrypts a message using AES

``` swift
privateEncrypt(message: String) -> String
```

#### Private Decrypt

Decrypts a message using AES

``` swift
privateDecrypt(encrypted: String) -> String
```

#### Shared Encrypt

Encrypts a message using AES with an ECDH shared secret for a given public key

``` swift
sharedEncrypt(message: String, publicKey: Data) -> String
```

#### Shared Decrypt

Decrypts a message using AES with an ECDH shared secret for a given public key

``` swift
sharedDecrypt(encrypted: String, publicKey: Data) -> String
```

#### Export QR

Creates a QR code view for the given key (see [keyType](#key-type) for more information). If `key` is `.NEP2` then the optional `passphrase` argument to `exportQR` should be used, otherwise it should be ignored.

``` swift
exportQR(key: KeyType, frame: CGRect = CGRect(x: 0, y: 0, width: 230, height: 230), passphrase: String = "") -> QRView
```

### Helpers

#### Key Type
``` swift
public enum KeyType {
  case PrivateKey
  case NEOPrivateKey
  case NEP2
  case WIF
  case Address
  case PublicKey
}
```

#### New Wallet

Creates a new `Wallet`

``` swift
newWallet() -> Wallet
```

#### New Wallet Mnemonic Pair

Creates a new `Wallet` and corresponding `Mnemonic`

``` swift
newWalletMnemonicPair() -> (Wallet, Mnemonic)
```

#### Wallet From WIF

Creates a new `Wallet` from a given wif, `nil` if the wif is invalid.

``` swift
walletFromWIF(wif: String) -> Wallet?
```

#### Wallet From PrivateKey

Creates a new `Wallet` from a given private key, `nil` if the private key is invalid. Works with both Ontology and NEO style private keys.

``` swift
walletFromPrivateKey(privateKey: Data) -> Wallet?
```
and
``` swift
walletFromPrivateKey(privateKey: String) -> Wallet?
```

#### New EncryptedKey

Creates a new `NEP2` encrypted key

``` swift
newEncryptedKey(wif: String, password: String) -> String?
```

#### WIF From EncryptedKey

Creates a wif from a given `NEP2` encrypted key

``` swift
wifFromEncryptedKey(encrypted: String, password: String) -> String?
```

#### Address From WIF

Gets an address from a wif

``` swift
addressFromWif(wif: String) -> String?
```

#### PublicKey From WIF

Gets a public key from a wif

``` swift
publicKeyFromWif(wif: String) -> String?
```

#### PublicKey From PrivateKey

Gets a public key from a private key

``` swift
publicKeyFromPrivateKey(privateKey: String) -> String?
```

#### Wallet From Mnemonic Phrase

Creates a `Wallet` from a given mnemonic phrase

``` swift
walletFromMnemonicPhrase(mnemonic: String) -> Wallet?
```
