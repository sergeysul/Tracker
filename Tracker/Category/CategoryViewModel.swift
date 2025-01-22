import Foundation


final class CategoryViewModel: CategoryViewModelProtocol {
    
    private let store: TrackerCategoryStore
    
    var changedCategories: (([TrackerCategory]) -> Void)?
    
    var categories: [TrackerCategory] = [] {
        didSet {
            changedCategories?(categories)
        }
    }
    
    init(store: TrackerCategoryStore = .shared) {
        self.store = store
    }

    func fetchCategories() {
        store.fetchCategories { [weak self] categories in
            self?.categories = categories
        }
    }

    func addCategory(name: String) {
        store.createCategory(name: name) { [weak self] category in
            guard let newCategory = category else { return }
            self?.categories.append(newCategory)
        }
    }
}
