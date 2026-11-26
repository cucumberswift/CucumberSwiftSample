/// A shopping basket: 10% off from 3 items, and free shipping over 100.
public final class Basket {
    public private(set) var prices = [Int]()
    public private(set) var isSaved = false

    public init() {}

    public func add(_ price: Int) {
        prices.append(price)
    }

    public func add(contentsOf more: [Int]) {
        // cucumberswift:mutation-ignore - reserving capacity changes speed, not results
        prices.reserveCapacity(prices.count + more.count)
        prices.append(contentsOf: more)
    }

    public var total: Int {
        let sum = prices.reduce(0, +)
        // Takes 10% off when the basket has 3 or more items. Integer division rounds the result down.
        let discounted = prices.count >= 3 ? sum * 9 / 10 : sum
        return discounted > 100 ? discounted : discounted + 5
    }

    public func checkout() {
        guard !prices.isEmpty else { return }
        isSaved = true
    }

    /// No scenario prints a receipt: a coverage gap, so mutation testing leaves its mutant out of the score.
    public func receipt() -> String {
        prices.isEmpty ? "Nothing to pay" : "Total: \(total)"
    }
}
