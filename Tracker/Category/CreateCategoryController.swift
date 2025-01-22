import UIKit
import Foundation

final class CategoryCreateViewController: UIViewController {
    
    private let viewModel: CategoryViewModelProtocol

    init(viewModel: CategoryViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private lazy var label: UILabel = {
        let label = UILabel()
        label.text = "Новая категория"
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        return label
    }()

    private lazy var nameCategoryField: UITextField = {
        let field = UITextField()
        field.placeholder = "Введите название категории"
        field.font = .systemFont(ofSize: 17)
        field.layer.cornerRadius = 16
        field.backgroundColor = UIColor(red: 230/255, green: 232/255, blue: 235/255, alpha: 0.3)
        let leftEdge = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: field.frame.height))
        field.leftView = leftEdge
        field.leftViewMode = .always
        let rightEdge = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: field.frame.height))
        field.rightView = rightEdge
        field.rightViewMode = .always
        return field
    }()
    
    
    private lazy var create: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Готово", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .gray
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.layer.cornerRadius = 16
        button.backgroundColor = .gray
        return button
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addSubviews()
        setupConstraints()
        navigationItem.hidesBackButton = true
        view.backgroundColor = .white
        nameCategoryField.delegate = self
        nameCategoryField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        create.addTarget(self, action: #selector(tapCreate), for: .touchUpInside)
    }
    
    private func addSubviews() {
        [
            label,
            nameCategoryField,
            create
        ].forEach { [weak self] in
            $0.translatesAutoresizingMaskIntoConstraints = false
            self?.view.addSubview($0)
        }
    }

    func setupConstraints() {
        NSLayoutConstraint.activate([
            
            label.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 38),
            label.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 122),
            label.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -120),
            
            nameCategoryField.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 38),
            nameCategoryField.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            nameCategoryField.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            nameCategoryField.heightAnchor.constraint(equalToConstant: 75),

            create.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            create.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            create.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            create.heightAnchor.constraint(equalToConstant: 60)
        ])
    }

    private func refreshCreateButton() {
        
        let completedCategory = nameCategoryField.text?.isEmpty == false
        create.isEnabled = completedCategory
        create.backgroundColor = completedCategory ? .black : .gray
    }

    @objc private func textFieldDidChange() {
        refreshCreateButton()
    }

    @objc private func tapCreate() {
        guard let categoryName = nameCategoryField.text, !categoryName.isEmpty else { return }
        viewModel.addCategory(name: categoryName)
        dismiss(animated: true, completion: nil)
    }
}


extension CategoryCreateViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
