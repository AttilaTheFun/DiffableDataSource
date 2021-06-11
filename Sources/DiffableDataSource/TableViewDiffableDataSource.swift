import UIKit

open class TableViewDiffableDataSource<Section, Item>:
    UITableViewDiffableDataSource<DiffableWrapper<Section>, DiffableWrapper<Item>>
    where Section: SectionType, Section.Item == Item
{
    // MARK: Properties

    private weak var tableView: UITableView?
    private let cellProvider: CellProvider
    private let cellConfigurer: CellConfigurer

    // MARK: Initialization

    /// Deque and return a cell for the given tableview, index path, and item.
    public typealias CellProvider = (UITableView, IndexPath, Item) -> UITableViewCell?

    /// Configure a cell that was returned from the provider or is being re-configured in place for the given index path and item.
    public typealias CellConfigurer = (UITableView, IndexPath, Item, UITableViewCell) -> Void

    public init(tableView: UITableView, cellProvider: @escaping CellProvider, cellConfigurer: @escaping CellConfigurer) {
        self.tableView = tableView
        self.cellProvider = cellProvider
        self.cellConfigurer = cellConfigurer

        super.init(tableView: tableView) { tableView, indexPath, wrappedItem in
            guard let cell = cellProvider(tableView, indexPath, wrappedItem.value) else {
                return nil
            }

            cellConfigurer(tableView, indexPath, wrappedItem.value, cell)
            return cell
        }
    }

    // MARK: Interface

    open func apply(
        sections: [Section],
        animatingDifferences: Bool = true,
        completion: (() -> Void)? = nil)
    {
        // Construct the new snapshot:
        var newSnapshot = NSDiffableDataSourceSnapshot<DiffableWrapper<Section>, DiffableWrapper<Item>>()
        let sectionIdentifiers = sections.map { DiffableWrapper(value: $0) }
        newSnapshot.appendSections(sectionIdentifiers)
        for sectionIdentifier in sectionIdentifiers {
            let itemIdentifiers = sectionIdentifier.value.items.map { DiffableWrapper(value: $0) }
            newSnapshot.appendItems(itemIdentifiers, toSection: sectionIdentifier)

            // Re-configure cells for the item identifiers if they exist:
            for itemIdentifier in itemIdentifiers {
                if
                    let indexPath = self.indexPath(for: itemIdentifier),
                    let tableView = self.tableView,
                    let cell = tableView.cellForRow(at: indexPath)
                {
                    self.cellConfigurer(tableView, indexPath, itemIdentifier.value, cell)
                }
            }
        }

        // Determine if we should animate the differences or not:
        if self.isTableViewSetAndAttachedToWindow {
            self.apply(newSnapshot, animatingDifferences: animatingDifferences, completion: nil)
        } else {
            self.apply(newSnapshot, animatingDifferences: false, completion: nil)
        }
    }

    // MARK: Private

    private var isTableViewSetAndAttachedToWindow: Bool {
        if let tableView = self.tableView, tableView.window != nil {
            return true
        }

        return false
    }
}
