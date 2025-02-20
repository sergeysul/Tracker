import UIKit

final class StatsCell: UITableViewCell {
    
    static let identifier = "CellStats"
        
    private let number: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 34)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let title: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let containerView: EditStatsCell = {
        let view = EditStatsCell()
        view.layer.cornerRadius = 16
        view.layer.masksToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addSubviews()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func addSubviews() {
        contentView.addSubview(containerView)
        
        [number, title].forEach{
            containerView.addSubview($0)
        }
    }
    func setupConstraints() {
        NSLayoutConstraint.activate([
            
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            number.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            number.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            number.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            
            title.topAnchor.constraint(equalTo: number.bottomAnchor, constant: 7),
            title.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            title.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            title.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -12)
        ])
    }
    
    func configure(with statistic: Stats) {
        backgroundColor = .white
        number.text = statistic.number
        title.text = statistic.title
    }
}

