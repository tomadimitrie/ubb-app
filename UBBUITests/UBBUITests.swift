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
        app.launchArguments += ["test"]
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
        
        for (name, color) in [
            ("Course", "85D2FF"),
            ("Seminar", "0AA5FF"),
            ("Lab", "0067A3")
        ] {
            tablesQuery.otherElements["\(name) color"].children(matching: .button).element.tap()
            let scrollViewsQuery = app.scrollViews
            let elementsQuery = scrollViewsQuery.otherElements
            let slidersButton = elementsQuery.buttons["Sliders"]
            slidersButton.tap()
            let textField = scrollViewsQuery.otherElements.containing(.button, identifier:"Floating color picker").children(matching: .textField).element(boundBy: 3)
            textField.tap()
            for _ in 0...5 {
                textField.typeText(XCUIKeyboardKey.delete.rawValue)
            }
            textField.typeText(color)
            let closeButton = elementsQuery.buttons["close"]
            closeButton.tap()
        }
        snapshot("02Settings")
        app.tabBars["Tab Bar"].buttons["Timetable"].tap()
        snapshot("01Timetable")
        app.navigationBars["Timetable"].buttons["Edit"].tap()
        snapshot("03Edit")
    }
}
