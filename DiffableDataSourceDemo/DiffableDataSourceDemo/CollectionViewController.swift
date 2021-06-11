import DiffableDataSource
import UIKit

final class CollectionViewController: UICollectionViewController {

    // MARK: Properties

    private static let reuseIdentifier = "Cell"
    private var dataSource: CollectionViewDiffableDataSource<Section, Item>!
    private var items: [Item] = [
        Item(id: "1", ticker: "AAPL", marketCap: 2.125),
        Item(id: "2", ticker: "MSFT", marketCap: 1.942),
        Item(id: "3", ticker: "AMZN", marketCap: 1.688),
        Item(id: "4", ticker: "GOOG", marketCap: 1.655),
        Item(id: "5", ticker: "FB", marketCap: 0.9392),
    ]

    // MARK: Initialization

    init() {

        // Create the collection view layout:
        let size = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(96))
        let item = NSCollectionLayoutItem(layoutSize: size)
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: size, subitem: item, count: 1)
        let section = NSCollectionLayoutSection(group: group)
        let collectionViewLayout = UICollectionViewCompositionalLayout(section: section)

        super.init(collectionViewLayout: collectionViewLayout)

        // Configure the table view and data source:
        self.collectionView.register(ItemCollectionViewCell.self, forCellWithReuseIdentifier: Self.reuseIdentifier)
        self.dataSource = CollectionViewDiffableDataSource<Section, Item>(
            collectionView: self.collectionView,
            cellProvider: { collectionView, indexPath, _ in
                return collectionView.dequeueReusableCell(withReuseIdentifier: Self.reuseIdentifier, for: indexPath)
            },
            cellConfigurer: { collectionView, indexPath, item, cell in
                guard let cell = cell as? ItemCollectionViewCell else { return }
                cell.configure(for: item)
            }
        )

        // Load the initial data:
        self.updateSections()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configureCollectionViewAndDataSource() {

    }

    // MARK: View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        // Configure the collection view:
        self.collectionView.backgroundColor = .white

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
    }

    // MARK: Private

    private func updateSections() {
        let section = Section(id: "top-5-market-caps", items: self.items)
        self.dataSource.apply(sections: [section])
    }
}

