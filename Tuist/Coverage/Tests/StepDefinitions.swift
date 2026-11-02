import Account
import Calculator
import CucumberSwift
import XCTest

// CucumberSwift finds your steps through this extension. It runs setupSteps() once,
// then runs each scenario in the bundle's feature files as a test.
extension Cucumber: @retroactive StepImplementation {
    // The bundle that holds the Features folder: this test bundle.
    public var bundle: Bundle {
        class ThisBundle {}
        return Bundle(for: ThisBundle.self)
    }

    public func setupSteps() {
        let calculator = Calculator()
        let display = Display()
        let user = User(username: "ada", balance: 120)
        var shown = ""
        var session = Session()
        var menu = ProfileMenu(session: session)

        // setupSteps() runs once, so clear the display and log out before each scenario.
        BeforeScenario { _ in
            shown = ""
            session = Session()
            menu = ProfileMenu(session: session)
        }

        Given("a calculator") { _, _ in
            // The calculator has no state. This step only reads well.
        }
        When("I add {int} and {int}") { match, _ in
            shown = display.text(for: calculator.add(try match.first(\.int), try match.last(\.int)))
        }
        When("I subtract {int} from {int}") { match, _ in
            shown = display.text(for: calculator.subtract(try match.last(\.int), try match.first(\.int)))
        }
        When("I divide {int} by {int}") { match, _ in
            do {
                shown = display.text(for: try calculator.divide(try match.first(\.int), by: try match.last(\.int)))
            } catch let error as CalculatorError {
                shown = display.text(for: error)
            }
        }
        When("I classify {int}") { match, _ in
            shown = calculator.classify(try match.first(\.int))
        }
        Then("the display shows {string}") { match, _ in
            XCTAssertEqual(shown, try match.first(\.string))
        }

        // The profile menu's steps. ProfileMenu.feature's click steps each open the menu before
        // they show an item, so both run the code that opens it. ProfileMenu-optimized.feature
        // opens it in the Background, and its view steps only show an item.
        Given("the user is logged in") { _, _ in
            session.logIn(user)
        }
        Given("the user's profile menu is open") { _, _ in
            try menu.open()
        }
        When("I click my user profile") { _, _ in
            try menu.open()
            shown = try menu.profile()
        }
        When("I click my account") { _, _ in
            try menu.open()
            shown = try menu.account()
        }
        When("I view my user profile") { _, _ in
            shown = try menu.profile()
        }
        When("I view my account") { _, _ in
            shown = try menu.account()
        }
        Then("I should see my username") { _, _ in
            XCTAssertEqual(shown, user.username)
        }
        Then("I should see my balance") { _, _ in
            XCTAssertEqual(shown, "$\(user.balance)")
        }
    }
}
