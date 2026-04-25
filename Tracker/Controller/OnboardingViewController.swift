import UIKit

// MARK: - Model

private struct OnboardingPage {
    let imageName: String
    let title: String
}

// MARK: - Content VC (один экран)

private final class OnboardingContentViewController: UIViewController {

    private let imageView = UIImageView()
    private let titleLabel = UILabel()

    private let page: OnboardingPage

    init(page: OnboardingPage) {
        self.page = page
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    private func setupUI() {
        view.backgroundColor = .ypWhite

        imageView.image = UIImage(named: page.imageName)
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false

        titleLabel.text = page.title
        titleLabel.font = .systemFont(ofSize: 32, weight: .bold)
        titleLabel.textColor = .ypBlack
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(imageView)
        view.addSubview(titleLabel)

        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: view.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 70),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32)
        ])
    }
}

// MARK: - PageViewController

final class OnboardingViewController: UIPageViewController {

    // MARK: Data

    private let pages: [OnboardingPage] = [
        OnboardingPage(
            imageName: "onboardingBlue",
            title: "Отслеживайте только то, что хотите"
        ),
        OnboardingPage(
            imageName: "onboardingRed",
            title: "Даже если это не литры воды и йога"
        )
    ]

    private lazy var controllers: [UIViewController] = {
        pages.map { OnboardingContentViewController(page: $0) }
    }()

    private var currentIndex = 0

    // MARK: UI

    private let pageControl = UIPageControl()
    private let nextButton = UIButton(type: .system)

    // MARK: Lifecycle

    init() {
        super.init(
            transitionStyle: .scroll,
            navigationOrientation: .horizontal
        )
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        dataSource = self
        delegate = self

        setViewControllers(
            [controllers[0]],
            direction: .forward,
            animated: true
        )

        setupUI()
    }

    // MARK: UI Setup

    private func setupUI() {
        view.backgroundColor = .ypWhite

        pageControl.numberOfPages = controllers.count
        pageControl.currentPage = 0
        pageControl.currentPageIndicatorTintColor = .ypBlack
        pageControl.pageIndicatorTintColor = .ypGray
        pageControl.translatesAutoresizingMaskIntoConstraints = false

        nextButton.setTitle("Вот это технологии!", for: .normal)
        nextButton.titleLabel?.font = AppTextStyles.medium16
        nextButton.setTitleColor(.ypWhite, for: .normal)
        nextButton.backgroundColor = .ypBlack
        nextButton.layer.cornerRadius = 16
        nextButton.translatesAutoresizingMaskIntoConstraints = false
        nextButton.addTarget(self, action: #selector(nextTapped), for: .touchUpInside)

        view.addSubview(pageControl)
        view.addSubview(nextButton)

        NSLayoutConstraint.activate([
            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            pageControl.bottomAnchor.constraint(equalTo: nextButton.topAnchor, constant: -16),

            nextButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            nextButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            nextButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -50),
            nextButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }

    // MARK: Actions

    @objc private func nextTapped() {
        if currentIndex < controllers.count - 1 {
            currentIndex += 1

            setViewControllers(
                [controllers[currentIndex]],
                direction: .forward,
                animated: true
            )

            pageControl.currentPage = currentIndex
        } else {
            UserDefaultsService.shared.hasSeenOnboarding = true

            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                  let window = windowScene.windows.first else { return }

            window.rootViewController = MainTabBarController()
            window.makeKeyAndVisible()
        }
    }
}

// MARK: - PageViewController DataSource

extension OnboardingViewController: UIPageViewControllerDataSource {

    func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerBefore viewController: UIViewController
    ) -> UIViewController? {
        guard let index = controllers.firstIndex(of: viewController),
              index > 0 else { return nil }
        return controllers[index - 1]
    }

    func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerAfter viewController: UIViewController
    ) -> UIViewController? {
        guard let index = controllers.firstIndex(of: viewController),
              index < controllers.count - 1 else { return nil }
        return controllers[index + 1]
    }
}

// MARK: - PageViewController Delegate

extension OnboardingViewController: UIPageViewControllerDelegate {

    func pageViewController(
        _ pageViewController: UIPageViewController,
        didFinishAnimating finished: Bool,
        previousViewControllers: [UIViewController],
        transitionCompleted completed: Bool
    ) {
        guard completed,
              let currentVC = viewControllers?.first,
              let index = controllers.firstIndex(of: currentVC) else { return }

        currentIndex = index
        pageControl.currentPage = index
    }
}
