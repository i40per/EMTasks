//
//  EMTasksUITestsLaunchTests.swift
//  EMTasksUITests
//
//  Created by Евгений Лукин on 21.03.2026.
//

import XCTest

final class EMTasksUITestsLaunchTests: XCTestCase {

    // MARK: - Properties
    override class var runsForEachTargetApplicationUIConfiguration: Bool {
        true
    }

    // MARK: - Lifecycle
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    // MARK: - Tests
    @MainActor
    func testLaunch() throws {
        let app = XCUIApplication()
        app.launch()

        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "Launch Screen"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
