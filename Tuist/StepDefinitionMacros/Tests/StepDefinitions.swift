import CucumberSwiftMacros
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
        var cukes = 0

        // A Cucumber expression. The closure takes one argument per parameter, in order,
        // already converted: {int} gives an Int, {string} a String.
        #Given("I have {int} cukes in my {string}") { (count: Int, container: String) in
            XCTAssertFalse(container.isEmpty)
            cukes = count
        }
        #When("I eat {int} cukes") { (count: Int) in
            cukes -= count
        }

        // A last argument of type Step gives the step itself, here for its data table.
        #When("I eat these cukes:") { (step: Step) in
            let rows = try XCTUnwrap(step.dataTable?.rows, "List the cukes in a data table.")
            cukes -= rows.count
        }

        // A regular expression: it starts with ^ and ends with $. Each capture group is
        // a String argument.
        #Then("^the basket holds (\\d+) cukes?$") { (count: String) in
            XCTAssertEqual(cukes, Int(count))
        }

        // Every localized step definition has a macro of the same name, for feature files
        // in another language: #ES_Dado for "Dado", #ES_Entonces for "Entonces".
        #ES_Dado("tengo {int} pepinos en mi {string}") { (cantidad: Int, recipiente: String) in
            XCTAssertFalse(recipiente.isEmpty)
            cukes = cantidad
        }
        #ES_Entonces("la cesta tiene {int} pepinos") { (cantidad: Int) in
            XCTAssertEqual(cukes, cantidad)
        }

        // Mistakes the compiler finds. Uncomment one at a time to see its error, and where
        // there is one, the fix Xcode offers.
        //
        // The closure takes too few arguments.
        // Fix: "Change the closure's parameters to (count: Int, string: String)"
        // #Given("I have {int} cukes in my {string}") { (count: Int) in }
        //
        // An argument has the wrong type. Fix: "Change the type to Int"
        // #When("I eat {int} cukes") { (count: String) in }
        //
        // A parameter is missing its closing brace. Fix: "Insert '}'"
        // #Given("I have {int cukes") { (count: Int) in }
        //
        // Optional text, in parentheses, cannot be empty. No fix: the error says what to change.
        // #Given("I have () cukes") {}
        //
        // The $ makes the pattern a regular expression, and {int} is not valid in one.
        // Fix: "Use it as a Cucumber Expression", which removes the $
        // #Then("the basket holds {int} cukes$") { (count: Int) in }
        //
        // The pattern must be a string literal. Swift reports that a String is not a
        // StaticString. No fix: write the pattern out.
        // let thing = "cukes"
        // #Given("I have \(thing)") {}
    }
}
