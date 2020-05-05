//
//  SwifterPOSTTests.swift
//  SwifterSpikeUITests
//
//  Created by Corbin Montague on 5/5/20.
//  Copyright © 2020 Corbin. All rights reserved.
//

import Swifter
import XCTest

class SwifterPOSTTests: XCTestCase {

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
        
        // Setup the Swifter server
        server.setUp()
        
        // Setup the app for ui testing against localhost
        app = XCUIApplication()
        app.launchEnvironment["animations"] = "0"
        app.launchArguments.append("--uitesting")
        
        if let port = server.port {
            app.launchArguments.append("--port:\(port)")
        }
        
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
    
    func testPOST_success() {
        server.addJSONStub(url: Paths.post, filename: "post_success", method: .POST)
        
        app.buttons["Send POST"].tap()
        
        XCTAssertTrue(app.buttons["My Mock POST Response"].waitForExistence(timeout: 5.0))
    }
    
    func testPOST_internalServerError() {
        server.addStub(url: Paths.post, method: .POST) { _ in
            return HttpResponse.internalServerError
        }

        app.buttons["Send POST"].tap()

        XCTAssertTrue(app.buttons["POST Request Failed: \(HttpResponse.internalServerError.statusCode)"].waitForExistence(timeout: 5.0))
    }
    
    func testPOST_notFound() {
        server.addStub(url: Paths.post, method: .POST) { _ in
            return HttpResponse.notFound
        }

        app.buttons["Send POST"].tap()

        XCTAssertTrue(app.buttons["POST Request Failed: \(HttpResponse.notFound.statusCode)"].waitForExistence(timeout: 5.0))
    }
    
    func testPOST_forbidden() {
        server.addStub(url: Paths.post, method: .POST) { _ in
            return HttpResponse.forbidden
        }

        app.buttons["Send POST"].tap()

        XCTAssertTrue(app.buttons["POST Request Failed: \(HttpResponse.forbidden.statusCode)"].waitForExistence(timeout: 5.0))
    }
    
    func testPOST_badJSON() {
        server.addJSONStub(url: Paths.post, filename: "post_badJSON", method: .POST)
        
        app.buttons["Send POST"].tap()
        
        XCTAssertTrue(app.buttons["POST Request Failed: Bad JSON"].waitForExistence(timeout: 5.0))
    }
    
}
