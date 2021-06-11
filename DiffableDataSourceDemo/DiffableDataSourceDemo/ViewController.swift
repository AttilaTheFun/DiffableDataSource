import DiffableDataSource
import UIKit

struct Item: ItemType {
    let id: String
    let title: String
    let subtitle: String
}

struct Section: SectionType {
    let id: String
    let items: [Item]
}

final class TableViewController: UITableViewController {

    private static let reuseIdentifier = "Cell"
    private var dataSource: TableViewDiffableDataSource<Section, Item>!

    override init(style: UITableView.Style) {
        super.init(style: style)

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: Self.reuseIdentifier)
        var dataSource = TableViewDiffableDataSource(
            tableView: self.tableView,
            cellProvider: { tableView, indexPath, item in
                return tableView.dequ
            },
            cellConfigurer: { tableView, indexPath, item, cell in

            })
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
}

