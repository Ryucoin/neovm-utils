# OntMonitor

Implemented in [OntMonitor.swift](https://github.com/Ryucoin/neovm-utils/blob/master/neovmUtils/Classes/OntMonitor.swift)

Implements a websocket connection to https://monitor.ryu.games as outlined in the [OntMonitor GitHub README](https://github.com/Ryucoin/OntMonitor/blob/master/README.md).

You can access the OntMonitor through the singleton (and initialize the socket the first time it is instantiated):

``` swift
let monitor = OntMonitor.shared
```

The available properties are:

``` swift
public var blockHeight: Int = 0
public var elapsedTime: Int = 0
public var previous: Int = 0
public var totalTx: Int = 0
public var tps: Double = 0
public var blockTime: Double = 0
```
