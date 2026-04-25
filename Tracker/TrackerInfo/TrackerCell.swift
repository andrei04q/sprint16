import UIKit

final class TrackerCell: UICollectionViewCell {
    static let identifier = "TrackerCell"

    var completionHandler: ((Bool) -> Void)?

    private let coloredContainer = UIView()
    private let bottomContainer = UIView()

    private let emojiLabel = UILabel()
    private let emojiBackgroundView = UIView()
    private let titleLabel = UILabel()
    private let counterLabel = UILabel()
    private let completeButton = UIButton(type: .custom)

    private var tracker: TrackerModel?
    private var isCompleted = false
    private var completionCount = 0

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.layer.cornerRadius = 16
        contentView.layer.masksToBounds = false
    }

    // MARK: - Public

    func configure(
        with tracker: TrackerModel,
        isCompleted: Bool,
        isFutureDate: Bool,
        completionCount: Int
    ) {
        self.tracker = tracker
        self.isCompleted = isCompleted
        self.completionCount = completionCount

        let color = UIColor(named: tracker.color) ?? .systemBlue
        coloredContainer.backgroundColor = color
        completeButton.backgroundColor = color

        emojiLabel.text = tracker.emoji
        titleLabel.text = tracker.title

        let word = daysText(for: completionCount)
        counterLabel.text = "\(completionCount) \(word)"

        updateButtonAppearance()

        completeButton.isEnabled = !isFutureDate
        contentView.alpha = isFutureDate ? 0.5 : 1.0
    }

    // MARK: - Private

    private func setupUI() {
        contentView.backgroundColor = .clear

        coloredContainer.layer.cornerRadius = 16
        coloredContainer.layer.maskedCorners = [
            .layerMinXMinYCorner,
            .layerMaxXMinYCorner,
            .layerMinXMaxYCorner,
            .layerMaxXMaxYCorner
        ]
        coloredContainer.clipsToBounds = true
        coloredContainer.translatesAutoresizingMaskIntoConstraints = false

        bottomContainer.backgroundColor = .white
        bottomContainer.layer.cornerRadius = 0
        bottomContainer.clipsToBounds = true
        bottomContainer.translatesAutoresizingMaskIntoConstraints = false

        emojiLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        emojiLabel.textColor = UIColor(resource: .ypBlack)
        emojiLabel.textAlignment = .center
        emojiLabel.translatesAutoresizingMaskIntoConstraints = false

        emojiBackgroundView.backgroundColor = UIColor.white.withAlphaComponent(0.3)
        emojiBackgroundView.layer.cornerRadius = 12
        emojiBackgroundView.clipsToBounds = true
        emojiBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        emojiBackgroundView.addSubview(emojiLabel)

        NSLayoutConstraint.activate([
            emojiBackgroundView.widthAnchor.constraint(equalToConstant: 24),
            emojiBackgroundView.heightAnchor.constraint(equalToConstant: 24),
            emojiLabel.centerXAnchor.constraint(equalTo: emojiBackgroundView.centerXAnchor),
            emojiLabel.centerYAnchor.constraint(equalTo: emojiBackgroundView.centerYAnchor)
        ])

        titleLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        titleLabel.textColor = .white
        titleLabel.numberOfLines = 2
        titleLabel.lineBreakMode = .byWordWrapping
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        counterLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        counterLabel.textColor = UIColor(resource: .ypBlack)
        counterLabel.textAlignment = .left
        counterLabel.translatesAutoresizingMaskIntoConstraints = false

        completeButton.layer.cornerRadius = 17
        completeButton.layer.borderWidth = 0
        completeButton.tintColor = UIColor(resource: .ypWhite)
        completeButton.translatesAutoresizingMaskIntoConstraints = false
        completeButton.addTarget(self, action: #selector(didTapComplete), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            completeButton.widthAnchor.constraint(equalToConstant: 34),
            completeButton.heightAnchor.constraint(equalToConstant: 34)
        ])
        
        let symbolConfig = UIImage.SymbolConfiguration(pointSize: 11, weight: .medium)
        let plusImage = UIImage(systemName: "plus", withConfiguration: symbolConfig)
        let checkmarkImage = UIImage(systemName: "checkmark", withConfiguration: symbolConfig)
        
        completeButton.setImage(plusImage, for: .normal)
        completeButton.setImage(checkmarkImage, for: .selected)

        let coloredStack = UIStackView(arrangedSubviews: [emojiBackgroundView, titleLabel])
        coloredStack.axis = .vertical
        coloredStack.spacing = 8
        coloredStack.alignment = .leading
        coloredStack.layoutMargins = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        coloredStack.isLayoutMarginsRelativeArrangement = true
        coloredStack.translatesAutoresizingMaskIntoConstraints = false

        coloredContainer.addSubview(coloredStack)

        let bottomStack = UIStackView(arrangedSubviews: [counterLabel, completeButton])
        bottomStack.axis = .horizontal
        bottomStack.alignment = .center
        bottomStack.distribution = .fill
        bottomStack.spacing = 8
        bottomStack.layoutMargins = UIEdgeInsets(top: 16, left: 12, bottom: 12, right: 12)
        bottomStack.isLayoutMarginsRelativeArrangement = true
        bottomStack.translatesAutoresizingMaskIntoConstraints = false

        bottomContainer.addSubview(bottomStack)

        contentView.addSubview(coloredContainer)
        contentView.addSubview(bottomContainer)

        NSLayoutConstraint.activate([
            coloredContainer.topAnchor.constraint(equalTo: contentView.topAnchor),
            coloredContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            coloredContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            coloredContainer.heightAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 0.59),
            
            bottomContainer.topAnchor.constraint(equalTo: coloredContainer.bottomAnchor),
            bottomContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            bottomContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            bottomContainer.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            coloredStack.topAnchor.constraint(equalTo: coloredContainer.topAnchor),
            coloredStack.leadingAnchor.constraint(equalTo: coloredContainer.leadingAnchor),
            coloredStack.trailingAnchor.constraint(equalTo: coloredContainer.trailingAnchor),
            coloredStack.bottomAnchor.constraint(equalTo: coloredContainer.bottomAnchor),
            
            bottomStack.topAnchor.constraint(equalTo: bottomContainer.topAnchor),
            bottomStack.leadingAnchor.constraint(equalTo: bottomContainer.leadingAnchor),
            bottomStack.trailingAnchor.constraint(equalTo: bottomContainer.trailingAnchor),
            bottomStack.bottomAnchor.constraint(equalTo: bottomContainer.bottomAnchor)
        ])
    }

    private func updateButtonAppearance() {
        if let colorName = tracker?.color {
            let buttonColor = UIColor(named: colorName) ?? .systemGreen
            
            UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut) {
                self.completeButton.backgroundColor = self.isCompleted
                    ? buttonColor.withAlphaComponent(0.4)
                    : buttonColor
            }
        }
        
        completeButton.isSelected = isCompleted
    }

    private func daysText(for count: Int) -> String {
        let lastTwo = count % 100
        let last = count % 10

        if lastTwo >= 11 && lastTwo <= 14 {
            return "дней"
        }

        switch last {
        case 1:
            return "день"
        case 2, 3, 4:
            return "дня"
        default:
            return "дней"
        }
    }

    @objc
    private func didTapComplete() {
        guard tracker != nil else { return }
        isCompleted.toggle()
        updateButtonAppearance()
        completionHandler?(isCompleted)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        tracker = nil
        isCompleted = false
        completionCount = 0
        completionHandler = nil
        
        coloredContainer.backgroundColor = nil
        completeButton.backgroundColor = nil
        emojiLabel.text = nil
        titleLabel.text = nil
        counterLabel.text = nil
        completeButton.isSelected = false
        completeButton.isEnabled = true
        contentView.alpha = 1.0
    }
}
