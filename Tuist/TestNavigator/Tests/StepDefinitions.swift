import CucumberSwift
import XCTest

extension Cucumber: @retroactive StepImplementation {
    public var bundle: Bundle {
        class ThisBundle {}
        return Bundle(for: ThisBundle.self)
    }

    public func setupSteps() {
        checkoutSteps()
        searchSteps()
        cartSteps()
        accountSteps()
    }

    // Checkout.feature
    private func checkoutSteps() {
        var items = 0
        var discount = ""
        Given("a cart with {int} item(s)") { match, _ in items = try match.first(\.int) }
        When("I pay with my saved card") { _, _ in }
        When("I pay with a gift card") { _, _ in }
        // Deliberately buggy, so "Apply a discount code" fails: the code is remembered
        // but never taken off the total.
        When("I apply the discount code {string}") { match, _ in discount = try match.first(\.string) }
        Then("I see the discount {string}") { match, _ in XCTAssertEqual(discount, try match.first(\.string)) }
        // Throwing XCTSkip skips the rest of the scenario.
        Given("the card terminal is offline") { _, _ in throw XCTSkip("The card terminal is offline") }
        Then("the order total is {int}") { match, _ in
            XCTAssertEqual(items * 10, try match.first(\.int), "order total")
        }
        Given("a user {word} with role {word}") { _, _ in }
        When("they sign in") { _, _ in }
        Then("they can pay") { _, _ in }
    }

    // Search.feature
    private func searchSteps() {
        var catalogue = [String]()
        var results = [String]()
        Given("the catalogue has a product named {string}") { match, _ in catalogue = [try match.first(\.string)] }
        When("I search for {string}") { match, _ in
            let query = try match.first(\.string).lowercased()
            results = catalogue.filter { $0.lowercased().contains(query) }
        }
        Then("I see {int} result(s)") { match, _ in XCTAssertEqual(results.count, try match.first(\.int)) }
    }

    // Cart.feature
    private func cartSteps() {
        var cart = [String: Int]()
        var message = ""
        func add(_ quantity: Int, of product: String) {
            guard cart.values.reduce(0, +) + quantity <= 10 else { message = "Your cart is full"; return }
            cart[product, default: 0] += quantity
        }
        Given("an empty cart") { _, _ in cart = [:]; message = "" }
        When("I add {int} {string}") { match, _ in add(try match.first(\.int), of: try match.first(\.string)) }
        When("I try to add {int} {string}") { match, _ in add(try match.first(\.int), of: try match.first(\.string)) }
        // A data table: the first row is the header.
        When("I add these products:") { _, step in
            for row in try XCTUnwrap(step.dataTable).rows.dropFirst() {
                add(try XCTUnwrap(Int(row[1])), of: row[0])
            }
        }
        Then("the cart has {int} item(s)") { match, _ in
            XCTAssertEqual(cart.values.reduce(0, +), try match.first(\.int))
        }
        Then("the cart contains {string}") { match, _ in XCTAssertNotNil(cart[try match.first(\.string)]) }
        Then("the cart does not contain {string}") { match, _ in XCTAssertNil(cart[try match.first(\.string)]) }
        Then("I am told {string}") { match, _ in XCTAssertEqual(message, try match.first(\.string)) }
    }

    // Account.feature
    private func accountSteps() {
        var password = ""
        var terms = ""
        Given("I sign up with the password {string}") { match, _ in password = try match.first(\.string) }
        Then("my password is {word}") { match, _ in
            XCTAssertEqual(password.count >= 12 ? "accepted" : "rejected", try match.first(\.word))
        }
        // A doc string: the text between the """ lines.
        Given("the terms say:") { _, step in terms = try XCTUnwrap(step.docString).literal }
        Then("the terms have {int} lines") { match, _ in
            XCTAssertEqual(terms.split(separator: "\n").count, try match.first(\.int))
        }
    }
}
