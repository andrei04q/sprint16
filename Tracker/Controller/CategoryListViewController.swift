import UIKit

protocol CategoryListViewControllerDelegate: AnyObject {
    func categoryListViewController(_ viewController: CategoryListViewController, didSelectCategory category: String?)
}

final class CategoryListViewController: UIViewController {
    // MARK: - Properties
    weak var delegate: CategoryListViewControllerDelegate?

    private let viewModel: CategoryViewModel
    private let tableView = UITableView(frame: .zero, style: .plain)
    private let addButton = UIButton(type: .system)
    private let placeholderView = PlaceholderView()

    private var selectedCategory: String? {
        didSet {
            updateUI()
        }
    }

    // MARK: - Initialization
    init(viewModel: CategoryViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.setHidesBackButton(true, animated: false)
        setupUI()
        setupBindings()
        viewModel.loadCategories()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavigationBar()
    }

    // MARK: - Setup Methods
    private func setupNavigationBar() {
        title = "Категория"
        navigationController?.navigationBar.prefersLargeTitles = false

        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(resource: .ypWhite)
        appearance.titleTextAttributes = [
            .font: UIFont.systemFont(ofSize: 16, weight: .medium),
            .foregroundColor: UIColor(resource: .ypBlack)
        ]

        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.compactAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
    }

    private func setupUI() {
        view.backgroundColor = UIColor(resource: .ypWhite)

        setupTableView()
        setupAddButton()
        setupPlaceholderView()
        updateUI()
    }

    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(CategoryCell.self, forCellReuseIdentifier: CategoryCell.identifier)
        tableView.backgroundColor = UIColor(resource: .ypWhite)
        tableView.separatorStyle = .singleLine
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        tableView.separatorColor = UIColor(resource: .ypGray).withAlphaComponent(0.3)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 16))
        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 16))

        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -100)
        ])
    }

    private func setupAddButton() {
        addButton.setTitle("Добавить категорию", for: .normal)
        addButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        addButton.setTitleColor(.white, for: .normal)
        addButton.backgroundColor = UIColor(resource: .ypBlack)
        addButton.layer.cornerRadius = 16
        addButton.layer.masksToBounds = true
        addButton.addTarget(self, action: #selector(didTapAddCategory), for: .touchUpInside)
        addButton.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(addButton)

        NSLayoutConstraint.activate([
            addButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            addButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            addButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            addButton.heightAnchor.constraint(equalToConstant: 60)
        ])

        tableView.bottomAnchor.constraint(equalTo: addButton.topAnchor, constant: -16).isActive = true
    }

    private func setupPlaceholderView() {
        placeholderView.configure(
            image: UIImage(named: "errorStar"),
            title: "Привычки и события можно\nобъединить по смыслу",
            subtitle: nil
        )
        placeholderView.isHidden = true
        placeholderView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(placeholderView)

        NSLayoutConstraint.activate([
            placeholderView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            placeholderView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            placeholderView.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 16),
            placeholderView.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -16)
        ])
    }

    private func setupBindings() {
        viewModel.categoriesDidChange = { [weak self] _ in
            DispatchQueue.main.async {
                self?.updateUI()
                self?.tableView.reloadData()
            }
        }

        viewModel.selectedCategoryDidChange = { [weak self] category in
            DispatchQueue.main.async {
                self?.selectedCategory = category
                self?.notifyDelegate()
            }
        }

        viewModel.errorDidOccur = { [weak self] errorMessage in
            DispatchQueue.main.async {
                self?.showErrorAlert(message: errorMessage)
            }
        }
    }

    private func notifyDelegate() {
        delegate?.categoryListViewController(self, didSelectCategory: selectedCategory)
    }

    // MARK: - UI Updates
    private func updateUI() {
        let hasCategories = viewModel.numberOfCategories() > 0
        tableView.isHidden = !hasCategories
        placeholderView.isHidden = hasCategories
    }

    private func showErrorAlert(message: String) {
        let alert = UIAlertController(
            title: "Ошибка",
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    // MARK: - Actions
    @objc private func didTapAddCategory() {
        showNewCategoryScreen(isEditing: false, category: nil)
    }

    private func showNewCategoryScreen(isEditing: Bool, category: String?) {
        let newCategoryVC = NewCategoryViewController(categoryName: category)

        newCategoryVC.onSave = { [weak self] categoryName in
            if isEditing, let oldCategory = category {
                self?.viewModel.updateCategory(oldName: oldCategory, newName: categoryName)
            } else {
                self?.viewModel.createCategory(name: categoryName)

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    self?.viewModel.selectCategory(categoryName)
                }
            }
        }

        navigationController?.pushViewController(newCategoryVC, animated: true)
    }

    private func showDeleteConfirmation(for category: String, at indexPath: IndexPath) {
        let alert = UIAlertController(
            title: "Эта категория точно не нужна?",
            message: nil,
            preferredStyle: .actionSheet
        )

        alert.addAction(UIAlertAction(title: "Удалить", style: .destructive) { [weak self] _ in
            self?.viewModel.deleteCategory(category)
        })

        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel))

        if let popoverController = alert.popoverPresentationController {
            popoverController.sourceView = tableView
            popoverController.sourceRect = tableView.rectForRow(at: indexPath)
        }

        present(alert, animated: true)
    }
}

// MARK: - UITableViewDataSource
extension CategoryListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfCategories()
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: CategoryCell.identifier,
            for: indexPath
        ) as? CategoryCell else {
            return UITableViewCell()
        }

        let category = viewModel.category(at: indexPath.row)
        let isSelected = viewModel.isCategorySelected(at: indexPath.row)
        let isLastCell = indexPath.row == viewModel.numberOfCategories() - 1
        let isFirstCell = indexPath.row == 0

        cell.configure(
            with: category,
            isSelected: isSelected,
            isLastCell: isLastCell,
            isFirstCell: isFirstCell
        )

        return cell
    }
}

// MARK: - UITableViewDelegate
extension CategoryListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let category = viewModel.category(at: indexPath.row)
        viewModel.selectCategory(category)
        tableView.reloadData()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.navigationController?.popViewController(animated: true)
        }
    }

    func tableView(
        _ tableView: UITableView,
        trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath
    ) -> UISwipeActionsConfiguration? {
        let category = viewModel.category(at: indexPath.row)

        let deleteAction = UIContextualAction(style: .destructive, title: "Удалить") { [weak self] _, _, completion in
            self?.showDeleteConfirmation(for: category, at: indexPath)
            completion(true)
        }

        let editAction = UIContextualAction(style: .normal, title: "Редактировать") { [weak self] _, _, completion in
            self?.showNewCategoryScreen(isEditing: true, category: category)
            completion(true)
        }
        editAction.backgroundColor = UIColor(resource: .ypBlue)

        return UISwipeActionsConfiguration(actions: [deleteAction, editAction])
    }

    func tableView(
        _ tableView: UITableView,
        contextMenuConfigurationForRowAt indexPath: IndexPath,
        point: CGPoint
    ) -> UIContextMenuConfiguration? {
        let category = viewModel.category(at: indexPath.row)

        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
            let editAction = UIAction(
                title: "Редактировать",
                image: UIImage(systemName: "pencil")
            ) { [weak self] _ in
                self?.showNewCategoryScreen(isEditing: true, category: category)
            }

            let deleteAction = UIAction(
                title: "Удалить",
                image: UIImage(systemName: "trash"),
                attributes: .destructive
            ) { [weak self] _ in
                self?.showDeleteConfirmation(for: category, at: indexPath)
            }

            return UIMenu(title: "", children: [editAction, deleteAction])
        }
    }
}
