import UIKit

protocol CreateHabitsControllerDelegate: AnyObject {
    func newCreationTracker(_ tracker: Tracker, categoryName: String)
    func trackerUpdate(_ tracker: Tracker, categoryName: String)
}

final class CreateHabitsController: UIViewController, SheduleControllerDelegate, CategorySelectionDelegate{
    
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
    private var selectedCategory: TrackerCategory? {
        didSet { refreshCreateButton() }
    }
    private var scheduleSubtitle: String = "" {
        didSet {
            traits.reloadData()
        }
    }
    private var categorySubtitle: String = "" {
        didSet {
            traits.reloadData()
        }
    }
    private let cellId = "Habitcell"
    private let trackerStore = TrackerStore.shared
    private let themeSettings = ThemeSettings.shared
    private let recordStore = TrackerRecordStore.shared
    private let emoji: [String] = ["🙂", "😻", "🌺", "🐶", "❤️", "😱", "😇", "😡", "🥶", "🤔", "🙌", "🍔", "🥦", "🏓", "🥇", "🎸", "🏝", "😪"]
    private let colors: [UIColor] = [.colorSet1, .colorSet2, .colorSet3, .colorSet4, .colorSet5, .colorSet6, .colorSet7, .colorSet8, .colorSet9, .colorSet10, .colorSet11, .colorSet12, .colorSet13, .colorSet14, .colorSet15, .colorSet16, .colorSet17, .colorSet18]
    var trackerRecords: [TrackerRecord] = []
    var trackerForEdit: Tracker?
    var isEditingTracker: Bool = false
    
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
    
    let label: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        return label
    }()
    
    private let daysLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 32)
        label.textColor = .black
        label.textAlignment = .center
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
        configureUIForEditing()
        setupConstraints()
        setupCollectionView()
        emojiCollection.reloadData()
        colorCollection.reloadData()
        cancel.addTarget(self, action: #selector(tapCancel), for: .touchUpInside)
        create.addTarget(self, action: #selector(tapCreate), for: .touchUpInside)
        if isEditingTracker {
            fetchCompletedTrackers() 
        }
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
            daysLabel,
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
            label.centerXAnchor.constraint(equalTo: contentView.centerXAnchor)
        ])

        if isEditingTracker {
            daysLabel.isHidden = false
            NSLayoutConstraint.activate([
                daysLabel.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 38),
                daysLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
                daysLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
                nameTrackerField.topAnchor.constraint(equalTo: daysLabel.bottomAnchor, constant: 40)
            ])
        } else {
            daysLabel.isHidden = true
            NSLayoutConstraint.activate([
                nameTrackerField.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 38)
            ])
        }

        NSLayoutConstraint.activate([
            nameTrackerField.heightAnchor.constraint(equalToConstant: 75),
            nameTrackerField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            nameTrackerField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            traits.heightAnchor.constraint(equalToConstant: 150),
            traits.topAnchor.constraint(equalTo: nameTrackerField.bottomAnchor, constant: 24),
            traits.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            traits.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            emojiLabel.topAnchor.constraint(equalTo: traits.bottomAnchor, constant: 32),
            emojiLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 28),

            emojiCollection.topAnchor.constraint(equalTo: emojiLabel.bottomAnchor, constant: 0),
            emojiCollection.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 18),
            emojiCollection.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -18),

            colorLabel.topAnchor.constraint(equalTo: emojiCollection.bottomAnchor, constant: 16),
            colorLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 28),

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
            create.leadingAnchor.constraint(equalTo: cancel.trailingAnchor, constant: 8),
            create.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20)
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

        let daysLabelHeight: CGFloat = isEditingTracker ? (daysLabel.intrinsicContentSize.height + 16) : 0
        let totalHeight = emojiHeight + colorHeight + 530 + daysLabelHeight

        contentView.heightAnchor.constraint(equalToConstant: totalHeight).isActive = true
    }
    
    private func refreshCreateButton() {
    
        let isFormComplete = nameTrackerField.text?.isEmpty == false &&
        selectedEmoji != nil &&
        selectedColor != nil &&
        !selectedDays.isEmpty &&
        selectedCategory != nil
        create.isEnabled = isFormComplete
        create.backgroundColor = isFormComplete ? .black : .gray
    }
    
    func pickDay(_ days: [WeekDay]) {
        self.selectedDays = days
        if days.isEmpty {
            scheduleSubtitle = ""
        } else if days.count == WeekDay.allCases.count {
            scheduleSubtitle = "Каждый день"
        } else {
            scheduleSubtitle = days.map { $0.shortDisplayName }.joined(separator: ", ")
        }
    }
    
    func pickCategory(_ category: TrackerCategory) {
        selectedCategory = category
        categorySubtitle = category.name
        traits.reloadData()
    }
    
    private func populateDataForEditing() {
        guard isEditingTracker, let trackerForEdit = trackerForEdit else {
            daysLabel.isHidden = true
            return
        }

        daysLabel.isHidden = false

        let completedDays = trackerRecords.filter { $0.trackerId == trackerForEdit.id }.count
        daysLabel.text = formatNumerDays(for: completedDays)
        nameTrackerField.text = trackerForEdit.name
        selectedColor = trackerForEdit.color
        selectedEmoji = trackerForEdit.emoji
        selectedDays = trackerForEdit.timing

        if selectedDays.isEmpty {
            scheduleSubtitle = ""
        } else if selectedDays.count == WeekDay.allCases.count {
            scheduleSubtitle = "Каждый день"
        } else {
            scheduleSubtitle = selectedDays.map { $0.shortDisplayName }.joined(separator: ", ")
        }

        if let category = trackerStore.fetchCategory(for: trackerForEdit.id) {
            selectedCategory = category
            categorySubtitle = category.name
        }

        traits.reloadData()
        colorCollection.reloadData()
        emojiCollection.reloadData()
        refreshCreateButton()
    }


    private func formatNumerDays(for count: Int) -> String {
        let formatString: String = NSLocalizedString("days_count", comment: "")
        let result: String = String.localizedStringWithFormat(formatString, count)
        return result
    }

    private func fetchCompletedTrackers() {
        recordStore.fetchRecords { [weak self] records in
            DispatchQueue.main.async {
                self?.trackerRecords = records
                self?.populateDataForEditing()
            }
        }
    }
    
    private func configureUIForEditing() {
        label.text = isEditingTracker ? "Редактирование привычки" : "Новая привычка"
        create.setTitle(isEditingTracker ? "Сохранить" : "Создать", for: .normal)

        
        if isEditingTracker {
            
            NSLayoutConstraint.deactivate(label.constraints)
            label.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                label.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 38),
                label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 77),
                label.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -100),
            ])
        } else {
           

            NSLayoutConstraint.activate([
                label.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 38),
                label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 122),
                label.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -120),
            ])
        }
    }

    @objc func tapCancel(){
        if isEditingTracker {
            navigationController?.popViewController(animated: true)
        } else {
            dismiss(animated: true, completion: nil)
        }
    }
    
    @objc func tapCreate() {
        guard let habitName = nameTrackerField.text, !habitName.isEmpty,
              let color = selectedColor,
              let emoji = selectedEmoji,
              let categoryName = selectedCategory?.name else {
            return
        }
        
        if isEditingTracker, let trackerForEdit = trackerForEdit {
            trackerStore.updateTracker(
                trackerForEdit,
                name: habitName,
                color: color,
                emoji: emoji,
                timing: selectedDays,
                categoryName: categoryName
            ) { [weak self] success in
                DispatchQueue.main.async {
                    if success {
                        self?.delegate?.trackerUpdate(trackerForEdit, categoryName: categoryName)
                        self?.dismiss(animated: true, completion: nil)
                    }
                }
            }
        } else {
            let newTracker = Tracker(
                id: UUID(),
                name: habitName,
                color: color,
                emoji: emoji,
                timing: selectedDays
            )
            
            trackerStore.createTracker(
                id: newTracker.id,
                name: newTracker.name,
                color: newTracker.color,
                emoji: newTracker.emoji,
                timing: newTracker.timing,
                categoryName: categoryName
            ) { [weak self] tracker in
                DispatchQueue.main.async {
                    guard let tracker = tracker else { return }
                    self?.delegate?.newCreationTracker(tracker, categoryName: categoryName)
                    self?.dismiss(animated: true, completion: nil) 
                }
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
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: cellId)

        cell.textLabel?.text = indexPath.row == 0 ? "Категория" : "Расписание"
        cell.textLabel?.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        cell.backgroundColor = UIColor(red: 230/255, green: 232/255, blue: 235/255, alpha: 0.3)

        if indexPath.row == 0 {
            cell.detailTextLabel?.text = categorySubtitle.isEmpty ? "" : categorySubtitle
        } else if indexPath.row == 1 {
            cell.detailTextLabel?.text = scheduleSubtitle
        }
        
        cell.detailTextLabel?.textColor = UIColor(red: 174/255, green: 175/255, blue: 180/255, alpha: 1)
        cell.detailTextLabel?.font = UIFont.systemFont(ofSize: 17, weight: .regular)

        let chevron = UIImageView(image: UIImage(named: "Chevron.right"))
        chevron.tag = indexPath.row
        cell.accessoryView = chevron
        cell.selectionStyle = .none
        return cell
    }


    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            let categoryViewModel = CategoryViewModel()
            let categoryViewController = CategoryViewController(viewModel: categoryViewModel, pickedCategory: selectedCategory)
            categoryViewController.delegate = self
            present(categoryViewController, animated: true)
        } else if indexPath.row == 1 {
            let scheduleViewController = SheduleController()
            scheduleViewController.delegate = self
            scheduleViewController.selectedDays = Set(selectedDays)
            present(scheduleViewController, animated: true)
        }
    }

}

extension CreateHabitsController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let currentText = textField.text ?? ""
        guard let textRange = Range(range, in: currentText) else { return true }
        let updatedText = currentText.replacingCharacters(in: textRange, with: string)

        if updatedText.count > 38 {
            self.create.isEnabled = false
            return false
        } else {
            self.refreshCreateButton()
            return true
        }
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
