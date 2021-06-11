
public protocol SectionType: DiffableType {
    associatedtype Item: ItemType
    var items: [Item] { get }
}
