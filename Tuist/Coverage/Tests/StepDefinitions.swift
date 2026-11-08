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
        var display = Display()
        var accumulator = Accumulator()
        var shown = ""

        // setupSteps() runs once, so reset the display and the keypad before each scenario.
        BeforeScenario { _ in
            shown = ""
            display = Display()
            accumulator = Accumulator()
        }

        Given("a calculator") { _, _ in
            // The calculator has no state. This step only reads well.
        }
        Given("the display rounds to {int} decimal places") { match, _ in
            display = Display(decimalPlaces: try match.first(\.int))
        }
        Given("the number {int} is entered") { match, _ in
            accumulator.enter(try match.first(\.int))
        }
        When("I add {int} and {int}") { match, _ in
            shown = display.text(for: calculator.add(try match.first(\.int), try match.last(\.int)))
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
        When("I get the quotient of {int} and {int}") { match, _ in
            shown = display.text(for: calculator.quotient(of: try match.first(\.int), try match.last(\.int)))
        }
        When("I double {int}") { match, _ in
            accumulator.enter(try match.first(\.int))
            shown = accumulator.doubled()
        }
        When("I triple {int}") { match, _ in
            accumulator.enter(try match.first(\.int))
            shown = accumulator.tripled()
        }
        When("I double it") { _, _ in
            shown = accumulator.doubled()
        }
        When("I triple it") { _, _ in
            shown = accumulator.tripled()
        }
        Then("the display shows {string}") { match, _ in
            XCTAssertEqual(shown, try match.first(\.string))
        }
    }
}
