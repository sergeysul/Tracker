import UIKit
import Foundation


final class StatsController: UIViewController {
    
    private let trackerRecordStore = TrackerRecordStore.shared
    private let trackerStore = TrackerStore.shared
    private var statistics: [Stats] = []
    
    private lazy var label: UILabel = {
        let label = UILabel()
        label.text =  "Статистика"
        label.font = .systemFont(ofSize: 34, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var table: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(StatsCell.self, forCellReuseIdentifier: StatsCell.identifier)
        tableView.separatorStyle = .none
        tableView.backgroundColor = .white
        return tableView
    }()
    
    private lazy var defaultImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "NothingFoundLogo")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var defaultLabel: UILabel = {
        let label = UILabel()
        label.text = "Анализировать пока нечего"
        label.font = .systemFont(ofSize: 12)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var emptyStateView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 8
        return stackView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        addSubviews()
        setupConstraints()
        updateView()
        loadStats()
        NotificationCenter.default.addObserver(self, selector: #selector(handleTrackerRecordDidChange), name: NSNotification.Name("TrackerRecordDidChange"), object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name("TrackerRecordDidChange"), object: nil)
    }
    
    func addSubviews() {
        view.addSubview(label)
        [defaultImage, defaultLabel].forEach{
            emptyStateView.addArrangedSubview($0)
        }
        [table, emptyStateView].forEach{
            view.addSubview($0)
        }
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            label.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            label.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),

            table.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 70),
            table.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            table.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            table.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            emptyStateView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyStateView.widthAnchor.constraint(lessThanOrEqualTo: view.widthAnchor, multiplier: 0.8)
        ])
    }
    
    private func loadStats() {
        trackerRecordStore.fetchRecords { [weak self] records in
            guard let self = self else { return }
            self.trackerStore.fetchTrackers { trackers in
                self.calculateStatistics(records: records, trackers: trackers)
                DispatchQueue.main.async {
                    self.table.reloadData()
                    self.updateView()
                }
            }
        }
    }
    
    @objc private func handleTrackerRecordDidChange() {
        loadStats()
    }
        
    private func calculateStatistics(records: [TrackerRecord], trackers: [Tracker]) {
        guard !records.isEmpty else {
            statistics = []
            updateView()
            return
        }
        
        let totalCompleted = records.count
        let averageCompletion = calculateAverage(records: records)
        
        statistics = [
            Stats(number: "\(totalCompleted)", title: "Трекеров завершено"),
            Stats(number: "\(averageCompletion)", title: "Среднее значение"),
        ]
        
        DispatchQueue.main.async {
            self.updateView()
            self.table.reloadData()
        }
    }
    
    private func calculateAverage(records: [TrackerRecord]) -> Int {
        guard !records.isEmpty else { return 0 }
        
        let groupedByDay = Dictionary(grouping: records, by: { Calendar.current.startOfDay(for: $0.date) })
        let daysCount = groupedByDay.count
        
        return records.count / daysCount
    }
    
    private func updateView() {
        let hasData = !statistics.isEmpty
        table.isHidden = !hasData
        emptyStateView.isHidden = hasData
    }
}


extension StatsController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return statistics.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: StatsCell.identifier, for: indexPath) as? StatsCell else {
            return UITableViewCell()
        }
        
        let statistic = statistics[indexPath.row]
        cell.configure(with: statistic)
        return cell
    }
}

