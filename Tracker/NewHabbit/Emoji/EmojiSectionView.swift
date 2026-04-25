import UIKit

protocol EmojiSectionViewDelegate: AnyObject {
    func didSelectEmoji(_ emoji: String)
}

final class EmojiSectionView: UIView {
    weak var delegate: EmojiSectionViewDelegate?

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Emoji"
        label.font = AppTextStyles.bold19
        label.textColor = UIColor(resource: .ypBlack)
        return label
    }()

    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.layer.cornerRadius = 16
        view.layer.masksToBounds = true
        return view
    }()

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 5
        layout.minimumLineSpacing = 0
        layout.itemSize = CGSize(width: 52, height: 52)

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(EmojiCell.self, forCellWithReuseIdentifier: EmojiCell.identifier)
        collectionView.backgroundColor = .clear
        collectionView.isScrollEnabled = false
        collectionView.dataSource = self
        collectionView.delegate = self
        return collectionView
    }()

    private var selectedEmoji: String?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        addSubview(titleLabel)
        addSubview(containerView)
        containerView.addSubview(collectionView)

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0),

            containerView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            containerView.heightAnchor.constraint(equalToConstant: 200),

            collectionView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            collectionView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 10),
            collectionView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -10),
            collectionView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -16)
        ])
    }

    func getSelectedEmoji() -> String? {
        selectedEmoji
    }

    func setSelectedEmoji(_ emoji: String?) {
        selectedEmoji = emoji
        collectionView.reloadData()
    }
}

// MARK: - UICollectionViewDataSource & UICollectionViewDelegate
extension EmojiSectionView: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        MockData.emojis.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: EmojiCell.identifier,
            for: indexPath
        ) as? EmojiCell else {
            return UICollectionViewCell()
        }

        let emoji = MockData.emojis[indexPath.item]
        let isSelected = selectedEmoji == emoji
        cell.configure(with: emoji, isSelected: isSelected)

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedEmoji = MockData.emojis[indexPath.item]
        self.selectedEmoji = selectedEmoji
        collectionView.reloadData()
        delegate?.didSelectEmoji(selectedEmoji)
    }
}
