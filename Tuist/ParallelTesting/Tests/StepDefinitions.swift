import CucumberSwift
import Foundation
import XCTest

/// Stands in for a slow dependency, such as a server or the app under a UI test. Each order
/// and each delivery takes about a second, so a scenario takes about a second too: the kind
/// of scenario that parallel testing speeds up.
struct Warehouse {
    static let delay: TimeInterval = 1

    var stock = [String: Int]()

    mutating func receive(_ quantity: Int, of product: String) {
        Thread.sleep(forTimeInterval: Self.delay)
        stock[product, default: 0] += quantity
    }

    /// Takes the order if the warehouse has enough in stock.
    mutating func order(_ quantity: Int, of product: String) -> Bool {
        Thread.sleep(forTimeInterval: Self.delay)
        guard let available = stock[product], available >= quantity else { return false }
        stock[product] = available - quantity
        return true
    }
}

// CucumberSwift finds your steps through this extension. It runs setupSteps() once in each
// worker process, then runs the scenarios that Xcode hands that worker.
extension Cucumber: @retroactive StepImplementation {
    // The bundle that holds the Features folder: this test bundle.
    public var bundle: Bundle {
        class ThisBundle {}
        return Bundle(for: ThisBundle.self)
    }

    public func setupSteps() {
        // Parallel testing can also be turned on here, for every run of the target:
        //
        //     Cucumber.parallelTesting = true
        //
        // This sample sets CUCUMBER_PARALLEL_TESTING in its Parallel test plan instead, so
        // that its Serial test plan can run the same scenarios one after another.

        // State that belongs to one scenario. A worker runs a scenario's steps in order, but
        // it runs other scenarios before and after it, so reset the state before each one.
        // Nothing here is shared between scenarios: each worker is a process of its own.
        var warehouse = Warehouse()
        var accepted: Bool?
        var lastOrder = 0
        BeforeScenario { _ in
            warehouse = Warehouse()
            accepted = nil
            lastOrder = 0
        }

        Given("the warehouse has {int} {string}") { match, _ in
            warehouse = Warehouse(stock: [try match.first(\.string): try match.first(\.int)])
        }
        // A data table: the first row is the header.
        Given("the warehouse has these stock levels:") { _, step in
            var stock = [String: Int]()
            for row in try XCTUnwrap(step.dataTable).rows.dropFirst() {
                stock[row[0]] = try XCTUnwrap(Int(row[1]))
            }
            warehouse = Warehouse(stock: stock)
        }

        When("I order {int} {string}") { match, _ in
            lastOrder = try match.first(\.int)
            accepted = warehouse.order(lastOrder, of: try match.first(\.string))
        }
        When("a delivery of {int} {string} arrives") { match, _ in
            warehouse.receive(try match.first(\.int), of: try match.first(\.string))
        }

        Then("the order is accepted") { _, _ in XCTAssertEqual(accepted, true) }
        Then("the order is rejected") { _, _ in XCTAssertEqual(accepted, false) }
        Then("the warehouse has {int} {string} in stock") { match, _ in
            XCTAssertEqual(warehouse.stock[try match.first(\.string)] ?? 0, try match.first(\.int))
        }
        // Orders of up to 5 items go by post, larger ones by courier.
        Then("the order ships by {string}") { match, _ in
            XCTAssertEqual(accepted, true)
            XCTAssertEqual(lastOrder <= 5 ? "post" : "courier", try match.first(\.string))
        }
    }
}
