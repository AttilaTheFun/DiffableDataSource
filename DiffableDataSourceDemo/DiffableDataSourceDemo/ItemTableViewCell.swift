import UIKit

final class ItemTableViewCell: UITableViewCell {

    private let formatter = NumberFormatter()
    private let tickerLabel = UILabel()
    private let marketCapLabel = UILabel()
    private let stackView = UIStackView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        // Configure the formatter:
        self.formatter.usesSignificantDigits = true
        self.formatter.minimumSignificantDigits = 4
        self.formatter.maximumSignificantDigits = 4

        // Configure the views:
        self.tickerLabel.translatesAutoresizingMaskIntoConstraints = false
        self.tickerLabel.font = UIFont.preferredFont(forTextStyle: .headline)
        self.marketCapLabel.translatesAutoresizingMaskIntoConstraints = false
        self.marketCapLabel.font = UIFont.preferredFont(forTextStyle: .subheadline)
        self.stackView.translatesAutoresizingMaskIntoConstraints = false
        self.stackView.isLayoutMarginsRelativeArrangement = true
        self.stackView.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 8, leading: 24, bottom: 8, trailing: 24)
        self.stackView.axis = .vertical
        self.stackView.spacing = 4

        self.stackView.addArrangedSubview(self.tickerLabel)
        self.stackView.addArrangedSubview(self.marketCapLabel)
        self.addSubview(self.stackView)

        NSLayoutConstraint.activate([
            self.stackView.topAnchor.constraint(equalTo: self.topAnchor),
            self.stackView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.stackView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            self.stackView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(for item: Item) {
        self.tickerLabel.text = item.ticker
        let formattedMarketCap = self.formatter.string(from: NSNumber(value: item.marketCap)) ?? "0.000"
        self.marketCapLabel.text = "$\(formattedMarketCap)T"
    }
}

