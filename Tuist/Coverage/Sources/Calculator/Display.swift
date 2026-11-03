import Foundation

/// Writes a result for the calculator's display.
public struct Display {
    private let decimalPlaces: Int

    public init(decimalPlaces: Int = 0) {
        self.decimalPlaces = decimalPlaces
    }

    public func text(for value: Int) -> String {
        value < 0 ? "minus \(-value)" : "\(value)"
    }

    public func text(for value: Double) -> String {
        let digits = String(format: "%.\(decimalPlaces)f", abs(value))
        if value < 0 {
            return "minus \(digits)"
        }
        return digits
    }

    public func text(for error: CalculatorError) -> String {
        switch error {
            case .divisionByZero: "You can't divide by zero"
        }
    }
}
