import UIKit

protocol FilterSelectionDelegate: AnyObject {
    func didSelectFilter(_ filter: FilterType)
}

final class FilterViewController: UIViewController {
    

    weak var delegate: FilterSelectionDelegate?
    var selectedFilter: FilterType = .all
    private let themeSettings = ThemeSettings.shared
    
    private let label: UILabel = {
        let label = UILabel()
        label.text = "Фильтры"
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        return label
    }()


    private lazy var tableView: UITableView = {
        let table = UITableView()
        table.layer.cornerRadius = 16
        table.rowHeight = 75
        table.backgroundColor = .white
        table.layer.masksToBounds = true
        table.separatorStyle = .singleLine
        table.separatorColor = themeSettings.separatorColor
        table.isScrollEnabled = true
        return table
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        addSubviews()
        setupConstraints()
        setupTableView()
    }

    private func addSubviews() {
        [
           
            label,
            tableView
        ].forEach { [weak self] in
            $0.translatesAutoresizingMaskIntoConstraints = false
            self?.view.addSubview($0)
        }
    }

    func setupConstraints() {
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 38),
            label.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 152),
            label.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -151),
            
            tableView.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 38),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
        ])
    }

    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(FilterCell.self, forCellReuseIdentifier: "FilterViewCell")
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 1))
    }
}


extension FilterViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return FilterType.allCases.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(withIdentifier: "FilterViewCell", for: indexPath) as? FilterCell else {
            fatalError("Не удалось dequeFilterTableViewCell")
        }
        
        let filter = FilterType.allCases[indexPath.row]
        let isSelected = filter.title == selectedFilter.title
        cell.configure(with: filter.title, isSelected: isSelected)

        if indexPath.row == FilterType.allCases.count - 1 {
            cell.layer.cornerRadius = 16
            cell.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            cell.clipsToBounds = true
        } else {
            cell.layer.cornerRadius = 0
            cell.clipsToBounds = false
        }
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let filter = FilterType(rawValue: indexPath.row) else { return }
        selectedFilter = filter
        delegate?.didSelectFilter(filter)
        dismiss(animated: true, completion: nil)
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.separatorInset = (indexPath.row == FilterType.allCases.count - 1)
        ? UIEdgeInsets(top: 0, left: cell.bounds.width, bottom: 0, right: 0)
        : UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
    }
}
