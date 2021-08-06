import UIKit

public protocol DiffableViewType: UIView {
    associatedtype CellType: UIView
    func cellForItem(at indexPath: IndexPath) -> CellType?
}

extension UICollectionView: DiffableViewType {}

extension UITableView: DiffableViewType {
    public func cellForItem(at indexPath: IndexPath) -> UITableViewCell? {
        return self.cellForRow(at: indexPath)
    }
}
