import UIKit

final class NewHabitViewController: UIViewController {
    // MARK: - Lazy Properties

    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = true
        scrollView.keyboardDismissMode = .onDrag
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()

    private lazy var contentView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var titleSectionView: TitleSectionView = {
        let view = TitleSectionView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var tabContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var emojiSectionView: EmojiSectionView = {
        let view = EmojiSectionView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var colorSectionView: ColorSectionView = {
        let view = ColorSectionView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var actionButtonsView: ActionButtonsView = {
        let view = ActionButtonsView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    // MARK: - Other Properties

    private var selectedCategory: String?
    private var categoryTitleLabel: UILabel?
    private var scheduleTitleLabel: UILabel?
    private var selectedSchedule: Set<WeekDay> = []

    var onSave: ((TrackerModel) -> Void)?

    // MARK: - Public Properties
    var currentSelectedCategory: String? {
        return selectedCategory
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        configureNavigationBar()
        setupDelegates()
        setDefaultSelections()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let bottomInset = actionButtonsView.frame.height +
            UIConstants.actionButtonsBottomPadding
        scrollView.contentInset
            .bottom = bottomInset
    }

    // MARK: - Setup Methods

    private func setupUI() {
        view.backgroundColor = UIColor(resource: .ypWhite)

        setupActionButtons()
        setupScrollView()
        setupContentView()
        setupTitleSection()
        setupTabContainer()
        setupEmojiSection()
        setupColorSection()
    }

    private func configureNavigationBar() {
        navigationController?.navigationBar.titleTextAttributes = [
            .font: AppTextStyles.medium16,
            .foregroundColor: UIColor(resource: .ypBlack)
        ]
        title = "Новая привычка"

        let navigationBarAppearance = UINavigationBarAppearance()
        navigationBarAppearance.configureWithOpaqueBackground()
        navigationBarAppearance.backgroundColor = UIColor(resource: .ypWhite)
        navigationBarAppearance.titlePositionAdjustment = UIOffset(horizontal: 0, vertical: 12)

        navigationController?.navigationBar.standardAppearance = navigationBarAppearance
    }

    private func setupDelegates() {
        titleSectionView.delegate = self
        emojiSectionView.delegate = self
        colorSectionView.delegate = self
        actionButtonsView.delegate = self
    }

    private func setDefaultSelections() {
        updateCategoryButtonTitle()
        updateCreateButtonState()
        updateScheduleButtonTitle()

        emojiSectionView.setSelectedEmoji("📱")
        colorSectionView.setSelectedColor(MockData.colors.first)
    }

    // MARK: - Setup Components

    private func setupScrollView() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = true
        scrollView.keyboardDismissMode = .onDrag

        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: actionButtonsView.topAnchor, constant: -8)
        ])
    }

    private func setupContentView() {
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.backgroundColor = .clear

        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),

            contentView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor)
        ])
    }

    private func setupTitleSection() {
        titleSectionView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(titleSectionView)

        NSLayoutConstraint.activate([
            titleSectionView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 24),
            titleSectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            titleSectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20)
        ])
    }

    private func setupTabContainer() {
        tabContainerView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(tabContainerView)

        NSLayoutConstraint.activate([
            tabContainerView.topAnchor.constraint(equalTo: titleSectionView.bottomAnchor, constant: 8),
            tabContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            tabContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            tabContainerView.heightAnchor.constraint(equalToConstant: 150)
        ])

        setupTabContainerContent()
    }

    private func setupEmojiSection() {
        emojiSectionView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(emojiSectionView)

        NSLayoutConstraint.activate([
            emojiSectionView.topAnchor.constraint(equalTo: tabContainerView.bottomAnchor, constant: 8),
            emojiSectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            emojiSectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            emojiSectionView.heightAnchor.constraint(equalToConstant: 220)
        ])
    }

    private func setupColorSection() {
        colorSectionView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(colorSectionView)

        NSLayoutConstraint.activate([
            colorSectionView.topAnchor.constraint(equalTo: emojiSectionView.bottomAnchor, constant: 8),
            colorSectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            colorSectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            colorSectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
            colorSectionView.heightAnchor.constraint(equalToConstant: 180)
        ])
    }

    private func setupActionButtons() {
        actionButtonsView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(actionButtonsView)

        NSLayoutConstraint.activate([
            actionButtonsView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            actionButtonsView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            actionButtonsView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            actionButtonsView.heightAnchor.constraint(equalToConstant: 60)
        ])
    }

    // MARK: - Helper Methods

    private func updateCreateButtonState() {
        let title = titleSectionView.getTitle()
        let hasValidTitle = title != nil && !title!.isEmpty

        let isValid = hasValidTitle &&
            !selectedSchedule.isEmpty &&
            selectedCategory != nil && !selectedCategory!.isEmpty &&
            emojiSectionView.getSelectedEmoji() != nil &&
            colorSectionView.getSelectedColor() != nil

        actionButtonsView.setCreateButtonEnabled(isValid)
    }

    private func updateScheduleButtonTitle() {
        guard let titleLabel = scheduleTitleLabel else { return }

        let scheduleText = getScheduleText()
        let fullText = scheduleText == "Расписание" || scheduleText.isEmpty ? "Расписание" : "Расписание\n\(scheduleText)"

        let attributedText = NSAttributedStringBuilder.buildScheduleText(
            fullText: fullText,
            primaryFont: AppTextStyles.regular17,
            primaryColor: UIColor(resource: .ypBlack),
            secondaryFont: AppTextStyles.regular17,
            secondaryColor: UIColor(resource: .ypGray)
        )

        titleLabel.attributedText = attributedText
        titleLabel.numberOfLines = 2
    }

    private func updateCategoryButtonTitle() {
        guard let titleLabel = categoryTitleLabel else { return }

        let fullText = selectedCategory == nil || selectedCategory?
            .isEmpty == true ? "Категория" : "Категория\n\(selectedCategory!)"

        let attributedText = NSAttributedStringBuilder.buildScheduleText(
            fullText: fullText,
            primaryFont: AppTextStyles.regular17,
            primaryColor: UIColor(resource: .ypBlack),
            secondaryFont: AppTextStyles.regular17,
            secondaryColor: UIColor(resource: .ypGray)
        )

        titleLabel.attributedText = attributedText
        titleLabel.numberOfLines = 2
    }

    private func getScheduleText() -> String {
        if selectedSchedule.count == WeekDay.allCases.count {
            return "Каждый день"
        } else if selectedSchedule.isEmpty {
            return "Расписание"
        } else {
            let order: [WeekDay] = [.monday, .tuesday, .wednesday, .thursday, .friday, .saturday, .sunday]
            let sortedDays = order.compactMap { day in
                selectedSchedule.contains(day) ? day : nil
            }
            return sortedDays.map { $0.shortTitle }.joined(separator: ", ")
        }
    }
}

// MARK: - Tab Container Setup

extension NewHabitViewController {
    private func setupTabContainerContent() {
        let containerBackground = UIView()
        containerBackground.backgroundColor = UIColor(resource: .ypBackground)
        containerBackground.layer.cornerRadius = 16
        containerBackground.layer.masksToBounds = true
        containerBackground.translatesAutoresizingMaskIntoConstraints = false

        let buttonStack = UIStackView()
        buttonStack.axis = .vertical
        buttonStack.spacing = 0
        buttonStack.distribution = .fillEqually
        buttonStack.translatesAutoresizingMaskIntoConstraints = false

        let categoryContainer = createCategoryContainer()
        let scheduleContainer = createScheduleContainer()

        let divider = UIView()
        divider.backgroundColor = UIColor(named: "ypBlack")?.withAlphaComponent(0.3)
        divider.translatesAutoresizingMaskIntoConstraints = false

        buttonStack.addArrangedSubview(categoryContainer)
        buttonStack.addArrangedSubview(scheduleContainer)
        buttonStack.setCustomSpacing(0.5, after: categoryContainer)

        containerBackground.addSubview(buttonStack)
        containerBackground.addSubview(divider)
        tabContainerView.addSubview(containerBackground)

        NSLayoutConstraint.activate([
            divider.leadingAnchor.constraint(equalTo: containerBackground.leadingAnchor, constant: 20),
            divider.trailingAnchor.constraint(equalTo: containerBackground.trailingAnchor, constant: -20),
            divider.centerYAnchor.constraint(equalTo: containerBackground.centerYAnchor),
            divider.heightAnchor.constraint(equalToConstant: 0.5),

            buttonStack.topAnchor.constraint(equalTo: containerBackground.topAnchor),
            buttonStack.leadingAnchor.constraint(equalTo: containerBackground.leadingAnchor),
            buttonStack.trailingAnchor.constraint(equalTo: containerBackground.trailingAnchor),
            buttonStack.bottomAnchor.constraint(equalTo: containerBackground.bottomAnchor),

            containerBackground.topAnchor.constraint(equalTo: tabContainerView.topAnchor),
            containerBackground.leadingAnchor.constraint(equalTo: tabContainerView.leadingAnchor),
            containerBackground.trailingAnchor.constraint(equalTo: tabContainerView.trailingAnchor),
            containerBackground.bottomAnchor.constraint(equalTo: tabContainerView.bottomAnchor)
        ])

        NSLayoutConstraint.activate([
            categoryContainer.heightAnchor.constraint(equalToConstant: 75),
            scheduleContainer.heightAnchor.constraint(equalToConstant: 75)
        ])
    }

    private func createCategoryContainer() -> UIView {
        let container = UIView()
        container.backgroundColor = .clear
        container.translatesAutoresizingMaskIntoConstraints = false
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapCategory))
        container.addGestureRecognizer(tapGesture)
        container.isUserInteractionEnabled = true

        let label = UILabel()
        label.numberOfLines = 2
        label.lineBreakMode = .byWordWrapping
        label.text = "Категория"
        categoryTitleLabel = label

        let arrow = UIImageView(image: UIImage(systemName: "chevron.right")?.withRenderingMode(.alwaysTemplate))
        arrow.tintColor = UIColor(resource: .ypGray)
        arrow.contentMode = .scaleAspectFit

        let stack = UIStackView(arrangedSubviews: [label, arrow])
        stack.axis = .horizontal
        stack.spacing = 8
        stack.alignment = .center
        stack.distribution = .fill
        stack.translatesAutoresizingMaskIntoConstraints = false

        container.addSubview(stack)

        label.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        label.setContentHuggingPriority(.defaultLow, for: .horizontal)
        arrow.setContentCompressionResistancePriority(.required, for: .horizontal)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: container.topAnchor, constant: 16),
            stack.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -20),
            stack.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -16),
            arrow.widthAnchor.constraint(equalToConstant: 16),
            arrow.heightAnchor.constraint(equalToConstant: 16)
        ])

        return container
    }

    private func createScheduleContainer() -> UIView {
        let container = UIView()
        container.backgroundColor = .clear
        container.translatesAutoresizingMaskIntoConstraints = false
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapSchedule))
        container.addGestureRecognizer(tapGesture)
        container.isUserInteractionEnabled = true

        let label = UILabel()
        label.numberOfLines = 2
        label.lineBreakMode = .byWordWrapping
        label.text = "Расписание"
        scheduleTitleLabel = label

        let arrow = UIImageView(image: UIImage(systemName: "chevron.right")?.withRenderingMode(.alwaysTemplate))
        arrow.tintColor = UIColor(resource: .ypGray)
        arrow.contentMode = .scaleAspectFit

        let stack = UIStackView(arrangedSubviews: [label, arrow])
        stack.axis = .horizontal
        stack.spacing = 8
        stack.alignment = .center
        stack.distribution = .fill
        stack.translatesAutoresizingMaskIntoConstraints = false

        container.addSubview(stack)

        label.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        label.setContentHuggingPriority(.defaultLow, for: .horizontal)
        arrow.setContentCompressionResistancePriority(.required, for: .horizontal)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: container.topAnchor, constant: 16),
            stack.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -20),
            stack.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -16),
            arrow.widthAnchor.constraint(equalToConstant: 16),
            arrow.heightAnchor.constraint(equalToConstant: 16)
        ])

        return container
    }
}

// MARK: - Actions

extension NewHabitViewController {
    @objc private func didTapCategory() {
        let categoryViewModel = CategoryViewModel(selectedCategory: selectedCategory)
        let categoryListVC = CategoryListViewController(viewModel: categoryViewModel)
        categoryListVC.delegate = self

        navigationController?.pushViewController(categoryListVC, animated: true)
    }

    @objc private func didTapSchedule() {
        print("✅ Schedule button tapped!")
        let scheduleVC = ScheduleViewController()
        scheduleVC.selectedDays = Array(selectedSchedule)
        scheduleVC.onSave = { [weak self] days in
            guard let self = self else { return }
            self.selectedSchedule = Set(days)
            self.updateScheduleButtonTitle()
            self.updateCreateButtonState()
        }
        navigationController?.pushViewController(scheduleVC, animated: true)
    }

    private func createTracker() {
        guard let title = titleSectionView.getTitle(),
              !selectedSchedule.isEmpty,
              let selectedCategory = selectedCategory,
              let emoji = emojiSectionView.getSelectedEmoji(),
              let color = colorSectionView.getSelectedColor() else { return }

        let colorName = MockData.getColorName(for: color) ?? "ColorSelection1"

        let tracker = TrackerModel(
            id: UUID(),
            title: title,
            color: colorName,
            emoji: emoji,
            schedule: Array(selectedSchedule)
        )

        onSave?(tracker)
        dismiss(animated: true)
    }
}

// MARK: - TitleSectionViewDelegate

extension NewHabitViewController: TitleSectionViewDelegate {
    func titleDidChange(_ text: String) {
        updateCreateButtonState()
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)

        updateCreateButtonState()
        return updatedText.count <= UIConstants.maxTitleLength
    }
}

// MARK: - EmojiSectionViewDelegate & ColorSectionViewDelegate

extension NewHabitViewController: EmojiSectionViewDelegate, ColorSectionViewDelegate {
    func didSelectEmoji(_ emoji: String) {
        print("Selected emoji: \(emoji)")
        updateCreateButtonState()
    }

    func didSelectColor(_ color: UIColor) {
        print("Selected color: \(color)")
        updateCreateButtonState()
    }
}

// MARK: - ActionButtonsViewDelegate

extension NewHabitViewController: ActionButtonsViewDelegate {
    func didTapCancelButton() {
        dismiss(animated: true)
    }

    func didTapCreateButton() {
        createTracker()
    }
}

// MARK: - CategoryListViewControllerDelegate
extension NewHabitViewController: CategoryListViewControllerDelegate {
    func categoryListViewController(_ viewController: CategoryListViewController, didSelectCategory category: String?) {
        selectedCategory = category
        updateCategoryButtonTitle()
        updateCreateButtonState()
    }
}
