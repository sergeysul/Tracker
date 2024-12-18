import UIKit

final class ColorsCell: UICollectionViewCell {
    
    static let identifier = "ColorsCell"
    
    private let borderView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 8
        view.layer.masksToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let colorView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 8
        view.layer.masksToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()


    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubviews()
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    private func addSubviews() {
        contentView.addSubview(borderView)
        borderView.addSubview(colorView)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([

            borderView.topAnchor.constraint(equalTo: contentView.topAnchor),
            borderView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            borderView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            borderView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),

            colorView.topAnchor.constraint(equalTo: borderView.topAnchor, constant: 6),
            colorView.bottomAnchor.constraint(equalTo: borderView.bottomAnchor, constant: -6),
            colorView.leadingAnchor.constraint(equalTo: borderView.leadingAnchor, constant: 6),
            colorView.trailingAnchor.constraint(equalTo: borderView.trailingAnchor, constant: -6)
        ])
    }

    func config(with color: UIColor, isSelected: Bool) {
        colorView.backgroundColor = color
        borderView.layer.borderWidth = isSelected ? 3 : 0
        borderView.layer.borderColor = isSelected ? color.withAlphaComponent(0.3).cgColor : UIColor.clear.cgColor
    }
}
