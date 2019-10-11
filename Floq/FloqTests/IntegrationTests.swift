//
//  IntegrationTests.swift
//  FloqTests
//
//  Created by Shadrach Mensah on 10/10/2019.
//  Copyright © 2019 Arun Nagarajan. All rights reserved.
//

import XCTest
@testable import Floq

class IntegrationTests: XCTestCase {
    
    var service:DataService!

    override func setUp() {
        service = DataService.main
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testisRegistered() {
        let expectation = self.expectation(description: "isRegistered")
        var isRegistered:Bool?
        service.isRegistered(uid: "0fcW6IPQCgSL7DgocL5uh5s040i1") { (bool, id) in
            isRegistered = bool
            
            expectation.fulfill()
        }
        waitForExpectations(timeout: 20, handler: nil)
        XCTAssertNotNil(isRegistered)
        XCTAssertTrue(isRegistered!)
    }
    
    
    func test_isNotRegistered(){
        let expectation = self.expectation(description: "isRegistered")
        var isRegistered:Bool?
        service.isRegistered(uid: "id") { (bool, id) in
            isRegistered = bool
            
            expectation.fulfill()
        }
        waitForExpectations(timeout: 20, handler: nil)
        XCTAssertNotNil(isRegistered)
        XCTAssertFalse(isRegistered!)
    }
    
    

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
