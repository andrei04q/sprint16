import SwiftUI
import UIKit

final class TrackerCategoryHeader: UICollectionReusableView {
    static let reuseIdentifier = "CategoryHeader"

    private let titleLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        titleLabel.font = UIFont.systemFont(ofSize: 19, weight: .bold)
        titleLabel.textColor = UIColor(resource: .ypBlack)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        addSubview(titleLabel)
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8)
        ])
    }

    func configure(with title: String) {
        titleLabel.text = title
    }
}

class TrackersViewController: UIViewController {
    // MARK: - Properties
    private let trackerStore = TrackerStore()
    private let categoryStore = TrackerCategoryStore()
    private let recordStore = TrackerRecordStore()
    private var currentDate: Date = .init()

    private let searchManager = SearchManager()
    private let collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
    private let placeholderView: UIView = {
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false

        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 12
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false

        let starImage = UIImageView(image: UIImage(named: "errorStar"))
        starImage.tintColor = UIColor(resource: .ypGray)
        starImage.contentMode = .scaleAspectFit
        starImage.widthAnchor.constraint(equalToConstant: 80).isActive = true
        starImage.heightAnchor.constraint(equalToConstant: 80).isActive = true

        let label = UILabel()
        label.attributedText = AppTextStyles.attributed(
            "Что будем отслеживать?",
            style: AppTextStyles.medium12,
            lineHeight: 12,
            color: UIColor(resource: .ypBlack)
        )
        label.textAlignment = .center
        label.numberOfLines = 1
        label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        label.setContentHuggingPriority(.defaultHigh, for: .horizontal)

        let textSize = label.sizeThatFits(CGSize(width: CGFloat.greatestFiniteMagnitude, height: 20))
        label.widthAnchor.constraint(greaterThanOrEqualToConstant: textSize.width).isActive = true

        stack.addArrangedSubview(starImage)
        stack.addArrangedSubview(label)

        containerView.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            stack.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: 110),
            stack.leadingAnchor.constraint(greaterThanOrEqualTo: containerView.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(lessThanOrEqualTo: containerView.trailingAnchor, constant: -16)
        ])

        return containerView
    }()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        print("✅ TrackersViewController: viewDidLoad")

        trackerStore.delegate = self
        categoryStore.delegate = self
        recordStore.delegate = self
        searchManager.delegate = self

        title = "Трекеры"
        view.backgroundColor = UIColor(resource: .ypWhite)
        navigationItem.largeTitleDisplayMode = .always
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.largeTitleTextAttributes = [
            .font: AppTextStyles.bold34,
            .foregroundColor: UIColor(resource: .ypBlack)
        ]

        if categoryStore.categories.isEmpty {
        }

        setupPlusButton()
        setupDatePicker()
        setupSearchController()
        setupCollectionView()
        updateUI()
    }

    // MARK: - Layout
    private static func createLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { _, _ in

            let itemSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(0.5),
                heightDimension: .absolute(148)
            )
            let item = NSCollectionLayoutItem(layoutSize: itemSize)

            let groupSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .absolute(148)
            )
            let group = NSCollectionLayoutGroup.horizontal(
                layoutSize: groupSize,
                repeatingSubitem: item,
                count: 2
            )
            group.interItemSpacing = .fixed(8)

            let section = NSCollectionLayoutSection(group: group)
            section.interGroupSpacing = 12

            let headerSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .estimated(30)
            )
            let header = NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: headerSize,
                elementKind: UICollectionView.elementKindSectionHeader,
                alignment: .top
            )
            section.boundarySupplementaryItems = [header]

            section.contentInsets = NSDirectionalEdgeInsets(
                top: 4,
                leading: 12,
                bottom: 16,
                trailing: 12
            )

            return section
        }
        return layout
    }

    // MARK: - UI Setup
    private func setupPlusButton() {
        let plusButton = UIButton(type: .system)
        plusButton.setImage(UIImage(named: "plus"), for: .normal)
        plusButton.tintColor = UIColor(resource: .ypBlack)
        plusButton.addTarget(self, action: #selector(didTapAdd), for: .touchUpInside)

        plusButton.translatesAutoresizingMaskIntoConstraints = false
        plusButton.widthAnchor.constraint(equalToConstant: 30).isActive = true
        plusButton.heightAnchor.constraint(equalToConstant: 30).isActive = true

        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: plusButton)
    }

    private func setupDatePicker() {
        let datePicker = UIDatePicker()
        datePicker.preferredDatePickerStyle = .compact
        datePicker.datePickerMode = .date
        datePicker.locale = Locale(identifier: "ru_RU")
        datePicker.addTarget(self, action: #selector(dateChanged), for: .valueChanged)
        datePicker.date = currentDate

        datePicker.translatesAutoresizingMaskIntoConstraints = false
        datePicker.widthAnchor.constraint(equalToConstant: 100).isActive = true
        datePicker.heightAnchor.constraint(equalToConstant: 40).isActive = true

        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: datePicker)
    }

    private func setupSearchController() {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.delegate = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.automaticallyShowsCancelButton = false
        searchController.searchBar.placeholder = "Поиск"
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }

    private func setupCollectionView() {
        collectionView.backgroundColor = UIColor(resource: .ypWhite)
        collectionView.register(TrackerCell.self, forCellWithReuseIdentifier: TrackerCell.identifier)
        collectionView.register(
            TrackerCategoryHeader.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: TrackerCategoryHeader.reuseIdentifier
        )
        collectionView.dataSource = self
        collectionView.delegate = self

        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.contentInsetAdjustmentBehavior = .scrollableAxes

        view.addSubview(collectionView)
        view.addSubview(placeholderView)

        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            placeholderView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            placeholderView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            placeholderView.widthAnchor.constraint(lessThanOrEqualToConstant: 200),
            placeholderView.heightAnchor.constraint(lessThanOrEqualToConstant: 200)
        ])
    }

    // MARK: - Actions
    @objc private func dateChanged(_ sender: UIDatePicker) {
        currentDate = sender.date
        updateUI()
    }

    @objc private func didTapAdd() {
        let newHabitVC = NewHabitViewController()
        
        newHabitVC.onSave = { [weak self] tracker in
            guard let categoryName = newHabitVC.currentSelectedCategory else {
                print("❌ Категория не выбрана")
                return
            }
            self?.addTracker(tracker, to: categoryName)
        }

        let navController = UINavigationController(rootViewController: newHabitVC)
        navController.modalPresentationStyle = .pageSheet
        present(navController, animated: true)
    }

    // MARK: - Helpers
    private func updateUI() {
        let categories = trackerStore.fetchTrackers(for: currentDate)

        searchManager.updateCategories(categories)

        let currentCategories = searchManager.getCurrentCategories()
        let hasVisibleCategories = !currentCategories.isEmpty

        collectionView.isHidden = !hasVisibleCategories
        placeholderView.isHidden = hasVisibleCategories

        collectionView.reloadData()
    }

    // MARK: - Data Methods
    func addTracker(_ tracker: TrackerModel, to categoryTitle: String) {
        do {
            let categoryId = try categoryStore.createCategoryIfNeeded(with: categoryTitle)
            try trackerStore.addTracker(tracker, to: categoryId)

            updateUI()
        } catch {
            print("❌ Failed to add tracker: \(error)")
        }
    }

    func completeTracker(_ trackerId: UUID, date: Date) {
        do {
            try recordStore.addRecord(trackerId: trackerId, date: date)
        } catch TrackerRecordStore.StoreError.duplicateRecord {
            print("Record already exists for this date")
        } catch {
            print("❌ Failed to complete tracker: \(error)")
        }
    }

    func uncompleteTracker(trackerId: UUID, date: Date) {
        do {
            try recordStore.deleteRecord(trackerId: trackerId, date: date)
        } catch {
            print("❌ Failed to uncomplete tracker: \(error)")
        }
    }

    private func isFutureDate(_ date: Date) -> Bool {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let selectedDay = calendar.startOfDay(for: date)
        return selectedDay > today
    }
}

// MARK: - Store Delegates
extension TrackersViewController: TrackerStoreDelegate {
    func didUpdateTrackers() {
        updateUI()
    }
}

extension TrackersViewController: TrackerCategoryStoreDelegate {
    func didUpdateCategories() {
        updateUI()
    }
}

extension TrackersViewController: TrackerRecordStoreDelegate {
    func didUpdateRecords() {
        collectionView.reloadData()
    }
}

// MARK: - SearchManagerDelegate
extension TrackersViewController: SearchManagerDelegate {
    func didUpdateSearchResults(_ filteredCategories: [TrackerCategoryModel]) {
        collectionView.reloadData()

        let hasVisibleCategories = !filteredCategories.isEmpty
        collectionView.isHidden = !hasVisibleCategories
        placeholderView.isHidden = hasVisibleCategories
    }
}

// MARK: - UISearchResultsUpdating
extension TrackersViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let searchText = searchController.searchBar.text ?? ""
        searchManager.filterCategories(searchText: searchText)
    }
}

// MARK: - UISearchControllerDelegate
extension TrackersViewController: UISearchControllerDelegate {
    func willDismissSearchController(_ searchController: UISearchController) {
        searchManager.resetSearch()
    }

    func didDismissSearchController(_ searchController: UISearchController) {
        updateUI()
    }
}

// MARK: - UICollectionViewDataSource
extension TrackersViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return searchManager.getCurrentCategories().count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        let categories = searchManager.getCurrentCategories()
        guard section < categories.count else { return 0 }

        let category = categories[section]
        return category.trackers.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: TrackerCell.identifier,
            for: indexPath
        ) as? TrackerCell else {
            return UICollectionViewCell()
        }

        let categories = searchManager.getCurrentCategories()
        guard indexPath.section < categories.count else {
            return cell
        }

        let category = categories[indexPath.section]

        guard indexPath.item < category.trackers.count else {
            return cell
        }

        let tracker = category.trackers[indexPath.item]

        let isCompletedForSelectedDate = recordStore.isCompletedToday(
            trackerId: tracker.id,
            date: currentDate
        )

        let totalCompletions = recordStore.completedCount(for: tracker.id)
        let isFuture = isFutureDate(currentDate)

        cell.configure(
            with: tracker,
            isCompleted: isCompletedForSelectedDate,
            isFutureDate: isFuture,
            completionCount: totalCompletions
        )

        if !isFuture {
            cell.completionHandler = { [weak self] isCompletedNew in
                guard let self = self else { return }

                if isCompletedNew {
                    self.completeTracker(tracker.id, date: self.currentDate)
                } else {
                    self.uncompleteTracker(
                        trackerId: tracker.id,
                        date: self.currentDate
                    )
                }
            }
        } else {
            cell.completionHandler = nil
        }

        return cell
    }

    func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath
    ) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader else {
            return UICollectionReusableView()
        }

        guard let header = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: TrackerCategoryHeader.reuseIdentifier,
            for: indexPath
        ) as? TrackerCategoryHeader else {
            return UICollectionReusableView()
        }

        let categories = searchManager.getCurrentCategories()
        guard indexPath.section < categories.count else {
            header.configure(with: "")
            return header
        }

        header.configure(with: categories[indexPath.section].title)
        return header
    }
}

// MARK: - UICollectionViewDelegate
extension TrackersViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return false
    }
}
