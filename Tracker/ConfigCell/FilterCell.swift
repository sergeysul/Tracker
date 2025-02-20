import UIKit

final class FilterCell: UITableViewCell {

    private let filterLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17)
        label.textColor = .blackFull
        return label
    }()

    private let selectionIndicator: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "checkmark")
        imageView.tintColor = UIColor(red: 55/255, green: 114/255, blue: 231/255, alpha: 1)
        imageView.isHidden = true
        return imageView
    }()


    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addSubviews()
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func addSubviews() {
        [
            filterLabel,
            selectionIndicator
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }
    }

    func setupConstraints() {
        NSLayoutConstraint.activate([
            filterLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            filterLabel.centerYAnchor.constraint(equalTo: centerYAnchor),

            selectionIndicator.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            selectionIndicator.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }

    func configure(with filterName: String, isSelected: Bool) {
        backgroundColor = UIColor(red: 230/255, green: 232/255, blue: 235/255, alpha: 0.3)
        filterLabel.text = filterName
        selectionIndicator.isHidden = !isSelected
    }
}
