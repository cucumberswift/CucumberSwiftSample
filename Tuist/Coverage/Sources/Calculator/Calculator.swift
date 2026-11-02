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

    /// Names a number. One scenario classifies one number, so it covers one of the six cases.
    public func classify(_ value: Int) -> String {
        switch value {
            case ..<0: "negative"
            case 0: "zero"
            case 1...9: "small"
            case 10...99: "medium"
            case 100...999: "large"
            default: "huge"
        }
    }

    /// No scenario calls this, so a report shows it as not covered.
    public func squareRoot(of value: Double) -> Double {
        value < 0 ? .nan : value.squareRoot()
    }
}
