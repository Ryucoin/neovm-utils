//
//  OntMonitorTests.swift
//  neovmUtils_Tests
//
//  Created by Wyatt Mufson on 10/2/19.
//  Copyright © 2019 Ryu Blockchain Technologies. All rights reserved.
//

import XCTest

class OntMonitorTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testOntMonitor() {
        let exp = expectation(description: "Ont monitor")
        let monitor = OntMonitor.shared
        let blockHeight = monitor.blockHeight
        XCTAssertEqual(blockHeight, 0)

        func finish(_ monitor: OntMonitor, _ num: Int, _ exp: XCTestExpectation) {
            print("Found new height #\(num): \(monitor.blockHeight)")
            print("TPS: \(monitor.tps)")
            print("Block time: \(monitor.blockTime)")
            print("Since last block: \(monitor.sinceLastBlock)")
            print("Status: \(monitor.currentState.name)")
            exp.fulfill()
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            let blockHeight2 = monitor.blockHeight
            if blockHeight == blockHeight2 {
                DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                    let blockHeight3 = monitor.blockHeight
                    if blockHeight == blockHeight3 {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                            let blockHeight4 = monitor.blockHeight
                            if blockHeight == blockHeight4 {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                                    let blockHeight5 = monitor.blockHeight
                                    if blockHeight == blockHeight5 {
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                                            let blockHeight6 = monitor.blockHeight
                                            if blockHeight == blockHeight6 {
                                                XCTFail("No block in 30 seconds")
                                            } else {
                                                finish(monitor, 6, exp)
                                            }
                                        }
                                    } else {
                                        finish(monitor, 5, exp)
                                    }
                                }
                            } else {
                                finish(monitor, 4, exp)
                            }
                        }
                    } else {
                        finish(monitor, 3, exp)
                    }
                }
            } else {
                finish(monitor, 2, exp)
            }
        }
        wait(for: [exp], timeout: 35)
    }
}
