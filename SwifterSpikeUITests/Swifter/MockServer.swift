//
//  MockServer.swift
//  SwifterSpikeUITests
//
//  Created by Corbin Montague on 5/5/20.
//  Copyright © 2020 Corbin. All rights reserved.
//

import Foundation
import Swifter

// MARK: - HTTPMethod

enum HTTPMethod {
    case POST
    case GET
    case PUT
}

// MARK: - HTTPStubInfo

struct HTTPStubInfo {
    let url: String
    let jsonFilename: String
    let method: HTTPMethod
}

// MARK: - MockServer

/// Encapsulates a Swifter `HttpServer`. Allows you to stub `URLRequest`s when running tests.
class MockServer {
    
    /// Swifter tiny http server
    var server: HttpServer = {
        let server = HttpServer()
        return server
    }()
    
    /// The port this server is running on
    var port: in_port_t?
    
    /// Place responses here for standard (REST) API calls.
    /// Use this to setup global stubs.
    let initialStubs: [HTTPStubInfo] = []
    
    /// Start up the Swifter tiny http server
    func setUp() {
        setupInitialStubs()
        startServer()
    }
    
    /// Stop the Swifter tiny http server
    func tearDown() {
        server.stop()
    }
    
    /// Stub the specified url with the provided JSON.
    /// - Parameters:
    ///   - url: The url to stub.
    ///   - filename: A file containing JSON to return when a URLRequest against `url` is intercepted.
    ///   - method: The HTTPMethod to stub against.
    func addJSONStub(url: String, filename: String, method: HTTPMethod) {
        let testBundle = Bundle(for: type(of: self))
        let filePath = testBundle.path(forResource: filename, ofType: "json")
        let fileUrl = URL(fileURLWithPath: filePath!)
        let data = try! Data(contentsOf: fileUrl, options: .uncached)
        
        // Looking for a file and converting it to JSON
        let json = dataToJSON(data: data)
        
        // Swifter makes it very easy to create stubbed responses
        let response: ((HttpRequest) -> HttpResponse) = { _ in
            return HttpResponse.ok(.json(json as AnyObject))
        }
        
        switch method  {
        case .GET : server.GET[url] = response
        case .POST: server.POST[url] = response
        case .PUT: server.PUT[url] = response
        }
    }
    
    /// Adds a new stub for the given url and method with a custom request handler
    /// - Parameters:
    ///   - url: The url to stub.
    ///   - method: The HTTPMethod to stub against.
    ///   - requestHandler: The HttpResponse to return when a URLRequest against `url` is intercepted.
    func addStub(url: String, method: HTTPMethod, requestHandler: @escaping ((HttpRequest) -> HttpResponse)) {
        switch method {
        case .GET:
            server.GET[url] = requestHandler
        case .POST:
            server.POST[url] = requestHandler
        case .PUT:
            server.PUT[url] = requestHandler
        }
    }
    
    // MARK: - Helpers
    
    /// Start the HTTP server on the specified port number, in case of the port number
    /// is being used it would try to find another free port.
    ///
    /// - Parameters:
    ///   - port: The port number to start the server
    ///   - maximumOfAttempts: The maximum number of attempts to find an unused port
    private func startServer(port: in_port_t = 8080, maximumOfAttempts: Int = 5) {
        // Stop the retrying when the attempts is zero
        if maximumOfAttempts == 0 {
            return
        }
        
        do {
            try server.start(port)
            self.port = port
            print("Server has started ( port = \(try server.port()) ). Try to connect now...")
        } catch SocketError.bindFailed(let message) where message == "Address already in use" {
            startServer(port: in_port_t.random(in: 8081..<10000), maximumOfAttempts: maximumOfAttempts - 1)
        } catch {
            print("Server start error: \(error)")
        }
    }
    
    
    /// Setup initial stubs.
    /// Use this to setup global stubs.
    private func setupInitialStubs() {
        for stub in initialStubs {
            addJSONStub(url: stub.url, filename: stub.jsonFilename, method: stub.method)
        }
    }
    
    /// Attempt to convert the provided `Data` to JSON.
    private func dataToJSON(data: Data) -> Any? {
        do {
            return try JSONSerialization.jsonObject(with: data, options: .mutableContainers)
        } catch let myJSONError {
            print(myJSONError)
        }
        return nil
    }
}
