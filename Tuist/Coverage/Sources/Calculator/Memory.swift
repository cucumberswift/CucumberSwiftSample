/// The calculator's memory: 3 slots that start at 0. Reading and clearing both open the memory
/// first, so their steps run the same code to open it, and get a redundant step warning.
public final class Memory {
    static let slotCount = 3
    private var slots: [Int] = []

    public init() { }

    /// The number in the last slot.
    public func read() -> Int {
        open()
        return slots[slots.count - 1]
    }

    /// Empties the memory, and returns how many slots it cleared.
    public func clear() -> Int {
        open()
        guard !slots.isEmpty else { return 0 }
        defer { slots.removeAll() }
        return slots.count
    }

    private func open() {
        for _ in slots.count..<Memory.slotCount {
            slots.append(0)
        }
    }
}
