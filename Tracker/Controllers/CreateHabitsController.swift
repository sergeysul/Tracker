import UIKit

protocol CreateHabitsControllerDelegate: AnyObject{
    func newCreationTracker(_ tracker: Tracker, categoryName: String)
}

final class CreateHabitsController: UIViewController, SheduleControllerDelegate{
    
    weak var delegate: CreateHabitsControllerDelegate?
    private let cellId = "Habitcell"
    private var selectedDays: [WeekDay] = []
    
    private let label: UILabel = {
        let label = UILabel()
        label.text = "Новая привычка"
        label.textAlignment = .center
        label.font = UIFont(name: "YSDisplay-Medium", size: 16)
        return label
    }()
    
    private let nameTrackerField: UITextField = {
        let field = UITextField()
        field.text = "Введите название трекера"
        field.font = .systemFont(ofSize: 17)
        field.layer.cornerRadius = 16
        field.backgroundColor = UIColor(red: 230/255, green: 232/255, blue: 235/255, alpha: 0.3)
        field.textColor = UIColor(red: 174/255, green: 175/255, blue: 180/255, alpha: 1.0)
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
        button.backgroundColor = .black
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

    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        traits.dataSource = self
        traits.delegate = self
        nameTrackerField.delegate = self
        addSubviews()
        constraints()
        cancel.addTarget(self, action: #selector(tapCancel), for: .touchUpInside)
        create.addTarget(self, action: #selector(tapCreate), for: .touchUpInside)
    }

    private func addSubviews() {
        [
            
            label,
            nameTrackerField,
            cancel,
            create,
            traits
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
            
            nameTrackerField.heightAnchor.constraint(equalToConstant: 75),
            nameTrackerField.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 38),
            nameTrackerField.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            nameTrackerField.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),

            traits.heightAnchor.constraint(equalToConstant: 150),
            traits.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 197),
            traits.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            traits.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            
            cancel.heightAnchor.constraint(equalToConstant: 60),
            cancel.widthAnchor.constraint(equalToConstant: 166),
            cancel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 1),
            cancel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            
            create.heightAnchor.constraint(equalToConstant: 60),
            create.widthAnchor.constraint(equalToConstant: 166),
            create.centerYAnchor.constraint(equalTo: cancel.centerYAnchor),
            create.leadingAnchor.constraint(equalTo: cancel.trailingAnchor, constant: 8)
        ])
    }
    
    func pickDay(_ days: [WeekDay]) {
        self.selectedDays = days
    }
    
    @objc func tapCancel(){
        dismiss(animated: true, completion: nil)
    }
    
    @objc func tapCreate(){
        guard let habitName = nameTrackerField.text, !habitName.isEmpty else {
            nameTrackerField.text? = "Введите название трекера"
            return
        }
        
        let habit = Tracker(id: UUID(), name: habitName, color: .green, emoji: "😪", timing: selectedDays)
        delegate?.newCreationTracker(habit, categoryName: "Важное")
        dismiss(animated: true, completion: nil)
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

        if (indexPath.row == 0) {
            cell.textLabel?.text = "Категория"
        } else {
            cell.textLabel?.text = "Расписание"
        }
        
        cell.backgroundColor = UIColor(red: 230/255, green: 232/255, blue: 235/255, alpha: 0.3)
        
        let chevron = UIImageView(image: UIImage(named: "Chevron.right"))
        chevron.tag = indexPath.row
        cell.accessoryView = chevron
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (indexPath.row == 0) {
            //cell.textLabel?.text = "Категория"
        } else {
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
}
