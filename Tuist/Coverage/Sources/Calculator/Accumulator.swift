/// The number on the calculator's keypad, which a scenario enters before it works on it.
public final class Accumulator {
    private var digits: [Int] = []

    public init() { }

    /// Enters a number one digit at a time, as a person would key it in.
    public func enter(_ number: Int) {
        guard number >= 0 else { return }
        digits = []
        for digit in String(number) {
            digits.append(digit.wholeNumberValue ?? 0)
        }
    }

    public func doubled() -> Int {
        value * 2
    }

    public func tripled() -> Int {
        value * 3
    }

    private var value: Int {
        digits.reduce(0) { $0 * 10 + $1 }
    }
}
