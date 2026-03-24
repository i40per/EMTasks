//
//  EMTasksUITests.swift
//  EMTasksUITests
//
//  Created by Евгений Лукин on 21.03.2026.
//

import XCTest

final class EMTasksUITests: XCTestCase {

    // MARK: - Lifecycle
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    // MARK: - Tests
    @MainActor
    func testAppLaunch() throws {
        let app = XCUIApplication()
        app.launch()

        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 5))
    }

    @MainActor
    func testLaunchPerformance() throws {
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }
}
