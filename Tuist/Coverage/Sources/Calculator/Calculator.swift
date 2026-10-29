public enum CalculatorError: Error, Equatable {
    case divisionByZero
}

/// The code that the scenarios cover.
public struct Calculator {
    public init() { }

    public func add(_ first: Int, _ second: Int) -> Int {
        first + second
    }

    public func subtract(_ first: Int, _ second: Int) -> Int {
        first - second
    }

    public func divide(_ first: Int, by second: Int) throws -> Int {
        guard second != 0 else {
            throw CalculatorError.divisionByZero
        }
        return first / second
    }

    /// No scenario calls this, so a report shows it as not covered.
    public func squareRoot(of value: Double) -> Double {
        value < 0 ? .nan : value.squareRoot()
    }
}
