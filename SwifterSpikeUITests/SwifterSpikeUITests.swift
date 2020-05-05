//
//  SwifterSpikeUITests.swift
//  SwifterSpikeUITests
//
//  Created by Corbin Montague on 5/5/20.
//  Copyright © 2020 Corbin. All rights reserved.
//

import Swifter
import XCTest

class SwifterSpikeUITests: XCTestCase {

    // MARK: - Properties
    
    let server = MockServer()
    
    var app: XCUIApplication!
    
    var launchEnvironment: [String: String]?
    
    struct Paths {
        static let get = "/todos/1"
        static let post = "/todos"
    }
    
    // MARK: - XCTestCase
    
    override func setUp() {
        super.setUp()
        
        // Setup the app for ui testing against localhost
        app = XCUIApplication()
        app.launchEnvironment["animations"] = "0"
        app.launchArguments.append("--uitesting")
        
        // Setup the Swifter server
        server.setUp()
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        app.launch()
    }
    
    override func tearDown() {
        server.tearDown()
        super.tearDown()
    }
    
    // MARK: - Tests
    
    func testGETSuccess() {
        server.addJSONStub(url: Paths.get, filename: "get_success", method: .GET)
        
        app.buttons["Send GET"].tap()
        
        XCTAssertTrue(app.buttons["My Mock GET Response"].waitForExistence(timeout: 5.0))
    }
    
    // TODO: testGETFailed
    
    func testPOSTSuccess() {
        server.addJSONStub(url: Paths.post, filename: "post_success", method: .POST)
        
        app.buttons["Send POST"].tap()
        
        XCTAssertTrue(app.buttons["My Mock POST Response"].waitForExistence(timeout: 5.0))
    }
    
    // TODO: testPOSTFailed
    
}
