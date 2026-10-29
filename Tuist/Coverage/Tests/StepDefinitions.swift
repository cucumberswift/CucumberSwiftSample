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
        var shown = ""

        // setupSteps() runs once, so clear the display before each scenario.
        BeforeScenario { _ in
            shown = ""
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
        Then("the display shows {string}") { match, _ in
            XCTAssertEqual(shown, try match.first(\.string))
        }
    }
}
