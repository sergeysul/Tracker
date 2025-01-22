import UIKit
import Foundation

final class CreateCategoryCell: UITableViewCell {

    private let categoryLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17)
        label.textColor = .black
        return label
    }()

    private let selectionIndicator: UIImageView = {
        let indicator = UIImageView()
        indicator.image = UIImage(systemName: "checkmark")
        indicator.tintColor = .blue
        indicator.isHidden = true
        return indicator
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
            categoryLabel,
            selectionIndicator
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }
    }

    func setupConstraints() {
        NSLayoutConstraint.activate([
            categoryLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            categoryLabel.centerYAnchor.constraint(equalTo: centerYAnchor),

            selectionIndicator.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            selectionIndicator.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }


    func configure(with categoryName: String, isSelected: Bool) {
        backgroundColor = UIColor(red: 230/255, green: 232/255, blue: 235/255, alpha: 0.3)       
        categoryLabel.text = categoryName
        selectionIndicator.isHidden = !isSelected
    }

}
