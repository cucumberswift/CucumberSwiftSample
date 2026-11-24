/// The number on the calculator's keypad, which a scenario enters before it works on it.
public final class Accumulator {
    private var number = 0

    public init() { }

    /// Enters a number one digit at a time, as a person would key it in.
    public func enter(_ value: Int) {
        guard value >= 0 else { return }
        number = 0
        for digit in String(value) {
            number = number * 10 + (digit.wholeNumberValue ?? 0)
        }
    }

    public func doubled() -> String {
        "\(number * 2)"
    }

    public func tripled() -> String {
        "\(number * 3)"
    }
}
