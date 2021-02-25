//
//  UBBUITests.swift
//  UBBUITests
//
//  Created by Dimitrie-Toma Furdui on 24.02.2021.
//

import XCTest

class UBBUITests: XCTestCase {

    override func setUpWithError() throws {
        self.continueAfterFailure = false
    }

    override func tearDownWithError() throws {
        
    }

    func testScreenshots() throws {
        let app = XCUIApplication()
        app.launch()
        setupSnapshot(app)
        
        let tabBar = app.tabBars["Tab Bar"]
        tabBar.buttons["Settings"].tap()
        let tablesQuery = app.tables
        tablesQuery.buttons.element(matching: NSPredicate(format: "(label BEGINSWITH[cd] %@)", "Year")).tap()
        tablesQuery.buttons["Year 1 (IE1)"].tap()
        tablesQuery.buttons["Group "].tap()
        tablesQuery.buttons["913"].tap()
        tablesQuery.buttons["Semigroup "].tap()
        tablesQuery.buttons["2"].tap()
        snapshot("02Settings")
        app.tabBars["Tab Bar"].buttons["Timetable"].tap()
        snapshot("01Timetable")
    }
}
