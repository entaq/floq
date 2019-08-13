//
//  FloqUITests.swift
//  FloqUITests
//
//  Created by Shadrach Mensah on 13/02/2019.
//  Copyright © 2019 Arun Nagarajan. All rights reserved.
//

import XCTest

class FloqUITests: XCTestCase {
    
    private var application:XCUIApplication!

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        application = XCUIApplication()
        application.launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() {
        
        let app = XCUIApplication()
        app.otherElements.containing(.navigationBar, identifier:"My Cliqs").children(matching: .other).element.children(matching: .other).element.children(matching: .other).element(boundBy: 0).collectionViews.cells.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.tap()
        
        let collectionViewsQuery = app.collectionViews
        collectionViewsQuery.children(matching: .cell).element(boundBy: 0).children(matching: .other).element.children(matching: .other).element.children(matching: .other).element(boundBy: 0).tap()
        
        let cellsQuery = collectionViewsQuery.cells
        cellsQuery.children(matching: .other).element.tap()
        
        let image = cellsQuery.otherElements.children(matching: .image).element
        image.tap()
        image.tap()
        image.tap()
        image.tap()
        app.images["imageplaceholder"].tap()
        app.otherElements.containing(.navigationBar, identifier:"IIyn Payne").children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.swipeRight()
        app.navigationBars["IIyn Payne"].buttons["Back"].tap()
        app.statusBars.otherElements["82% battery power, Charging"].tap()
        
        let floqNavigationBar = app.navigationBars["Floq"]
        floqNavigationBar.buttons["Share"].tap()
        app.sheets["Save Photo"].buttons["Save"].tap()
        app.alerts["INFO"].buttons["Dismiss"].tap()
        floqNavigationBar.buttons["Heartbeat"].tap()
        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

}
