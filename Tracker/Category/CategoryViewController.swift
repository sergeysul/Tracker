import UIKit
import Foundation

protocol CategorySelectionDelegate: AnyObject {
    func pickCategory(_ category: TrackerCategory)
}

protocol CategoryViewModelProtocol: AnyObject {
    
    var changedCategories: (([TrackerCategory]) -> Void)? { get set }
    var categories: [TrackerCategory] { get }
    func fetchCategories()
    func addCategory(name: String)
}

final class CategoryViewController: UIViewController {
    
    private let viewModel: CategoryViewModelProtocol
    private var pickedCategory: TrackerCategory?
    weak var delegate: CategorySelectionDelegate?
    
    
    init(viewModel: CategoryViewModelProtocol, pickedCategory: TrackerCategory? = nil) {
        self.viewModel = viewModel
        self.pickedCategory = pickedCategory
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var label: UILabel = {
        let label = UILabel()
        label.text = "Категория"
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        return label
    }()
    
    private lazy var defaultLogo: UIImageView = {
        let logo = UIImageView()
        logo.image = UIImage(named: "TrackersDefaultLogo")
        logo.contentMode = .scaleAspectFit
        return logo
    }()
    
    private lazy var defaultLabel: UILabel = {
        let label = UILabel()
        label.text = "Привычки и события можно\nобъединить по смыслу"
        label.numberOfLines = 2
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textAlignment = .center
        label.textColor = .black
        return label
    }()
    
    private lazy var tableView: UITableView = {
        let table = UITableView()
        table.layer.cornerRadius = 16
        table.layer.masksToBounds = true
        table.separatorStyle = .singleLine
        table.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        table.rowHeight = 75
        table.isScrollEnabled = true
        return table
    }()
    
    private lazy var add: UIButton = {
        let button = UIButton()
        button.setTitle("Добавить категорию", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = .black
        button.layer.cornerRadius = 16
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        addSubviews()
        setupConstraints()
        setupTableView()
        fetchCategories()
        updateView()
        add.addTarget(self, action: #selector(tapAdd), for: .touchUpInside)
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(CreateCategoryCell.self, forCellReuseIdentifier: "CategoryTableCell")
        tableView.tableFooterView = UIView()
    }
    
    
    private func addSubviews() {
        [
            label,
            defaultLogo,
            defaultLabel,
            tableView,
            add
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
            
            defaultLogo.heightAnchor.constraint(equalToConstant: 80),
            defaultLogo.widthAnchor.constraint(equalToConstant: 80),
            defaultLogo.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            defaultLogo.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 246),
            
            defaultLabel.heightAnchor.constraint(equalToConstant: 36),
            defaultLabel.widthAnchor.constraint(equalToConstant: 343),
            defaultLabel.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            defaultLabel.topAnchor.constraint(equalTo: defaultLogo.bottomAnchor, constant: 8),
            
            tableView.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 38),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            tableView.bottomAnchor.constraint(equalTo: add.topAnchor, constant: -28),
            
            
            add.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            add.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            add.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            add.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    private func updateView() {
        let isEmpty = viewModel.categories.isEmpty
        defaultLogo.isHidden = !isEmpty
        defaultLabel.isHidden = !isEmpty
        tableView.isHidden = isEmpty
    }

    
    private func fetchCategories() {
        viewModel.changedCategories = { [weak self] categories in
            DispatchQueue.main.async {
                self?.updateView()
                self?.tableView.reloadData()
            }
        }
        viewModel.fetchCategories()
    }
    
    
    @objc private func tapAdd() {
        let createCategoryController = CategoryCreateViewController(viewModel: viewModel)
        present(createCategoryController, animated: true, completion: nil)
    }
}


extension CategoryViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.categories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryTableCell", for: indexPath) as? CreateCategoryCell else {
            fatalError("Failed to dequeue CategoryTableCell")
        }
        
        let category = viewModel.categories[indexPath.row]
        
        let picked = category.name == pickedCategory?.name
        
        cell.configure(with: category.name, isSelected: picked)
        
        if indexPath.row == viewModel.categories.count - 1 {
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
        let picked = viewModel.categories[indexPath.row]
        pickedCategory = picked
        
        tableView.reloadData()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
            guard let self = self else { return }
            self.delegate?.pickCategory(picked)
            
            if let navigationController = self.navigationController {
                navigationController.popViewController(animated: true)
            } else {
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
}
