import UIKit
import YandexMobileMetrica

final class TrackerController: UIViewController, UITextFieldDelegate, CreateHabitsControllerDelegate, CreateEventsControllerDelegate {
    
    private var completedTrackers: Set<TrackerRecord> = []
    private var categories: [TrackerCategory] = []
    private var currentDate: Date = Date()
    private var displayedCategory: [TrackerCategory] = []
    private var currentFilter: FilterType {
        
        get {
            let rawValue = userDefaults.currentFilterRawValue
            return FilterType(rawValue: rawValue) ?? .all
        }
        set {
            userDefaults.currentFilterRawValue = newValue.rawValue
        }
    }
    private var isUserChangingDate = false
    private let trackerStore = TrackerStore.shared
    private let categoryStore = TrackerCategoryStore.shared
    private let userDefaults = UserDefaultsSettings.shared
    private let recordStore = TrackerRecordStore.shared
    private let textForTrackers = NSLocalizedString("trackers", comment: "Текст лейбла трекеры")
    private let textForSearch = NSLocalizedString("search", comment: "Текст для UISearchTextField")
    private let textForDefaultLabel = NSLocalizedString("emptyState.title", comment: "Текст для defaultTrackerLabel")
    private let textForFilterButton = NSLocalizedString("filter_button", comment: "Текст для filter")
    private let pinnedCategoryName  = NSLocalizedString("pinned", comment: "")
  
    private let trackerButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "plus"), for: .normal)
        button.tintColor = .label
        return button
    }()
    
    private let label: UILabel = {
        let label = UILabel()
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
        searchText.backgroundColor = .systemBackground
        searchText.font = UIFont.systemFont(ofSize: 17)
        return searchText
    }()
    
    private let defaultTrackerLogo: UIImageView = {
        let logo = UIImageView()
        logo.image = UIImage(named: "TrackersDefaultLogo")
        return logo
    }()
    
    private let defaultTrackerLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 12)
        return label
    }()
    
    private var collection: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collection.register(TrackerCell.self, forCellWithReuseIdentifier: "cell")
        collection.backgroundColor = .backgroundDark
        collection.showsVerticalScrollIndicator = false
        return collection
    }()
    
    private lazy var filter: UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor(red: 55/255, green: 114/255, blue: 231/255, alpha: 1)
        button.setTitle(textForFilterButton, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 17)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 16
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        YMMYandexMetrica.reportEvent("Screen Open", parameters: ["event": "open", "screen": "Main"])
        view.backgroundColor = .backgroundDark
        trackerButton.addTarget(self, action: #selector(tapTrackerButton), for: .touchUpInside)
        date.addTarget(self, action: #selector(changeDate), for: .valueChanged)
        filter.addTarget(self, action: #selector(tapFilterButton), for: .touchUpInside)
        collection.delegate = self
        collection.dataSource = self
        searchText.delegate = self
        label.text = textForTrackers
        searchText.placeholder = textForSearch
        defaultTrackerLabel.text = textForDefaultLabel
        collection.register(CategoryCell.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: CategoryCell.identifier)
        addSubviews()
        setupConstraints()
        setupInsetCollection()
        getCategories()
        getDoneTrackers()
        userDefaults.loadPinnedTrackers()
        applyCurrentFilter()
        updateTrackerView()
    }
    
    @objc private func tapTrackerButton() {
        YMMYandexMetrica.reportEvent("TapTrackerButton", parameters: ["event": "click", "screen": "Main", "item": "add_track"])
        let createTracker = CreateTrackerViewController()
        createTracker.delegateHabit = self
        createTracker.delegateEvent = self
        present(createTracker, animated: true, completion: nil)
    }
    
    @objc private func changeDate(_ sender: UIDatePicker) {
        currentDate = sender.date
        applyCurrentFilter()
    }
    
    @objc private func tapFilterButton() {
        YMMYandexMetrica.reportEvent("TapFilterButton", parameters: ["event": "click", "screen": "Main", "item": "filter"])
        let filterVC = FilterViewController()
        filterVC.selectedFilter = currentFilter
        filterVC.delegate = self
        filterVC.modalPresentationStyle = .formSheet
        present(filterVC, animated: true, completion: nil)
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
            filter
        ].forEach { [weak self] in
            $0.translatesAutoresizingMaskIntoConstraints = false
            self?.view.addSubview($0)
        }
    }
    
    private func setupConstraints() {
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
            date.widthAnchor.constraint(equalToConstant: 97),
            date.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 5),
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
            
            filter.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            filter.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            filter.heightAnchor.constraint(equalToConstant: 50),
            filter.widthAnchor.constraint(equalToConstant: 114),
        ])
    }
    
    private func getCategories() {
        
        categoryStore.fetchCategories { [weak self] categories in
            DispatchQueue.main.async {
                
                guard let self = self else { return }
                var filteredCategories = categories.filter { !$0.list.isEmpty }
                let allTrackers = filteredCategories.flatMap { $0.list }
                let pinnedTrackerList = allTrackers.filter { self.userDefaults.isPinned(trackerId: $0.id) }
                
                filteredCategories.removeAll { $0.name == NSLocalizedString("pinned", comment: "") }
        
                for (index, category) in filteredCategories.enumerated() {
                    let trackersWithoutPinned = category.list.filter { !self.userDefaults.isPinned(trackerId: $0.id) }
                    filteredCategories[index] = TrackerCategory(name: category.name, list: trackersWithoutPinned)
                }
                
                filteredCategories = filteredCategories.filter { !$0.list.isEmpty }
            
                if !pinnedTrackerList.isEmpty {
                    let pinnedCategory = TrackerCategory(name: NSLocalizedString("pinned", comment: ""), list: pinnedTrackerList)
                    filteredCategories.insert(pinnedCategory, at: 0)
                }
   
                self.categories = filteredCategories
                self.applyCurrentFilter()
                self.updateTrackerView()
            }
        }
    }


    private func getDoneTrackers() {
        recordStore.fetchRecords { [weak self] records in
            DispatchQueue.main.async {
                self?.completedTrackers = Set(records)
                self?.applyCurrentFilter()
                self?.collection.reloadData()
            }
            
        }
    }

    private func reloadCompletedTrackers(completion: @escaping () -> Void) {
        recordStore.fetchRecords { [weak self] records in
            DispatchQueue.main.async {
                self?.completedTrackers = Set(records)
                completion()
            }
        }
    }

    private func updateTrackerView() {
        let trackersOnSelectedDate = displayedCategory.flatMap { $0.list }
        
        if trackersOnSelectedDate.isEmpty {
            if currentFilter == .completed || currentFilter == .incomplete {
                defaultTrackerLogo.isHidden = false
                defaultTrackerLabel.isHidden = false
                filter.isHidden = false
                collection.isHidden = true

                defaultTrackerLabel.text = "Ничего не найдено"
                defaultTrackerLogo.image = UIImage(named: "NothingFoundLogo")
            } else {
                defaultTrackerLogo.isHidden = false
                defaultTrackerLabel.isHidden = false
                filter.isHidden = true
                collection.isHidden = true

                defaultTrackerLabel.text = textForDefaultLabel
                defaultTrackerLogo.image = UIImage(named: "TrackersDefaultLogo")
            }
        } else {
            defaultTrackerLogo.isHidden = true
            defaultTrackerLabel.isHidden = true
            filter.isHidden = false
            collection.isHidden = false
        }
        collection.reloadData()
    }

    
    
    private func refreshTrackersForDate() {
        
        let selectedDate = currentDate

        displayedCategory = categories.compactMap { category in
            let trackersForDate = category.list.filter { tracker in
                category.name == pinnedCategoryName ||
                tracker.timing.contains { day in
                    switch day {
                    case .special(let date):
                        return Calendar.current.isDate(date, inSameDayAs: selectedDate)
                    default:
                        return day == WeekDay.from(date: selectedDate)
                    }
                }
            }
            if trackersForDate.isEmpty {
                return nil
            } else {
                return TrackerCategory(name: category.name, list: trackersForDate)
            }
        }
          
        collection.reloadData()
        updateTrackerView()
    }


    
    private func setupInsetCollection() {
        
        let filterButtonHeight: CGFloat = 50
        let filterButtonBottomPadding: CGFloat = 16
        let totalBottomInset = filterButtonHeight + filterButtonBottomPadding + 16

        collection.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: totalBottomInset, right: 0)
        collection.verticalScrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: totalBottomInset, right: 0)
        collection.alwaysBounceVertical = true
        collection.contentInsetAdjustmentBehavior = .never
    }
    
    func trackerUpdate(_ tracker: Tracker, categoryName: String) {
        getCategories()
    }
    
    
    func newCreationTracker(_ tracker: Tracker, categoryName: String) {
        getCategories()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    private func markButtonTapped(at indexPath: IndexPath) {
        let selectedDate = currentDate
        let tracker = displayedCategory[indexPath.section].list[indexPath.item]
        YMMYandexMetrica.reportEvent("TapMarkButton", parameters: ["event": "click", "screen": "Main", "item": "track"])
        let isCompleted = completedTrackers.first { record in
            record.trackerId == tracker.id && Calendar.current.isDate(record.date, inSameDayAs: selectedDate)
        }
        
        guard Calendar.current.compare(selectedDate, to: Date(), toGranularity: .day) != .orderedDescending else {
            return
        }

        if let record = isCompleted {
            recordStore.delete(trackerId: tracker.id, date: record.date) { [weak self] success in
                guard success else { return }
                self?.reloadCompletedTrackers {
                    DispatchQueue.main.async {
                        self?.collection.reloadItems(at: [indexPath])
                    }
                }
            }
        } else {
            recordStore.add(trackerId: tracker.id, date: selectedDate) { [weak self] success in
                guard success else { return }
                self?.reloadCompletedTrackers {
                    DispatchQueue.main.async {
                        self?.collection.reloadItems(at: [indexPath])
                    }
                }
            }
        }
    }
    
    
    private func applyCurrentFilter() {
        
        switch currentFilter {
        case .all:
            refreshTrackersForDate()
        case .today:
            currentDate = Date()
            date.setDate(currentDate, animated: true)
            refreshTrackersForDate()
        case .completed:
            displayedCategory = categories.compactMap { category in
                let filteredTrackers = category.list.filter { tracker in
                    completedTrackers.contains { $0.trackerId == tracker.id && Calendar.current.isDate($0.date, inSameDayAs: currentDate) }
                }
                return filteredTrackers.isEmpty ? nil : TrackerCategory(name: category.name, list: filteredTrackers)
            }
        case .incomplete:
            displayedCategory = categories.compactMap { category in
                let filteredTrackers = category.list.filter { tracker in
                    !completedTrackers.contains { $0.trackerId == tracker.id && Calendar.current.isDate($0.date, inSameDayAs: currentDate) }
                }
                return filteredTrackers.isEmpty ? nil : TrackerCategory(name: category.name, list: filteredTrackers)
            }
        }
        collection.reloadData()
        updateTrackerView()
    }
    
    private func togglePinTracker(_ tracker: Tracker, at indexPath: IndexPath) {
        
        if userDefaults.isPinned(trackerId: tracker.id) {
            userDefaults.removePinnedTracker(id: tracker.id)
        } else {
            userDefaults.addPinnedTracker(id: tracker.id)
        }
        getCategories()
        collection.reloadData()
    }


    private func deleteTracker(_ tracker: Tracker, at indexPath: IndexPath) {
        trackerStore.deleteTracker(tracker) { [weak self] success in
            guard let self = self else { return }
            if success {
                DispatchQueue.main.async {
                    let category = self.displayedCategory[indexPath.section]
                    let updatedTrackers = category.list.filter { $0.id != tracker.id }
                    if updatedTrackers.isEmpty {
                        self.displayedCategory.remove(at: indexPath.section)
                    } else {
                        let updatedCategory = TrackerCategory(name: category.name, list: updatedTrackers)
                        self.displayedCategory[indexPath.section] = updatedCategory
                    }

                    if self.userDefaults.isPinned(trackerId: tracker.id) {
                        self.userDefaults.removePinnedTracker(id: tracker.id)
                    }

                    self.getCategories()
                    self.collection.reloadData()
                }
            } else {
                print("Не удалось удалить трекер")
            }
        }
    }

    private func editTracker(_ tracker: Tracker) {
        let editViewController = CreateHabitsController()
        editViewController.trackerForEdit = tracker
        editViewController.isEditingTracker = true
        editViewController.delegate = self
        editViewController.title = "Редактирование привычки"
        present(editViewController, animated: true)
    }


    private func presentEditController(for tracker: Tracker) {
        YMMYandexMetrica.reportEvent("TapEdit", parameters: ["event": "click", "screen": "Main", "item": "edit"])
        if tracker.timing.contains(where: { day in
            if case .special = day { return true }
            return false
        }) {
            guard tracker.timing.compactMap({ day -> Date? in
                if case .special(let date) = day {
                    return date
                }
                return nil
            }).first != nil else {
                return
            }
            let editViewController = CreateEventsController()
            editViewController.trackerForEdit = tracker
            editViewController.isEditingTracker = true
            editViewController.delegate = self
            editViewController.title = "Редактирование нерегулярного события"
            present(editViewController, animated: true)
        } else {
            editTracker(tracker)
        }
    }

    
    private func presentDeleteConfirmation(for tracker: Tracker, at indexPath: IndexPath) {
        YMMYandexMetrica.reportEvent("TapDelete", parameters: ["event": "click", "screen": "Main", "item": "delete"])
        let alertController = UIAlertController(title: nil, message: "Уверены что хотите удалить трекер?", preferredStyle: .actionSheet)

        let deleteAction = UIAlertAction(title: "Удалить", style: .destructive) { _ in
            self.deleteTracker(tracker, at: indexPath)
        }

        let cancelAction = UIAlertAction(title: "Отменить", style: .cancel, handler: nil)
        alertController.addAction(deleteAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
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

        let isCompleted = completedTrackers.contains { record in
            record.trackerId == tracker.id && Calendar.current.isDate(record.date, inSameDayAs: selectedDate)
        }
        let completedDays = completedTrackers.filter { $0.trackerId == tracker.id }.count
        let isPinned = userDefaults.isPinned(trackerId: tracker.id)

        cell.config(with: tracker, isCompleted: isCompleted, completedDays: completedDays, isFutureDate: isFutureDate, isPinned: isPinned)
        cell.statusTrackerButtonAction = { [weak self] in
            self?.markButtonTapped(at: indexPath)
        }

        return cell
    }

    func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath
    ) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader,
              let header = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: CategoryCell.identifier,
                for: indexPath
              ) as? CategoryCell else { return UICollectionReusableView()}
        header.updateLabel(text: displayedCategory[indexPath.section].name)
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
    
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        
        return UIContextMenuConfiguration(identifier: indexPath as NSIndexPath, previewProvider: nil) { _ in
            let tracker = self.displayedCategory[indexPath.section].list[indexPath.item]
            
            let pinTitle = self.userDefaults.isPinned(trackerId: tracker.id) ? "Открепить" : "Закрепить"
            let pinAction = UIAction(title: pinTitle) { _ in
                self.togglePinTracker(tracker, at: indexPath)
            }
                        
            let editAction = UIAction(title: "Редактировать") { _ in
                self.presentEditController(for: tracker)
            }

            
            let deleteAction = UIAction(title: "Удалить", attributes: .destructive) { _ in
                self.presentDeleteConfirmation(for: tracker, at: indexPath)
            }

            return UIMenu(title: "", children: [pinAction, editAction, deleteAction])
        }
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, previewForHighlightingContextMenuWithConfiguration configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
        guard let indexPath = configuration.identifier as? IndexPath,
                let cell = collectionView.cellForItem(at: indexPath) as? TrackerCell else {
            return nil
        }

        let parameters = UIPreviewParameters()
        parameters.backgroundColor = .clear

        return UITargetedPreview(view: cell, parameters: parameters)
    }

    func collectionView(_ collectionView: UICollectionView, previewForDismissingContextMenuWithConfiguration configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
        guard let indexPath = configuration.identifier as? IndexPath,
                let cell = collectionView.cellForItem(at: indexPath) as? TrackerCell else {
            return nil
        }

        let parameters = UIPreviewParameters()
        parameters.backgroundColor = .clear

        return UITargetedPreview(view: cell, parameters: parameters)
    }

}


extension TrackerController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        if let searchText = searchController.searchBar.text, !searchText.isEmpty {
            displayedCategory = categories.compactMap { category in
                let filteredTrackers = category.list.filter { tracker in
                    tracker.name.lowercased().contains(searchText.lowercased())
                }
                
                if filteredTrackers.isEmpty {
                    return nil
                } else {
                    return TrackerCategory(name: category.name, list: filteredTrackers)
                }
            }
            collection.reloadData()
            updateTrackerView()
        } else {
            applyCurrentFilter()
        }
    }
}

extension TrackerController: FilterSelectionDelegate {
    func didSelectFilter(_ filter: FilterType) {
        currentFilter = filter
        applyCurrentFilter()
    }
}
