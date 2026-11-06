import CucumberSwift
import Foundation
import Shop
import XCTest

// CucumberSwift finds your steps through this extension. It runs setupSteps() once,
// then runs each scenario in the bundle's feature files as a test.
extension Cucumber: @retroactive StepImplementation {
    // The bundle that holds the Features folder: the test bundle in Xcode, and the resource bundle that
    // SwiftPM makes for mutation testing, which runs on the package.
    public var bundle: Bundle {
        #if SWIFT_PACKAGE
        return Bundle.module
        #else
        class ThisBundle {}
        return Bundle(for: ThisBundle.self)
        #endif
    }

    public func setupSteps() {
        // Turns mutation testing on once `swift run cucumberswift-mutation-test` has written its report to
        // .build/mutation-testing: each feature's Coverage scores then have a Mutation test, which fails if a
        // scenario passes with the code changed. It needs the tests to run with code coverage, as both schemes
        // do. See README.md.
        let sample = URL(fileURLWithPath: #filePath).deletingLastPathComponent().deletingLastPathComponent()
        let report = sample.appendingPathComponent(".build/mutation-testing/mutation-report.json")
        if FileManager.default.fileExists(atPath: report.path) {
            Cucumber.mutationTesting = true
            Cucumber.mutationReport = report.path
        }

        var basket = Basket()
        BeforeScenario { _ in
            basket = Basket()
        }

        // {int} captures a whole number, and match.allParameters(\.int) reads every one back as an Int.
        Given("an empty basket") { _, _ in
            // The basket that BeforeScenario made is empty.
        }
        Given("a basket with items costing {int} and {int}") { match, _ in
            basket.add(contentsOf: try match.allParameters(\.int))
        }
        Given("a basket with items costing {int}, {int} and {int}") { match, _ in
            for price in try match.allParameters(\.int) {
                basket.add(price)
            }
        }
        When("I check out") { _, _ in
            basket.checkout()
        }
        Then("the total is {int}") { match, _ in
            XCTAssertEqual(basket.total, try match.first(\.int))
        }
        Then("the total is at least {int}") { match, _ in
            XCTAssertGreaterThanOrEqual(basket.total, try match.first(\.int))
        }
        Then("the basket is saved") { _, _ in
            XCTAssertTrue(basket.isSaved)
        }
        Then("the basket isn't saved") { _, _ in
            XCTAssertFalse(basket.isSaved)
        }
    }
}
