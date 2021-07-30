
/**
 Apple's own diffable data sources only consider the identity of items when diffing.
 This wrapper type allows us to pluck the identity value from a diffable type and implement Hashable with only the ID.
 */
public struct DiffableWrapper<Value> where Value: DiffableType {
    public let value: Value

    public init(value: Value) {
        self.value = value
    }
}

// MARK: DiffableWrapper + Hashable

extension DiffableWrapper: Hashable {
    public static func == (lhs: DiffableWrapper<Value>, rhs: DiffableWrapper<Value>) -> Bool {
        return lhs.value.id == rhs.value.id
    }

    public func hash(into hasher: inout Hasher) {
        self.value.id.hash(into: &hasher)
    }
}
