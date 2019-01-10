//
//  PhotoEngineTests.swift
//  FloqTests
//
//  Created by Mensah Shadrach on 10/01/2019.
//  Copyright © 2019 Arun Nagarajan. All rights reserved.
//

import XCTest
@testable import Floq
class PhotoEngineTests: XCTestCase {
    var photoEngine:PhotoEngine!
    override func setUp() {
        photoEngine = PhotoEngine()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        photoEngine = nil
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    

    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
