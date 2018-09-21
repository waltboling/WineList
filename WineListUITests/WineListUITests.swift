//
//  WineListUITests.swift
//  WineListUITests
//
//  Created by Jon Boling on 8/7/18.
//  Copyright © 2018 Walt Boling. All rights reserved.
//

import XCTest

class WineListUITests: XCTestCase {
        
    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    
    
    
    
    /*func testPhotoTools() {
        let app = XCUIApplication()
        app.buttons["Add New Wine"].tap()
        XCUIDevice.shared.orientation = .portrait
        XCUIDevice.shared.orientation = .faceUp
        
        let snapPhotoButton = app/*@START_MENU_TOKEN@*/.buttons["Snap Photo"]/*[[".scrollViews.buttons[\"Snap Photo\"]",".buttons[\"Snap Photo\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
        snapPhotoButton.tap()
        app/*@START_MENU_TOKEN@*/.buttons["Retake"]/*[[".scrollViews.buttons[\"Retake\"]",".buttons[\"Retake\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        snapPhotoButton.tap()
        XCUIDevice.shared.orientation = .faceUp
        
    }*/
    
    func testSaveWine() {
        XCUIDevice.shared.orientation = .faceUp
        
        let app = XCUIApplication()
        let wineName = app.scrollViews.textFields["wineNameTextField"]
        let newItem = app.staticTexts["test example"]
        let exists = NSPredicate(format: "exists == true")
        expectation(for: exists, evaluatedWith: newItem, handler: nil)
        
        app.buttons["Add New Wine"].tap()
        XCUIDevice.shared.orientation = .portrait
        XCUIDevice.shared.orientation = .faceUp
        app/*@START_MENU_TOKEN@*/.buttons["Snap Photo"]/*[[".scrollViews.buttons[\"Snap Photo\"]",".buttons[\"Snap Photo\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        wineName.tap()
        wineName.typeText("test example")
        
        app.scrollViews.buttons["Save Wine"].tap()
        
        app.buttons["Go To WineList"].tap()
        waitForExpectations(timeout: 5, handler: nil)
        XCTAssert(newItem.exists)
        
        //app.tables/*@START_MENU_TOKEN@*/.staticTexts["example 1"]/*[[".cells.staticTexts[\"example 1\"]",".staticTexts[\"example 1\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        //app.navigationBars["WineList.WineDetailVC"].buttons["WineList"].tap()
        
        
    }
    
    func testSearchBar() {
        
    }
    
}
