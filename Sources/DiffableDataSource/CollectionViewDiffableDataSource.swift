import UIKit

open class CollectionViewDiffableDataSource<Section, Item>:
    UICollectionViewDiffableDataSource<DiffableWrapper<Section>, DiffableWrapper<Item>>,
    DiffableDataSource
    where Section: SectionType, Section.Item == Item
{
    public typealias ViewType = UICollectionView

    // MARK: Properties

    public private(set) weak var view: ViewType?
    public let cellProvider: DiffableCellProvider<ViewType, Section.Item>
    public let cellConfigurer: DiffableCellConfigurer<ViewType, Section.Item>

    public var sections: [Section] = []

    // MARK: Initialization

    public init(
        view: ViewType,
        cellProvider: @escaping DiffableCellProvider<ViewType, Section.Item>,
        cellConfigurer: @escaping DiffableCellConfigurer<ViewType, Section.Item>)
    {
        // Save the injected dependencies:
        self.view = view
        self.cellProvider = cellProvider
        self.cellConfigurer = cellConfigurer

        super.init(collectionView: view) { collectionView, indexPath, wrappedItem in
            guard let cell = cellProvider(collectionView, indexPath, wrappedItem.value) else {
                return nil
            }

            cellConfigurer(collectionView, indexPath, wrappedItem.value, cell)
            return cell
        }

        // For some reason, this class defaults to one section with zero items, so let's clear them out.
        self.apply(sections: self.sections)
    }

//    // MARK: Interface
//
//    open func apply(
//        sections: [Section],
//        animatingDifferences: Bool = true,
//        completion: (() -> Void)? = nil)
//    {
//        // Save the old snapshot:
//        let oldSnapshot = self.snapshot()
//
//        // Construct the new snapshot:
//        var newSnapshot = NSDiffableDataSourceSnapshot<DiffableWrapper<Section>, DiffableWrapper<Item>>()
//        let sectionIdentifiers = sections.map { DiffableWrapper(value: $0) }
//        newSnapshot.appendSections(sectionIdentifiers)
//        for sectionIdentifier in sectionIdentifiers {
//            let itemIdentifiers = sectionIdentifier.value.items.map { DiffableWrapper(value: $0) }
//            newSnapshot.appendItems(itemIdentifiers, toSection: sectionIdentifier)
//        }
//
//        // Save a reference to the sections:
//        self.sections = sections
//
//        // Determine if we should animate the differences or not:
//        if self.isViewSetAndAttachedToWindow {
//
//            // Re-configure cells for the item identifiers if they exist.
//            // NOTE: If the collectionView is not set and attached to the window, cell for row forces an early layout.
//            // The call without animating differences below is the same as calling reload data so this is unnecessary.
//            for sectionIdentifier in sectionIdentifiers {
//                let itemIdentifiers = sectionIdentifier.value.items.map { DiffableWrapper(value: $0) }
//                for itemIdentifier in itemIdentifiers {
//                    if
//                        let indexPath = self.indexPath(for: itemIdentifier),
//                        let collectionView = self.collectionView,
//                        let cell = collectionView.cellForItem(at: indexPath)
//                    {
//                        self.cellConfigurer(collectionView, indexPath, itemIdentifier.value, cell)
//                    }
//                }
//            }
//
//            self.apply(newSnapshot, animatingDifferences: animatingDifferences, completion: nil)
//        } else {
//            self.apply(newSnapshot, animatingDifferences: false, completion: nil)
//        }
//    }
}
