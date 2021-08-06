import DiffableDataSource
import UIKit

final class TableViewController: UITableViewController {

    // MARK: Properties

    private static let reuseIdentifier = "Cell"
    private var dataSource: TableViewDiffableDataSource<Section, Item>!
    private var items: [Item] = [
        Item(id: "1", ticker: "AAPL", marketCap: 2.125),
        Item(id: "2", ticker: "MSFT", marketCap: 1.942),
        Item(id: "3", ticker: "AMZN", marketCap: 1.688),
        Item(id: "4", ticker: "GOOG", marketCap: 1.655),
        Item(id: "5", ticker: "FB", marketCap: 0.9392),
    ]

    // MARK: Initialization

    init() {
        super.init(style: .plain)

        // Configure the table view and data source:
        self.tableView.register(ItemTableViewCell.self, forCellReuseIdentifier: Self.reuseIdentifier)
        self.dataSource = TableViewDiffableDataSource<Section, Item>(
            view: self.tableView,
            cellProvider: { tableView, indexPath, _ in
                return tableView.dequeueReusableCell(withIdentifier: Self.reuseIdentifier, for: indexPath)
            },
            cellConfigurer: { tableView, indexPath, item, cell in
                guard let cell = cell as? ItemTableViewCell else { return }
                print("Configuring cell at index path: \(indexPath) for item: \(item.id)")
                cell.configure(for: item)
            }
        )

        // Load the initial data:
        self.updateSections()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configureTableViewAndDataSource() {

    }

    // MARK: View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        // Simulate receiving new stock data every second:
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            let newItems = self.items.map { oldItem -> Item in
                let multiplier = Double.random(in: 0.995...1.005)
                let newMarketCap = oldItem.marketCap * multiplier
                let newItem = Item(id: oldItem.id, ticker: oldItem.ticker, marketCap: newMarketCap)
                return newItem
            }.sorted(by: { $0.marketCap > $1.marketCap })

            self.items = newItems
            self.updateSections()
        }

//        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
//            let newItems = Array(self.items[1...])
//            self.items = newItems
//            self.updateSections()
//        }
    }

    // MARK: Private

    private func updateSections() {
        let section = Section(id: "top-5-market-caps", items: self.items)
        self.dataSource.apply(sections: [section])
    }
}

