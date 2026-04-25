import Foundation

// MARK: - CategoryViewModel

final class CategoryViewModel {
    // MARK: - Bindings (замыкания для биндингов)

    var categoriesDidChange: (([String]) -> Void)?
    var selectedCategoryDidChange: ((String?) -> Void)?
    var errorDidOccur: ((String) -> Void)?

    // MARK: - Properties

    private let categoryStore: TrackerCategoryStore
    private(set) var categories: [String] = [] {
        didSet {
            categoriesDidChange?(categories)
        }
    }

    private(set) var selectedCategory: String? {
        didSet {
            selectedCategoryDidChange?(selectedCategory)
        }
    }

    // MARK: - Initialization
    init(categoryStore: TrackerCategoryStore = TrackerCategoryStore(), selectedCategory: String? = nil) {
        self.categoryStore = categoryStore
        self.selectedCategory = selectedCategory
        self.categoryStore.delegate = self
        loadCategories()
    }

    // MARK: - Public Methods
    func loadCategories() {
        let categoryModels = categoryStore.categories
        categories = categoryModels.map { $0.title }
    }

    func selectCategory(_ category: String?) {
        selectedCategory = category
    }

    func createCategory(name: String) {
        do {
            _ = try categoryStore.addCategory(with: name)
        } catch {
            errorDidOccur?("Не удалось создать категорию: \(error.localizedDescription)")
        }
    }

    func updateCategory(oldName: String, newName: String) {
        guard let categoryId = categoryStore.fetchCategoryId(for: oldName) else {
            errorDidOccur?("Категория не найдена")
            return
        }
        do {
            try categoryStore.updateCategory(categoryId, with: newName)
        } catch {
            errorDidOccur?("Не удалось обновить категорию: \(error.localizedDescription)")
        }
    }

    func deleteCategory(_ category: String) {
        guard let categoryId = categoryStore.fetchCategoryId(for: category) else {
            errorDidOccur?("Категория не найдена")
            return
        }
        do {
            try categoryStore.deleteCategory(with: categoryId)

            if category == selectedCategory {
                selectedCategory = nil
            }
        } catch {
            errorDidOccur?("Не удалось удалить категорию: \(error.localizedDescription)")
        }
    }

    func numberOfCategories() -> Int {
        return categories.count
    }

    func category(at index: Int) -> String {
        return categories[index]
    }

    func isCategorySelected(at index: Int) -> Bool {
        let category = categories[index]
        return category == selectedCategory
    }

    func hasSelectedCategory() -> Bool {
        return selectedCategory != nil
    }
}

// MARK: - TrackerCategoryStoreDelegate
extension CategoryViewModel: TrackerCategoryStoreDelegate {
    func didUpdateCategories() {
        loadCategories()
    }
}
