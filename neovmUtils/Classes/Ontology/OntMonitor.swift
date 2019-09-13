//
//  OntMonitor.swift
//  neovmUtils
//
//  Created by Wyatt Mufson on 5/22/19.
//  Copyright © 2019 Ryu Blockchain Technologies. All rights reserved.
//

import UIKit
import SocketIO

final public class OntMonitor: NSObject {
    public static let shared = OntMonitor()
    public var blockHeight: Int = 0
    public var elapsedTime: Int = 0
    public var previous: Int = 0
    public var totalTx: Int = 0
    public var tps: Double = 0
    public var blockTime: Double = 0
    public var sinceLastBlock: Double = 0

    public var currentState: OMState = .Calculating

    private var manager: SocketManager!
    private let monitorString: String = "https://monitor.ryu.games"

    override init() {
        super.init()
        self.manager = SocketManager(socketURL: URL(string: self.monitorString)!, config: [.log(false), .compress])
        let socket = self.manager.defaultSocket
        socket.on("StatUpdate") {data, _ in
            if let event = data[0] as? [String: Any]{
                self.blockHeight = event["latest"] as? Int ?? 0
                self.elapsedTime = event["elapsedTime"] as? Int ?? 0
                self.previous = event["previous"] as? Int ?? 0
                self.totalTx = event["totalTransactions"] as? Int ?? 0
                self.tps = (event["txPerSecond"] as? Double ?? 0).rounded(to: 2)
                self.blockTime = (event["blockTime"] as? Double ?? 0).rounded(to: 2)
                self.sinceLastBlock = (event["sinceLastBlock"] as? Double ?? 0).rounded(to: 2)

                if self.sinceLastBlock > 120 {
                    self.currentState = .Dead
                } else if self.sinceLastBlock > 35 {
                    self.currentState = .Lagging
                } else if self.sinceLastBlock > self.blockTime + 2 {
                    self.currentState = .Slow
                } else {
                    self.currentState = .Fast
                }
            }
        }
        socket.connect()
    }
}

public enum OMState: String {
    case Calculating
    case Fast
    case Slow
    case Lagging
    case Dead

    public var name: String {
        return self.rawValue
    }
}

fileprivate extension Double {
    func rounded(to places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}
