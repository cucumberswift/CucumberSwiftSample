/// Writes a result for the calculator's display.
public struct Display {
    public init() { }

    public func text(for value: Int) -> String {
        value < 0 ? "minus \(-value)" : "\(value)"
    }

    public func text(for error: CalculatorError) -> String {
        switch error {
            case .divisionByZero: "You can't divide by zero"
        }
    }
}
