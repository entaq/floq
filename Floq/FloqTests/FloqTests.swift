//
//  FloqTests.swift
//  FloqTests
//
//  Created by Mensah Shadrach on 04/01/2019.
//  Copyright © 2019 Arun Nagarajan. All rights reserved.
//

import XCTest

@testable import Floq

class FloqTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    
    func testDateExtensionDateByAdding24hours(){
        let date = Date()
        let date2 = Date(timeIntervalSince1970: (1546713000000 / 1000))
        XCTAssertGreaterThan(date.nextDay, date2)
    }

}
