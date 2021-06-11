import UIKit

open class CollectionViewDiffableDataSource<Section, Item>:
    UICollectionViewDiffableDataSource<DiffableWrapper<Section>, DiffableWrapper<Item>>
    where Section: SectionType, Section.Item == Item
{
    // MARK: Properties

    private weak var collectionView: UICollectionView?
    private let cellProvider: CellProvider
    private let cellConfigurer: CellConfigurer

    // MARK: Initialization

    /// Deque and return a cell for the given tableview, index path, and item.
    public typealias CellProvider = (UICollectionView, IndexPath, Item) -> UICollectionViewCell?

    /// Configure a cell that was returned from the provider or is being re-configured in place for the given index path and item.
    public typealias CellConfigurer = (UICollectionView, IndexPath, Item, UICollectionViewCell) -> Void

    public init(collectionView: UICollectionView, cellProvider: @escaping CellProvider, cellConfigurer: @escaping CellConfigurer) {
        self.collectionView = collectionView
        self.cellProvider = cellProvider
        self.cellConfigurer = cellConfigurer

        super.init(collectionView: collectionView) { collectionView, indexPath, wrappedItem in
            guard let cell = cellProvider(collectionView, indexPath, wrappedItem.value) else {
                return nil
            }

            cellConfigurer(collectionView, indexPath, wrappedItem.value, cell)
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
                    let collectionView = self.collectionView,
                    let cell = collectionView.cellForItem(at: indexPath)
                {
                    self.cellConfigurer(collectionView, indexPath, itemIdentifier.value, cell)
                }
            }
        }

        // Determine if we should animate the differences or not:
        if self.isCollectionViewSetAndAttachedToWindow {
            self.apply(newSnapshot, animatingDifferences: animatingDifferences, completion: nil)
        } else {
            self.apply(newSnapshot, animatingDifferences: false, completion: nil)
        }
    }

    // MARK: Private

    private var isCollectionViewSetAndAttachedToWindow: Bool {
        if let collectionView = self.collectionView, collectionView.window != nil {
            return true
        }

        return false
    }
}
