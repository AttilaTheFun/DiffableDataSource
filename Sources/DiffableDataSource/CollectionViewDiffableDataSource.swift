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
}
