import DiffableDataSource

struct Item: ItemType {

    /// The id of the item.
    let id: String

    /// The NSYE ticker of the company.
    let ticker: String

    /// The market cap of the company in trillions of USD.
    let marketCap: Double
}

struct Section: SectionType {
    let id: String
    let items: [Item]
}
