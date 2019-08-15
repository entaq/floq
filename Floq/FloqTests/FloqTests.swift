//
//  FloqTests.swift
//  FloqTests
//
//  Created by Shadrach Mensah on 13/02/2019.
//  Copyright © 2019 Arun Nagarajan. All rights reserved.
//

import XCTest
@testable import Floq


class FloqTests: XCTestCase {
    
    var commentEngine:CommentEngine!

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() {
        XCTAssert(4 == 10, "Wrong Assertion")
        
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
