//
//  MockServer.swift
//  SwifterSpikeUITests
//
//  Created by Corbin Montague on 5/5/20.
//  Copyright © 2020 Corbin. All rights reserved.
//

import Foundation
import Swifter

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

// Place responses here for standard (REST) API calls.
let initialStubs: [HTTPStubInfo] = []

class MockServer {
    
    var server: HttpServer = {
        let server = HttpServer()
        return server
    }()
    
    func setUp() {
        setupInitialStubs()
        try! server.start(8080)
        
    }
    
    func tearDown() {
        server.stop()
    }
    
    func setupInitialStubs() {
        for stub in initialStubs {
            addJSONStub(url: stub.url, filename: stub.jsonFilename, method: stub.method)
        }
    }
    
    func addJSONStub(url: String, filename: String, method: HTTPMethod = .GET) {
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
    func addStub(url: String, method: HTTPMethod = .GET, requestHandler: @escaping ((HttpRequest) -> HttpResponse)) {
        switch method {
        case .GET:
            server.GET[url] = requestHandler
        case .POST:
            server.POST[url] = requestHandler
        case .PUT:
            server.PUT[url] = requestHandler
        }
    }
    
    func dataToJSON(data: Data) -> Any? {
        do {
            return try JSONSerialization.jsonObject(with: data, options: .mutableContainers)
        } catch let myJSONError {
            print(myJSONError)
        }
        return nil
    }
}
