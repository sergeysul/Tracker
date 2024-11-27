import UIKit

protocol SheduleControllerDelegate: AnyObject {
    func pickDay(_ days: [WeekDay])
}

final class SheduleController: UIViewController{
    
    weak var delegate: SheduleControllerDelegate?
    var selectedDays: Set<WeekDay> = []
    
    private let weekDays: [WeekDay] = {
        let allDays = WeekDay.allCases
        let startIndex = allDays.firstIndex(of: .monday) ?? 0
        let reorderedDays = allDays[startIndex...] + allDays[..<startIndex]
        return Array(reorderedDays)
    }()
    
    private let label: UILabel = {
        let label = UILabel()
        label.text = "Расписание"
        label.textAlignment = .center
        label.font = UIFont(name: "YSDisplay-Medium", size: 16)
        return label
    }()
    
    private let week: UITableView = {
        let table = UITableView()
        table.layer.cornerRadius = 16
        table.separatorStyle = .singleLine
        table.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        //table.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        //table.clipsToBounds = true
        table.isScrollEnabled = false
        return table
    }()
    
    private let confirm: UIButton = {
        let button = UIButton()
        button.setTitle("Готово", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont(name: "YSDisplay-Medium", size: 16)
        button.layer.cornerRadius = 16
        button.backgroundColor = .black
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        week.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        week.dataSource = self
        week.delegate = self
        addSubviews()
        constraints()
        confirm.addTarget(self, action: #selector(tapConfirm), for: .touchUpInside)
    }

    private func addSubviews() {
        [
           label,
           week,
           confirm
        ].forEach { [weak self] in
            $0.translatesAutoresizingMaskIntoConstraints = false
            self?.view.addSubview($0)
        }
    }
    
    private func constraints() {
        NSLayoutConstraint.activate([
                
            label.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 38),
            label.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 114),
            label.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -112),

            week.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 90),
            week.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 123),
            week.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            week.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),

            confirm.heightAnchor.constraint(equalToConstant: 60),
            confirm.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 662),
            confirm.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            confirm.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16)
        ])
    }
    
    @objc private func switchChanged(_ sender: UISwitch) {
        
        let day = weekDays[sender.tag]

        if sender.isOn {
            selectedDays.insert(day)
        } else {
            selectedDays.remove(day)
        }
    }
    
    @objc private func tapConfirm(){
        
        let sortedDays = selectedDays.sorted { (day1, day2) -> Bool in
                guard let index1 = weekDays.firstIndex(of: day1),
                      let index2 = weekDays.firstIndex(of: day2) else {
                    return false
                }
                return index1 < index2
        }
        delegate?.pickDay(sortedDays)
        dismiss(animated: true, completion: nil)
    }
}

extension SheduleController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return WeekDay.allCases.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let day = weekDays[indexPath.row]
        
        let switchUI = UISwitch(frame: .zero)
        switchUI.setOn(selectedDays.contains(day), animated: true)
        switchUI.tag = indexPath.row
        switchUI.onTintColor = UIColor(red: 55/255, green: 114/255, blue: 231/255, alpha: 1.0)
        switchUI.addTarget(self, action: #selector(switchChanged(_:)), for: .valueChanged)

        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = day.displayName
        cell.backgroundColor = UIColor(red: 230/255, green: 232/255, blue: 235/255, alpha: 0.3)
        cell.textLabel?.font = .systemFont(ofSize: 17)
        cell.accessoryView = switchUI
        
        if indexPath.row == weekDays.count - 1 {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
        }
        return cell
    }
}
