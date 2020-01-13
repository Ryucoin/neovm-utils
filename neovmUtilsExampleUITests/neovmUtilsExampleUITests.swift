//
//  neovmUtilsExampleUITests.swift
//  neovmUtilsExampleUITests
//
//  Created by Wyatt Mufson on 2/19/19.
//  Copyright © 2020 Ryu Blockchain Technologies. All rights reserved.
//

import XCTest

class neovmUtilsExampleUITests: XCTestCase {
    var app: XCUIApplication!

    override func setUp() {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testQR() {
        let expectation = XCTestExpectation(description: "Test qr")
        XCUIApplication().buttons["Generate"].tap()
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 5.1)
    }
}
