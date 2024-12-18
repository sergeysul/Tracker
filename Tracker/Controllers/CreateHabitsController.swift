import UIKit

protocol CreateHabitsControllerDelegate: AnyObject {
    func newCreationTracker(_ tracker: Tracker, categoryName: String)
}

final class CreateHabitsController: UIViewController, SheduleControllerDelegate{
    
    weak var delegate: CreateHabitsControllerDelegate?
    private var selectedDays: [WeekDay] = [] {
        didSet { refreshCreateButton() }
    }
    private var selectedEmoji: String? {
        didSet { refreshCreateButton() }
    }
    private var selectedColor: UIColor? {
        didSet { refreshCreateButton() }
    }
    private let cellId = "Habitcell"
    private let trackerStore = TrackerStore.shared
    private let emoji: [String] = ["🙂", "😻", "🌺", "🐶", "❤️", "😱", "😇", "😡", "🥶", "🤔", "🙌", "🍔", "🥦", "🏓", "🥇", "🎸", "🏝", "😪"]
    private let colors: [UIColor] = [.colorSet1, .colorSet2, .colorSet3, .colorSet4, .colorSet5, .colorSet6, .colorSet7, .colorSet8, .colorSet9, .colorSet10, .colorSet11, .colorSet12, .colorSet13, .colorSet14, .colorSet15, .colorSet16, .colorSet17, .colorSet18]
    
    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private let label: UILabel = {
        let label = UILabel()
        label.text = "Новая привычка"
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        return label
    }()
    
    private let nameTrackerField: UITextField = {
        let field = UITextField()
        field.placeholder = "Введите название трекера"
        field.font = .systemFont(ofSize: 17)
        field.layer.cornerRadius = 16
        field.backgroundColor = UIColor(red: 230/255, green: 232/255, blue: 235/255, alpha: 0.3)
        field.textColor = UIColor.black 
        let leftEdge = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: field.frame.height))
        field.leftView = leftEdge
        field.leftViewMode = .always
        let rightEdge = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: field.frame.height))
        field.rightView = rightEdge
        field.rightViewMode = .always
        return field
    }()
    
    private let cancel: UIButton = {
        let button = UIButton()
        button.setTitle("Отменить", for: .normal)
        button.setTitleColor(.red, for: .normal)
        button.titleLabel?.font = UIFont(name: "YSDisplay-Medium", size: 16)
        button.layer.cornerRadius = 16
        button.layer.borderWidth = 1.0
        button.layer.borderColor = UIColor.red.cgColor
        return button
    }()
    
    private let create: UIButton = {
        let button = UIButton()
        button.setTitle("Создать", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont(name: "YSDisplay-Medium", size: 16)
        button.layer.cornerRadius = 16
        button.backgroundColor = .gray
        return button
    }()
    
    private let traits: UITableView = {
        let table = UITableView()
        table.layer.cornerRadius = 16
        table.separatorStyle = .singleLine
        table.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        table.alwaysBounceVertical = false
        return table
    }()
    
    private let emojiLabel: UILabel = {
        let label = UILabel()
        label.text = "Emoji"
        label.font = UIFont.systemFont(ofSize: 19, weight: .bold)
        return label
    }()

    private let emojiCollection: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collection.isScrollEnabled = false
        collection.showsVerticalScrollIndicator = false
        collection.backgroundColor = .white
        return collection
    }()
    
    private let colorLabel: UILabel = {
        let label = UILabel()
        label.text = "Цвет"
        label.font = UIFont.systemFont(ofSize: 19, weight: .bold)
        return label
    }()
    
    private let colorCollection: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collection.isScrollEnabled = false
        collection.showsVerticalScrollIndicator = false
        collection.backgroundColor = .white
        return collection
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        traits.dataSource = self
        traits.delegate = self
        nameTrackerField.delegate = self
        addSubviews()
        setupConstraints()
        setupCollectionView()
        emojiCollection.reloadData()
        colorCollection.reloadData()
        cancel.addTarget(self, action: #selector(tapCancel), for: .touchUpInside)
        create.addTarget(self, action: #selector(tapCreate), for: .touchUpInside)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateCollectionHeight()
    }

    private func addSubviews() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        [
            label,
            nameTrackerField,
            cancel,
            create,
            traits,
            emojiLabel,
            emojiCollection,
            colorLabel,
            colorCollection
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            label.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 38),
            label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 122),
            label.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -120),
            
            nameTrackerField.heightAnchor.constraint(equalToConstant: 75),
            nameTrackerField.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 38),
            nameTrackerField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            nameTrackerField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            traits.heightAnchor.constraint(equalToConstant: 150),
            traits.topAnchor.constraint(equalTo: nameTrackerField.bottomAnchor, constant: 24),
            traits.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            traits.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            emojiLabel.topAnchor.constraint(equalTo: traits.bottomAnchor, constant: 32),
            emojiLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 28),
            emojiLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -295),
            
            emojiCollection.topAnchor.constraint(equalTo: emojiLabel.bottomAnchor, constant: 0),
            emojiCollection.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 18),
            emojiCollection.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -18),
            
            colorLabel.topAnchor.constraint(equalTo: emojiCollection.bottomAnchor, constant: 16),
            colorLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 28),
            colorLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -299),
            
            colorCollection.topAnchor.constraint(equalTo: colorLabel.bottomAnchor, constant: 0),
            colorCollection.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 18),
            colorCollection.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -18),
            
            cancel.heightAnchor.constraint(equalToConstant: 60),
            cancel.widthAnchor.constraint(equalToConstant: 166),
            cancel.topAnchor.constraint(equalTo: colorCollection.bottomAnchor, constant: 16),
            cancel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
           
            create.heightAnchor.constraint(equalToConstant: 60),
            create.widthAnchor.constraint(equalToConstant: 166),
            create.centerYAnchor.constraint(equalTo: cancel.centerYAnchor),
            create.leadingAnchor.constraint(equalTo: cancel.trailingAnchor, constant: 8)
            
        ])
    }
    
    
    private func setupCollectionView() {
        emojiCollection.delegate = self
        emojiCollection.dataSource = self
        emojiCollection.register(EmojiCell.self, forCellWithReuseIdentifier: "EmojiCell")
        colorCollection.delegate = self
        colorCollection.dataSource = self
        colorCollection.register(ColorsCell.self, forCellWithReuseIdentifier: "ColorsCell")
    }
    
    private func updateCollectionHeight() {
        
        contentView.layoutIfNeeded()
        let itemsPerRow: CGFloat = 6
        let interItemSpacing: CGFloat = 5
        let lineSpacing: CGFloat = 0
        let padding = 18
        let totalInterItemSpacing = (itemsPerRow - 1) * interItemSpacing
        let availableWidth = contentView.frame.width - CGFloat(padding * 2) - totalInterItemSpacing
        let itemWidth = floor(availableWidth / itemsPerRow)
        let headerHeight: CGFloat = 18

        let emojiRows = ceil(CGFloat(emoji.count) / itemsPerRow)
        let emojiHeight = (emojiRows * itemWidth) + ((emojiRows - 1) * lineSpacing) + headerHeight + 24 + 24
        emojiCollection.heightAnchor.constraint(equalToConstant: emojiHeight).isActive = true

        let colorRows = ceil(CGFloat(colors.count) / itemsPerRow)
        let colorHeight = (colorRows * itemWidth) + ((colorRows - 1) * lineSpacing) + headerHeight + 24 + 24
        colorCollection.heightAnchor.constraint(equalToConstant: colorHeight).isActive = true
        
        let totalHeight = emojiHeight + colorHeight + 507
        contentView.heightAnchor.constraint(equalToConstant: totalHeight).isActive = true
       }
    
    private func refreshCreateButton() {
        
        let isFormComplete = nameTrackerField.text?.isEmpty == false &&
        selectedEmoji != nil &&
        selectedColor != nil &&
        !selectedDays.isEmpty
        create.isEnabled = isFormComplete
        create.backgroundColor = isFormComplete ? .black : .gray
      }
    
    func pickDay(_ days: [WeekDay]) {
        self.selectedDays = days
    }
    
    @objc func tapCancel(){
        dismiss(animated: true, completion: nil)
    }
    
    @objc func tapCreate(){
        
        guard let habitName = nameTrackerField.text, !habitName.isEmpty,
              let color = selectedColor,
              let emoji = selectedEmoji else {
            return
        }
        
        let habit = Tracker(id: UUID(), name: habitName, color: color, emoji: emoji, timing: selectedDays)
        
        trackerStore.createTracker(id: habit.id, name: habit.name, color: habit.color, emoji: habit.emoji, timing: habit.timing, categoryName: "Важное") { [weak self] tracker in
            DispatchQueue.main.async {
                guard let tracker = tracker else { return }
                self?.delegate?.newCreationTracker(tracker, categoryName: "Важное")
                self?.dismiss(animated: true, completion: nil)
            }
        }
    }
}

extension CreateHabitsController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell(style: .default, reuseIdentifier: cellId)

        cell.textLabel?.text = indexPath.row == 0 ? "Категория" : "Расписание"
        cell.backgroundColor = UIColor(red: 230/255, green: 232/255, blue: 235/255, alpha: 0.3)
        
        let chevron = UIImageView(image: UIImage(named: "Chevron.right"))
        chevron.tag = indexPath.row
        cell.accessoryView = chevron
        cell.selectionStyle = .none
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard indexPath.row != 0 else { return }
        let scheduleViewController = SheduleController()
        scheduleViewController.delegate = self
        scheduleViewController.selectedDays = Set(selectedDays)
        present(scheduleViewController, animated: true)
    }
}

extension CreateHabitsController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension CreateHabitsController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return collectionView == emojiCollection ? emoji.count : colors.count
    }

    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == emojiCollection {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EmojiCell", for: indexPath) as? EmojiCell else {
                return UICollectionViewCell()
            }
            let emoji = self.emoji[indexPath.item]
            let isSelected = emoji == selectedEmoji
            cell.config(with: emoji, isSelected: isSelected)
            return cell
        } else {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ColorsCell", for: indexPath) as? ColorsCell else {
                return UICollectionViewCell()
            }
            let color = self.colors[indexPath.item]
            let isSelected = color == selectedColor
            cell.config(with: color, isSelected: isSelected)
            return cell
        }
    }
    

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == emojiCollection {
            selectedEmoji = emoji[indexPath.item]
        } else {
            selectedColor = colors[indexPath.item]
        }
        collectionView.reloadData()
    }

    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let numberOfItemsPerRow: CGFloat = 6
        let interItemSpacing: CGFloat = 5
        let totalInterItemSpacing = (numberOfItemsPerRow - 1) * interItemSpacing
        let availableWidth = collectionView.bounds.width - totalInterItemSpacing
        let itemWidth = floor(availableWidth / numberOfItemsPerRow)
        return CGSize(width: itemWidth, height: itemWidth)
    }
    

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
    

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 24, left: 0, bottom: 24, right: 0)
    }
}
