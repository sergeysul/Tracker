import UIKit

final class TrackerController: UIViewController, CreateHabitsControllerDelegate {
    
    private var doneTrackers: Set<TrackerRecord> = []
    private var category: [TrackerCategory] = []
    private var currentDate: Date = Date()
    private var displayedCategory: [TrackerCategory] = []
    
    private let trackerButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "AddTracker"), for: .normal)
        return button
    }()
    
    private let label: UILabel = {
        let label = UILabel()
        label.text = "Трекеры"
        label.font = UIFont.boldSystemFont(ofSize: 34)
        return label
    }()
    
    private let date: UIDatePicker = {
        let date = UIDatePicker()
        date.datePickerMode = .date
        date.preferredDatePickerStyle = .compact
        date.locale = Locale(identifier: "ru_RU")
        return date
    }()
    
    private let searchText: UISearchTextField = {
        let searchText = UISearchTextField()
        searchText.text = "Поиск"
        return searchText
    }()
    
    private let defaultTrackerLogo: UIImageView = {
        let logo = UIImageView()
        logo.image = UIImage(named: "TrackersDefaultLogo")
        return logo
    }()
    
    private let defaultTrackerLabel: UILabel = {
        let label = UILabel()
        label.text = "Что будем отслеживать?"
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 12)
        return label
    }()
    
    private var collection: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collection.register(TrackerCell.self, forCellWithReuseIdentifier: "cell")
        collection.backgroundColor = .white
        collection.showsVerticalScrollIndicator = false
        return collection
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        trackerButton.addTarget(self, action: #selector(tapTrackerButton), for: .touchUpInside)
        date.addTarget(self, action: #selector(changeDate), for: .valueChanged)
        collection.delegate = self
        collection.dataSource = self
        collection.register(CategoryCell.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: CategoryCell.identifier)
        addSubviews()
        constraints()
        update()
    }
    
    @objc private func tapTrackerButton(){
        
        let createTracker = CreateTrackerViewController()
        createTracker.delegate = self
        present(createTracker, animated: true, completion: nil)
    }
    
    @objc private func changeDate(_ sender: UIDatePicker){
        currentDate = sender.date
        refreshTrackersForDate()
    }
    
    private func addSubviews() {
        [
            trackerButton,
            label,
            date,
            defaultTrackerLogo,
            searchText,
            defaultTrackerLabel,
            collection,
        ].forEach { [weak self] in
            $0.translatesAutoresizingMaskIntoConstraints = false
            self?.view.addSubview($0)
        }
    }
    
    private func constraints() {
        NSLayoutConstraint.activate([
            trackerButton.heightAnchor.constraint(equalToConstant: 42),
            trackerButton.widthAnchor.constraint(equalToConstant: 42),
            trackerButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 6),
            trackerButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 1),
            
            label.heightAnchor.constraint(equalToConstant: 41),
            label.widthAnchor.constraint(equalToConstant: 254),
            label.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            label.topAnchor.constraint(equalTo: trackerButton.bottomAnchor, constant: 1),
            
            date.heightAnchor.constraint(equalToConstant: 34),
            date.widthAnchor.constraint(equalToConstant: 77),
            date.centerYAnchor.constraint(equalTo: trackerButton.centerYAnchor, constant: 0),
            date.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            
            searchText.heightAnchor.constraint(equalToConstant: 36),
            searchText.widthAnchor.constraint(equalToConstant: 343),
            searchText.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 7),
            searchText.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            searchText.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            
            defaultTrackerLogo.heightAnchor.constraint(equalToConstant: 80),
            defaultTrackerLogo.widthAnchor.constraint(equalToConstant: 80),
            defaultTrackerLogo.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            defaultTrackerLogo.topAnchor.constraint(equalTo: searchText.bottomAnchor, constant: 230),
            
            defaultTrackerLabel.heightAnchor.constraint(equalToConstant: 18),
            defaultTrackerLabel.widthAnchor.constraint(equalToConstant: 343),
            defaultTrackerLabel.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            defaultTrackerLabel.topAnchor.constraint(equalTo: defaultTrackerLogo.bottomAnchor, constant: 8),
            
            collection.topAnchor.constraint(equalTo: searchText.topAnchor, constant: 64),
            collection.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            collection.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            collection.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
        ])
    }
    
    private func update() {
        let isEmpty = displayedCategory.isEmpty
        defaultTrackerLogo.isHidden = !isEmpty
        defaultTrackerLabel.isHidden = !isEmpty
        collection.isHidden = isEmpty
        collection.reloadData()
    }
    
    private func refreshTrackersForDate() {
        
        let selectedDate = currentDate
        let calendar = Calendar.current
        let selectedWeekdayNumber = calendar.component(.weekday, from: selectedDate)

        guard let selectedWeekday = WeekDay(rawValue: selectedWeekdayNumber) else {
            displayedCategory = []
            collection.reloadData()
            update()
            return
        }

        displayedCategory = category.compactMap { category in
            let trackersForDate = category.list.filter { tracker in
                return tracker.timing.contains(selectedWeekday)
            }
            if trackersForDate.isEmpty {
                return nil
            } else {
                return TrackerCategory(name: category.name, list: trackersForDate)
            }
        }
        collection.reloadData()
        update()
    }
    
    func newCreationTracker(_ tracker: Tracker, categoryName: String) {
        
        var newCategories = category

        if let index = newCategories.firstIndex(where: { $0.name == categoryName }) {
            let existingCategory = newCategories[index]
            var updatedTrackers = existingCategory.list
            updatedTrackers.append(tracker)
            let updatedCategory = TrackerCategory(name: existingCategory.name, list: updatedTrackers)
            newCategories[index] = updatedCategory
        } else {
            let newCategory = TrackerCategory(name: categoryName, list: [tracker])
            newCategories.append(newCategory)
        }

        category = newCategories
        refreshTrackersForDate()
        update()
        collection.reloadData()
    }
    
    private func markButtonTapped(at indexPath: IndexPath) {
        let selectedDate = currentDate
        let tracker = displayedCategory[indexPath.section].list[indexPath.item]
        
        guard Calendar.current.compare(selectedDate, to: Date(), toGranularity: .day) != .orderedDescending else {
            return
        }
        
        let record = TrackerRecord(trackerId: tracker.id, date: selectedDate)
        
        if doneTrackers.contains(record) {
            doneTrackers.remove(record)
        } else {
            doneTrackers.insert(record)
        }
        collection.reloadItems(at: [indexPath])
    }
}


extension TrackerController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return displayedCategory.count
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return displayedCategory[section].list.count

    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? TrackerCell else {
            return UICollectionViewCell()
        }

        let tracker = displayedCategory[indexPath.section].list[indexPath.item]
        let selectedDate = currentDate
        let isFutureDate = Calendar.current.compare(selectedDate, to: Date(), toGranularity: .day) == .orderedDescending

        let isCompleted = doneTrackers.contains { record in
            record.trackerId == tracker.id && Calendar.current.isDate(record.date, inSameDayAs: selectedDate)
        }
        let completedDays = doneTrackers.filter { $0.trackerId == tracker.id }.count

        cell.config(with: tracker, isCompleted: isCompleted, completedDays: completedDays, isFutureDate: isFutureDate)
        cell.statusTrackerButtonAction = { [weak self] in
            self?.markButtonTapped(at: indexPath)
        }

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader,
              let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: CategoryCell.identifier, for: indexPath) as? CategoryCell else {
            return UICollectionReusableView()
        }
        header.label.text = displayedCategory[indexPath.section].name
        return header
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 18)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let interItemSpacing: CGFloat = 7
        let availableWidth = collectionView.bounds.width - interItemSpacing
        let width = availableWidth / 2
        return CGSize(width: width, height: 141)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 7
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 12, left: 0, bottom: 16, right: 0)
    }
}
