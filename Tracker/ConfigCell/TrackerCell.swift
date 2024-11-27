import UIKit

final class TrackerCell: UICollectionViewCell {
    
    private var cellView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 16
        view.layer.masksToBounds = true
        return view
    }()
    
    private var emojiTracker: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.layer.cornerRadius = 12
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.layer.masksToBounds = true
        label.backgroundColor = UIColor.white.withAlphaComponent(0.3)
        return label
    }()
    
    private var textTracker: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont(name: "YSDisplay-Medium", size: 12)
        return label
    }()
    
    private var numberOfDays: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = UIFont(name: "YSDisplay-Medium", size: 12)
        return label
    }()
    
    private var statusTrackerButton: UIButton = {
        let button = UIButton()
        button.tintColor = .white
        button.layer.cornerRadius = 17
        return button
    }()
    
    var statusTrackerButtonAction: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        statusTrackerButton.addTarget(self, action: #selector(tapStatusTrackerButton), for: .touchUpInside)
        addSubviews()
        constraints()
    }
    
    required init?(coder: NSCoder){
        fatalError("init(coder:) has not been implemented")
    }
    
    private func addSubviews() {
        [
            cellView,
            emojiTracker,
            textTracker,
            numberOfDays,
            statusTrackerButton
        ].forEach { [weak self] in
            $0.translatesAutoresizingMaskIntoConstraints = false
            self?.contentView.addSubview($0)
        }
    }
    
    
    private func constraints() {
        NSLayoutConstraint.activate([
            
            cellView.heightAnchor.constraint(equalToConstant: 90),
            cellView.widthAnchor.constraint(equalToConstant: 167),
            cellView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 0),
            cellView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 0),
            cellView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 0),
            

            emojiTracker.heightAnchor.constraint(equalToConstant: 24),
            emojiTracker.widthAnchor.constraint(equalToConstant: 24),
            emojiTracker.topAnchor.constraint(equalTo: cellView.topAnchor, constant: 12),
            emojiTracker.leadingAnchor.constraint(equalTo: cellView.leadingAnchor, constant: 12),

            textTracker.bottomAnchor.constraint(equalTo: cellView.bottomAnchor, constant: -12),
            textTracker.leadingAnchor.constraint(equalTo: cellView.leadingAnchor, constant: 12),
            textTracker.trailingAnchor.constraint(equalTo: cellView.trailingAnchor, constant: -12),
            
            numberOfDays.topAnchor.constraint(equalTo: cellView.bottomAnchor, constant: 16),
            numberOfDays.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            numberOfDays.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 54),
            
            statusTrackerButton.heightAnchor.constraint(equalToConstant: 34),
            statusTrackerButton.widthAnchor.constraint(equalToConstant: 34),
            statusTrackerButton.topAnchor.constraint(equalTo: cellView.bottomAnchor, constant: 8),
            statusTrackerButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12)
            
        ])
    }
    
    private func formatNumerDays(for count: Int) -> String {
        let units = count % 10
        let hundreds = count % 100
        
        if units == 1 && hundreds != 11 {
            return "\(count) день"
        } else if (units >= 2 && units <= 4 && hundreds < 10) || hundreds >= 20 {
            return "\(count) дня"
        } else {
            return "\(count) дней"
        }
    }

    func config(with tracker: Tracker, isCompleted: Bool, completedDays: Int, isFutureDate: Bool) {
        emojiTracker.text = tracker.emoji
        textTracker.text = tracker.name
        cellView.backgroundColor = tracker.color
    
        let day = formatNumerDays(for: completedDays)
        numberOfDays.text = "\(day)"
        
        let configuration = UIImage.SymbolConfiguration(pointSize: 11, weight: .bold)
        let imageName = isCompleted ? "checkmark" : "plus"
        let image = UIImage(systemName: imageName, withConfiguration: configuration)
        
        statusTrackerButton.setImage(image, for: .normal)
        statusTrackerButton.backgroundColor = isCompleted ? tracker.color.withAlphaComponent(0.3) : tracker.color
        statusTrackerButton.isEnabled = !isFutureDate
        statusTrackerButton.alpha = isFutureDate ? 0.5 : 1.0
    }
    
    @objc func tapStatusTrackerButton(){
       statusTrackerButtonAction?()
    }
}
