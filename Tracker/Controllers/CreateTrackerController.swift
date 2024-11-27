import UIKit

final class CreateTrackerViewController: UIViewController {
    
    weak var delegate: CreateHabitsControllerDelegate?

    private let habits: UIButton = {
        let button = UIButton()
        button.setTitle("Привычка", for: .normal)
        button.backgroundColor = .black
        button.titleLabel?.font = UIFont(name: "YSDisplay-Medium", size: 16)
        button.layer.cornerRadius = 16
        return button
    }()

    private let events: UIButton = {
        let button = UIButton()
        button.setTitle("Нерегулярное событие", for: .normal)
        button.backgroundColor = .black
        button.titleLabel?.font = UIFont(name: "YSDisplay-Medium", size: 16)
        button.layer.cornerRadius = 16
        return button
    }()
    
    private let label: UILabel = {
        let label = UILabel()
        label.text = "Создание трекера"
        label.textAlignment = .center
        label.font = UIFont(name: "YSDisplay-Medium", size: 16)
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        addSubviews()
        constraints()
        habits.addTarget(self, action: #selector(tapHabitsButton), for: .touchUpInside)
    }
    
    @objc private func tapHabitsButton() {
        
        let createHabitsController = CreateHabitsController()
        createHabitsController.delegate = delegate
        present(createHabitsController, animated: true, completion: nil)
       
    }
    
    
    private func addSubviews() {
        [
         label,
         events,
         habits
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
            
            habits.heightAnchor.constraint(equalToConstant: 60),
            habits.widthAnchor.constraint(equalToConstant: 335),
            habits.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 295),
            habits.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            
            events.heightAnchor.constraint(equalToConstant: 60),
            events.widthAnchor.constraint(equalToConstant: 335),
            events.topAnchor.constraint(equalTo: habits.bottomAnchor, constant: 16),
            events.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20)
            
        ])
    }
}
