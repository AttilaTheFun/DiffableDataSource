import UIKit

/// A closure that dequeues and returns a cell for the given diffable view, index path, and item.
public typealias DiffableCellProvider<View, Item> = (View, IndexPath, Item) -> View.CellType?
    where View: DiffableViewType, Item: ItemType

/// A closure that configures a cell that was returned from the provider or is being re-configured in place for the given index path and item.
public typealias DiffableCellConfigurer<View, Item> = (View, IndexPath, Item, View.CellType) -> Void
    where View: DiffableViewType, Item: ItemType

public protocol DiffableDataSource: AnyObject {
    associatedtype Section: SectionType
    associatedtype ViewType: DiffableViewType

    // MARK: View

    /// The view that this data source is associated with.
    var view: ViewType? { get }

    /// The cell provider for the data source.
    var cellProvider: DiffableCellProvider<ViewType, Section.Item> { get }

    /// The cell configurer for the data source.
    var cellConfigurer: DiffableCellConfigurer<ViewType, Section.Item> { get }

    // MARK: Sections

    /// TODO: See if I can break this dependency.
    var sections: [Section] { get set }

    // MARK: Updating Data

    /**
     Returns a representation of the current state of the data in the view.
     */
    func snapshot() -> NSDiffableDataSourceSnapshot<DiffableWrapper<Section>, DiffableWrapper<Section.Item>>

    /**
     Updates the UI to reflect the state of the data in the specified snapshot, optionally animating the UI changes and executing a completion handler.
     */
    func apply(
        _ snapshot: NSDiffableDataSourceSnapshot<DiffableWrapper<Section>, DiffableWrapper<Section.Item>>,
        animatingDifferences: Bool,
        completion: (() -> Void)?)
}

extension DiffableDataSource {

    /// Whether the view has been assigned to the data source and moved to a window.
    var isViewSetAndAttachedToWindow: Bool {
        if let view = self.view, view.window != nil {
            return true
        }

        return false
    }

    public func apply(
        sections: [Section],
        animatingDifferences: Bool = true,
        completion: (() -> Void)? = nil)
    {
        // Save a reference to the old snapshot:
        let oldSnapshot = self.snapshot()

        // Construct the new snapshot:
        var newSnapshot = NSDiffableDataSourceSnapshot<DiffableWrapper<Section>, DiffableWrapper<Section.Item>>()
        let sectionIdentifiers = sections.map { DiffableWrapper(value: $0) }
        newSnapshot.appendSections(sectionIdentifiers)
        for sectionIdentifier in sectionIdentifiers {
            let itemIdentifiers = sectionIdentifier.value.items.map { DiffableWrapper(value: $0) }
            newSnapshot.appendItems(itemIdentifiers, toSection: sectionIdentifier)
        }

        // Save a reference to the sections:
        self.sections = sections

        // Determine if we should animate the differences or not:
        if self.isViewSetAndAttachedToWindow {

            // Re-configure the visible cells from the old snapshot if they exist in the new snapshot.
            // NOTE: This means we could potentially do extra work to configure a cell
            // that gets re-configured due to the updated cell shifting off screen, but this isn't a big deal.
            for (oldSectionIndex, oldSectionIdentifier) in oldSnapshot.sectionIdentifiers.enumerated() {
                let oldItemIdentifiers = oldSectionIdentifier.value.items.map { DiffableWrapper(value: $0) }
                for (oldItemIndex, oldItemIdentifier) in oldItemIdentifiers.enumerated() {
                    let oldIndexPath = IndexPath(item: oldItemIndex, section: oldSectionIndex)
                    guard
                        let view = self.view,
                        let oldCell = view.cellForItem(at: oldIndexPath) else
                    {
//                        print("Not re-configuring cell with id: \(oldItemIdentifier.value.id) because the old cell was not visible")
                        continue
                    }

                    guard
                        let newSectionIdentifier = newSnapshot.sectionIdentifier(containingItem: oldItemIdentifier),
                        let newSectionIndex = newSnapshot.indexOfSection(newSectionIdentifier),
                        let newItemIndex = newSnapshot.indexOfItem(oldItemIdentifier) else
                    {
//                        print("Not re-configuring cell with id: \(oldItemIdentifier.value.id) because the item was not present in the new snapshot")
                        continue
                    }

                    let newItemIdentifier = newSnapshot.itemIdentifiers(inSection: newSectionIdentifier)[newItemIndex]
                    guard newItemIdentifier.value != oldItemIdentifier.value else {
//                        print("Not re-configuring cell with id: \(oldItemIdentifier.value.id) because new value was unchanged")
                        continue
                    }

                    let newIndexPath = IndexPath(item: newItemIndex, section: newSectionIndex)
//                    print("Re-configuring cell with id: \(newItemIdentifier.value.id) with old index path: \(oldIndexPath), new index path: \(newIndexPath)")

                    // Re-configure the cell:
                    self.cellConfigurer(view, oldIndexPath, oldItemIdentifier.value, oldCell)
                }
            }

            self.apply(newSnapshot, animatingDifferences: animatingDifferences, completion: nil)
        } else {
            self.apply(newSnapshot, animatingDifferences: false, completion: nil)
        }
    }
}
